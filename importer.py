# -*- coding: utf-8 -*-
"""Import voprosov iz .txt / .csv / .docx / .pdf s nastraivayemymi formatami."""
import re
from pathlib import Path


def parse_text(text: str, delimiter: str = "|") -> list[dict]:
    """Razbiraet text - kazhdaya stroka -> karta.
    Format: vopros [delim] otvet [delim] obyasnenie"""
    if delimiter == "tab":
        delimiter = "\t"
    cards = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        line = re.sub(r"^\s*\d+[\.\)]\s*", "", line)
        parts = [p.strip() for p in line.split(delimiter)]
        if len(parts) >= 2 and parts[0] and parts[1]:
            cards.append({
                "front": parts[0],
                "back":  parts[1],
                "note":  parts[2] if len(parts) >= 3 else "",
            })
    return cards


def parse_qa_blocks(text: str) -> list[dict]:
    """Q: ... A: ... Note: ... format."""
    cards = []
    blocks = re.split(r"\n\s*\n", text)
    for block in blocks:
        lines = [l.strip() for l in block.splitlines() if l.strip()]
        q, a, n = "", "", ""
        for ln in lines:
            m = re.match(r"^(?:Q|Q:|Вопрос:?|Savol:?)\s*[:.]?\s*(.*)$", ln, re.I)
            if m: q = m.group(1); continue
            m = re.match(r"^(?:A|A:|Ответ:?|Javob:?)\s*[:.]?\s*(.*)$", ln, re.I)
            if m: a = m.group(1); continue
            m = re.match(r"^(?:Note|Объяснение:?|Izoh:?)\s*[:.]?\s*(.*)$", ln, re.I)
            if m: n = m.group(1); continue
        if q and a:
            cards.append({"front": q, "back": a, "note": n})
    return cards


# === MCQ parser ===
# Vopros nachinaetsya s "1)", "1.", "1-", "Вопрос 1", "№1" i t.d.
QUESTION_START_RE = re.compile(
    r"^\s*(?:№\s*)?(?:вопрос|savol|question)?\s*(\d{1,4})\s*[\)\.\:\-]\s*(.+)$",
    re.IGNORECASE
)
# Variant otveta: "A)", "A.", "А)", "1)" (no tol'ko esli posle voprosa)
OPTION_RE = re.compile(
    r"^\s*([A-Za-zА-Яа-яЁё])\s*[\)\.\:\-]\s*(.+)$"
)
# Marker pravil'nogo otveta v kontse stroki: *, +, ✓, [x], (правильный)
ANSWER_MARKER_END_RE = re.compile(
    r"\s*(?:\*|\+|✓|✔|☑|\[\s*[xXхХvV✓]\s*\]|\(\s*(?:правильн\w*|right|correct|to'?g'?ri)\s*\))\s*$",
    re.IGNORECASE
)
# Marker pravil'nogo otveta v nachale stroki (do bukvy varianta): "✓ A) ..."
ANSWER_MARKER_START_RE = re.compile(
    r"^\s*(?:\*|\+|✓|✔|☑|\[\s*[xXхХvV✓]\s*\])\s+"
)


def _split_into_blocks(text: str) -> list[list[str]]:
    """Razbivaet tekst na bloki: kazhdyy blok nachinaetsya s "N)" i konchaetsya pered sleduyushchim "N)" ili pustoy strokoy.
    Vozvraschaet spisok blokov, gde kazhdyy blok = spisok strok."""
    lines = [l.rstrip() for l in text.splitlines()]

    # Snachala probuem razdelit' po pustym strokam
    by_blank = []
    cur = []
    for ln in lines:
        if not ln.strip():
            if cur:
                by_blank.append(cur)
                cur = []
        else:
            cur.append(ln)
    if cur:
        by_blank.append(cur)

    # Esli kazhdyy blok nachinaetsya s nomera — vse OK
    good = all(QUESTION_START_RE.match(b[0]) for b in by_blank if b)
    if good and by_blank:
        return by_blank

    # Inache razbivaem po nomeram
    blocks = []
    cur = []
    for ln in lines:
        if not ln.strip():
            continue
        if QUESTION_START_RE.match(ln) and cur:
            blocks.append(cur)
            cur = []
        cur.append(ln)
    if cur:
        blocks.append(cur)
    return blocks


