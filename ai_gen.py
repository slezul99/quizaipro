# -*- coding: utf-8 -*-
"""AI-generatsia voprosov cherez Gemini (Google AI Studio).
Besplatnyy tier: 1500 zaprosov/sutki.
Klyuch: gemini_key.txt v korne proekta.
"""
import json
import os
import random
import re
import time
from pathlib import Path
from urllib import request as urlreq
from urllib import error as urlerr

BASE = Path(__file__).resolve().parent
KEY_FILE = BASE / "gemini_key.txt"
DEEPSEEK_KEY_FILE = BASE / "deepseek_key.txt"

# Single model across the whole app: gemini-3.5-flash (per product decision —
# mirror Musi AI, no mixed/older models). The *_FALLBACK aliases are kept so the
# retry loops and app.py diagnostics keep working, but they point at the SAME
# 3.5-flash model — a retry, never a downgrade to 2.5/lite.
_GEMINI_MODEL = "gemini-3.5-flash"
_GEMINI_BASE = "https://generativelanguage.googleapis.com/v1beta/models/"

# Prompt set version — bump on any meaningful prompt change. Logged with every
# call (AI-METRIC pv=...) so quality/cost in the logs can be correlated with the
# prompt version, and so eval results are attributable to a specific revision.
PROMPTS_VERSION = "2025-06-22.1"

API_URL = f"{_GEMINI_BASE}{_GEMINI_MODEL}:generateContent"
API_URL_FALLBACK = API_URL
API_URL_VISION_PRIMARY = API_URL
API_URL_VISION_FALLBACK = API_URL
API_URL_STREAM = f"{_GEMINI_BASE}{_GEMINI_MODEL}:streamGenerateContent"

# === DeepSeek API (OpenAI-sovmestimyy endpoint) ===
# DISABLED — the app now uses gemini-3.5-flash for everything, including the AI
# Tutor chat (see is_deepseek_available below). Kept only so existing references
# don't break.
DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions"
DEEPSEEK_MODEL = "deepseek-v4-flash"


def _key():
    # 1. ENV variable (production na Railway)
    env_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if env_key:
        return env_key
    # 2. Lokal'nyy fayl (razrabotka)
    if KEY_FILE.exists():
        return KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


# === Vertex AI (primary) ===================================================
# Billed through the GCP project (musi-ai-caa65) so it uses the Cloud credits,
# unlike the Gemini Developer API key which runs on a separate (empty) prepay
# balance. Same gemini-3.5-flash model and request body; auth is a Bearer token
# from a service account instead of ?key=. The Developer API key stays as a
# fallback when no service account is configured.
SA_FILE = BASE / "sa_key.json"
# Empty → derive the project from the service-account JSON itself, so the
# request always targets the SA's own project (where it has permissions) no
# matter which project's key is configured.
VERTEX_PROJECT = os.environ.get("VERTEX_PROJECT", "").strip()
VERTEX_LOCATION = os.environ.get("VERTEX_LOCATION", "global")  # gemini-3.5 → global
_vertex_creds_cache = None


def _vertex_sa_info():
    raw = os.environ.get("GOOGLE_SERVICE_ACCOUNT_JSON", "").strip()
    if raw:
        try:
            return json.loads(raw)
        except Exception as e:
            print(f"[Vertex] bad GOOGLE_SERVICE_ACCOUNT_JSON: {e}")
            return None
    if SA_FILE.exists():
        try:
            return json.loads(SA_FILE.read_text(encoding="utf-8"))
        except Exception as e:
            print(f"[Vertex] bad sa_key.json: {e}")
            return None
    return None


def _vertex_creds():
    global _vertex_creds_cache
    if _vertex_creds_cache is not None:
        return _vertex_creds_cache
    info = _vertex_sa_info()
    if not info:
        return None
    try:
        from google.oauth2 import service_account
        _vertex_creds_cache = service_account.Credentials.from_service_account_info(
            info, scopes=["https://www.googleapis.com/auth/cloud-platform"])
        return _vertex_creds_cache
    except Exception as e:
        print(f"[Vertex] creds load failed: {e}")
        return None


def vertex_enabled() -> bool:
    return _vertex_creds() is not None


def _vertex_project():
    if VERTEX_PROJECT:
        return VERTEX_PROJECT
    info = _vertex_sa_info()
    if info and info.get("project_id"):
        return info["project_id"]
    return "musi-ai-caa65"


def _vertex_token():
    creds = _vertex_creds()
    if creds is None:
        return None
    try:
        from google.auth.transport.requests import Request as _GReq
        if not creds.valid:
            creds.refresh(_GReq())
        return creds.token
    except Exception as e:
        print(f"[Vertex] token refresh failed: {e}")
        return None


def _vertex_url(model: str, stream: bool = False) -> str:
    loc = VERTEX_LOCATION
    host = "aiplatform.googleapis.com" if loc == "global" else f"{loc}-aiplatform.googleapis.com"
    method = "streamGenerateContent" if stream else "generateContent"
    return (f"https://{host}/v1/projects/{_vertex_project()}/locations/{loc}"
            f"/publishers/google/models/{model}:{method}")


def _deepseek_key():
    """DeepSeek API klyuch. ENV var DEEPSEEK_API_KEY (Railway) ili lokal'nyy fayl."""
    env_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if env_key:
        return env_key
    if DEEPSEEK_KEY_FILE.exists():
        return DEEPSEEK_KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


def is_deepseek_available() -> bool:
    # DeepSeek intentionally disabled — everything runs on gemini-3.5-flash now.
    return False


def is_available() -> bool:
    return vertex_enabled() or bool(_key())


# Controlled-generation schema for flashcard output. With this set, Gemini is
# constrained to emit a clean JSON array of cards, so the brittle regex recovery
# in _parse_cards_json becomes a belt-and-suspenders fallback rather than the
# primary path. Type names are the Gemini Schema enum (uppercase).
_FLASHCARD_LIST_SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "question": {"type": "STRING"},
            "answer": {"type": "STRING"},
            "note": {"type": "STRING"},
        },
        "required": ["question", "answer"],
    },
}

# Same as above plus an English image search query (generate_with_photos).
_FLASHCARD_PHOTO_SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "question": {"type": "STRING"},
            "answer": {"type": "STRING"},
            "note": {"type": "STRING"},
            "image_query": {"type": "STRING"},
        },
        "required": ["question", "answer"],
    },
}

# Grounded generation (text / PDF): every card must cite the exact supporting
# snippet from the source in source_span. Forcing a citation makes the model
# stay faithful to the material (less hallucination) and lets us show learners
# where a card came from.
_FLASHCARD_GROUNDED_SCHEMA = {
    "type": "ARRAY",
    "items": {
        "type": "OBJECT",
        "properties": {
            "question": {"type": "STRING"},
            "answer": {"type": "STRING"},
            "note": {"type": "STRING"},
            "source_span": {"type": "STRING"},
        },
        "required": ["question", "answer", "source_span"],
    },
}


_GROUNDING_RULE = (
    "GROUNDING (strict): use ONLY facts present in the source. For every card, "
    "copy the exact sentence(s) from the source that justify the answer into "
    "\"source_span\". If a fact is not in the source, do NOT create that card."
)

# Pedagogical balance — push the model past flat recall decks.
_BALANCE_RULE = (
    "DIFFICULTY & DEPTH MIX: vary difficulty across the set (~30% easy recall, "
    "~50% medium, ~20% challenging) and cognitive level — don't only test "
    "definitions/recall; include 'apply it', 'compare', and 'why/how' questions."
)


def _log_metric(*, label, model, latency_ms, ok, usage=None, finish=None, error=None):
    """One structured line per Gemini call → greppable in Railway logs
    (`grep AI-METRIC`). Captures model, latency, token usage, finishReason and
    errors so cost/latency/quality can actually be measured per change."""
    parts = [f"label={label}", f"model={model}", f"pv={PROMPTS_VERSION}",
             f"ms={latency_ms}", f"ok={int(bool(ok))}"]
    if usage:
        parts.append(f"in_tok={usage.get('promptTokenCount', '?')}")
        parts.append(f"out_tok={usage.get('candidatesTokenCount', '?')}")
        parts.append(f"tot_tok={usage.get('totalTokenCount', '?')}")
    if finish:
        parts.append(f"finish={finish}")
    if error:
        parts.append(f"err={str(error)[:120]}")
    try:
        print("[AI-METRIC] " + " ".join(parts), flush=True)
    except Exception:
        pass


def _gemini_endpoints():
    """Endpoints to try in order: Vertex AI first (billed via Cloud credits),
    Developer API key as fallback. Each item is (model_label, url, headers)."""
    attempts = []
    if vertex_enabled():
        tok = _vertex_token()
        if tok:
            attempts.append((f"vertex:{_GEMINI_MODEL}", _vertex_url(_GEMINI_MODEL),
                             {"Authorization": f"Bearer {tok}", "Content-Type": "application/json"}))
    key = _key()
    if key:
        attempts.append((f"dev:{_GEMINI_MODEL}", f"{API_URL}?key={key}",
                         {"Content-Type": "application/json"}))
    return attempts


_MAX_RETRIES = 3
_RETRYABLE = {429, 500, 502, 503, 504}


def _backoff_sleep(attempt: int):
    """Exponential backoff with jitter: ~1s, 2s, 4s (capped 8s) + 0–0.6s."""
    time.sleep(min(8.0, 2 ** attempt) + random.uniform(0, 0.6))


def _call_gemini(prompt: str, max_tokens: int = 4000, response_schema: dict | None = None,
                 label: str = "gen") -> str | None:
    gen_config = {
        "temperature": 0.5,
        "maxOutputTokens": max_tokens,
        "responseMimeType": "application/json",
    }
    if response_schema is not None:
        gen_config["responseSchema"] = response_schema
    body = {
        # role is required by Vertex AI; the Developer API ignores it.
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": gen_config,
    }
    data = json.dumps(body).encode("utf-8")

    attempts = _gemini_endpoints()
    if not attempts:
        return None

    # Vertex first, Developer-key fallback. Each endpoint is retried a few times
    # on transient errors (429/5xx/network) with exponential backoff + jitter
    # before moving to the next.
    last_error = None
    for model, url, headers in attempts:
        for attempt in range(_MAX_RETRIES):
            req = urlreq.Request(url, data=data, method="POST", headers=headers)
            t0 = time.time()
            try:
                with urlreq.urlopen(req, timeout=90) as resp:
                    payload = json.loads(resp.read().decode("utf-8"))
                ms = int((time.time() - t0) * 1000)
                usage = payload.get("usageMetadata") or {}
                cand = (payload.get("candidates") or [{}])[0]
                finish = cand.get("finishReason")
                try:
                    text = cand["content"]["parts"][0]["text"]
                except (KeyError, IndexError, TypeError):
                    text = None
                if text and text.strip():
                    _log_metric(label=label, model=model, latency_ms=ms, ok=True,
                                usage=usage, finish=finish)
                    return text
                _log_metric(label=label, model=model, latency_ms=ms, ok=False,
                            usage=usage, finish=finish, error="empty")
                last_error = f"Empty response (finish={finish})"
                print(f"[AI] {last_error[:300]}")
                break  # empty/SAFETY won't fix on retry → next endpoint
            except urlerr.HTTPError as e:
                ms = int((time.time() - t0) * 1000)
                err_body = ""
                try:
                    err_body = e.read().decode("utf-8", errors="replace")[:300]
                except Exception:
                    pass
                last_error = f"HTTP {e.code} ({model}): {err_body}"
                _log_metric(label=label, model=model, latency_ms=ms, ok=False,
                            error=f"HTTP {e.code}: {err_body[:80]}")
                print(f"[AI] {last_error}")
                if e.code in _RETRYABLE and attempt < _MAX_RETRIES - 1:
                    _backoff_sleep(attempt)
                    continue
                break  # non-retryable (403/400) or out of retries → next endpoint
            except Exception as e:
                ms = int((time.time() - t0) * 1000)
                last_error = f"{type(e).__name__}: {e}"
                _log_metric(label=label, model=model, latency_ms=ms, ok=False, error=last_error)
                print(f"[AI] {last_error}")
                if attempt < _MAX_RETRIES - 1:
                    _backoff_sleep(attempt)
                    continue
                break

    if last_error:
        raise RuntimeError(f"Gemini API недоступен: {last_error[:200]}")
    return None


def _parse_cards_json(text: str) -> list[dict]:
    """Razbiraet otvet AI v list[{front, back, note}].
    Podderzhivayet razlichnyye formaty: massiv, {questions:[]}, {cards:[]}, {data:[]}."""
    if not text:
        print("[AI parse] empty input")
        return []
    # Log first 300 chars chtoby videt' chto prikhodit
    print(f"[AI parse] input ({len(text)} chars): {text[:300]}")
    # Snimaem markdown-blocks
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
    data = None
    try:
        data = json.loads(text)
    except Exception as e:
        print(f"[AI parse] full json failed: {e}")
        # Probuyem nayti JSON-array v tekste
        m = re.search(r"\[\s*\{.*?\}\s*\]", text, re.DOTALL)
        if m:
            try:
                data = json.loads(m.group(0))
                print("[AI parse] recovered array from text")
            except Exception:
                pass
        if data is None:
            # Probuyem nayti JSON-objekt
            m2 = re.search(r"\{.*\}", text, re.DOTALL)
            if m2:
                try:
                    data = json.loads(m2.group(0))
                    print("[AI parse] recovered object from text")
                except Exception:
                    pass
    if data is None:
        print("[AI parse] could not parse anything")
        return []

    # Esli prishyol diktiy s polem-massivom — izvlekaem
    if isinstance(data, dict):
        # Probuyem populyarnyye nazvaniya
        for k in ("questions", "cards", "data", "items", "result", "results", "flashcards"):
            if k in data and isinstance(data[k], list):
                data = data[k]
                break
        else:
            # Esli k=keys vse list — beryom pervyy massiv
            for v in data.values():
                if isinstance(v, list) and v and isinstance(v[0], dict):
                    data = v
                    break

    if not isinstance(data, list):
        print(f"[AI parse] not a list, type: {type(data)}")
        return []

    out = []
    for item in data:
        if not isinstance(item, dict):
            continue
        # Mnozhestvennye varianty nazvaniy poley
        q = (
            item.get("question")
            or item.get("front")
            or item.get("q")
            or item.get("term")
            or item.get("Q")
            or ""
        )
        a = (
            item.get("answer")
            or item.get("back")
            or item.get("a")
            or item.get("definition")
            or item.get("A")
            or ""
        )
        n = (
            item.get("note")
            or item.get("explanation")
            or item.get("explain")
            or item.get("context")
            or item.get("hint")
            or ""
        )
        src = item.get("source_span") or item.get("source") or ""
        # Stringify esli prishyol ne string
        q = str(q).strip() if q else ""
        a = str(a).strip() if a else ""
        n = str(n).strip() if n else ""
        if q and a:
            card = {"front": q, "back": a, "note": n}
            if src:
                card["source_span"] = str(src).strip()[:300]
            out.append(card)
    print(f"[AI parse] extracted {len(out)} cards from {len(data) if isinstance(data, list) else 0}")
    return out


