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
# Vision-specific URLs (vision rabotayet TOLKO na flash, ne na flash-lite)
# gemini-2.0-flash: 1500 RPD na free tier (vyshe chem 2.5)
# gemini-2.5-flash: 250 RPD na free tier (NIZHE — eto byla nasha problema!)
API_URL_VISION_PRIMARY = ("https://generativelanguage.googleapis.com/v1beta/models/"
                          "gemini-2.0-flash:generateContent")
API_URL_VISION_FALLBACK = ("https://generativelanguage.googleapis.com/v1beta/models/"
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


def _gemini_vision_call(images: list[bytes], timeout: int = 240, prompt: str = None) -> str | None:
    """Otdelnyy zapros k Gemini Vision s nabor kartinok. Vozvrashchaet raw text otveta.
    prompt: kastomnyy promt (po default — VISION_EXTRACT_PROMPT).
    Probuet snachala gemini-2.0-flash (1500 RPD), potom gemini-2.5-flash (250 RPD)."""
    key = _key()
    if not key:
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
                    err_body = e.read().decode("utf-8", errors="replace")[:300]
                except Exception:
                    pass
                last_err = f"HTTP {e.code}: {err_body}"
                print(f"[AI vision] {model_name} attempt {attempt+1}/2: {last_err}")
                if e.code == 429:
                    # Rate limit — perehodim k sleduyushchey modeli
                    print(f"[AI vision] {model_name} rate limited, switching to next model")
                    break
                if e.code in (503, 500, 502, 504):
                    import time
                    time.sleep(3 + attempt * 3)
                    continue
                # Drugie HTTP oshibki — probuyem fallback model'
                break
            except Exception as e:
                last_err = f"{type(e).__name__}: {e}"
                print(f"[AI vision] {model_name} attempt {attempt+1}/2: {last_err}")
                import time
                time.sleep(2)
                continue

    print(f"[AI vision] FAILED on all models: {last_err}")
    return None


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
        raise RuntimeError(
            "Дневной лимит Gemini AI исчерпан (1500 запросов в сутки на free tier). "
            "Попробуйте завтра, или подождите перезагрузки квоты в полночь по UTC. "
            "Если проблема повторяется — возможно перегрузка серверов Google."
        )

    deduped = _dedupe_cards(all_cards)
    for c in deduped:
        c.pop("_number", None)

    _status(f"FINAL: {len(deduped)} unique cards from {total_pages} pages")
    return deduped



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