def parse_mcq(text: str) -> list[dict]:
    """Razbiraet tekst v formate:
        1) Vopros ?
        A) variant
        B) variant *
        C) variant

        2) Sleduyushchiy vopros .
        A) ...
    Vozvraschaet karty s front=vopros, back=pravil'nyy otvet (ili spisok variantov),
    note=vse varianty cherez perenos.
    """
    # Snachala probuem PDF-format s "Answer:" markerom (samyy chastyy v PDF testakh)
    pdf = parse_mcq_pdf(text)
    if pdf:
        return pdf

    # Potom inline-format: "1. Vopros? A) ... B) ... C) ..."
    inline = parse_mcq_inline(text)
    if inline:
        return inline

    cards = []
    for block in _split_into_blocks(text):
        if not block:
            continue

        first = block[0].strip()
        m = QUESTION_START_RE.match(first)
        if not m:
            continue

        # Sobiraem tekst voprosa (mozhet zanimat' neskol'ko strok do pervogo varianta)
        q_lines = [m.group(2).strip()]
        options = []
        i = 1
        while i < len(block):
            ln = block[i].strip()
            opt = OPTION_RE.match(ln)
            if opt:
                break
            q_lines.append(ln)
            i += 1

        question = " ".join(q_lines).strip()

        # Sobiraem varianty
        correct_letter = None
        while i < len(block):
            ln = block[i].strip()
            # Snachala proverim "✓ A) ..." — marker v nachale
            mark_at_start = bool(ANSWER_MARKER_START_RE.match(ln))
            if mark_at_start:
                ln = ANSWER_MARKER_START_RE.sub("", ln)
            opt = OPTION_RE.match(ln)
            if not opt:
                # Vozmozhno prodolzhenie predydushchego varianta
                if options:
                    options[-1] = (options[-1][0], options[-1][1] + " " + ln, options[-1][2])
                i += 1
                continue
            letter = opt.group(1).upper()
            text_opt = opt.group(2).strip()
            is_correct = mark_at_start or bool(ANSWER_MARKER_END_RE.search(text_opt))
            if is_correct:
                text_opt = ANSWER_MARKER_END_RE.sub("", text_opt).strip()
                correct_letter = letter
            options.append((letter, text_opt, is_correct))
            i += 1

        if not question or not options:
            continue

        # Esli pravil'nyy otmechen — back = etot otvet
        # Esli net — back = vse varianty (uchitel' otmetit pozzhe)
        if correct_letter:
            correct = next((o for o in options if o[2]), options[0])
            back = f"{correct[0]}) {correct[1]}"
            note = "\n".join(f"{l}) {t}" for l, t, _ in options)
        else:
            # Net markera — pomeshchaem vse varianty v back
            back = "\n".join(f"{l}) {t}" for l, t, _ in options)
            note = ""

        cards.append({"front": question, "back": back, "note": note})

    return cards


# Inline-format: "1. Vopros? A) variant B) variant C) variant"
INLINE_QUESTION_RE = re.compile(
    r"^\s*(?:№\s*)?(?:вопрос|savol|question)?\s*(\d{1,4})\s*[\)\.\:\-]\s*(.+)$",
    re.IGNORECASE
)
# Razdelyaem stroku po " A)", " B)" i t.d. — bukva (lat/kir) + ) ili .
INLINE_OPTION_SPLIT_RE = re.compile(
    r"\s+([A-Za-zА-Яа-яЁё])\s*[\)\.\:]\s*"
)


