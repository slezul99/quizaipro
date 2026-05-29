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
DEEPSEEK_KEY_FILE = BASE / "deepseek_key.txt"

API_URL = ("https://generativelanguage.googleapis.com/v1beta/models/"
           "gemini-3.5-flash:generateContent")
# Fallback model esli osnovnaya zabita (rate limit)
API_URL_FALLBACK = ("https://generativelanguage.googleapis.com/v1beta/models/"
                    "gemini-2.5-flash:generateContent")
# Vision URLs.
# Maj 2026: Gemini 3.5 Flash uzhe v free tier, podderzhivaet vision
# (text+image+video+audio+pdf, 1M context, 65k output).
# - gemini-3.5-flash:        primary (samaya posledniaya, mnogofunkcional'naya)
# - gemini-2.5-flash:        fallback (proverennyy backup, 250 RPD free)
# - gemini-2.5-flash-lite:   ekstrennyy backup (1000 RPD free, lite versiya)
API_URL_VISION_PRIMARY = ("https://generativelanguage.googleapis.com/v1beta/models/"
                          "gemini-3.5-flash:generateContent")
API_URL_VISION_FALLBACK = ("https://generativelanguage.googleapis.com/v1beta/models/"
                           "gemini-2.5-flash:generateContent")

# === DeepSeek API (OpenAI-sovmestimyy endpoint) ===
# Ispolzuetsya tolko dlya tekstovogo chata (AI Tutor).
# Vision i generatsia kolod ostalis na Gemini.
DEEPSEEK_API_URL = "https://api.deepseek.com/v1/chat/completions"
DEEPSEEK_MODEL = "deepseek-v4-flash"  # bystryy + deshyovyy, $0.14/$0.28 za 1M tokens


def _key():
    # 1. ENV variable (production na Railway)
    env_key = os.environ.get("GEMINI_API_KEY", "").strip()
    if env_key:
        return env_key
    # 2. Lokal'nyy fayl (razrabotka)
    if KEY_FILE.exists():
        return KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


def _deepseek_key():
    """DeepSeek API klyuch. ENV var DEEPSEEK_API_KEY (Railway) ili lokal'nyy fayl."""
    env_key = os.environ.get("DEEPSEEK_API_KEY", "").strip()
    if env_key:
        return env_key
    if DEEPSEEK_KEY_FILE.exists():
        return DEEPSEEK_KEY_FILE.read_text(encoding="utf-8").strip()
    return ""


def is_deepseek_available() -> bool:
    return bool(_deepseek_key())


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
        # Stringify esli prishyol ne string
        q = str(q).strip() if q else ""
        a = str(a).strip() if a else ""
        n = str(n).strip() if n else ""
        if q and a:
            out.append({"front": q, "back": a, "note": n})
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

MAKE CARDS ENGAGING — avoid boring "What is X?" questions. Mix these formats:
1. 🎯 Direct fact: "What does [term] mean in this context?"
2. 🔍 Spot it: "Which statement about [topic] is correct?"
3. 🔄 Apply it: "How would you use [concept] in practice?"
4. 💡 Why/How: "Why does [fact from text] happen?"
5. ⚠️ Common mistake: "What's the common misconception about [topic]?"
6. 🌍 Real example: "Give an example of [concept] from real life"
7. 🔗 Connect: "How does [A] relate to [B] according to the text?"

Rules:
- Answer directly first, then explain
- Use concrete examples from the text
- Keep it conversational, not textbook-style
- "note": surprising fact, memory trick, or real-world connection
- Only use information from the text

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"..."}}, ...]