def _critique_and_improve(cards: list[dict], lang: str = "ru") -> list[dict]:
    """Quality mode: vtoroy proxod cherez AI-kritika.
    Pervyy AI sgeneriroval vopros, vtoroy proveryaet i ispravlyaet pered podachey polzovatelyu.

    Proveryaet:
      - dvusmyslennost' formulirovki
      - grammaticheskie oshibki
      - sliskom ochevidnyy / sliskom nelogichnyy otvet
      - zadvoeniya s drugimi voprosami
      - nepravil'nyy otvet po sushchestvu

    Esli iz N kart ostalos' < N — ne kriticheski; eto fitcha (filtruyem ploxie).
    """
    if not cards:
        return []

    # Otpravlyaem AI batchom — ekonomim API quota
    cards_json = json.dumps(cards, ensure_ascii=False, indent=2)
    lang_map = {"ru": "русском", "en": "English", "uz": "oʻzbek tilida"}
    lang_name = lang_map.get(lang, "русском")

    prompt = f"""Ty — strogiy AI-redaktor obuchayushchih voprosov.

Tebe dali spisok karta-voprosov sgenerirovannyh drugim AI. Proverь kazhdyy vopros po kriteriyam:

1. **Dvusmyslennost'**: mozhno li ponyat' vopros odnoznachno? Vyderzhivaesh li otvet?
2. **Tochnost' otveta**: pravilen li otvet po sushchestvu? Net li faktologicheskih oshibok?
3. **Yazyk**: vse na yazyke "{lang_name}", net pereputannyh slov, grammatika OK?
4. **Trivial'nost'**: vopros ne sliskom ochevidnyy ("kto napisal Voinu i mir? Tolstoy")?
5. **Dubli**: net li blizkih po smyslu duplikatov sredi voprosov?

Tvoya zadacha: vernut' VSE voprosy s ulushchhennoy formulirovkoy, gde nuzhno — ispravit'.
Esli vopros sovsem ploxoy (faktologicheski neverno, dvusmyslenno, ne mozhno spasti) — propusti ego.

Vyhod TOL'KO JSON:
{{"cards": [{{"question":"...","answer":"...","note":"..."}}, ...], "removed_count": N}}

VHODNYE KARTY:
{cards_json}"""

    raw = _call_gemini(prompt, max_tokens=8000, response_schema=_FLASHCARD_LIST_SCHEMA)
    if not raw:
        return cards  # Fallback: vozvrashchaem kak est' esli kritik upal

    # Razbiraem otvet
    try:
        text = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
        data = json.loads(text)
    except Exception:
        m = re.search(r"\{.*\}", raw, re.DOTALL)
        if not m:
            return cards
        try:
            data = json.loads(m.group(0))
        except Exception:
            return cards

    improved = data.get("cards") if isinstance(data, dict) else None
    if not isinstance(improved, list):
        return cards

    out = []
    for item in improved:
        if not isinstance(item, dict):
            continue
        q = (item.get("question") or item.get("front") or "").strip()
        a = (item.get("answer") or item.get("back") or "").strip()
        n = (item.get("note") or item.get("explanation") or "").strip()
        if q and a:
            out.append({"front": q, "back": a, "note": n})

    # Esli kritik vse otsek — vozvrashchaem ishodnye
    if not out:
        return cards
    return out


def generate_from_text(text: str, count: int = 10, lang: str = "ru",
                       quality: bool = False, output_lang: str = "auto") -> list[dict]:
    """Generiruyet voprosy iz proizvol'nogo teksta."""
    if output_lang in ("", None, "auto", "source"):
        lang_instruction = (
            "Language of questions and answers: EXACTLY THE SAME as the source text language. "
            "If the source is in English — write in English. If in Russian — write in Russian. "
            "Do NOT translate, do NOT mix languages."
        )
    else:
        lang_map = {"ru": "Russian (русский)", "en": "English", "uz": "Uzbek (o'zbek)"}
        lang_name = lang_map.get(output_lang, "Russian")
        lang_instruction = f"Language of questions and answers: {lang_name}. Translate if needed."

    prompt = f"""You are a creative teacher making ENGAGING flashcards from a text.

From the TEXT below, generate exactly {count} flashcards for self-testing.
{lang_instruction}

EMOTIONAL EXAMPLES RULE:
When creating examples or context, use relatable situations:
games, food, phones, social media, friends, music, sports, school life.
NOT: "John goes to work" — YES: "She checks her phone every 5 minutes"

QUESTION FORMATS (mix these):
1. 🎯 Direct fact with relatable context
2. 🔍 Spot the mistake in a real situation
3. 🔄 Apply the concept to everyday life
4. 💡 Why/How does this work?
5. ⚠️ Common misconception: "What's wrong with thinking that...?"
6. 🌍 Real example: "Give an example from daily life"
7. 🔗 Connect two concepts from the text

ANSWER FORMAT:
- Answer directly first, then explain
- Use concrete, relatable examples
- "note" field: memory trick, surprising fact, or ⚠️ common mistake
- Only use information from the text

{_GROUNDING_RULE}

{_BALANCE_RULE}

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"...","source_span":"exact supporting sentence from the text"}}, ...]

TEXT:
{text[:8000]}"""

    raw = _call_gemini(prompt, max_tokens=8000, response_schema=_FLASHCARD_GROUNDED_SCHEMA)
    cards = _fold_sources(_validate_cards(_parse_cards_json(raw or "")))
    if quality and cards:
        cards = _critique_and_improve(cards, lang=output_lang if output_lang not in ("auto", "source") else lang)
    return cards


def generate_from_topic(topic: str, count: int = 10, lang: str = "ru",
                          difficulty: str = "medium",
                          quality: bool = False, output_lang: str = "auto") -> list[dict]:
    """Generiruyet voprosy po teme."""
    if output_lang in ("", None, "auto", "source"):
        lang_instruction = (
            "Language: SAME as the topic language. "
            "If topic is in English — answer in English. If in Russian — in Russian."
        )
    else:
        lang_map = {"ru": "Russian (русский)", "en": "English", "uz": "Uzbek (o'zbek)"}
        lang_name = lang_map.get(output_lang, "Russian")
        lang_instruction = f"Language of questions and answers: {lang_name}."

    diff_map = {
        "easy": "beginners / elementary level",
        "medium": "intermediate level students",
        "hard": "advanced students and professionals",
    }
    diff_name = diff_map.get(difficulty, diff_map["medium"])

    # Detect if topic is about language learning — special prompt for grammar/vocabulary
    lang_topic_keywords = [
        "english", "grammar", "tense", "verb", "noun", "adjective", "adverb",
        "present", "past", "future", "simple", "continuous", "perfect",
        "vocabulary", "words", "phrases", "pronunciation", "spelling",
        "английский", "грамматика", "время", "глагол", "существительное",
        "ingliz", "grammatika", "fe'l", "ot", "sifat",
        "beginner", "начинающий", "boshlang'ich",
    ]
    is_language_topic = any(kw.lower() in topic.lower() for kw in lang_topic_keywords)

    if is_language_topic:
        prompt = f"""You are a creative language teacher making ENGAGING flashcards that students actually enjoy.

Topic: "{topic}"
Level: {diff_name}
Count: exactly {count} flashcards.
{lang_instruction}

EMOTIONAL EXAMPLES RULE (MOST IMPORTANT):
When giving examples, use situations students ACTUALLY CARE ABOUT:
✅ GOOD examples (relatable, emotional, fun):
  - Gaming: "I play Minecraft every day" / "She doesn't like losing in games"
  - Food: "He eats pizza on Fridays" / "We always order sushi on weekends"
  - Phone/Social media: "She checks Instagram every morning" / "I don't use TikTok at school"
  - Friends/Family: "My best friend calls me every night" / "We watch Netflix together"
  - School life: "I hate waking up at 7am" / "She always forgets her homework"
  - Music: "He listens to music while studying" / "They go to concerts every summer"
  - Sports: "I play football with my friends on Saturdays"

❌ BORING examples (avoid these):
  - "John goes to school" — too generic
  - "She reads books" — no emotion
  - "They work in an office" — not relatable for students
  - "I check my email every day" — replace with something fun like "I check my messages every day"

QUESTION FORMATS (mix these):
1. 🎮 Translate with emotional context: "Как перевести: 'Я играю в компьютерные игры каждый день'?"
2. 🔍 Spot the mistake: "Найди ошибку: 'She don't like pizza'"
3. 💬 Real situation: "Твой друг говорит 'I am agree'. Правильно ли это?"
4. ✏️ Fill in: "She ___ (play) Minecraft every evening."
5. 🔄 Transform: "Сделай отрицательным: 'He plays games every day'"
6. 🤔 Choose: "Что правильно: 'everyday tasks' или 'every day tasks'?"
7. 💡 Why: "Почему мы говорим 'goes' а не 'go' для he/she/it?"

ANSWER FORMAT:
- Start with ✓ for correct answer
- Show the rule clearly
- "note" field: memory trick, common mistake warning ⚠️, or fun fact

{_BALANCE_RULE}

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"..."}}, ...]"""

    else:
        prompt = f"""You are a creative teacher making ENGAGING flashcards that students love.

Topic: "{topic}"
Count: exactly {count} flashcards.
Difficulty: {diff_name}.
{lang_instruction}

EMOTIONAL EXAMPLES RULE:
Use real, relatable situations — not dry textbook examples.
Connect concepts to things students care about: games, food, phones, friends, music, sports, school life.

QUESTION FORMATS (mix these):
1. 🎯 Practical scenario: "You need to [do something]. What do you use/do?"
2. 🔍 Spot the error: "What's wrong with this: [wrong example]?"
3. ✅ True/False + explain why
4. 🔄 Compare: "What's the difference between A and B?"
5. 💡 Why/How: "Why does [phenomenon] happen?"
6. 🌍 Real world: "Give a real-life example of [concept]"
7. 🧩 Apply it: "How would you use [concept] in practice?"

ANSWER FORMAT:
- Direct answer first, then explanation
- Use concrete, relatable examples
- "note" field: memory trick, surprising fact, or common mistake ⚠️

{_BALANCE_RULE}

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"..."}}, ...]"""

    raw = _call_gemini(prompt, max_tokens=8000, response_schema=_FLASHCARD_LIST_SCHEMA)
    cards = _validate_cards(_parse_cards_json(raw or ""))
    if quality and cards:
        cards = _critique_and_improve(cards, lang=output_lang if output_lang not in ("auto", "source") else lang)
    return cards


def generate_from_pdf(pdf_path: Path, count: int = 10, lang: str = "ru",
                      quality: bool = False, output_lang: str = "auto") -> list[dict]:
    """Chitaet PDF i generiruet voprosy.
    Esli tekst.layer pustoy (skan) — avtomaticheski perekhodit na Vision."""
    try:
        from pypdf import PdfReader
    except ImportError:
        return []
    reader = PdfReader(str(pdf_path))
    text = "\n".join(p.extract_text() or "" for p in reader.pages[:30])
    # Esli teksta net ili ochen' malo (skan) — probuyem cherez Vision
    if not text.strip() or len(text.strip()) < 100:
        cards = vision_pdf_to_cards(pdf_path, lang=lang)
        if cards:
            return cards[:count] if count else cards
        return []
    return generate_from_text(text, count=count, lang=lang, quality=quality, output_lang=output_lang)


# === VISION: PDF -> kartochki cherez Gemini Vision (dlya skanov i kartinok) ===

def _pdf_to_images(pdf_path: Path, max_pages: int = 30, dpi: int = 200) -> list[bytes]:
    """Renderim stranitsy PDF v PNG-baytah. PyMuPDF — bez sistemnyh zavisimostey.
    DPI=200 dlya luchshego raspoznaniya (vyshe = bolshe API tokens, no luchshe OCR).
    Vozvrashchaem spisok PNG bytes."""
    try:
        import pymupdf  # type: ignore
    except ImportError:
        try:
            import fitz as pymupdf  # type: ignore
        except ImportError:
            print("[AI vision] PyMuPDF not installed (pip install pymupdf)")
            return []
    images = []
    try:
        doc = pymupdf.open(str(pdf_path))
        zoom = dpi / 72.0
        mat = pymupdf.Matrix(zoom, zoom)
        for i, page in enumerate(doc):
            if i >= max_pages:
                break
            pix = page.get_pixmap(matrix=mat, alpha=False)
            images.append(pix.tobytes("png"))
        doc.close()
    except Exception as e:
        print(f"[AI vision] pdf->png err: {type(e).__name__}: {e}")
        return []
    return images


# Promt edinyy dlya vsekh chankov — MAKSIMALNO GIBKY i ZHADNYY
VISION_EXTRACT_PROMPT = """Ты — извлекатель тестовых вопросов из учебных материалов.

КРИТИЧНО: твоя задача — извлечь ВСЁ что хоть отдалённо похоже на закрытый тест.
ПРОПУСТИТЬ ВОПРОС ПЛОХО. Лучше извлечь сомнительный, чем потерять реальный.

🎯 ПОДРОБНЫЙ АЛГОРИТМ:
1. Внимательно осмотри ВСЁ изображение сверху донизу
2. Найди КАЖДЫЙ блок где есть варианты ответов (любая буква/цифра + текст после)
3. Для каждого блока определи вопрос (часто над вариантами или со стороны)
4. ИЗВЛЕКИ. Не фильтруй по сложности, не оценивай качество — просто извлекай ВСЁ

✅ БЕРИ (закрытые тесты — ЛЮБОЙ из этих форматов):
• A) ... B) ... C) ... D) ... — классический MCQ
• 1) ... 2) ... 3) ... 4) ... — нумерованный
• а) ... б) ... в) ... г) ... — кириллица
• ① ② ③ ④ — кружки
• I, II, III, IV — римские
• ☐ или □ или ⚪ перед вариантами — чекбоксы
• Заполни пропуск: "I ___ to school" + варианты — БЕРИ
• Match (соединить) — БЕРИ как 1 карточку с вариантами
• True/False (Верно/Неверно) — БЕРИ
• Yes/No вопросы с вариантами — БЕРИ
• Reading comprehension: текст + 5 вопросов после — извлеки ВСЕ 5 вопросов отдельно
  (можно НЕ повторять контекст в каждом, AI сам поймёт)
• Грамматика, vocabulary, аудирование (если ответ виден) — БЕРИ
• Любой "Choose the correct..." / "Выберите..." / "Tanlang..."

❌ НЕ БЕРИ:
• Открытые: "Write an essay", "Describe", "Explain in your own words"
• Только если ЯВНО нет вариантов
• Заголовки страниц, footer/header, номера страниц
• Логотипы школ, водяные знаки

🔧 ФОРМАТ:
- "number": номер задания если есть ("1", "12", "Q5")
- "question": текст вопроса (если есть контекст-текст — кратко включи в вопрос или пропусти)
- "options": МАССИВ ВСЕХ вариантов как текст ["A) текст", "B) текст", ...]
- "correct_letter": "A"/"B"/"C"/"D" если правильный отмечен (✓, кружок, жирный, "Ответ: B"), иначе null

📌 ВАЖНО:
- Минимум 2 варианта = это уже тест, БЕРИ
- Если на странице явно видишь несколько вопросов → должно быть несколько объектов в массиве
- Орфографию сохраняй как на картинке
- Не пропускай вопросы из-за плохого качества скана — попробуй угадать текст

🎯 ОЖИДАНИЕ: на типичной странице теста 5-15 вопросов. Если ты вернул < 5 — перепроверь, ты точно ничего не пропустил?

⛔ ГРАУНДИНГ (строго): извлекай ТОЛЬКО то, что реально напечатано на странице.
НЕ придумывай вопросы, варианты или правильные ответы, которых нет на изображении.
Если правильный ответ на странице не отмечен — ставь "correct_letter": null.

ВЫХОД — JSON-массив. Если 0 закрытых вопросов на странице → `[]`.
НЕ ОБЪЯСНЯЙ, не пиши комментарии, ТОЛЬКО JSON:

[
  {"number": "1", "question": "...", "options": ["A) ...", "B) ...", "C) ...", "D) ..."], "correct_letter": "A"},
  {"number": "2", "question": "...", "options": [...], "correct_letter": null}
]"""