# === PDF-format s yavnym markerom "Answer:" ===
# Stroka voprosa: tol'ko nomer "1." ili "1)"
PDF_NUM_ONLY_RE = re.compile(r"^\s*(\d{1,4})\s*[\.\)]\s*$")
# Variant otveta: "a)", "b)", "A)" — vozmozhno s • v nachale (TOL'KO bukva, ne tsifra)
PDF_OPTION_RE = re.compile(
    r"^\s*[•·\-\*]?\s*([A-Za-zА-Яа-яЁё])\s*[\)\.\:]\s*(.+)$"
)
# Marker "Answer: b) am" ili "Otvet: ..."
PDF_ANSWER_RE = re.compile(
    r"^\s*(?:Answer|Otvet|Ответ|Javob)\s*[:.]?\s*(.+)$",
    re.IGNORECASE
)


def parse_mcq_pdf(text: str) -> list[dict]:
    """Razbiraet PDF-format:
        1.
        Vopros tekst.
        a) variant1
        b) variant2
        c) variant3
        Answer: b) variant2
    """
    # Ochishchayem ot mussora: bullety (•), tochki na otdel'nyh strokah, nomera stranic
    raw_lines = text.splitlines()
    lines = []
    for ln in raw_lines:
        s = ln.strip()
        if not s:
            continue
        # Propuskaem stroki tol'ko iz bulletov ili tochek
        if re.fullmatch(r"[•·\-\*\s]+", s):
            continue
        # Propuskaem nomera stranits (odna tsifra)
        if re.fullmatch(r"\d{1,3}", s):
            continue
        # Ubirayem vedushchiy bullet
        s = re.sub(r"^[•·\*]\s*", "", s).strip()
        if not s:
            continue
        lines.append(s)

    cards = []
    i = 0
    n = len(lines)
    while i < n:
        ln = lines[i]
        # Ishchem nomer voprosa
        m = PDF_NUM_ONLY_RE.match(ln)
        if not m:
            # Mozhet byt' nomer i vopros na odnoy stroke: "1. Vopros tekst."
            inline_m = re.match(r"^\s*(\d{1,4})[\.\)]\s+(.+)$", ln)
            if inline_m and not PDF_OPTION_RE.match(ln):
                # Eto nachalo voprosa s tekstom srazu
                question_text = inline_m.group(2).strip()
                i += 1
            else:
                i += 1
                continue
        else:
            # Tol'ko nomer — vopros na sleduyushchih strokah
            i += 1
            q_parts = []
            while i < n:
                next_ln = lines[i]
                if PDF_OPTION_RE.match(next_ln):
                    break
                if PDF_NUM_ONLY_RE.match(next_ln):
                    break
                if PDF_ANSWER_RE.match(next_ln):
                    break
                q_parts.append(next_ln)
                i += 1
            question_text = " ".join(q_parts).strip()

        if not question_text:
            continue

        # Sobiraem varianty
        options = []
        while i < n:
            opt_m = PDF_OPTION_RE.match(lines[i])
            if not opt_m:
                break
            letter = opt_m.group(1).upper()
            opt_text = opt_m.group(2).strip()
            options.append((letter, opt_text))
            i += 1

        # Ishchem Answer:
        correct_letter = None
        correct_text = None
        if i < n:
            ans_m = PDF_ANSWER_RE.match(lines[i])
            if ans_m:
                ans_full = ans_m.group(1).strip()
                # Pytayemsya razobrat' "b) am"
                ans_letter_m = re.match(
                    r"^([A-Za-zА-Яа-яЁё]|\d{1,2})\s*[\)\.\:]\s*(.+)$",
                    ans_full
                )
                if ans_letter_m:
                    correct_letter = ans_letter_m.group(1).upper()
                    correct_text = ans_letter_m.group(2).strip()
                else:
                    correct_text = ans_full
                i += 1

        if not options:
            continue

        # Formiruem kartu
        if correct_letter:
            correct_opt = next(
                ((l, t) for l, t in options if l == correct_letter),
                None
            )
            if correct_opt:
                back = f"{correct_opt[0]}) {correct_opt[1]}"
            else:
                back = f"{correct_letter}) {correct_text or ''}"
            note = "\n".join(f"{l}) {t}" for l, t in options)
        elif correct_text:
            back = correct_text
            note = "\n".join(f"{l}) {t}" for l, t in options)
        else:
            # Net Answer: — vse varianty v back
            back = "\n".join(f"{l}) {t}" for l, t in options)
            note = ""

        cards.append({"front": question_text, "back": back, "note": note})

    return cards


