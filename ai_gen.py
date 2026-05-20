# -*- coding: utf-8 -*-
"""AI-generatsia voprosov cherez Gemini (Google AI Studio).
Besplatnyy tier: 1500 zaprosov/sutki.
Klyuch: gemini_key.txt v korne proekta.
"""
import json
import os
import re
from pathlib import Path
from urllib import request as urlreq
from urllib import error as urlerr

BASE = Path(__file__).resolve().parent
KEY_FILE = BASE / "gemini_key.txt"

API_URL = ("https://generativelanguage.googleapis.com/v1beta/models/"
           "gemini-2.0-flash-lite:generateContent")
# Fallback model esli osnovnaya zabita (rate limit)
API_URL_FALLBACK = ("https://generativelanguage.googleapis.com/v1beta/models/"
                    "gemini-2.5-flash:generateContent")


def _key():
    # 1. ENV variable (production na Railway)
    env_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if env_key:
        return env_key
    # 2. Lokal'nyy fayl (razrabotka)
    if KEY_FILE.exists():
        return KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


def is_available() -> bool:
    return bool(_key())


def _call_gemini(prompt: str, max_tokens: int = 4000) -> str | None:
    key = _key()
    if not key:
        return None
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.5,
            "maxOutputTokens": max_tokens,
            "responseMimeType": "application/json",
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Probuyem snachala osnovnuyu model', potom fallback
    last_error = None
    for url_template in [API_URL, API_URL_FALLBACK]:
        url = f"{url_template}?key={key}"
        req = urlreq.Request(url, data=data, method="POST",
                             headers={"Content-Type": "application/json"})
        try:
            with urlreq.urlopen(req, timeout=90) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            # Proverka chto otvet validnyy
            try:
                text = payload["candidates"][0]["content"]["parts"][0]["text"]
                if text and text.strip():
                    return text
            except (KeyError, IndexError, TypeError) as e:
                # Mozhet byt' "finishReason": "SAFETY" ili pustoy otvet
                last_error = f"Empty response: {payload}"
                print(f"[AI] {last_error[:300]}")
                continue
        except urlerr.HTTPError as e:
            err_body = ""
            try:
                err_body = e.read().decode("utf-8", errors="replace")[:300]
            except Exception:
                pass
            last_error = f"HTTP {e.code} ({url_template.split('/')[-1].split(':')[0]}): {err_body}"
            print(f"[AI] {last_error}")
            # Esli 429 (rate limit) ili 503 (overload) — probuyem fallback
            if e.code in (429, 503, 500, 502, 504):
                continue
            # Drugie oshibki — vykhodim
            return None
        except Exception as e:
            last_error = f"{type(e).__name__}: {e}"
            print(f"[AI] {last_error}")
            continue

    # Vse modeli zafailili
    if last_error:
        # Probrasyvayem oshibku v vyzyvayushchiy kod chtoby flash pokazal pol'zovatelyu
        raise RuntimeError(f"Gemini API недоступен: {last_error[:200]}")
    return None