# Audit prompt — vtoroy proxod chtoby nayti propushchennye voprosy
VISION_AUDIT_PROMPT = """Ты — АУДИТОР извлечения тестовых вопросов.

Другой AI уже извлёк часть вопросов с этой страницы. Твоя задача — НАЙТИ ПРОПУЩЕННЫЕ.

УЖЕ ИЗВЛЕЧЕНЫ ВОПРОСЫ С НОМЕРАМИ: {extracted_numbers}

Внимательно посмотри на изображение и:
1. Найди ВСЕ закрытые вопросы (с вариантами A/B/C/D) на странице
2. Для каждого вопроса проверь — есть ли его номер в списке уже извлечённых?
3. Если НЕТ — извлеки его как новую карточку

Те же правила что для основной экстракции:
- Закрытые вопросы (с вариантами) — ДА
- Открытые (essay, describe) — НЕТ
- Reading comprehension — ДА с контекстом

ВЫХОД — JSON-массив с ПРОПУЩЕННЫМИ вопросами в формате:
[{"number": "...", "question": "...", "options": [...], "correct_letter": "..." or null, "is_open": false}]

Если ничего не пропущено → `[]`. Не возвращай дубликаты тех номеров что уже в списке."""


# Globalnaya peremennaya — sokranyaem POSLEDNUYU HTTP-oshibku ot Gemini
# Chtoby pokazat' polzovatelyu konkretno chto skazal Google (429, 401, 503...)
_last_gemini_error = ""


def _gemini_vision_call(images: list[bytes], timeout: int = 240, prompt: str = None) -> str | None:
    """Otdelnyy zapros k Gemini Vision s nabor kartinok. Vozvrashchaet raw text otveta.
    prompt: kastomnyy promt (po default — VISION_EXTRACT_PROMPT).
    Edinaya model' gemini-3.5-flash; Vertex AI pervym, Developer-key fallback."""
    global _last_gemini_error
    import base64
    parts = [{"text": prompt or VISION_EXTRACT_PROMPT}]
    for png in images:
        parts.append({
            "inline_data": {
                "mime_type": "image/png",
                "data": base64.b64encode(png).decode("ascii"),
            }
        })
    body = {
        "contents": [{"role": "user", "parts": parts}],  # role required by Vertex
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 16000,
            "responseMimeType": "application/json",
        },
    }
    data = json.dumps(body).encode("utf-8")
    print(f"[AI vision] sending {len(images)} images, body size: {len(data)//1024}KB")

    endpoints = _gemini_endpoints()  # Vertex first (credits), Developer key fallback
    if not endpoints:
        _last_gemini_error = "net AI endpoint (Vertex SA / GEMINI_API_KEY ne nastroeny)"
        print("[AI vision] " + _last_gemini_error)
        return None

    last_err = None
    for model, url, headers in endpoints:
        for attempt in range(2):  # 2 retry per endpoint (for 5xx)
            req = urlreq.Request(url, data=data, method="POST", headers=headers)
            try:
                with urlreq.urlopen(req, timeout=timeout) as resp:
                    payload = json.loads(resp.read().decode("utf-8"))
                cand = (payload.get("candidates") or [{}])[0]
                text = cand.get("content", {}).get("parts", [{}])[0].get("text")
                if text and text.strip():
                    print(f"[AI vision] OK on {model}, response {len(text)} chars")
                    return text
                last_err = f"empty response: {str(payload)[:200]}"
                print(f"[AI vision] {model}: {last_err}")
                break  # empty → try next endpoint
            except urlerr.HTTPError as e:
                err_body = ""
                try:
                    err_body = e.read().decode("utf-8", errors="replace")[:500]
                except Exception:
                    pass
                last_err = f"{model} HTTP {e.code}: {err_body[:300]}"
                _last_gemini_error = last_err
                print(f"[AI vision] {model} attempt {attempt+1}/2: HTTP {e.code}: {err_body[:200]}")
                if e.code in (503, 500, 502, 504):
                    time.sleep(3 + attempt * 3)
                    continue
                break  # 429 / 4xx → next endpoint
            except Exception as e:
                last_err = f"{model} {type(e).__name__}: {e}"
                _last_gemini_error = last_err
                print(f"[AI vision] {model} attempt {attempt+1}/2: {last_err}")
                time.sleep(2)
                continue

    print(f"[AI vision] FAILED on all endpoints: {last_err}")
    return None


def get_last_gemini_error() -> str:
    """Vozvrashchaem poslednyuyu detal'nuyu HTTP-oshibku ot Gemini (dlya debug)."""
    return _last_gemini_error


def transcribe_audio(audio_bytes: bytes, mime: str = "audio/mpeg", timeout: int = 300) -> str | None:
    """Phase 4: transcribe an audio file via Gemini's native audio understanding
    (no separate STT service). Returns the transcript text, or None on failure.
    Bounded at the call site by file size + a per-user budget (audio costs money)."""
    global _last_gemini_error
    import base64
    parts = [
        {"text": "Transcribe this audio VERBATIM in its original language. "
                 "Return ONLY the transcript text — no timestamps, no speaker "
                 "labels, no commentary."},
        {"inline_data": {"mime_type": mime,
                         "data": base64.b64encode(audio_bytes).decode("ascii")}},
    ]
    body = {"contents": [{"role": "user", "parts": parts}],
            "generationConfig": {"temperature": 0.1, "maxOutputTokens": 8000}}
    data = json.dumps(body).encode("utf-8")
    print(f"[AI audio] transcribing {len(audio_bytes)//1024}KB ({mime})")
    endpoints = _gemini_endpoints()
    if not endpoints:
        _last_gemini_error = "no AI endpoint (Vertex SA / GEMINI_API_KEY not set)"
        return None
    for model, url, headers in endpoints:
        req = urlreq.Request(url, data=data, method="POST", headers=headers)
        try:
            with urlreq.urlopen(req, timeout=timeout) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            cand = (payload.get("candidates") or [{}])[0]
            text = (cand.get("content", {}).get("parts", [{}])[0].get("text") or "").strip()
            if text:
                print(f"[AI audio] OK on {model}, transcript {len(text)} chars")
                return text
        except urlerr.HTTPError as e:
            _last_gemini_error = f"{model} HTTP {e.code}"
            print(f"[AI audio] {model} HTTP {e.code} — fallback")
            continue
        except Exception as e:
            _last_gemini_error = f"{model} {type(e).__name__}: {e}"
            print(f"[AI audio] {model} {type(e).__name__}: {e}")
            continue
    return None


def ocr_pdf_pages(pdf_path, max_pages: int = 20) -> list[tuple]:
    """OCR a scanned / no-text-layer PDF via Gemini Vision. Renders up to
    `max_pages` pages to images and transcribes them in ONE vision call (cheaper),
    returning [(page_no, text), …]. Empty list on failure. Used by the tutor
    document upload when pypdf finds no text layer — bounded by a per-user budget
    at the call site (Vision costs money per page)."""
    from pathlib import Path as _Path
    images = _pdf_to_images(_Path(str(pdf_path)), max_pages=max_pages, dpi=175)
    if not images:
        return []
    prompt = (
        "You are an OCR engine. Transcribe ALL text from each page image VERBATIM, "
        "preserving reading order. Do NOT summarise, translate, or add commentary. "
        "There are N images in order (page 1..N). Return ONLY JSON: "
        '{"pages":[{"page":1,"text":"<full text of page 1>"}, …]} '
        "— exactly one entry per input image, in order."
    )
    raw = _gemini_vision_call(images, prompt=prompt)
    if not raw:
        return []
    try:
        data = json.loads(raw)
    except Exception:
        m = re.search(r"\{.*\}", raw, re.S)
        if not m:
            return []
        try:
            data = json.loads(m.group(0))
        except Exception:
            return []
    out = []
    for p in (data.get("pages") if isinstance(data, dict) else None) or []:
        try:
            pg = int(p.get("page"))
        except (TypeError, ValueError):
            pg = None
        txt = (p.get("text") or "").strip()
        if txt:
            out.append((pg, txt))
    if not out and isinstance(data, dict) and (data.get("text") or "").strip():
        out = [(None, data["text"].strip())]
    return out


def _parse_vision_response(text: str) -> list[dict]:
    """Razbiraet otvet Gemini -> spisok kart. MAKSIMALNO GIBKY parser.
    Sokranyaet pole '_number' dlya dedupe."""
    if not text:
        return []
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
    try:
        items = json.loads(text)
    except Exception:
        m = re.search(r"\[.*\]", text, re.DOTALL)
        if not m:
            print(f"[AI vision parse] no JSON array. Raw: {text[:300]}")
            return []
        try:
            items = json.loads(m.group(0))
        except Exception as e:
            print(f"[AI vision parse] JSON parse err: {e}. Raw: {text[:300]}")
            return []
    # Esli vernuli {"questions": [...]} ili pohozhee — razvorachivaem
    if isinstance(items, dict):
        for key in ("questions", "cards", "items", "data", "results"):
            if key in items and isinstance(items[key], list):
                items = items[key]
                break
    if not isinstance(items, list):
        print(f"[AI vision parse] not a list, type={type(items).__name__}")
        return []
    cards = []
    for it in items:
        if not isinstance(it, dict):
            continue
        # Yavno propustit otkrytye TOLKO esli AI yavno pomenil
        if it.get("is_open") is True:
            continue
        q = (it.get("question") or it.get("front") or it.get("q") or it.get("text") or "").strip()
        opts = it.get("options") or it.get("choices") or it.get("variants") or []
        correct_raw = (it.get("correct_letter") or it.get("answer") or it.get("correct") or "").strip()
        # Esli correct = "B) text" — vyderzhi bukvu
        if correct_raw and len(correct_raw) > 2:
            m = re.match(r"^\s*([A-Za-zА-Яа-яЁё0-9])", correct_raw)
            if m:
                correct_raw = m.group(1)
        correct = correct_raw.upper()
        number = str(it.get("number") or "").strip()
        # Trebuyem minimum 2 varianta
        if not q or not isinstance(opts, list) or len(opts) < 2:
            continue
        # Ochishchaem varianty
        clean_opts = []
        for opt in opts:
            opt_str = str(opt).strip()
            if opt_str:
                clean_opts.append(opt_str)
        if len(clean_opts) < 2:
            continue
        # Sobiraem note: vse varianty cherez perenos
        note = "\n".join(clean_opts)
        # Esli est' bukva pravilnogo otveta — formiruyem back v formate "B) tekst"
        back = ""
        if correct:
            for opt in clean_opts:
                m = re.match(r"^\s*([A-Za-zА-Яа-яЁё]|\d+)\s*[\)\.\:]?\s*(.+)$", opt)
                if m and m.group(1).upper() == correct:
                    back = f"{correct}) {m.group(2).strip()}"
                    break
        # Esli ne nashli — vse varianty v back (pust' uchitel sam otmetit)
        if not back:
            back = note
            note = ""
        cards.append({"front": q, "back": back, "note": note, "_number": number})
    return cards


def _dedupe_cards(cards: list[dict]) -> list[dict]:
    """Ubirayem dubli — chasto vznikayut na granitsah chankov ili pri povtorah strogi."""
    seen = set()
    out = []
    for c in cards:
        # Klyuch — pervye 80 simvolov voprosa v lower-case bez probelov
        key = re.sub(r"\s+", "", (c.get("front") or "").lower())[:80]
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(c)
    return out


def _validate_cards(cards: list[dict], max_len: int = 1500) -> list[dict]:
    """Quality gate run on every generated batch before it reaches the user:
    drops empty/too-short fronts, question==answer giveaways and over-long
    fields, then de-duplicates. Cheap, deterministic, no extra API cost — a
    floor under generation quality. Logs how many it rejected (grep AI-METRIC)."""
    def _norm(s):
        return re.sub(r"\W+", "", (s or "").lower())

    cleaned = []
    for c in cards or []:
        front = str(c.get("front") or "").strip()
        back = str(c.get("back") or "").strip()
        if len(front) < 5 or not back:
            continue
        if _norm(front) == _norm(back):
            continue  # question literally equals the answer — useless card
        nc = dict(c)
        nc["front"] = front[:max_len]
        nc["back"] = back[:max_len]
        nc["note"] = str(c.get("note") or "").strip()[:max_len]
        cleaned.append(nc)

    deduped = _dedupe_cards(cleaned)
    dropped = len(cards or []) - len(deduped)
    if dropped > 0:
        print(f"[AI-METRIC] label=validate of={len(cards or [])} kept={len(deduped)} "
              f"dropped={dropped}", flush=True)
    return deduped


_EMBED_MODEL = "text-multilingual-embedding-002"  # RU/EN/UZ, dim 768


def _embed_texts(texts: list[str]):
    """Embed texts via Vertex multilingual embeddings. Returns a list of vectors
    aligned to inputs, or None on any failure (caller falls back)."""
    texts = [t or "" for t in texts]
    if not texts or not vertex_enabled():
        return None
    tok = _vertex_token()
    if not tok:
        return None
    loc = VERTEX_LOCATION
    host = "aiplatform.googleapis.com" if loc == "global" else f"{loc}-aiplatform.googleapis.com"
    url = (f"https://{host}/v1/projects/{_vertex_project()}/locations/{loc}"
           f"/publishers/google/models/{_EMBED_MODEL}:predict")
    out = []
    for i in range(0, len(texts), 100):  # API caps instances per request
        chunk = texts[i:i + 100]
        body = {"instances": [{"content": (t or " ")[:2000]} for t in chunk]}
        try:
            req = urlreq.Request(url, data=json.dumps(body).encode("utf-8"), method="POST",
                                 headers={"Authorization": f"Bearer {tok}",
                                          "Content-Type": "application/json"})
            with urlreq.urlopen(req, timeout=60) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            for pred in payload.get("predictions", []):
                out.append(pred["embeddings"]["values"])
        except Exception as e:
            print(f"[embed] {type(e).__name__}: {e}")
            return None
    return out if len(out) == len(texts) else None


def _cosine(a, b) -> float:
    import math
    dot = sum(x * y for x, y in zip(a, b))
    na = math.sqrt(sum(x * x for x in a))
    nb = math.sqrt(sum(y * y for y in b))
    return dot / (na * nb) if na and nb else 0.0


def dedup_semantic(new_cards: list[dict], existing_fronts, threshold: float = 0.90) -> list[dict]:
    """Drop generated cards whose question is a SEMANTIC near-duplicate (cosine
    of multilingual embeddings) of an existing deck card or an earlier card in
    the batch — catches paraphrases that text dedup misses. Falls back to the
    cheap text dedup if embeddings are unavailable."""
    new_cards = new_cards or []
    if not new_cards:
        return new_cards
    new_fronts = [c.get("front", "") for c in new_cards]
    existing = list(existing_fronts or [])
    vecs = _embed_texts(new_fronts + existing)
    if not vecs:
        return dedup_against_existing(new_cards, existing)
    n = len(new_fronts)
    new_vecs, exist_vecs = vecs[:n], vecs[n:]
    kept, kept_vecs, dropped = [], [], 0
    for i, c in enumerate(new_cards):
        v = new_vecs[i]
        is_dup = (any(_cosine(v, ev) >= threshold for ev in exist_vecs)
                  or any(_cosine(v, kv) >= threshold for kv in kept_vecs))
        if is_dup:
            dropped += 1
            continue
        kept.append(c)
        kept_vecs.append(v)
    if dropped:
        print(f"[AI-METRIC] label=dedup_semantic dropped={dropped} kept={len(kept)}", flush=True)
    return kept