def parse_mcq_inline(text: str) -> list[dict]:
    """Razbiraet tekst gde kazhdyy vopros v odnoy stroke:
        1. Vopros? A) variant1 B) variant2 ✓ C) variant3
    """
    cards = []
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        m = INLINE_QUESTION_RE.match(line)
        if not m:
            continue
        rest = m.group(2).strip()

        # Razdelyaem ostal'nuyu stroku po markeram " A)", " B)"...
        # split vozvraschayet ['vopros', 'A', 'variant1', 'B', 'variant2', ...]
        parts = INLINE_OPTION_SPLIT_RE.split(rest)
        if len(parts) < 5:
            # men'she 2 variantov — eto ne MCQ
            continue

        question = parts[0].strip()
        # Tsiklim po param (letter, text)
        options = []
        correct_letter = None
        for j in range(1, len(parts) - 1, 2):
            letter = parts[j].upper()
            text_opt = parts[j + 1].strip()
            is_correct = bool(ANSWER_MARKER_END_RE.search(text_opt))
            if is_correct:
                text_opt = ANSWER_MARKER_END_RE.sub("", text_opt).strip()
                correct_letter = letter
            options.append((letter, text_opt, is_correct))

        if not question or len(options) < 2:
            continue

        if correct_letter:
            correct = next((o for o in options if o[2]), options[0])
            back = f"{correct[0]}) {correct[1]}"
            note = "\n".join(f"{l}) {t}" for l, t, _ in options)
        else:
            back = "\n".join(f"{l}) {t}" for l, t, _ in options)
            note = ""

        cards.append({"front": question, "back": back, "note": note})

    return cards


def parse_docx(filepath: Path, delimiter: str = "|") -> list[dict]:
    try:
        from docx import Document
    except ImportError:
        raise RuntimeError("Trebuetsya: pip install python-docx")
    doc = Document(str(filepath))
    paras = [p.text for p in doc.paragraphs if p.text.strip()]
    text = "\n".join(paras)
    cards = parse_text(text, delimiter)
    if not cards:
        cards = parse_mcq(text)
    if not cards:
        cards = parse_qa_blocks(text)
    return cards


def parse_pdf_raw(filepath: Path) -> str:
    """Vozvraschayet ves' tekst iz PDF (dlya AI)."""
    try:
        from pypdf import PdfReader
    except ImportError:
        raise RuntimeError("Trebuetsya: pip install pypdf")
    reader = PdfReader(str(filepath))
    return "\n".join(p.extract_text() or "" for p in reader.pages)


def parse_pdf(filepath: Path, delimiter: str = "|") -> list[dict]:
    """Probuyem v poryadke: text-format → MCQ → Q/A blocks."""
    text = parse_pdf_raw(filepath)
    cards = parse_text(text, delimiter)
    if not cards:
        cards = parse_mcq(text)
    if not cards:
        cards = parse_qa_blocks(text)
    return cards


def auto_parse(filepath: Path, delimiter: str = "|") -> list[dict]:
    """Avto-opredeleniye po rasshireniyu."""
    suffix = filepath.suffix.lower()
    if suffix == ".docx":
        return parse_docx(filepath, delimiter)
    if suffix == ".pdf":
        return parse_pdf(filepath, delimiter)
    if suffix in (".txt", ".csv", ".tsv"):
        text = filepath.read_text(encoding="utf-8", errors="ignore")
        if suffix == ".tsv":
            return parse_text(text, "\t")
        cards = parse_text(text, delimiter)
        if not cards:
            cards = parse_mcq(text)
        if not cards:
            cards = parse_qa_blocks(text)
        return cards
    raise RuntimeError(f"Nepodderzhivaemyy format: {suffix}")