def _parse_cards_json(text: str) -> list[dict]:
    """Razbiraet otvet AI v list[{front, back, note}]."""
    if not text:
        return []
    # Snimaem markdown-blocks
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
    try:
        data = json.loads(text)
    except Exception:
        # Probuyem nayti JSON-array v tekste
        m = re.search(r"\[.*\]", text, re.DOTALL)
        if not m:
            return []
        try:
            data = json.loads(m.group(0))
        except Exception:
            return []
    if isinstance(data, dict) and "questions" in data:
        data = data["questions"]
    if not isinstance(data, list):
        return []
    out = []
    for item in data:
        if not isinstance(item, dict):
            continue
        q = (item.get("question") or item.get("front") or item.get("q") or "").strip()
        a = (item.get("answer") or item.get("back") or item.get("a") or "").strip()
        n = (item.get("note") or item.get("explanation") or item.get("explain") or "").strip()
        if q and a:
            out.append({"front": q, "back": a, "note": n})
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

    raw = _call_gemini(prompt, max_tokens=8000)
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
                       quality: bool = False) -> list[dict]:
    """Generiruyet voprosy iz proizvol'nogo teksta.
    quality=True — dopolnitelnyy proxod cherez AI-kritika (medlenno, no luchshe)."""
    lang_map = {
        "ru": "русском", "en": "English", "uz": "oʻzbek tilida",
    }
    lang_name = lang_map.get(lang, "русском")

    prompt = f"""Ty - generator obuchayushchih voprosov dlya zapominaniya.

Iz sleduyushchego TEKSTA sgeneriruy rovno {count} voprosov dlya samoproverki.
Yazyk voprosov i otvetov: {lang_name}.

Trebovaniya:
- Voprosy raznoobraznye (faktologicheskie, terminy, opredeleniya, primery)
- Otvety korotkie i tochnye (1-3 predlozheniya max)
- "note" - dop. obyasneniye ili kontekst (1 predlozhenie)
- Ne pridumyvay faktov - tol'ko iz teksta

Vyhod TOL'KO JSON-arrey:
[{{"question":"...","answer":"...","note":"..."}}, ...]

TEKST:
{text[:8000]}"""

    raw = _call_gemini(prompt, max_tokens=8000)
    cards = _parse_cards_json(raw or "")
    if quality and cards:
        cards = _critique_and_improve(cards, lang=lang)
    return cards


def generate_from_topic(topic: str, count: int = 10, lang: str = "ru",
                          difficulty: str = "medium",
                          quality: bool = False) -> list[dict]:
    """Generiruyet voprosy po teme.
    quality=True — dopolnitelnyy proxod cherez AI-kritika."""
    lang_map = {"ru": "русском", "en": "English", "uz": "oʻzbek tilida"}
    lang_name = lang_map.get(lang, "русском")
    diff_map = {
        "easy": "uchashchimsya nachal'noy shkoly",
        "medium": "studentam srednego urovnya",
        "hard": "professionalam i ekspertam",
    }
    diff_name = diff_map.get(difficulty, diff_map["medium"])

    prompt = f"""Ty - opytnyy prepodavatel'.

Sgeneriruy {count} kachestvennyh voprosov po teme: "{topic}".
Slozhnost': dlya {diff_name}.
Yazyk: {lang_name}.

Trebovaniya:
- Voprosy raznoobraznye (terminy, ponyatiya, primery, sluchayi primeneniya)
- Otvety korotkie (1-3 predlozheniya)
- Polya:
  - "question" - vopros
  - "answer" - korotkiy otvet
  - "note" - obyasnenie ili rasshirennyy kontekst

Vyhod TOL'KO JSON-arrey:
[{{"question":"...","answer":"...","note":"..."}}, ...]"""

    raw = _call_gemini(prompt, max_tokens=8000)
    cards = _parse_cards_json(raw or "")
    if quality and cards:
        cards = _critique_and_improve(cards, lang=lang)
    return cards


def generate_from_pdf(pdf_path: Path, count: int = 10, lang: str = "ru",
                      quality: bool = False) -> list[dict]:
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
    return generate_from_text(text, count=count, lang=lang, quality=quality)


# === VISION: PDF -> kartochki cherez Gemini Vision (dlya skanov i kartinok) ===

def _pdf_to_images(pdf_path: Path, max_pages: int = 20, dpi: int = 150) -> list[bytes]:
    """Renderim stranitsy PDF v PNG-baytah. PyMuPDF — bez sistemnyh zavisimostey.
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


def vision_pdf_to_cards(pdf_path: Path, lang: str = "ru",
                        max_pages: int = 20) -> list[dict]:
    """Skaniruyet stranitsy PDF cherez Gemini Vision i izvlekayet voprosy s otvetami.
    Rabotaet s OTSKANIROVANNYMI PDF (ne tekstovymi).

    Vozvrashchaet [{front, back, note}].

    Strategiya: otdayem do max_pages stranits za odin zapros (Gemini umeet multi-image input).
    Esli stranits mnogo — bilo by dorogo, no dlya testa do 50 stranits OK.
    """
    images = _pdf_to_images(pdf_path, max_pages=max_pages)
    if not images:
        return []

    key = _key()
    if not key:
        return []

    lang_map = {"ru": "русском", "en": "English", "uz": "oʻzbek tilida"}
    lang_name = lang_map.get(lang, "русском")

    prompt = f"""Ты — экстрактор тестовых вопросов из изображений (сканов PDF).