def dedup_against_existing(new_cards: list[dict], existing_fronts) -> list[dict]:
    """Drop generated cards whose question is a near-duplicate of one already in
    the target deck (normalized text — cheap, no embeddings). Use when appending
    AI cards to an existing deck so users don't get the same question twice."""
    seen = set()
    for f in (existing_fronts or []):
        k = re.sub(r"\W+", "", (f or "").lower())[:80]
        if k:
            seen.add(k)
    out = []
    dropped = 0
    for c in new_cards or []:
        key = re.sub(r"\W+", "", (c.get("front") or "").lower())[:80]
        if key and key in seen:
            dropped += 1
            continue
        if key:
            seen.add(key)
        out.append(c)
    if dropped:
        print(f"[AI-METRIC] label=dedup_existing dropped={dropped} kept={len(out)}", flush=True)
    return out


def _fold_sources(cards: list[dict]) -> list[dict]:
    """For grounded generation: move each card's source citation into its note
    (prefixed with 📖) and drop the internal source_span key, so the citation
    reaches the learner without changing the {front, back, note} card shape."""
    for c in cards or []:
        src = (c.pop("source_span", "") or "").strip()
        if not src:
            continue
        note = (c.get("note") or "").strip()
        if src.lower() not in note.lower():
            note = (note + ("\n" if note else "") + f"📖 {src}")[:1500]
        c["note"] = note
    return cards


# === KONVERTATSIYA: Test → Flashcards i Flashcards → Test ====================

def convert_tests_to_flashcards(cards: list[dict], lang: str = "ru") -> list[dict]:
    """Iz testovyh kart (vopros + varianty + pravil'nyy otvet)
    delaet slovar/term-karty (kratkoye opredelenye/kontekst).

    Vhod: list[{'front': vopros, 'back': otvet (bukva ili tekst), 'note': varianty}]
    Vyhod: list[{'front': key term, 'back': brief definition, 'note': context}]"""
    if not cards:
        return []

    lang_map = {"ru": "русском", "en": "English", "uz": "oʻzbek tilida"}
    lang_name = lang_map.get(lang, "русском")

    # Otpravlyaem vse karty batchom v AI
    cards_json = json.dumps(cards, ensure_ascii=False, indent=2)

    prompt = f"""Ty — uchitel'.
Tebe dany testovye voprosy s variantami otvetov. Tvoya zadacha — preobrazovat' kazhdyy vopros
v slovarnuyu (term-style) kartu dlya zauchivaniya.

Pravila preobrazovaniya:
1. "front" — klyuchevoy termin, ponyatiye ili kratkiy vopros (NE polnyy testovyy vopros, a ego sut').
2. "back" — kratkoye opredelenye/otvet odnim-dvumya predlozheniyami (ne bukva, a smysl!).
3. "note" — kontekst, primer ili dopolnitel'noye obyasneniye.
4. Yazyk: {lang_name}.
5. Esli iz testa nelzya izvlech' vnyatnyy slovar' — propusti.

Primer vhoda:
{{"front": "Kto napisal Voinu i mir?", "back": "B", "note": "A) Pushkin\\nB) Tolstoy\\nC) Dostoyevsky\\nD) Chekhov"}}

Primer vyhoda:
{{"front": "Voina i mir", "back": "Roman Lva Tolstogo (1869), o nashestvii Napoleona na Rossiyu.", "note": "Klyuchevoye proizvedenie russkoy literatury XIX veka."}}

Vyhod TOL'KO JSON-arrey:
[{{"front":"...","back":"...","note":"..."}}, ...]

VHODNYE TESTY:
{cards_json}"""

    raw = _call_gemini(prompt, max_tokens=12000)
    return _validate_cards(_parse_cards_json(raw or ""))


def convert_flashcards_to_tests(cards: list[dict], lang: str = "ru") -> list[dict]:
    """Iz slovar/term-kart sozdayot testovye voprosy s 4 variantami.
    Pravil'nyy otvet — bukva (A/B/C/D), opciya teksta v note kak A) X\\nB) Y..."""
    if not cards:
        return []

    lang_map = {"ru": "русском", "en": "English", "uz": "oʻzbek tilida"}
    lang_name = lang_map.get(lang, "русском")

    cards_json = json.dumps(cards, ensure_ascii=False, indent=2)

    prompt = f"""Ty — sostavitel' testov.
Tebe dany slovarnye karty (termin + opredelenye). Tvoya zadacha — sdelat' iz kazhdoy
testovyy vopros s 4-mya variantami otveta (pravil'nyy + 3 pravdopodobnyh distraktora).

Pravila:
1. "front" — testovyy vopros (mozhet byt' "Chto takoe X?" ili kontekstnyy).
2. "back" — TOL'KO bukva pravil'nogo otveta: "A", "B", "C" ili "D".
3. "note" — chetyre varianta v formate:
   "A) tekst varianta\\nB) tekst varianta\\nC) tekst varianta\\nD) tekst varianta"
4. Distraktory dolzhny byt' pravdopodobnymi, no chetko nepravil'nymi (svyazany s temoy).
5. Pravil'nyy otvet sluchayno raspredelyay mezhdu A/B/C/D — ne tol'ko A.
6. Yazyk: {lang_name}.

Primer vhoda:
{{"front": "Voina i mir", "back": "Roman Tolstogo o Napoleone", "note": "1869 god"}}

Primer vyhoda:
{{
  "front": "Kto napisal roman 'Voina i mir'?",
  "back": "C",
  "note": "A) Aleksandr Pushkin\\nB) Fyodor Dostoyevskiy\\nC) Lev Tolstoy\\nD) Anton Chekhov"
}}

Vyhod TOL'KO JSON-arrey:
[{{"front":"...","back":"A","note":"A) ...\\nB) ...\\nC) ...\\nD) ..."}}, ...]

VHODNYE SLOVARI:
{cards_json}"""

    raw = _call_gemini(prompt, max_tokens=12000)
    return _validate_cards(_parse_cards_json(raw or ""))


# === AI GENERATION WITH PHOTOS ===============================================

def generate_with_photos(topic: str, count: int = 10, lang: str = "ru",
                         progress_cb=None) -> list[dict]:
    """Generiruyet testovye karty s fotografiyami.

    Algoritm:
    1. AI generiruyet voprosy s klyuchevymi slovami dlya poiska foto
    2. Dlya kazhdogo voprosa ishchem foto cherez Wikimedia/Pexels
    3. Vozvrashchaem karty s image_url

    progress_cb(done, total, msg) — optsional'nyy callback dlya progressa.
    """
    from image_search import find_image

    lang_map = {"ru": "Russian (русский)", "en": "English", "uz": "Uzbek (o'zbek)"}
    lang_name = lang_map.get(lang, "Russian")

    # Step 1: AI generates questions with image search keywords
    prompt = f"""You are a creative teacher creating visual flashcards with photos.

Topic: "{topic}"
Count: exactly {count} flashcards.
Language: {lang_name}

For each flashcard, generate:
1. A question that can be illustrated with a photo
2. The correct answer
3. A SHORT English search query (2-4 words) to find a relevant photo on Wikimedia Commons
4. A memory note or explanation

IMPORTANT for image_query:
- Use English regardless of the topic language
- Be specific: "Flag of France" not just "flag France" (Wikimedia uses "Flag of X" format)
- For flags ALWAYS use: "Flag of <country name in English>"
- Use descriptive terms: "human heart anatomy diagram" not "heart"
- For people: "Albert Einstein portrait"
- For places: "Eiffel Tower Paris photo"
- For animals: "Bengal tiger wildlife photo"
- For concepts: use a visual representation

Output ONLY a JSON array:
[{{
  "question": "...",
  "answer": "...",
  "note": "...",
  "image_query": "short english search query"
}}, ...]"""

    raw = _call_gemini(prompt, max_tokens=8000, response_schema=_FLASHCARD_PHOTO_SCHEMA)
    if not raw:
        return []

    # Parse with extended fields
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
    try:
        data = json.loads(text)
    except Exception:
        m = re.search(r"\[.*\]", text, re.DOTALL)
        if not m:
            return []
        try:
            data = json.loads(m.group(0))
        except Exception:
            return []

    if not isinstance(data, list):
        return []

    cards = []
    total = len(data)
    for i, item in enumerate(data):
        if not isinstance(item, dict):
            continue
        q = (item.get("question") or item.get("front") or "").strip()
        a = (item.get("answer") or item.get("back") or "").strip()
        n = (item.get("note") or item.get("explanation") or "").strip()
        img_query = (item.get("image_query") or item.get("image_search") or q).strip()

        if not q or not a:
            continue

        # Step 2: Search for image
        if progress_cb:
            progress_cb(i, total, f"Ищу фото: {img_query[:40]}...")

        image_url = None
        try:
            image_url = find_image(img_query, topic_hint=topic)
        except Exception as e:
            print(f"[ai_photo] image search error for '{img_query}': {e}")

        cards.append({
            "front": q,
            "back": a,
            "note": n,
            "image_url": image_url or "",
        })

    if progress_cb:
        progress_cb(total, total, f"Готово! {len(cards)} карточек с фото.")

    return cards


def vision_pdf_to_cards(pdf_path: Path, lang: str = "ru",
                        max_pages: int = 30,
                        chunk_size: int = 1,
                        progress_cb=None,
                        audit: bool = False,
                        status_cb=None) -> list[dict]:
    """Skaniruyet stranitsy PDF cherez Gemini Vision i izvlekayet ZAKRYTYE voprosy.

    Strategiya (BALANS skorost' / kachestvo):
    - DPI=175 (kompromis: kachestvo OK, body ne slishkom bolshoy)
    - chunk_size=1 — POSTRANICHNAYA obrabotka
    - audit=False po default (otklyucheno chtoby ne udvaivat' vremya)

    progress_cb(done, total, found_so_far) — posle kazhdoy stranitsy.
    status_cb(stage_msg) — tekstoviy status dlya debug ("extracting page 3/14", "audit page 5", ...).
    """
    images = _pdf_to_images(pdf_path, max_pages=max_pages, dpi=175)
    if not images:
        raise RuntimeError("Не удалось отрендерить страницы PDF (PyMuPDF). Возможно, файл повреждён.")
    if not is_available():
        raise RuntimeError("AI не настроен на сервере (нет Vertex service account или GEMINI_API_KEY).")

    total_pages = len(images)
    all_cards = []
    chunk_results = []  # (success: bool, parsed_count: int)
    last_chunk_error = None

    import time

    def _status(msg):
        if status_cb:
            try: status_cb(msg)
            except Exception: pass
        print(f"[AI vision] {msg}")

    # POSTRANICHNAYA obrabotka (chunk_size=1)
    for i in range(0, total_pages, chunk_size):
        chunk = images[i:i + chunk_size]
        page_num = i + 1
        _status(f"extracting page {page_num}/{total_pages}")

        # PASS 1: glavnaya extractsia
        raw = _gemini_vision_call(chunk, timeout=120, prompt=VISION_EXTRACT_PROMPT)
        page_cards = []
        if raw:
            page_cards = _parse_vision_response(raw)
            chunk_results.append((True, len(page_cards)))
            _status(f"page {page_num}: +{len(page_cards)} cards (total: {len(all_cards) + len(page_cards)})")
        else:
            chunk_results.append((False, 0))
            last_chunk_error = "Gemini API не ответил (rate limit / перегруз / сетевая ошибка)"
            _status(f"page {page_num}: FAILED")

        # PASS 2: AUDIT — esli vklyuchen i pervyy proxod chto-to nashel
        if audit and page_cards:
            time.sleep(3)
            extracted_numbers = [c.get("_number", "") for c in page_cards if c.get("_number")]
            if extracted_numbers:
                _status(f"audit page {page_num} (looking for missed)")
                audit_prompt = VISION_AUDIT_PROMPT.format(
                    extracted_numbers=", ".join(extracted_numbers)
                )
                audit_raw = _gemini_vision_call(chunk, timeout=120, prompt=audit_prompt)
                if audit_raw:
                    missed = _parse_vision_response(audit_raw)
                    existing_nums = set(c.get("_number", "") for c in page_cards)
                    truly_new = [c for c in missed if c.get("_number", "") not in existing_nums]
                    if truly_new:
                        _status(f"audit page {page_num}: +{len(truly_new)} MISSED recovered")
                        page_cards.extend(truly_new)

        all_cards.extend(page_cards)

        # Progress callback
        if progress_cb:
            try:
                progress_cb(min(i + chunk_size, total_pages), total_pages, len(all_cards))
            except Exception:
                pass

        # Mezhdu stranitsami — pauza (15 RPM = 1 zapros / 4 sek)
        if i + chunk_size < total_pages:
            time.sleep(4)

    # Esli VSE stranitsy upali — eto problema s API
    if chunk_results and not any(r[0] for r in chunk_results):
        # Beryom poslednyuyu detal'nuyu oshibku ot Gemini
        gemini_err = get_last_gemini_error() or "(net detalei)"
        # Opredelyaem konkretnyy tip oshibki
        if "429" in gemini_err or "RESOURCE_EXHAUSTED" in gemini_err.upper() or "quota" in gemini_err.lower():
            raise RuntimeError(
                "🚫 Лимит запросов к Gemini временно исчерпан (rate limit). "
                "Подождите минуту и попробуйте снова. "
                f"\n\nПодробности от Google: {gemini_err[:300]}"
            )
        elif "401" in gemini_err or "403" in gemini_err or "API_KEY" in gemini_err.upper():
            raise RuntimeError(
                "🔑 Проблема с доступом к Gemini. Проверьте Vertex service account "
                "(GOOGLE_SERVICE_ACCOUNT_JSON) или GEMINI_API_KEY в Railway env. "
                f"\n\nПодробности: {gemini_err[:300]}"
            )
        elif "503" in gemini_err or "500" in gemini_err or "overload" in gemini_err.lower():
            raise RuntimeError(
                "⚙️ Серверы Gemini перегружены. Попробуйте через 5-10 минут. "
                f"\n\nПодробности: {gemini_err[:300]}"
            )
        else:
            raise RuntimeError(
                "❌ Все запросы к Gemini Vision провалились. "
                f"\n\nПодробности: {gemini_err[:400]}"
            )

    deduped = _dedupe_cards(all_cards)
    for c in deduped:
        c.pop("_number", None)

    _status(f"FINAL: {len(deduped)} unique cards from {total_pages} pages")
    return deduped



