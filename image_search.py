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


def search_wikimedia(query: str, limit: int = 1) -> list[str]:
    """Search Wikimedia Commons for images.
    Returns list of direct image URLs."""
    try:
        params = urlparse.urlencode({
            "action": "query",
            "generator": "search",
            "gsrnamespace": "6",  # File namespace
            "gsrsearch": query,
            "gsrlimit": min(limit * 3, 10),  # fetch more to filter
            "prop": "imageinfo",
            "iiprop": "url|mime|size",
            "iiurlwidth": "800",
            "format": "json",
            "origin": "*",
        })
        url = f"https://commons.wikimedia.org/w/api.php?{params}"
        req = urlreq.Request(url, headers={"User-Agent": "QuizAIPro/1.0 (educational)"})
        with urlreq.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode("utf-8"))

        pages = data.get("query", {}).get("pages", {})
        urls = []
        for page in pages.values():
            info = page.get("imageinfo", [{}])[0]
            mime = info.get("mime", "")
            url_val = info.get("thumburl") or info.get("url", "")
            # Only images, skip SVG for better compatibility
            if url_val and mime.startswith("image/") and mime != "image/svg+xml":
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


def find_image(query: str) -> str | None:
    """Find one image for a query.
    Tries Pexels first (if key available), then Wikimedia Commons."""
    # Try Pexels first (better quality for general topics)
    if os.environ.get("PEXELS_API_KEY"):
        urls = search_pexels(query, limit=1)
        if urls:
            return urls[0]
    # Fallback to Wikimedia (great for educational content)
    urls = search_wikimedia(query, limit=1)
    return urls[0] if urls else None


def find_images_batch(queries: list[str]) -> dict[str, str | None]:
    """Find images for multiple queries. Returns {query: url_or_None}."""
    results = {}
    for q in queries:
        results[q] = find_image(q)
    return results