На картинках — тестовые задания. Извлеки ВСЕ вопросы с вариантами ответов.

Для каждого вопроса определи:
- "question" — текст вопроса (без номера типа "1.")
- "answer" — правильный ответ (только текст правильного варианта, БЕЗ буквы)
- "options" — список всех вариантов в формате "буква) текст"
- "correct_letter" — буква правильного ответа (A/B/C/D...). Если не отмечен — null.
- "note" — все варианты через перенос строки (для подсказки), это поле обязательное

Если в тестах есть отметки (✓, *, [x], "Answer: B", выделение жирным или подчёркиванием правильного ответа) — учти их.

Yazyk voprosov: оставь как в оригинале (на {lang_name} или другом).

Если вопросы дублируются (например, продолжаются на следующей странице) — объедини их.

Если на странице нет вопросов (титулка, инструкция и т.п.) — пропусти.

Вывод ТОЛЬКО JSON-массив:
[
  {{
    "question": "...",
    "answer": "...",
    "options": ["A) ...", "B) ...", "C) ..."],
    "correct_letter": "B",
    "note": "A) ...\\nB) ...\\nC) ..."
  }},
  ...
]

Если не можешь распознать ни одного вопроса — верни []."""

    # Sobiraem mnogokartinochnyy zapros
    parts = [{"text": prompt}]
    import base64
    for png in images:
        b64 = base64.b64encode(png).decode("ascii")
        parts.append({"inline_data": {"mime_type": "image/png", "data": b64}})

    body = {
        "contents": [{"parts": parts}],
        "generationConfig": {
            "temperature": 0.2,
            "maxOutputTokens": 8000,
            "responseMimeType": "application/json",
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Vision rabotayet TOL'KO na flash, ne na flash-lite
    url = f"{API_URL_FALLBACK}?key={key}"
    req = urlreq.Request(url, data=data, method="POST",
                         headers={"Content-Type": "application/json"})
    try:
        with urlreq.urlopen(req, timeout=180) as resp:
            payload = json.loads(resp.read().decode("utf-8"))
        text = payload["candidates"][0]["content"]["parts"][0]["text"]
    except urlerr.HTTPError as e:
        err_body = e.read().decode("utf-8", errors="replace")[:300]
        print(f"[AI vision] HTTP {e.code}: {err_body}")
        return []
    except Exception as e:
        print(f"[AI vision] {type(e).__name__}: {e}")
        return []

    if not text:
        return []

    # Razbiraem JSON
    text = re.sub(r"^```(?:json)?\s*|\s*```$", "", text.strip(), flags=re.MULTILINE)
    try:
        items = json.loads(text)
    except Exception:
        m = re.search(r"\[.*\]", text, re.DOTALL)
        if not m:
            return []
        try:
            items = json.loads(m.group(0))
        except Exception:
            return []

    if not isinstance(items, list):
        return []

    cards = []
    for it in items:
        if not isinstance(it, dict):
            continue
        q = (it.get("question") or it.get("front") or "").strip()
        a = (it.get("answer") or it.get("back") or "").strip()
        opts = it.get("options") or []
        correct = it.get("correct_letter") or ""
        # Sobiraem note: vse varianty cherez perenos
        note = (it.get("note") or "").strip()
        if not note and opts:
            note = "\n".join(str(o).strip() for o in opts if o)
        # Esli est' bukva pravil'nogo otveta — formiruem back v formate "B) tekst"
        if correct and opts:
            for opt in opts:
                opt_str = str(opt).strip()
                m = re.match(r"^\s*([A-Za-zА-Яа-яЁё])\s*[\)\.]\s*(.+)$", opt_str)
                if m and m.group(1).upper() == correct.upper():
                    a = f"{correct.upper()}) {m.group(2).strip()}"
                    break
        if q and (a or note):
            cards.append({
                "front": q,
                "back": a or (note.split("\n")[0] if note else ""),
                "note": note,
            })

    return cards



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
    key = _key()
    if not key:
        return None
    body = {
        "contents": [{"parts": [{"text": prompt}]}],
        "generationConfig": {
            "temperature": 0.4,
            "maxOutputTokens": 500,
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Probuyem 2 modeli: snachala flash-lite (besplatno), potom flash (esli rate-limit)
    for url_template in (API_URL, API_URL_FALLBACK):
        url = f"{url_template}?key={key}"
        req = urlreq.Request(url, data=data, method="POST",
                             headers={"Content-Type": "application/json"})
        try:
            with urlreq.urlopen(req, timeout=30) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            text = payload["candidates"][0]["content"]["parts"][0]["text"].strip()
            if text:
                return text
        except urlerr.HTTPError as e:
            if e.code == 429:
                print(f"[AI explain] {url_template.split('/models/')[1][:30]} → 429, fallback")
                continue
            err_body = e.read().decode("utf-8", errors="replace")[:200]
            print(f"[AI explain] HTTP {e.code}: {err_body}")
            return None
        except Exception as e:
            print(f"[AI explain] {type(e).__name__}: {e}")
            return None
    return None



def chat_tutor(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru") -> str | None:
    """AI-tutor: chat-bot kotoryy znayet o tekuschey kolode i mozhet podrobno ob'yasnyat'."""
    if not is_available():
        return None
    history = history or []
    lang_prompt = {
        "ru": "русском",
        "en": "English",
        "uz": "узбекском",
    }.get(lang, "русском")

    system_prompt = f"""Ты — дружелюбный AI-репетитор в приложении QuizPro для изучения с карточками.