def find_correct_answers(cards: list[dict], lang: str = "ru",
                          batch_size: int = 15) -> list[dict]:
    """Dlya kazhdoy karty bez otmechennogo pravil'nogo otveta —
    AI analiziruet vopros i varianty, vybirayet pravil'nyy.

    Vhod: list[{"id": ..., "front": vopros, "back": varianty (mnogostrochno),
                "note": (optional, varianty)}]

    Vozvraschayet: list[{"id": ..., "correct_letter": "B", "back": "B) text", "note": vse_varianty}]
    Karty bez korrektnogo razbora pomechayutsya correct_letter=None — propuskayutsya.
    """
    if not cards:
        return []

    lang_map = {"ru": "русском", "en": "English", "uz": "узбекском"}
    lang_name = lang_map.get(lang, "русском")

    results = []
    # Obrabatyvayem batchami chtoby ne vyletet po tokenam
    for batch_start in range(0, len(cards), batch_size):
        batch = cards[batch_start:batch_start + batch_size]
        # Sobiraem promt
        items_text = []
        for i, c in enumerate(batch):
            front = (c.get("front") or "").strip()
            # Varianty mogut byt' v back ili note
            options_text = (c.get("back") or "").strip()
            if c.get("note"):
                # Esli est' note s variantami — beryom ego
                note = c["note"].strip()
                if "\n" in note and any(re.match(r"^\s*[A-Da-d1-4]\s*[\)\.]", line)
                                          for line in note.split("\n")):
                    options_text = note

            items_text.append(f"[{i+1}]\nВопрос: {front}\nВарианты:\n{options_text}\n")

        prompt = f"""Ты — эксперт-преподаватель. Для каждого тестового вопроса определи ПРАВИЛЬНЫЙ ответ из вариантов.

ЯЗЫК: {lang_name}

ИНСТРУКЦИИ:
1. Внимательно прочитай вопрос и все варианты ответов
2. Используй свои знания чтобы определить какой вариант ВЕРНЫЙ
3. Если уверенность < 70% — пометь correct_letter как null (не угадывай)
4. Если в формате варианты не A/B/C/D, а 1/2/3/4 — конвертируй в A=1, B=2, C=3, D=4

ВОПРОСЫ:
{chr(10).join(items_text)}

Вывод СТРОГО JSON (массив, индекс i соответствует вопросу [i+1]):
[
  {{"index": 1, "correct_letter": "B", "confidence": 0.95}},
  {{"index": 2, "correct_letter": null, "confidence": 0.4}},
  ...
]

Если уверенность < 0.7 — correct_letter null. Не выдумывай ответы."""

        raw = _call_gemini(prompt, max_tokens=4000)
        if not raw:
            # Esli AI ne otvetil — propuskayem batch (pust' ostavet kak est')
            for c in batch:
                results.append({"id": c.get("id"), "correct_letter": None})
            continue

        try:
            text = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
            answers = json.loads(text)
        except Exception:
            m = re.search(r"\[.*\]", raw, re.DOTALL)
            if m:
                try:
                    answers = json.loads(m.group(0))
                except Exception:
                    answers = []
            else:
                answers = []

        if not isinstance(answers, list):
            answers = []

        # Sopostavlyaem otvety s kartami po index
        ans_by_idx = {}
        for a in answers:
            if isinstance(a, dict):
                idx = a.get("index")
                if isinstance(idx, int):
                    ans_by_idx[idx] = a

        for i, c in enumerate(batch):
            ans = ans_by_idx.get(i + 1, {})
            correct = (ans.get("correct_letter") or "").strip().upper() if ans.get("correct_letter") else None
            confidence = ans.get("confidence", 0.0)

            # Esli AI ne uverenny — propuskaem
            if not correct or confidence < 0.7:
                results.append({"id": c.get("id"), "correct_letter": None})
                continue

            # Konvertiruem 1/2/3/4 -> A/B/C/D
            if correct in "1234":
                correct = "ABCD"["1234".index(correct)]

            # Stroim novyy back v formate "B) text"
            options_text = (c.get("back") or "").strip()
            if c.get("note") and "\n" in c.get("note", ""):
                options_text = c["note"]

            new_back = correct
            new_note = options_text
            for line in options_text.split("\n"):
                m = re.match(r"^\s*([A-Da-d]|\d+)\s*[\)\.\:]?\s*(.+)$", line.strip())
                if m and m.group(1).upper() == correct:
                    new_back = f"{correct}) {m.group(2).strip()}"
                    break

            results.append({
                "id": c.get("id"),
                "correct_letter": correct,
                "back": new_back,
                "note": new_note,
                "confidence": confidence,
            })

    return results