TEXT:
{text[:8000]}"""

    raw = _call_gemini(prompt, max_tokens=8000)
    cards = _parse_cards_json(raw or "")
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

MAKE CARDS ENGAGING — use these question formats (mix them!):
1. 🎯 Rule + real example: "When do we use 'a' vs 'an'?"
2. 🔍 Spot the mistake: "Find the error: 'She don't like coffee'"
3. 💬 Real situation: "Your friend says 'I am agree'. Is it correct? Why?"
4. ✏️ Complete it: "She ___ (not/like) Mondays. (Present Simple)"
5. 🔄 Transform: "Make this negative: 'He plays football'"
6. 🌍 Translate naturally: "How do you say 'Я хожу в школу каждый день' in English?"
7. 🤔 Choose correctly: "Which is right: 'I have 20 years' or 'I am 20 years old'?"
8. 💡 Why?: "Why do we say 'goes' not 'go' for she/he/it?"

Rules for ENGAGING answers:
- Start with the direct answer (✓ or ✗ or the rule)
- Add 1-2 real-life examples people actually say
- Use emojis sparingly to highlight key points
- Keep it conversational, not textbook-style

"note" field: add a fun memory trick, real-life context, or "common mistake" warning ⚠️

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"..."}}, ...]"""

    else:
        prompt = f"""You are a creative teacher making ENGAGING flashcards that students love to study.

Topic: "{topic}"
Count: exactly {count} flashcards.
Difficulty: {diff_name}.
{lang_instruction}

MAKE CARDS ENGAGING — avoid boring "What is X?" questions. Use these formats:
1. 🎯 Practical: "You need to [do something]. What do you use/do?"
2. 🔍 Scenario: "Imagine you are [situation]. What happens when...?"
3. ✅ True or False + explain why
4. 🔄 Compare: "What's the difference between A and B?"
5. 💡 Why/How: "Why does [phenomenon] happen?"
6. 🧩 Connect: "How does [concept A] relate to [concept B]?"
7. ⚠️ Common mistake: "What's wrong with this: [wrong example]?"
8. 🌍 Real world: "Give a real-life example of [concept]"

Rules for ENGAGING answers:
- Be direct and clear — answer first, explain second
- Use concrete examples, not abstract definitions
- Add analogies or comparisons when helpful
- Keep it conversational

"note" field: memory trick, real-world connection, or surprising fact 🤯

Output ONLY a JSON array:
[{{"question":"...","answer":"...","note":"..."}}, ...]"""

    raw = _call_gemini(prompt, max_tokens=8000)
    cards = _parse_cards_json(raw or "")
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
    Probuet snachala gemini-3.5-flash (samaya posledniaya), potom gemini-2.5-flash (fallback)."""
    global _last_gemini_error
    key = _key()
    if not key:
        _last_gemini_error = "GEMINI_API_KEY ne nastroen"
        print("[AI vision] NO KEY — set GEMINI_API_KEY env var")
        return None
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
        "contents": [{"parts": parts}],
        "generationConfig": {
            "temperature": 0.1,
            "maxOutputTokens": 16000,
            "responseMimeType": "application/json",
        },
    }
    data = json.dumps(body).encode("utf-8")
    print(f"[AI vision] sending {len(images)} images, body size: {len(data)//1024}KB")

    last_err = None
    # Probuyem 2 modeli: 2.0-flash (1500 RPD) -> 2.5-flash (250 RPD)
    for model_idx, url_base in enumerate([API_URL_VISION_PRIMARY, API_URL_VISION_FALLBACK]):
        model_name = url_base.split("/models/")[-1].split(":")[0]
        url = f"{url_base}?key={key}"
        for attempt in range(2):  # 2 retry na model'
            req = urlreq.Request(url, data=data, method="POST",
                                 headers={"Content-Type": "application/json"})
            try:
                with urlreq.urlopen(req, timeout=timeout) as resp:
                    payload = json.loads(resp.read().decode("utf-8"))
                text = payload["candidates"][0]["content"]["parts"][0]["text"]
                if text and text.strip():
                    print(f"[AI vision] OK on {model_name}, response {len(text)} chars")
                    return text
                last_err = f"empty response: {str(payload)[:200]}"
                print(f"[AI vision] {model_name}: {last_err}")
            except urlerr.HTTPError as e:
                err_body = ""
                try:
                    err_body = e.read().decode("utf-8", errors="replace")[:500]
                except Exception:
                    pass
                last_err = f"{model_name} HTTP {e.code}: {err_body[:300]}"
                _last_gemini_error = last_err
                print(f"[AI vision] {model_name} attempt {attempt+1}/2: HTTP {e.code}: {err_body[:300]}")
                if e.code == 429:
                    # Rate limit — perehodim k sleduyushchey modeli
                    print(f"[AI vision] {model_name} rate limited, switching to next model")
                    break
                if e.code in (503, 500, 502, 504):
                    import time
                    time.sleep(3 + attempt * 3)
                    continue
                # Drugie HTTP oshibki (401, 403, 400) — probuyem fallback model'
                break
            except Exception as e:
                last_err = f"{model_name} {type(e).__name__}: {e}"
                _last_gemini_error = last_err
                print(f"[AI vision] {model_name} attempt {attempt+1}/2: {last_err}")
                import time
                time.sleep(2)
                continue

    print(f"[AI vision] FAILED on all models: {last_err}")
    return None


def get_last_gemini_error() -> str:
    """Vozvrashchaem poslednyuyu detal'nuyu HTTP-oshibku ot Gemini (dlya debug)."""
    return _last_gemini_error


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
    return _parse_cards_json(raw or "")


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
    return _parse_cards_json(raw or "")


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
    if not _key():
        raise RuntimeError("Gemini API ключ не настроен на сервере.")

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
                "🚫 Дневной лимит Gemini AI исчерпан. "
                "Free tier: gemini-3.5-flash и gemini-2.5-flash имеют дневные квоты. "
                "Квота сбрасывается в полночь по Pacific Time (=11:00 утра в Ташкенте). "
                "Для production-нагрузки нужен paid tier (~$0.10 за PDF). "
                f"\n\nПодробности от Google: {gemini_err[:300]}"
            )
        elif "401" in gemini_err or "403" in gemini_err or "API_KEY" in gemini_err.upper():
            raise RuntimeError(
                "🔑 Проблема с API ключом Gemini. Проверьте GEMINI_API_KEY в Railway env. "
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



def _build_tutor_prompt(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru") -> tuple[str, list]:
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

## Что ты умеешь как репетитор:
- Объяснять любые темы: математика, история, языки, программирование, биология, физика, химия, право, экономика и всё остальное
- Помогать готовиться к экзаменам и тестам
- Разбирать ошибки и непонятные моменты
- Составлять планы обучения
- Отвечать на вопросы по карточкам и темам пользователя
- Давать примеры, аналогии, мнемоники для запоминания
- Проверять знания — задавать вопросы и оценивать ответы

---

## Полный список функций платформы QuizAIPro:

### 📚 Карточки и колоды
- **Колоды** — наборы карточек по одной теме. Создаются вручную или через импорт/AI
- **Flashcards** (`/deck/ID/flashcards`) — режим изучения карточек с алгоритмом SM-2 (интервальное повторение). Карточки показываются в оптимальное время для запоминания
- **Тест** (`/deck/ID/test`) — тест по колоде: выбор количества вопросов (10/25/50/100), перемешивание
- **Match** (`/deck/ID/match`) — игра на сопоставление карточек
- **Экспорт** — экспорт колоды в JSON или PDF
- **Клонирование** — скопировать чужую колоду себе
- **Публичные колоды** — можно сделать колоду публичной для маркетплейса

### 🤖 AI-функции
- **AI Репетитор** (`/tutor`) — это ты! Персональный AI-ассистент для учёбы. Поддерживает историю диалогов, контекст колоды
- **AI Генератор** (`/ai`) — автоматическая генерация карточек и вопросов из текста через Gemini AI
- **Импорт с AI** (`/import`) — загрузка PDF, DOCX, TXT файлов. AI автоматически извлекает вопросы и создаёт карточки. Поддерживает Vision AI для сканирования изображений в PDF
- **AI объяснение карточки** — кнопка "Объяснить" на карточке, AI даёт подробное объяснение

### 📊 Статистика и прогресс
- **Dashboard** (`/dashboard`) — главная страница: статистика, цель на день, прогресс, колоды
- **Статистика** (`/stats`) — детальная аналитика: графики активности, прогресс по темам, история повторений
- **История тестов** (`/test/history`) — все пройденные тесты с результатами
- **Цели** (`/goals`) — постановка учебных целей с дедлайном и экзаменом. Трекинг прогресса
- **Достижения** (`/achievements`) — система XP и достижений за активность
- **Стрик** — счётчик дней подряд занятий (отображается в навбаре)
- **Ежедневная цель** — настраиваемое количество повторений в день

### ⚔️ Игры и соревнования
- **Дуэли** (`/duels`) — соревнование 1 на 1 с другим пользователем в реальном времени. Вызов по username
- **Турниры** (`/tournaments`) — групповые соревнования. Создание и участие в турнирах
- **Live тест** (`/live/join`, `/live/create`) — живые тесты в реальном времени. Учитель создаёт сессию с кодом, ученики подключаются. Как Kahoot

### 🌐 Социальные функции
- **Маркетплейс** (`/marketplace`) — публичные колоды от всех пользователей. Можно клонировать себе
- **Поиск** (`/search`) — поиск колод, пользователей, карточек
- **Друзья** (`/friends`) — добавление друзей, запросы дружбы
- **Чаты** (`/chats`) — личные сообщения и групповые чаты
- **Каналы** (`/channels`) — публичные каналы для общения
- **Учебные группы** (`/study-groups`) — создание групп для совместного изучения. Добавление колод в группу
- **Лидерборд** (`/leaderboard`) — рейтинг пользователей по XP
- **Профиль** (`/u/username`) — публичный профиль пользователя

### ⚙️ Настройки и аккаунт
- **Настройки** (`/settings`) — смена пароля, языка, темы (светлая/тёмная), аватара
- **Язык** — поддержка русского, английского, узбекского
- **Тёмная тема** — переключатель в навбаре
- **Поддержка** (`/support`) — тикеты в службу поддержки
- **Помощь** (`/help`) — FAQ и руководство по платформе

### 👨‍🏫 Для учителей и администраторов
- **Управление студентами** (`/admin/students`) — добавление/удаление учеников, сброс паролей
- **Категории** (`/categories`) — создание иерархии категорий для организации колод
- **Группы** — создание учебных групп для класса

---

## Как помочь пользователю с платформой:
Если пользователь спрашивает как что-то сделать на сайте — объясни пошагово и дай ссылку на нужную страницу. Например:
- "Как создать тест?" → объясни про /deck/ID/test или /ai для генерации
- "Где мои достижения?" → /achievements
- "Как пригласить друга на дуэль?" → /duels, кнопка "Вызвать"
- "Как импортировать PDF?" → /import, загрузить файл, AI сам создаст карточки

Если пользователь хочет изучить тему — помоги объяснить, составь план, задай вопросы для проверки."""

    if deck_context:
        system_prompt += f"\n\n---\n\n## Контекст текущей колоды пользователя:\n{deck_context[:2000]}"

    # Esli istoriya dlinnaya — dobavlyaem pervoe soobshchenie kak kontekst temy
    if len(history) > 10:
        first_user = next((h["content"] for h in history if h["role"] == "user"), None)
        if first_user:
            system_prompt += f"\n\nКонтекст: в начале разговора пользователь спросил: «{first_user[:400]}» — учитывай эту тему в ответах."

    messages = []
    for h in history[-20:]:
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


def chat_tutor(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru", provider: str = "") -> str | None:
    """AI-tutor: chat-bot kotoryy znayet o tekuschey kolode i mozhet podrobno ob'yasnyat'.

    provider: "" (avto: DeepSeek -> Gemini fallback), "deepseek", "gemini" — yavnyy vybor.
    """
    system_prompt, messages = _build_tutor_prompt(user_message, deck_context, history, lang)

    use_deepseek = (provider == "deepseek") or (provider == "" and is_deepseek_available())
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

    key = _key()
    if not key:
        return None
    body = {
        "contents": [{"parts": [{"text": full_prompt}]}],
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 4000,
        },
    }
    data = json.dumps(body).encode("utf-8")

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
                print(f"[AI tutor Gemini] {url_template.split('/models/')[1][:30]} → 429, пробуем fallback")
                continue
            print(f"[AI tutor Gemini] HTTP {e.code}: {e.read().decode('utf-8', errors='replace')[:200]}")
            return None
        except Exception as e:
            print(f"[AI tutor Gemini] {type(e).__name__}: {e}")
            return None
    return None


def chat_tutor_stream(user_message: str, deck_context: str = "", history: list = None, lang: str = "ru", provider: str = ""):
    """Streaming-versiya tutor'a. Yield-it text chunki po mere generatsii.

    provider: "" (avto), "deepseek" (tolko DeepSeek), "gemini" (tolko Gemini).
    """
    system_prompt, messages = _build_tutor_prompt(user_message, deck_context, history, lang)

    use_deepseek = (provider == "deepseek") or (provider == "" and is_deepseek_available())
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

    # 2. Gemini fallback (NE streaming — otdaem celikom)
    text = chat_tutor(user_message, deck_context, history, lang, provider="gemini")
    if text:
        yield text