Помоги студенту понять материал, ответь на вопрос на {lang_prompt} языке.

ПРАВИЛА:
- Отвечай 3-7 короткими предложениями
- Используй простой язык, примеры
- Если просят примеры — дай 2-3 разных
- Будь дружелюбным, но не льстивым
- Без вступлений вроде "Конечно!" — сразу к сути
"""

    if deck_context:
        system_prompt += f"\n\nКОНТЕКСТ КОЛОДЫ:\n{deck_context[:1500]}"

    parts = [system_prompt + "\n\nИстория диалога:"]
    for h in history[-6:]:
        role = "Студент" if h["role"] == "user" else "Репетитор"
        parts.append(f"{role}: {h['content']}")
    parts.append(f"Студент: {user_message}")
    parts.append("Репетитор:")

    full_prompt = "\n".join(parts)

    key = _key()
    if not key:
        return None
    body = {
        "contents": [{"parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "temperature": 0.6,
            "maxOutputTokens": 800,
        },
    }
    data = json.dumps(body).encode("utf-8")

    # Probuyem 2 modeli: snachala flash-lite (besplatno), potom flash (na sluchay rate-limit)
    for url_template in (API_URL, API_URL_FALLBACK):
        url = f"{url_template}?key={key}"
        req = urlreq.Request(url, data=data, method="POST",
                             headers={"Content-Type": "application/json"})
        try:
            with urlreq.urlopen(req, timeout=30) as resp:
                payload = json.loads(resp.read().decode("utf-8"))
            return payload["candidates"][0]["content"]["parts"][0]["text"].strip()
        except urlerr.HTTPError as e:
            if e.code == 429:
                # Rate limit — perehodim k fallback
                print(f"[AI tutor] {url_template.split('/models/')[1][:30]} → 429, пробуем fallback")
                continue
            print(f"[AI tutor] HTTP {e.code}: {e.read().decode('utf-8', errors='replace')[:200]}")
            return None
        except Exception as e:
            print(f"[AI tutor] {type(e).__name__}: {e}")
            return None
    return None