def auto_find_answers(cards: list[dict], lang: str = "ru",
                      batch_size: int = 10) -> list[dict]:
    """Avtomaticheski opredelyaet pravil'nyy otvet dlya VSEH kart s variantami.
    Uluchsheniya po sravneniyu s find_correct_answers():
    - batch_size=10 — DeepSeek stabil'no otvechaet na 10 voprosov
    - Rasshirennyy regex: 'A tekst' (bez skobki) tozhe raspoznayotsya
    - True/False karty: T/F tozhe schitayutsya variantami
    - Normalizatsiya variantov v note: vsegda 'A) tekst' so skobkoy
    - DeepSeek-first s Gemini fallback
    - max_tokens=2000 — JSON ne obrezaetsya
    - Adaptivnyy confidence threshold (0.5 dlya T/F, 0.6 dlya 3 var, 0.7 dlya 4+)
    """
    if not cards:
        return cards

    _OPT_RE = re.compile(r"^\s*([A-Da-dА-Гa-гTF1-4])\s*[\)\.\:\-]?\s+(.+)$", re.IGNORECASE)
    _TF_RE  = re.compile(r"^\s*(T|F|True|False|Верно|Неверно|Ha|Yo'q)\s*$", re.IGNORECASE)

    def _get_options(c: dict) -> list[str]:
        """Returns normalized option lines like ['A) text', 'B) text', ...]."""
        for src in [(c.get("note") or "").strip(), (c.get("back") or "").strip()]:
            if not src:
                continue
            lines = [l.strip() for l in src.split("\n") if l.strip()]
            # T/F format
            tf_lines = [l for l in lines if _TF_RE.match(l)]
            if len(tf_lines) >= 2 and len(tf_lines) == len(lines):
                normalized = []
                for l in lines:
                    u = l.strip().upper()
                    if u in ("T", "TRUE", "ВЕРНО", "HA"):
                        normalized.append("T) True")
                    elif u in ("F", "FALSE", "НЕВЕРНО", "YO'Q"):
                        normalized.append("F) False")
                    else:
                        normalized.append(l)
                return normalized
            # Regular MCQ
            normalized = []
            for line in lines:
                m = _OPT_RE.match(line)
                if m:
                    normalized.append(f"{m.group(1).upper()}) {m.group(2).strip()}")
            if len(normalized) >= 2:
                return normalized
        return []

    def _already_answered(c: dict) -> bool:
        back = (c.get("back") or "").strip()
        lines = [l for l in back.split("\n") if l.strip()]
        if len(lines) != 1:
            return False
        return bool(re.match(r"^\s*[A-Da-dTF1-4]\s*[\)\.\:\-]\s*\S", lines[0], re.IGNORECASE))

    to_process = [i for i, c in enumerate(cards)
                  if _get_options(c) and not _already_answered(c)]

    if not to_process:
        print(f"[auto_find_answers] vse {len(cards)} kart uzhe s otvetami ili bez variantov")
        return cards

    print(f"[auto_find_answers] {len(to_process)}/{len(cards)} kart nuzhno obrabotyvat'")
    lang_name = {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")
    result_cards = list(cards)

    for batch_start in range(0, len(to_process), batch_size):
        batch_indices = to_process[batch_start:batch_start + batch_size]
        batch_num = batch_start // batch_size + 1
        total_batches = (len(to_process) - 1) // batch_size + 1
        print(f"[auto_find_answers] batch {batch_num}/{total_batches}: {len(batch_indices)} kart")

        batch_opts = []
        items_text = []
        for local_i, orig_i in enumerate(batch_indices):
            c = cards[orig_i]
            opts = _get_options(c)
            batch_opts.append(opts)
            items_text.append(
                f"[{local_i + 1}]\nQuestion: {c.get('front', '').strip()}\n"
                f"Options:\n{chr(10).join(opts)}\n"
            )

        prompt = f"""You are an expert teacher. For each question, identify the CORRECT answer.
Language: {lang_name}

Rules:
1. Read the question and ALL options carefully
2. Use your knowledge to find the CORRECT answer
3. For True/False questions (2 options T/F): ALWAYS provide T or F
4. For 3+ options: if confidence < 70% → use null (do not guess)
5. Options 1/2/3/4 → convert to A/B/C/D

QUESTIONS:
{chr(10).join(items_text)}

Output ONLY a JSON array:
[
  {{"index": 1, "correct_letter": "B", "confidence": 0.95}},
  {{"index": 2, "correct_letter": "T", "confidence": 0.80}},
  {{"index": 3, "correct_letter": null, "confidence": 0.40}}
]

JSON only, no explanations."""

        raw = None
        # 1. DeepSeek (prioritet — bystree i tochneye dlya faktov)
        if is_deepseek_available():
            try:
                raw = _deepseek_chat_call(
                    system_prompt="You are an expert teacher. Reply only with JSON.",
                    messages=[{"role": "user", "content": prompt}],
                    max_tokens=2000, temperature=0.1, stream=False, timeout=60,
                )
                if raw:
                    print(f"[auto_find_answers] batch {batch_num}: DeepSeek OK")
            except Exception as e:
                print(f"[auto_find_answers] batch {batch_num}: DeepSeek err: {e}")
                raw = None

        # 2. Gemini fallback
        if not raw and is_available():
            try:
                raw = _call_gemini(prompt, max_tokens=2000)
                if raw:
                    print(f"[auto_find_answers] batch {batch_num}: Gemini OK")
            except Exception as e:
                print(f"[auto_find_answers] batch {batch_num}: Gemini err: {e}")
                raw = None

        if not raw:
            print(f"[auto_find_answers] batch {batch_num}: oba AI ne otvetili, propuskaem")
            continue

        try:
            cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
            answers = json.loads(cleaned)
        except Exception:
            m_arr = re.search(r"\[.*\]", raw, re.DOTALL)
            answers = json.loads(m_arr.group(0)) if m_arr else []
        if not isinstance(answers, list):
            continue

        ans_map = {a["index"]: a for a in answers
                   if isinstance(a, dict) and isinstance(a.get("index"), int)}

        for local_i, orig_i in enumerate(batch_indices):
            ans = ans_map.get(local_i + 1, {})
            correct = (ans.get("correct_letter") or "").strip().upper() if ans.get("correct_letter") else None
            confidence = float(ans.get("confidence") or 0.0)
            opts = batch_opts[local_i]
            # Adaptive threshold
            threshold = 0.5 if len(opts) <= 2 else (0.6 if len(opts) == 3 else 0.7)
            if not correct or confidence < threshold:
                continue
            # 1/2/3/4 → A/B/C/D
            if correct in "1234":
                correct = "ABCD"["1234".index(correct)]
            # Build new back
            new_back = correct
            for opt_line in opts:
                m2 = re.match(r"^\s*([A-Da-dTF1-4])\s*[\)\.\:\-]\s*(.+)$", opt_line.strip(), re.IGNORECASE)
                if m2 and m2.group(1).upper() == correct:
                    new_back = f"{correct}) {m2.group(2).strip()}"
                    break
            new_note = "\n".join(opts)
            result_cards[orig_i] = {**cards[orig_i], "back": new_back, "note": new_note}
            print(f"[auto_find_answers] [{orig_i + 1}] -> {correct} (conf={confidence:.2f}): {new_back[:60]}")

    answered = sum(1 for i in to_process if _already_answered(result_cards[i]))
    print(f"[auto_find_answers] ITOG: {answered}/{len(to_process)} kart poluchili otvet")
    return result_cards


def explain_question(question: str, answer: str, lang: str = "ru") -> str | None:
    """AI-pomoshnik: ob'yasnyayet vopros i otvet prostym yazykom."""
    if not is_available():
        return None
    lang_prompt = {
        "ru": "русском",
        "en": "English",
        "uz": "узбекском",
    }.get(lang, "русском")
    # Chistim otvet ot prefiksa "A) ..." dlya MCQ kartochek
    clean_answer = (answer or "").strip()
    first_line = clean_answer.split("\n")[0].strip()
    m = re.match(r"^([A-Za-zА-Яа-яЁё0-9]+)\s*[\)\.\:\-]\s*(.+)$", first_line)
    if m:
        clean_answer = m.group(2).strip()

    prompt = f"""Объясни простым и понятным языком на {lang_prompt} следующий вопрос и его правильный ответ.
Дай контекст: что это, почему ответ именно такой, какие есть нюансы.
Отвечай 3-5 короткими предложениями. Без вступлений вроде "Конечно!" — сразу к сути.

ВОПРОС: {question}
ПРАВИЛЬНЫЙ ОТВЕТ: {clean_answer}

Объяснение:"""
    body = {
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.4,
            # gemini-3.5-flash spends output budget on "thinking" first; a low
            # cap (was 500) gets fully consumed by thinking → empty reply.
            "maxOutputTokens": 2000,
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Vertex first (Cloud credits), Developer key fallback.
    for model, url, headers in _gemini_endpoints():
        req = urlreq.Request(url, data=data, method="POST", headers=headers)
        try:
            with urlreq.urlopen(req, timeout=40) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            cand = (payload.get("candidates") or [{}])[0]
            text = (cand.get("content", {}).get("parts", [{}])[0].get("text") or "").strip()
            if text:
                return text
        except urlerr.HTTPError as e:
            print(f"[AI explain] {model} HTTP {e.code} — fallback")
            continue
        except Exception as e:
            print(f"[AI explain] {model} {type(e).__name__}: {e}")
            continue
    return None


def _gemini_text(prompt: str, *, max_tokens: int = 2000, temperature: float = 0.4,
                 label: str = "card_action") -> str | None:
    """Free-text (non-JSON) Gemini call for tutor card/deck actions. Mirrors the
    explain_question call path (Vertex first, Developer-key fallback). Returns the
    model's prose, or None if AI is unavailable / every endpoint failed."""
    body = {
        "contents": [{"role": "user", "parts": [{"text": prompt}]}],
        "generationConfig": {"temperature": temperature, "maxOutputTokens": max_tokens},
    }
    data = json.dumps(body).encode("utf-8")
    for model, url, headers in _gemini_endpoints():
        req = urlreq.Request(url, data=data, method="POST", headers=headers)
        t0 = time.time()
        try:
            with urlreq.urlopen(req, timeout=60) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            cand = (payload.get("candidates") or [{}])[0]
            text = (cand.get("content", {}).get("parts", [{}])[0].get("text") or "").strip()
            if text:
                _log_metric(label=label, model=model,
                            latency_ms=int((time.time() - t0) * 1000), ok=True,
                            usage=payload.get("usageMetadata") or {},
                            finish=cand.get("finishReason"))
                return text
        except urlerr.HTTPError as e:
            print(f"[AI {label}] {model} HTTP {e.code} — fallback")
            continue
        except Exception as e:
            print(f"[AI {label}] {model} {type(e).__name__}: {e}")
            continue
    return None


def summarize_deck(cards: list, lang: str = "ru") -> str | None:
    """Phase 2: a structured study conspectus (markdown) built from a deck's
    cards via Gemini. Grounded ONLY in the cards. Returns markdown or None."""
    lines = []
    for c in cards[:150]:
        f = (c.get("front") or "").strip().replace("\n", " ")
        b = (c.get("back") or "").strip().replace("\n", " ")
        if f:
            lines.append(f"- {f} → {b}")
    material = "\n".join(lines)[:8000]
    if not material:
        return None
    lang_name = {"ru": "русском", "en": "English", "uz": "o'zbek"}.get(lang, "русском")
    prompt = (
        f"Ты — генератор учебных конспектов. На основе карточек ниже составь "
        f"СТРУКТУРИРОВАННЫЙ конспект на {lang_name} языке.\n"
        "Правила: опирайся ТОЛЬКО на карточки (не выдумывай факты); сгруппируй по темам; "
        "используй markdown (## заголовки, маркированные списки, **жирный** для терминов). "
        "Структура: краткий обзор темы; ключевые термины и определения; важные факты; "
        "короткое резюме в конце. Пиши сжато и по делу, без воды.\n\n"
        f"Карточки:\n{material}"
    )
    return _gemini_text(prompt, max_tokens=3000, temperature=0.4, label="deck_summary")


def generate_quiz(cards: list, lang: str = "ru", n: int = 8) -> list:
    """Phase 2: generate `n` multiple-choice quiz questions FROM a deck's cards
    (works even for flashcard-only decks). Returns a list of
    {q, options[≤4], correct(index), explanation}; [] on failure."""
    lines = []
    for c in cards[:150]:
        f = (c.get("front") or "").strip().replace("\n", " ")
        b = (c.get("back") or "").strip().replace("\n", " ")
        if f:
            lines.append(f"- {f} → {b}")
    material = "\n".join(lines)[:8000]
    if not material:
        return []
    lang_name = {"ru": "русском", "en": "English", "uz": "o'zbek"}.get(lang, "русском")
    prompt = (
        f"На основе учебного материала ниже составь {n} проверочных вопросов с "
        f"выбором ответа на {lang_name} языке.\n"
        "Опирайся ТОЛЬКО на материал (не выдумывай факты). У каждого вопроса ровно "
        "4 варианта, из них ровно один правильный; добавь краткое объяснение.\n"
        "Верни ТОЛЬКО валидный JSON-массив, без markdown-обрамления, по схеме:\n"
        '[{"q":"текст вопроса","options":["A","B","C","D"],"correct":0,'
        '"explanation":"почему этот вариант верный"}]\n\n'
        f"Материал:\n{material}"
    )
    raw = _gemini_text(prompt, max_tokens=4000, temperature=0.5, label="deck_quiz")
    if not raw:
        return []
    txt = raw.strip()
    txt = re.sub(r"^```(?:json)?", "", txt).strip()
    txt = re.sub(r"```$", "", txt).strip()
    try:
        data = json.loads(txt)
    except Exception:
        m = re.search(r"\[.*\]", txt, re.S)
        if not m:
            return []
        try:
            data = json.loads(m.group(0))
        except Exception:
            return []
    out = []
    for it in (data if isinstance(data, list) else []):
        try:
            q = (it.get("q") or "").strip()
            opts = [str(o).strip() for o in (it.get("options") or []) if str(o).strip()]
            corr = int(it.get("correct"))
        except (AttributeError, TypeError, ValueError):
            continue
        opts = opts[:4]
        if q and len(opts) >= 2 and 0 <= corr < len(opts):
            out.append({"q": q, "options": opts, "correct": corr,
                        "explanation": (it.get("explanation") or "").strip()[:400]})
    return out[:n]


# Tutor card actions — each turns a single flashcard into a micro-lesson.
_CARD_ACTION_INSTRUCTIONS = {
    "explain": "Объясни простыми словами, что это и почему ответ именно такой. Дай контекст и нюансы.",
    "simplify": "Объясни это МАКСИМАЛЬНО просто, как будто рассказываешь ребёнку 12 лет. Только простые слова, без терминов.",
    "example": "Приведи 1-2 конкретных, запоминающихся примера из реальной жизни, которые иллюстрируют этот ответ.",
    "analogy": "Придумай яркую, запоминающуюся аналогию или метафору, которая поможет легко это запомнить.",
}


def card_action(question: str, answer: str, action: str, lang: str = "ru",
                target_lang: str | None = None) -> str | None:
    """One AI tutor action on a single card. action ∈ {explain, simplify,
    example, analogy, translate}. Returns prose (in `lang`, or `target_lang` for
    translate); None if AI is unavailable or the action is unknown."""
    if not is_available():
        return None
    lang_name = {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")

    clean_answer = (answer or "").strip()
    first_line = clean_answer.split("\n")[0].strip()
    m = re.match(r"^([A-Za-zА-Яа-яЁё0-9]+)\s*[\)\.\:\-]\s*(.+)$", first_line)
    if m:
        clean_answer = m.group(2).strip()

    if action == "translate":
        target = (target_lang or "English").strip()
        prompt = f"""Переведи следующий вопрос и ответ на язык: {target}.
Сохрани смысл точно. Верни строго в формате:
Вопрос: <перевод вопроса>
Ответ: <перевод ответа>

ВОПРОС: {question}
ОТВЕТ: {clean_answer}"""
    else:
        instruction = _CARD_ACTION_INSTRUCTIONS.get(action)
        if instruction is None:
            return None
        prompt = f"""{instruction}
Пиши на {lang_name} языке. Отвечай 3-5 короткими предложениями. Без вступлений вроде "Конечно!" — сразу к сути.

ВОПРОС: {question}
ПРАВИЛЬНЫЙ ОТВЕТ: {clean_answer}

Результат:"""
    return _gemini_text(prompt, max_tokens=2000, temperature=0.5, label=f"card_{action}")


# ── Deck Tutor (Phase 2) ─────────────────────────────────────────────────────
# Deck-level learning guidance, grounded in REAL deck content + the learner's
# own spaced-repetition signal (weak cards / recent failures / retention). The
# caller (api_v1) assembles the grounding text from the DB; these functions only
# shape the prompt and parse structured JSON.

def _deck_lang_name(lang: str) -> str:
    return {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")


def _parse_ai_json(text: str | None):
    """Parse a Gemini JSON response (object or array). Tolerates ```json fences.
    Returns the decoded value, or None on failure."""
    if not text or not text.strip():
        return None
    try:
        return json.loads(text)
    except Exception:
        pass
    cleaned = text.strip()
    if cleaned.startswith("```"):
        cleaned = re.sub(r"^```[a-zA-Z]*\s*", "", cleaned)
        cleaned = cleaned.rstrip("`").strip()
    # Last resort: slice from the first bracket to its matching last bracket.
    for open_ch, close_ch in (("{", "}"), ("[", "]")):
        i, j = cleaned.find(open_ch), cleaned.rfind(close_ch)
        if 0 <= i < j:
            try:
                return json.loads(cleaned[i:j + 1])
            except Exception:
                continue
    return None


_MCQ_QUESTION_SCHEMA = {
    "type": "object",
    "properties": {
        "question": {"type": "string"},
        "options": {"type": "array", "items": {"type": "string"}},
        "correct_index": {"type": "integer"},
        "explanation": {"type": "string"},
    },
    "required": ["question", "options", "correct_index"],
}


def _valid_mcq(q) -> bool:
    if not isinstance(q, dict):
        return False
    opts = q.get("options")
    ci = q.get("correct_index")
    return (isinstance(q.get("question"), str) and q["question"].strip()
            and isinstance(opts, list) and len(opts) >= 2
            and isinstance(ci, int) and 0 <= ci < len(opts))


def deck_quiz(deck_context: str, weak_context: str = "", count: int = 5,
              lang: str = "ru") -> dict | None:
    """Adaptive multiple-choice quiz from the deck's cards, prioritising the
    learner's weak / recently-failed / low-retention cards. Returns
    {"questions": [{question, options, correct_index, explanation, focus}]} or
    None when AI is unavailable."""
    if not is_available() or not deck_context.strip():
        return None
    lang_name = _deck_lang_name(lang)
    focus_block = (
        "\nПРИОРИТЕТ. Студент испытывает трудности с этими карточками — "
        "составь вопросы В ПЕРВУЮ ОЧЕРЕДЬ по ним:\n" + weak_context + "\n"
        if weak_context.strip() else ""
    )
    prompt = f"""Ты — внимательный репетитор. На основе карточек колоды составь ровно {count} тренировочных вопросов с выбором ответа.
Правила: ровно 4 варианта на вопрос, один правильный (correct_index — его индекс с 0). Проверяй ПОНИМАНИЕ, а не дословную зубрёжку. Неправильные варианты должны быть правдоподобными. Не повторяй вопросы.
Для каждого вопроса поле focus: "weak" если он по трудной карточке выше, иначе "general".
{focus_block}
КАРТОЧКИ КОЛОДЫ (вопрос → ответ):
{deck_context}

Пиши на {lang_name} языке. Верни строго JSON."""
    schema = {
        "type": "object",
        "properties": {
            "questions": {
                "type": "array",
                "items": {
                    **_MCQ_QUESTION_SCHEMA,
                    "properties": {
                        **_MCQ_QUESTION_SCHEMA["properties"],
                        "focus": {"type": "string"},
                    },
                },
            },
        },
        "required": ["questions"],
    }
    try:
        text = _call_gemini(prompt, max_tokens=3500, response_schema=schema,
                            label="deck_quiz")
    except Exception as e:
        print(f"[deck_quiz] {type(e).__name__}: {e}")
        return None
    data = _parse_ai_json(text)
    if not isinstance(data, dict):
        return None
    questions = [q for q in (data.get("questions") or []) if _valid_mcq(q)]
    if not questions:
        return None
    return {"questions": questions}


def deck_mini_test(deck_context: str, count: int = 6, lang: str = "ru") -> dict | None:
    """Short balanced assessment from the deck's cards — a mix of easy / medium /
    hard MCQs across the whole deck (not weighted to weak cards). Returns
    {"questions": [{question, options, correct_index, difficulty, explanation}]}
    or None."""
    if not is_available() or not deck_context.strip():
        return None
    lang_name = _deck_lang_name(lang)
    prompt = f"""Ты — преподаватель, составляющий короткую проверочную работу по колоде. Составь ровно {count} вопросов с выбором ответа.
Сбалансируй сложность: примерно треть лёгких (узнавание факта), треть средних (применение), треть трудных (анализ/связь понятий). Покрой РАЗНЫЕ карточки колоды, а не одну тему.
Каждый вопрос: ровно 4 варианта, один правильный (correct_index с 0). Поле difficulty ∈ {{"easy","medium","hard"}}. Поле explanation — короткое пояснение правильного ответа.

КАРТОЧКИ КОЛОДЫ (вопрос → ответ):
{deck_context}

Пиши на {lang_name} языке. Верни строго JSON."""
    schema = {
        "type": "object",
        "properties": {
            "questions": {
                "type": "array",
                "items": {
                    **_MCQ_QUESTION_SCHEMA,
                    "properties": {
                        **_MCQ_QUESTION_SCHEMA["properties"],
                        "difficulty": {"type": "string"},
                    },
                },
            },
        },
        "required": ["questions"],
    }
    try:
        text = _call_gemini(prompt, max_tokens=3500, response_schema=schema,
                            label="deck_mini_test")
    except Exception as e:
        print(f"[deck_mini_test] {type(e).__name__}: {e}")
        return None
    data = _parse_ai_json(text)
    if not isinstance(data, dict):
        return None
    questions = []
    for q in (data.get("questions") or []):
        if _valid_mcq(q):
            diff = str(q.get("difficulty") or "medium").lower()
            q["difficulty"] = diff if diff in ("easy", "medium", "hard") else "medium"
            questions.append(q)
    if not questions:
        return None
    return {"questions": questions}


def deck_weak_areas(weak_context: str, retention_summary: str = "",
                    failures_context: str = "", lang: str = "ru") -> dict | None:
    """Diagnose the learner's weak areas for a deck from their real review
    signal. Returns {"weakest_topics":[{topic,why}], "weakest_cards":[{front,
    reason}], "focus_areas":[str], "summary":str} or None."""
    if not is_available() or not weak_context.strip():
        return None
    lang_name = _deck_lang_name(lang)
    retention_block = (f"\nУДЕРЖАНИЕ В ПАМЯТИ: {retention_summary}\n"
                       if retention_summary.strip() else "")
    failures_block = (f"\nНЕДАВНИЕ ОШИБКИ (последние неверные ответы):\n{failures_context}\n"
                      if failures_context.strip() else "")
    prompt = f"""Ты — репетитор, анализирующий прогресс студента по колоде. Используя реальные данные о его повторениях ниже, определи слабые места.
Не выдумывай: опирайся ТОЛЬКО на приведённые карточки и статистику.

ТРУДНЫЕ КАРТОЧКИ (с числом ошибок / низкой оценкой):
{weak_context}
{retention_block}{failures_block}
Сгруппируй трудные карточки в 2-4 тематические области (weakest_topics: topic + why). Перечисли 3-6 самых проблемных карточек (weakest_cards: front + краткая reason). Дай 2-4 конкретные рекомендации, на чём сосредоточиться (focus_areas). Добавь короткий ободряющий summary.

Пиши на {lang_name} языке. Верни строго JSON."""
    schema = {
        "type": "object",
        "properties": {
            "weakest_topics": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "topic": {"type": "string"},
                        "why": {"type": "string"},
                    },
                    "required": ["topic"],
                },
            },
            "weakest_cards": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "front": {"type": "string"},
                        "reason": {"type": "string"},
                    },
                    "required": ["front"],
                },
            },
            "focus_areas": {"type": "array", "items": {"type": "string"}},
            "summary": {"type": "string"},
        },
        "required": ["weakest_topics", "focus_areas"],
    }
    try:
        text = _call_gemini(prompt, max_tokens=2500, response_schema=schema,
                            label="deck_weak_areas")
    except Exception as e:
        print(f"[deck_weak_areas] {type(e).__name__}: {e}")
        return None
    data = _parse_ai_json(text)
    if not isinstance(data, dict):
        return None
    return {
        "weakest_topics": data.get("weakest_topics") or [],
        "weakest_cards": data.get("weakest_cards") or [],
        "focus_areas": data.get("focus_areas") or [],
        "summary": data.get("summary") or "",
    }


def deck_summary(deck_context: str, weak_context: str = "",
                 lang: str = "ru") -> dict | None:
    """Teach the deck like a teacher: key concepts, common mistakes, important
    facts — grounded in the deck's real cards. Returns {"key_concepts":[{title,
    explanation}], "common_mistakes":[str], "important_facts":[str]} or None."""
    if not is_available() or not deck_context.strip():
        return None
    lang_name = _deck_lang_name(lang)
    weak_block = (
        "\nСтудент чаще всего ошибается в этих карточках — учти это в "
        "common_mistakes:\n" + weak_context + "\n" if weak_context.strip() else ""
    )
    prompt = f"""Ты — преподаватель, который объясняет тему колоды студенту перед экзаменом. На основе карточек ниже подготовь учебное резюме.
key_concepts: 3-6 ключевых понятий (title + понятное explanation в 1-3 предложения, объясняй как учитель, связывай идеи). common_mistakes: 3-5 типичных ошибок/заблуждений по этой теме. important_facts: 3-6 фактов, которые точно нужно запомнить.
Опирайся ТОЛЬКО на содержание карточек, не добавляй посторонних тем.
{weak_block}
КАРТОЧКИ КОЛОДЫ (вопрос → ответ):
{deck_context}

Пиши на {lang_name} языке. Верни строго JSON."""
    schema = {
        "type": "object",
        "properties": {
            "key_concepts": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "title": {"type": "string"},
                        "explanation": {"type": "string"},
                    },
                    "required": ["title", "explanation"],
                },
            },
            "common_mistakes": {"type": "array", "items": {"type": "string"}},
            "important_facts": {"type": "array", "items": {"type": "string"}},
        },
        "required": ["key_concepts"],
    }
    try:
        text = _call_gemini(prompt, max_tokens=2500, response_schema=schema,
                            label="deck_summary")
    except Exception as e:
        print(f"[deck_summary] {type(e).__name__}: {e}")
        return None
    data = _parse_ai_json(text)
    if not isinstance(data, dict) or not data.get("key_concepts"):
        return None
    return {
        "key_concepts": data.get("key_concepts") or [],
        "common_mistakes": data.get("common_mistakes") or [],
        "important_facts": data.get("important_facts") or [],
    }


