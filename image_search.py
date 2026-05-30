# -*- coding: utf-8 -*-
"""Image search for AI-generated flashcards with photos.

Uses Wikimedia Commons API — free, no API key, huge educational image base.
Fallback: Pexels API (if PEXELS_API_KEY env var is set).
"""
import os
import json
from urllib import request as urlreq
from urllib import parse as urlparse
from urllib import error as urlerr


# Keywords that indicate a bad/irrelevant image (construction diagrams, etc.)
_BAD_TITLE_WORDS = [
    "construction", "diagram", "scheme", "template", "blank", "outline",
    "locator", "location", "map", "svg construction", "geometric",
    "чертёж", "схема", "шаблон", "контур", "построение",
]


def _is_bad_title(title: str) -> bool:
    t = title.lower()
    return any(w in t for w in _BAD_TITLE_WORDS)


def search_wikimedia(query: str, limit: int = 1) -> list[str]:
    """Search Wikimedia Commons for images.
    Returns list of direct image URLs (PNG/JPG preferred, SVG allowed for flags)."""
    try:
        params = urlparse.urlencode({
            "action": "query",
            "generator": "search",
            "gsrnamespace": "6",  # File namespace
            "gsrsearch": query,
            "gsrlimit": 15,  # fetch more to filter bad results
            "prop": "imageinfo",
            "iiprop": "url|mime|size|canonicaltitle",
            "iiurlwidth": "600",
            "format": "json",
            "origin": "*",
        })
        url = f"https://commons.wikimedia.org/w/api.php?{params}"
        req = urlreq.Request(url, headers={"User-Agent": "QuizAIPro/1.0 (educational)"})
        with urlreq.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))

        pages = data.get("query", {}).get("pages", {})
        urls = []
        for page in sorted(pages.values(), key=lambda p: p.get("index", 999)):
            info = page.get("imageinfo", [{}])[0]
            mime = info.get("mime", "")
            title = page.get("title", "")
            url_val = info.get("thumburl") or info.get("url", "")
            # Skip non-images
            if not url_val or not mime.startswith("image/"):
                continue
            # Skip bad titles (construction diagrams, blank templates, etc.)
            if _is_bad_title(title):
                continue
            # For SVG: only allow if it's a flag/coat/emblem (educational icons)
            if mime == "image/svg+xml":
                tl = title.lower()
                if not any(w in tl for w in ["flag", "флаг", "coat", "герб", "emblem", "logo", "symbol"]):
                    continue
            urls.append(url_val)
            if len(urls) >= limit:
                break
        return urls
    except Exception as e:
        print(f"[image_search] wikimedia error for '{query}': {e}")
        return []


def search_pexels(query: str, limit: int = 1) -> list[str]:
    """Search Pexels for images (requires PEXELS_API_KEY env var)."""
    api_key = os.environ.get("PEXELS_API_KEY", "").strip()
    if not api_key:
        return []
    try:
        params = urlparse.urlencode({"query": query, "per_page": limit, "size": "medium"})
        url = f"https://api.pexels.com/v1/search?{params}"
        req = urlreq.Request(url, headers={"Authorization": api_key})
        with urlreq.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))
        photos = data.get("photos", [])
        return [p["src"]["medium"] for p in photos if p.get("src")]
    except Exception as e:
        print(f"[image_search] pexels error for '{query}': {e}")
        return []


# Topic-specific search query builders
_FLAG_KEYWORDS = ["флаг", "flag", "bayroq", "знамя"]
_ANATOMY_KEYWORDS = ["анатомия", "anatomy", "anatomiya", "орган", "organ", "мышца", "muscle"]
_ANIMAL_KEYWORDS = ["животн", "animal", "hayvon", "птиц", "bird", "рыб", "fish"]
_LANDMARK_KEYWORDS = ["достопримечательност", "landmark", "monument", "diqqatga", "храм", "temple", "башн", "tower"]
_PERSON_KEYWORDS = ["личност", "person", "figure", "шахс", "портрет", "portrait"]


def _build_search_query(card_front: str, topic_hint: str = "") -> str:
    """Build an optimized Wikimedia search query based on topic type."""
    combined = (topic_hint + " " + card_front).lower()

    # For flags: search directly for "Flag of <country>"
    if any(k in combined for k in _FLAG_KEYWORDS):
        # Extract country name from question text
        # e.g. "На флаге какой страны..." → just search "flag <front text keywords>"
        # Better: use the answer (back) but we only have front here
        # Use "flag" prefix for Wikimedia which has "Flag of X.svg" files
        return f"flag {card_front}"

    # For anatomy: add "anatomy" to get diagrams
    if any(k in combined for k in _ANATOMY_KEYWORDS):
        return f"anatomy {card_front}"

    # For animals: direct name search works well
    if any(k in combined for k in _ANIMAL_KEYWORDS):
        return card_front

    # For landmarks: add "photo" to avoid maps
    if any(k in combined for k in _LANDMARK_KEYWORDS):
        return f"{card_front} photo"

    # For historical persons: add "portrait"
    if any(k in combined for k in _PERSON_KEYWORDS):
        return f"{card_front} portrait"

    return card_front


def find_image(query: str, topic_hint: str = "") -> str | None:
    """Find one image for a query.
    Tries Pexels first (if key available), then Wikimedia Commons."""
    search_q = _build_search_query(query, topic_hint)

    # Try Pexels first (better quality for general topics)
    if os.environ.get("PEXELS_API_KEY"):
        urls = search_pexels(search_q, limit=1)
        if urls:
            return urls[0]
    # Fallback to Wikimedia (great for educational content)
    urls = search_wikimedia(search_q, limit=1)
    # If nothing found with smart query, try raw query
    if not urls and search_q != query:
        urls = search_wikimedia(query, limit=1)
    return urls[0] if urls else None


def find_images_batch(queries: list[str], topic_hint: str = "") -> dict[str, str | None]:
    """Find images for multiple queries. Returns {query: url_or_None}."""
    results = {}
    for q in queries:
        results[q] = find_image(q, topic_hint)
    return results