def diagnose_mistake(question: str, chosen: str, correct: str, lang: str = "ru") -> dict | None:
    """AI-diagnostika konkretnoy oshibki studenta.

    V otlichie ot explain_question (kotoryy prosto ob'yasnyaet pravil'nyy otvet),
    eta funktsiya VIDIT, chto imenno vybral student, i ob'yasnyaet pochemu ego
    vybor neveren + nazyvaet veroyatnoye zabluzhdeniye. Eto prevrashchaet razbor
    oshibok v personalizirovannogo repetitora, a ne v spravochnik.

    Vozvrashchaet dict {why_wrong, why_correct, misconception, tip} ili None.
    """
    if not is_available():
        return None
    lang_name = {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")

    def _clean(text):
        first = (text or "").strip().split("\n")[0].strip()
        m = re.match(r"^([A-Za-zА-Яа-яЁё0-9]+)\s*[\)\.\:\-]\s*(.+)$", first)
        return m.group(2).strip() if m else first

    chosen_c = _clean(chosen)
    correct_c = _clean(correct)

    prompt = f"""Студент ответил на вопрос теста НЕВЕРНО. Разбери его конкретную ошибку как доброжелательный репетитор. Пиши на {lang_name} языке.

ВОПРОС: {question}
ОТВЕТ СТУДЕНТА (неверный): {chosen_c}
ПРАВИЛЬНЫЙ ОТВЕТ: {correct_c}

Верни ТОЛЬКО JSON-объект (без markdown, без ```):
{{"why_wrong": "1-2 предложения: почему именно ВЫБРАННЫЙ студентом вариант неверен (обращайся на «ты»)",
  "why_correct": "1-2 предложения: почему правильный ответ верен",
  "misconception": "короткая формулировка вероятного заблуждения, которое привело к ошибке (до 15 слов)",
  "tip": "короткий практический совет/мнемоника, как не ошибиться снова (до 15 слов)"}}

Говори по существу, без вступлений. Если ответ студента пуст — считай, что он не ответил."""

    try:
        raw = _call_gemini(prompt, max_tokens=2000)
    except Exception as e:
        print(f"[AI diagnose] {type(e).__name__}: {e}")
        return None
    if not raw:
        return None
    cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
    try:
        data = json.loads(cleaned)
    except Exception:
        # Model ne vernula chistyy JSON — otdadim hot' chto-to v why_wrong.
        return {"why_wrong": raw.strip()[:600], "why_correct": "", "misconception": "", "tip": ""}
    if not isinstance(data, dict):
        return None
    return {
        "why_wrong": str(data.get("why_wrong") or "").strip(),
        "why_correct": str(data.get("why_correct") or "").strip(),
        "misconception": str(data.get("misconception") or "").strip(),
        "tip": str(data.get("tip") or "").strip(),
    }


def generate_followup(question: str, correct: str, misconception: str = "", lang: str = "ru") -> dict | None:
    """Generiruet NOVYY trenirovochnyy vopros na tu zhe temu, chto i tot, gde
    student oshibsya — chtoby srazu zakrepit' ponimanie (cikl 'oshibsya → ponyal
    → zakrepil'). Esli izvestno zabluzhdenie (iz diagnose_mistake), tselim
    vopros imenno v nego.

    Vozvrashchaet {question, options:[str,...], correct_index, explanation} ili None.
    """
    if not is_available():
        return None
    lang_name = {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")
    mis_block = f"\nТипичное заблуждение, которое надо проверить: {misconception}" if misconception else ""

    prompt = f"""Студент ошибся в вопросе теста. Составь ОДИН новый похожий вопрос с выбором ответа на ту же тему, чтобы закрепить понимание. Вопрос должен проверять ту же концепцию, но не быть дословной копией. Пиши на {lang_name} языке.

ИСХОДНЫЙ ВОПРОС: {question}
ПРАВИЛЬНЫЙ ОТВЕТ на исходный: {correct}{mis_block}

Верни ТОЛЬКО JSON-объект (без markdown, без ```):
{{"question": "текст нового вопроса",
  "options": ["вариант 1", "вариант 2", "вариант 3", "вариант 4"],
  "correct_index": 0,
  "explanation": "1-2 предложения: почему верный вариант правильный"}}

Ровно 4 варианта. correct_index — индекс (0-3) правильного варианта. Варианты короткие и правдоподобные."""

    try:
        raw = _call_gemini(prompt, max_tokens=2000)
    except Exception as e:
        print(f"[AI followup] {type(e).__name__}: {e}")
        return None
    if not raw:
        return None
    cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
    try:
        data = json.loads(cleaned)
    except Exception:
        return None
    if not isinstance(data, dict):
        return None
    opts = data.get("options")
    if not isinstance(opts, list) or len(opts) < 2:
        return None
    opts = [str(o).strip() for o in opts if str(o).strip()][:6]
    try:
        ci = int(data.get("correct_index"))
    except (TypeError, ValueError):
        return None
    if not (0 <= ci < len(opts)):
        return None
    q = str(data.get("question") or "").strip()
    if not q:
        return None
    return {
        "question": q,
        "options": opts,
        "correct_index": ci,
        "explanation": str(data.get("explanation") or "").strip(),
    }


def find_answers(question: str, deck_context: str = "", lang: str = "ru") -> dict | None:
    """AI-pomoshnik: otvechaet na svobodnyy vopros studenta s kratkimi key points.
    Ispol'zuyet tu zhe infrastrukturu (_call_gemini), chto i generatsiya kart —
    tol'ko prosit strukturirovannyy JSON vmesto massiva kartochek."""
    if not is_available():
        return None
    lang_name = {"ru": "русском", "en": "English", "uz": "узбекском"}.get(lang, "русском")
    context_block = f"\n\nКонтекст из колоды пользователя (используй, если уместно):\n{deck_context}" if deck_context else ""

    prompt = f"""Студент задал вопрос. Дай ясный, полезный ответ на {lang_name} языке.

ВОПРОС: {question}{context_block}

Верни ТОЛЬКО JSON-объект:
{{"explanation": "развёрнутый ответ в 3-6 предложениях, по существу, без вступлений",
  "key_points": ["короткий ключевой тезис 1", "короткий ключевой тезис 2", "..."]}}

key_points — это 2-5 коротких (до 12 слов) тезисов, которые стоит запомнить."""

    try:
        raw = _call_gemini(prompt, max_tokens=2000)
    except Exception as e:
        print(f"[AI find-answers] {type(e).__name__}: {e}")
        return None
    if not raw:
        return None
    cleaned = re.sub(r"^```(?:json)?\s*|\s*```$", "", raw.strip(), flags=re.MULTILINE)
    try:
        data = json.loads(cleaned)
    except Exception:
        m = re.search(r"\{.*\}", cleaned, re.DOTALL)
        if not m:
            return None
        try:
            data = json.loads(m.group(0))
        except Exception:
            return None
    if not isinstance(data, dict):
        return None
    explanation = str(data.get("explanation") or "").strip()
    key_points = data.get("key_points") or []
    if not isinstance(key_points, list):
        key_points = []
    key_points = [str(p).strip() for p in key_points if str(p or "").strip()]
    if not explanation:
        return None
    return {"explanation": explanation, "key_points": key_points}


def _budget_history(history: list, max_chars: int = 8000) -> list:
    """Keep the most recent messages whose combined length fits max_chars
    (a cheap token proxy), preserving order. Bounds tutor context cost on long
    conversations without an extra summarisation call."""
    out = []
    total = 0
    for h in reversed(history or []):
        c = (h.get("content") or "")
        if total + len(c) > max_chars and out:
            break
        total += len(c)
        out.append(h)
    return list(reversed(out))


def _build_tutor_prompt(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru", learner_context: str = "") -> tuple[str, list]:
    """Stroit system prompt + soobshcheniya v formate ChatML."""
    history = history or []

    # Opredelyaem yazyk otveta
    lang_instruction = {
        "ru": "Отвечай на русском языке.",
        "en": "Reply in English.",
        "uz": "O'zbek tilida javob ber.",
    }.get(lang, "Отвечай на русском языке.")

    system_prompt = f"""Ты — умный AI-репетитор внутри платформы QuizAIPro (quizaipro.com) — AI-первой платформы для учёбы с карточками, тестами и персональным репетитором.

{lang_instruction}

Отвечай естественно и полно — как умный друг, который хорошо разбирается в теме. Если вопрос требует подробного объяснения — объясни подробно, если короткого — отвечай кратко. Используй markdown для структурирования (списки, **жирный**, заголовки, `код`) когда это улучшает читаемость. Не начинай с "Конечно!" или похожих вступлений — сразу к делу.

---

## ⛔ СТРОГИЕ ОГРАНИЧЕНИЯ (ОБЯЗАТЕЛЬНО СОБЛЮДАТЬ):

Ты — ТОЛЬКО образовательный репетитор. Ты НЕ отвечаешь на вопросы вне учёбы.

**Запрещённые темы — вежливо откажи и объясни что ты только репетитор:**
- Криптовалюты, биткоин, курсы валют, инвестиции, трейдинг, акции, форекс
- Ставки, азартные игры, лотереи
- Политика, новости, текущие события
- Медицинские диагнозы и лечение (можно объяснять биологию/анатомию как учебный предмет)
- Юридические консультации (можно объяснять право как учебный предмет)
- Развлечения, фильмы, музыка, игры (не связанные с учёбой)
- Личные советы по жизни, отношениям, работе

**Если спрашивают о запрещённой теме:**
Скажи: "Я — образовательный репетитор и помогаю только с учёбой. По этой теме помочь не могу. Могу помочь с [предложи учебную тему]?"

---

## Что ты умеешь как репетитор:
- Объяснять учебные темы: математика, история, языки, программирование, биология, физика, химия, право (как предмет), экономика (как предмет), география, литература и другие школьные/университетские дисциплины
- Помогать готовиться к экзаменам и тестам
- Разбирать ошибки и непонятные моменты
- Составлять планы обучения
- Отвечать на вопросы по карточкам и темам пользователя
- Давать примеры, аналогии, мнемоники для запоминания
- Проверять знания — задавать вопросы и оценивать ответы

---

## Платформа QuizAIPro (кратко — для вопросов «как это сделать на сайте»):
Колоды карточек; изучение Flashcards (SM-2, интервальное повторение); тесты по колоде (`/deck/ID/test`); Match; AI-генератор карточек (`/ai`); импорт PDF/DOCX/изображений (`/import`); дуэли (`/duels`), турниры, Live-тесты в стиле Kahoot; маркетплейс публичных колод (`/marketplace`); статистика (`/stats`), цели (`/goals`), достижения и XP (`/achievements`), стрик, ежедневная цель; друзья/чаты/группы; настройки (`/settings`) — язык RU/EN/UZ, тёмная тема.

Если спрашивают «как сделать X» — кратко объясни шаги и назови нужный раздел (тест → `/ai` или `/deck/ID/test`; импорт PDF → `/import`; достижения → `/achievements`; дуэль → `/duels`, кнопка «Вызвать»). НЕ выдумывай несуществующие функции; не уверен в точном пути — опиши действие словами. Если пользователь хочет изучить тему — объясни, составь план, задай проверочные вопросы."""

    if deck_context:
        system_prompt += (
            "\n\n---\n\n## Релевантные материалы пользователя (карточки и документы)\n"
            "Это самые близкие к вопросу фрагменты из колод и загруженных документов "
            "пользователя. Считай их источником истины: отвечай прежде всего на их "
            "основе и ссылайся на источники ТОЧНО так, как они помечены в квадратных "
            "скобках ниже — используй ту же метку и тот же номер (не переводи и не меняй "
            "метку). Если ответа в этих материалах нет — честно скажи об этом и ответь "
            "общими знаниями.\n\n"
            f"{deck_context[:2500]}"
        )

    # Learner model (RAG over the user's spaced-repetition data): the cards they
    # struggle with most. Lets the tutor personalise — reference weak topics,
    # suggest what to review — instead of being a generic chatbot.
    if learner_context:
        system_prompt += (
            "\n\n---\n\n## Слабые места этого ученика (по интервальному повторению):\n"
            f"{learner_context[:1500]}\n"
            "Учитывай это: если тема релевантна — мягко свяжи объяснение с этими "
            "пробелами и предложи повторить их. Не перечисляй их механически."
        )

    # History budgeting: keep the most recent turns that fit a character budget
    # (proxy for tokens) instead of a flat -20, so long chats don't blow up the
    # context cost. Older turns are summarised by a one-line topic anchor (the
    # first user message) so continuity isn't lost.
    windowed = _budget_history(history, max_chars=8000)
    if len(windowed) < len(history):
        first_user = next((h["content"] for h in history if h["role"] == "user"), None)
        if first_user:
            system_prompt += (
                f"\n\nКонтекст (ранее в диалоге): пользователь начал с «{first_user[:400]}». "
                "Учитывай эту тему, но опирайся на последние сообщения ниже."
            )

    messages = []
    for h in windowed:
        role = "user" if h["role"] == "user" else "assistant"
        messages.append({"role": role, "content": h["content"]})
    messages.append({"role": "user", "content": user_message})

    return system_prompt, messages


def _deepseek_chat_call(system_prompt: str, messages: list, max_tokens: int = 800, temperature: float = 0.6, stream: bool = False, timeout: int = 60):
    """Vyzyvayet DeepSeek API (OpenAI-sovmestimyy format).

    Esli stream=False -> vozvrashchaet str (text) ili None.
    Esli stream=True  -> vozvrashchaet generator strok-chunkov.
    """
    key = _deepseek_key()
    if not key:
        return None if not stream else iter(())

    body = {
        "model": DEEPSEEK_MODEL,
        "messages": [{"role": "system", "content": system_prompt}, *messages],
        "max_tokens": max_tokens,
        "temperature": temperature,
        "stream": stream,
    }
    data = json.dumps(body).encode("utf-8")
    req = urlreq.Request(
        DEEPSEEK_API_URL,
        data=data,
        method="POST",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {key}",
            "Accept": "text/event-stream" if stream else "application/json",
        },
    )

    if not stream:
        try:
            with urlreq.urlopen(req, timeout=timeout) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            text = payload["choices"][0]["message"]["content"]
            return text.strip() if text else None
        except urlerr.HTTPError as e:
            err_body = ""
            try:
                err_body = e.read().decode("utf-8", errors="replace")[:300]
            except Exception:
                pass
            print(f"[DeepSeek] HTTP {e.code}: {err_body}")
            return None
        except Exception as e:
            print(f"[DeepSeek] {type(e).__name__}: {e}")
            return None

    # Streaming rezhim — chitaem SSE-chunki
    def _gen():
        try:
            resp = urlreq.urlopen(req, timeout=timeout)
            for raw_line in resp:
                line = raw_line.decode("utf-8", errors="replace").strip()
                if not line or not line.startswith("data:"):
                    continue
                payload_str = line[5:].strip()
                if payload_str == "[DONE]":
                    break
                try:
                    obj = json.loads(payload_str)
                    delta = obj.get("choices", [{}])[0].get("delta", {})
                    chunk = delta.get("content")
                    if chunk:
                        yield chunk
                except Exception:
                    continue
        except urlerr.HTTPError as e:
            err_body = ""
            try:
                err_body = e.read().decode("utf-8", errors="replace")[:300]
            except Exception:
                pass
            print(f"[DeepSeek stream] HTTP {e.code}: {err_body}")
        except Exception as e:
            print(f"[DeepSeek stream] {type(e).__name__}: {e}")

    return _gen()


def _gemini_stream(full_prompt: str, max_tokens: int = 4000, temperature: float = 0.7):
    """Streams gemini-3.5-flash output token-by-token via streamGenerateContent
    (SSE). Tries Vertex AI first (Cloud credits), Developer key as fallback.
    Yields text deltas; silent (no yields) on failure."""
    body = {
        "contents": [{"role": "user", "parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "temperature": temperature,
            "maxOutputTokens": max_tokens,
            # Cap "thinking" so it doesn't eat the visible-answer budget.
            "thinkingConfig": {"thinkingBudget": 1024},
        },
    }
    data = json.dumps(body).encode("utf-8")

    endpoints = []
    if vertex_enabled():
        tok = _vertex_token()
        if tok:
            endpoints.append((f"{_vertex_url(_GEMINI_MODEL, stream=True)}?alt=sse",
                              {"Authorization": f"Bearer {tok}", "Content-Type": "application/json"}))
    key = _key()
    if key:
        endpoints.append((f"{API_URL_STREAM}?alt=sse&key={key}",
                          {"Content-Type": "application/json"}))

    for url, headers in endpoints:
        yielded_any = False
        try:
            req = urlreq.Request(url, data=data, method="POST", headers=headers)
            with urlreq.urlopen(req, timeout=90) as resp:
                for raw in resp:
                    line = raw.decode("utf-8", errors="replace").strip()
                    if not line.startswith("data:"):
                        continue
                    payload = line[5:].strip()
                    if not payload or payload == "[DONE]":
                        continue
                    try:
                        obj = json.loads(payload)
                        text = obj["candidates"][0]["content"]["parts"][0]["text"]
                        if text:
                            yielded_any = True
                            yield text
                    except (KeyError, IndexError, TypeError, json.JSONDecodeError):
                        continue
            return  # stream finished cleanly on this endpoint
        except Exception as e:
            print(f"[AI tutor stream] {type(e).__name__}: {e}")
            if yielded_any:
                return  # already streamed from this endpoint — don't duplicate
            # otherwise fall through to the next endpoint


def chat_tutor(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru", provider: str = "", learner_context: str = "") -> str | None:
    """AI-tutor: chat-bot kotoryy znayet o tekuschey kolode i mozhet podrobno ob'yasnyat'.

    provider: "" (avto: DeepSeek -> Gemini fallback), "deepseek", "gemini" — yavnyy vybor.
    """
    system_prompt, messages = _build_tutor_prompt(user_message, deck_context, history, lang, learner_context)

    # DeepSeek only ever runs when it's actually enabled (is_deepseek_available).
    # While it's disabled the whole app is on gemini-3.5-flash, so even an
    # explicit provider="deepseek" (e.g. a stale saved preference) routes to
    # Gemini instead of silently calling a turned-off provider.
    use_deepseek = is_deepseek_available() and provider != "gemini"
    use_gemini_only = provider == "gemini"

    # 1. DeepSeek pervym (esli ne forced gemini)
    if use_deepseek and not use_gemini_only:
        text = _deepseek_chat_call(system_prompt, messages, max_tokens=4000, temperature=0.7)
        if text:
            return text
        if provider == "deepseek":
            # Yavno vybran DeepSeek — ne fallback na Gemini
            return None
        print("[AI tutor] DeepSeek failed, falling back to Gemini")

    # 2. Gemini fallback / yavno vybran
    if not is_available():
        return None

    full_prompt_parts = [system_prompt, "\n\nИстория диалога:"]
    for m in messages[:-1]:
        role = "Студент" if m["role"] == "user" else "Репетитор"
        full_prompt_parts.append(f"{role}: {m['content']}")
    full_prompt_parts.append(f"Студент: {messages[-1]['content']}")
    full_prompt_parts.append("Репетитор:")
    full_prompt = "\n".join(full_prompt_parts)

    body = {
        # Plain-text reply (no responseMimeType). role required by Vertex.
        "contents": [{"role": "user", "parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "temperature": 0.7,
            # gemini-3.5-flash counts "thinking" against maxOutputTokens, so
            # unbounded thinking truncated answers. Cap thinking (keeps reasoning
            # quality) and give the visible answer plenty of room.
            "maxOutputTokens": 8000,
            "thinkingConfig": {"thinkingBudget": 1024},
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Vertex first (Cloud credits), Developer key fallback.
    for model, url, headers in _gemini_endpoints():
        try:
            req = urlreq.Request(url, data=data, method="POST", headers=headers)
            with urlreq.urlopen(req, timeout=60) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            cand = (payload.get("candidates") or [{}])[0]
            txt = (cand.get("content", {}).get("parts", [{}])[0].get("text") or "").strip()
            if txt:
                return txt
        except urlerr.HTTPError as e:
            print(f"[AI tutor Gemini] {model} HTTP {e.code} — fallback")
            continue
        except Exception as e:
            print(f"[AI tutor Gemini] {model} {type(e).__name__}: {e}")
            continue
    return None


# === Agentic tutor: function calling ========================================
# The model can call tools: generate a practice quiz, create a deck, or open an
# existing deck. Quiz is handled inside ai_gen (generation only); create_deck /
# open_deck need DB + user, so the route passes a tool_executor callback.
# Gated by intent so normal chat keeps token-streaming.

_TUTOR_TOOLS = [{
    "functionDeclarations": [
        {
            "name": "make_practice_quiz",
            "description": ("Generate a short practice quiz for the student on a "
                            "topic. Call when the student asks to be tested, "
                            "quizzed, checked, or to practice."),
            "parameters": {
                "type": "OBJECT",
                "properties": {
                    "topic": {"type": "STRING", "description": "Study topic"},
                    "count": {"type": "INTEGER", "description": "Questions (3-7)"},
                },
                "required": ["topic"],
            },
        },
        {
            "name": "create_deck",
            "description": ("Create a new flashcard deck for the student and fill "
                            "it with AI-generated cards on a topic. Call when the "
                            "student asks to create/make a deck or a set of cards."),
            "parameters": {
                "type": "OBJECT",
                "properties": {
                    "name": {"type": "STRING", "description": "Deck name"},
                    "topic": {"type": "STRING", "description": "Topic for the cards"},
                    "count": {"type": "INTEGER", "description": "Number of cards (5-20)"},
                },
                "required": ["topic"],
            },
        },
        {
            "name": "open_deck",
            "description": ("Find and open one of the student's existing decks by "
                            "name. Call when the student asks to open/show a deck."),
            "parameters": {
                "type": "OBJECT",
                "properties": {
                    "query": {"type": "STRING", "description": "Deck name or keywords"},
                },
                "required": ["query"],
            },
        },
    ]
}]

_TOOL_INTENT = re.compile(
    r"(провер|тест|викторин|опрос|испыта|потренир|зада(й|ть).*вопрос|"
    r"созда(й|ть).*(колод|карточ)|сдела(й|ть).*(колод|карточ)|"
    r"откро?й.*колод|покажи.*колод|"
    r"quiz|test me|check me|practice|qiz|sina|"
    r"creat.*(deck|card)|make.*(deck|card)|open.*deck|show.*deck)",
    re.IGNORECASE)

_QUIZ_INTRO = {
    "ru": "Лови мини-тест для проверки 👇 Сначала ответь сам, ответы — ниже.",
    "en": "Here's a quick practice quiz 👇 Try first, answers are below.",
    "uz": "Mana mashq testi 👇 Avval o'zingiz urinib ko'ring, javoblar pastda.",
}


def _format_quiz(cards: list, lang: str) -> str:
    """Client-agnostic markdown (renders in web AND Flutter): all questions
    first, then an answers block so the student can try before peeking."""
    intro = _QUIZ_INTRO.get(lang, _QUIZ_INTRO["ru"])
    ans_hdr = {"ru": "Ответы", "en": "Answers", "uz": "Javoblar"}.get(lang, "Ответы")
    qs = [intro, ""]
    ans = [f"---", f"**{ans_hdr}:**"]
    for i, c in enumerate(cards, 1):
        qs.append(f"**{i}.** {c.get('front','').strip()}")
        ans.append(f"**{i}.** {c.get('back','').strip()}")
    return "\n".join(qs + [""] + ans).strip()


def _gemini_generate_raw(system_prompt: str, contents: list, tools: list = None,
                         max_tokens: int = 4000, label: str = "tutor_tool"):
    """Single non-stream generateContent with systemInstruction + optional tools.
    Returns the first candidate dict (to inspect functionCall), or None."""
    body = {
        "systemInstruction": {"parts": [{"text": system_prompt}]},
        "contents": contents,
        "generationConfig": {"temperature": 0.7, "maxOutputTokens": max_tokens},
    }
    if tools:
        body["tools"] = tools
    data = json.dumps(body).encode("utf-8")
    for model, url, headers in _gemini_endpoints():
        t0 = time.time()
        try:
            req = urlreq.Request(url, data=data, method="POST", headers=headers)
            with urlreq.urlopen(req, timeout=60) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            _log_metric(label=label, model=model, latency_ms=int((time.time()-t0)*1000),
                        ok=True, usage=payload.get("usageMetadata") or {})
            return (payload.get("candidates") or [{}])[0]
        except Exception as e:
            print(f"[AI tutor tool] {model} {type(e).__name__}: {e}")
            continue
    return None


def _agentic_reply(system_prompt: str, messages: list, lang: str, tool_executor=None):
    """If the model calls a tool, run it and return the reply text. quiz is run
    internally; create_deck/open_deck are delegated to tool_executor(name, args)
    -> str (provided by the route, which has DB + user). Returns None to fall
    back to the normal chat flow."""
    contents = []
    for m in messages:
        role = "model" if m["role"] == "assistant" else "user"
        contents.append({"role": role, "parts": [{"text": m["content"]}]})

    cand = _gemini_generate_raw(system_prompt, contents, tools=_TUTOR_TOOLS, label="tutor_tool")
    if not cand:
        return None
    parts = cand.get("content", {}).get("parts", [])
    fc = next((p["functionCall"] for p in parts if isinstance(p, dict) and "functionCall" in p), None)
    if not fc:
        return None  # model chose to just answer → normal flow handles it
    name = fc.get("name")
    args = fc.get("args") or {}

    if name == "make_practice_quiz":
        topic = (args.get("topic") or "").strip()
        if not topic:
            return None
        try:
            count = max(3, min(7, int(args.get("count") or 5)))
        except (TypeError, ValueError):
            count = 5
        try:
            cards = generate_from_topic(topic, count=count, output_lang=lang)[:count]
        except Exception as e:
            print(f"[AI tutor tool] quiz gen failed: {e}")
            return None
        return _format_quiz(cards, lang) if cards else None

    if name in ("create_deck", "open_deck"):
        if tool_executor is None:
            return None  # route didn't provide DB executor → normal flow
        try:
            return tool_executor(name, args)
        except Exception as e:
            print(f"[AI tutor tool] {name} executor failed: {e}")
            return None

    return None


def chat_tutor_stream(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru", provider: str = "", learner_context: str = "", tool_executor=None):
    """Streaming-versiya tutor'a. Yield-it text chunki po mere generatsii.

    provider: "" (avto), "deepseek" (tolko DeepSeek), "gemini" (tolko Gemini).
    tool_executor: optional callback(name, args)->str for DB tools (create_deck,
    open_deck) provided by the route.
    """
    system_prompt, messages = _build_tutor_prompt(user_message, deck_context, history, lang, learner_context)

    # Agentic path: if the student seems to want a tool (quiz / create / open a
    # deck), let the model call it and yield the result instead of a plain
    # answer. Gated by intent so normal chat keeps token-streaming.
    if vertex_enabled() and _TOOL_INTENT.search(user_message or ""):
        try:
            tool_reply = _agentic_reply(system_prompt, messages, lang, tool_executor)
        except Exception as e:
            print(f"[AI tutor agentic] {type(e).__name__}: {e}")
            tool_reply = None
        if tool_reply:
            yield tool_reply
            return

    # DeepSeek only ever runs when it's actually enabled (is_deepseek_available).
    # While it's disabled the whole app is on gemini-3.5-flash, so even an
    # explicit provider="deepseek" (e.g. a stale saved preference) routes to
    # Gemini instead of silently calling a turned-off provider.
    use_deepseek = is_deepseek_available() and provider != "gemini"
    use_gemini_only = provider == "gemini"

    # 1. DeepSeek streaming
    if use_deepseek and not use_gemini_only:
        gen = _deepseek_chat_call(system_prompt, messages, max_tokens=4000, temperature=0.7, stream=True)
        any_chunk = False
        try:
            for chunk in gen:
                any_chunk = True
                yield chunk
        except Exception as e:
            print(f"[AI tutor stream] DeepSeek gen error: {e}")
        if any_chunk:
            return
        if provider == "deepseek":
            return  # Yavno DeepSeek — ne fallback
        print("[AI tutor stream] DeepSeek empty, fallback to Gemini")

    # 2. Gemini streaming (gemini-3.5-flash) — token-by-token via SSE.
    full_prompt_parts = [system_prompt, "\n\nИстория диалога:"]
    for m in messages[:-1]:
        role = "Студент" if m["role"] == "user" else "Репетитор"
        full_prompt_parts.append(f"{role}: {m['content']}")
    full_prompt_parts.append(f"Студент: {messages[-1]['content']}")
    full_prompt_parts.append("Репетитор:")
    full_prompt = "\n".join(full_prompt_parts)

    any_chunk = False
    try:
        for chunk in _gemini_stream(full_prompt, max_tokens=8000, temperature=0.7):
            any_chunk = True
            yield chunk
    except Exception as e:
        # A crash mid-stream (e.g. SSE blocked by the host proxy) must not bubble
        # up as a bare error — fall through to the non-streaming path below.
        print(f"[AI tutor stream] gemini stream crashed: {type(e).__name__}: {e}")

    # Last-resort: non-streaming (with retries — more proxy-friendly) if streaming
    # yielded nothing.
    if not any_chunk:
        text = None
        try:
            text = chat_tutor(user_message, deck_context, history, lang, provider="gemini")
        except Exception as e:
            print(f"[AI tutor stream] non-stream fallback crashed: {type(e).__name__}: {e}")
        if text:
            yield text
        else:
            # Empty even non-streaming — usually a SAFETY block or overload.
            # Give the user a clear, polite message instead of silence.
            yield {
                "ru": "Не получилось ответить на этот вопрос. Попробуй переформулировать "
                      "или задай учебный вопрос — я помогу разобраться с темой.",
                "en": "I couldn't answer that one. Try rephrasing, or ask a study "
                      "question and I'll help you work through it.",
                "uz": "Bu savolga javob bera olmadim. Boshqacha yozing yoki o'quv "
                      "savol bering — mavzuni tushuntiraman.",
            }.get(lang, "Не получилось ответить на этот вопрос. Попробуй переформулировать.")
