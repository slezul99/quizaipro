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


def parse_mcq_textbook(text: str) -> list[dict]:
    """Razbiraet format uchebnika tipa Oxford Solutions Placement Test:

        1  Question text without dot/paren after number?
         A First option  B Second option  C Third option  D Fourth option

        2  Next question ____ goes here.
         A First  B Second
         C Third  D Fourth

    Bez Answer: markerov — back budet soderzhat' vse varianty (uchitel' otmechaet).
    Eto poslednyaya popytka pered AI Vision dlya dovolno strukturirovannyh PDF.
    """
    raw_lines = text.splitlines()
    # Chistim
    lines = []
    for ln in raw_lines:
        s = ln.strip()
        if not s:
            continue
        # Page numbers / decoration
        if re.fullmatch(r"[•·\-\*\s]+", s):
            continue
        if re.fullmatch(r"\d{1,3}", s):
            continue
        # Skip headers (copyright, page name, etc.)
        if "PHOTOCOPIABLE" in s or "OXFORD UNIVERSITY" in s:
            continue
        if re.match(r"^Page\s+\d", s, re.IGNORECASE):
            continue
        lines.append(s)

    # Pattern: number at start with 2+ spaces — but no `.` or `)` after
    NUM_Q_RE = re.compile(r"^\s*(\d{1,4})\s{2,}(.+)$")
    # Inline options: " A Be  B Am  C Is  D Are" — bukva s odnym/dvumya probelami sleduyushchiy
    # Split po patternu " <letter> " (probel + bukva + probel)
    INLINE_OPTS_RE = re.compile(r"(?:^|\s)([A-D])\s+")
    # Single letter options at line start (no `)` `.`)
    LETTER_OPT_RE = re.compile(r"^\s*([A-D])\s+(.+)$")
    # Skip non-question lines
    SKIP_LINE_RE = re.compile(
        r"^(Mark:|Total:|Reading|Writing|Grammar|Placement|Circle the|"
        r"Solutions Third|Are the sentences|Choose the best)",
        re.IGNORECASE
    )

    def _extract_inline_opts(s: str) -> list[tuple[str, str]]:
        """Try to parse 'A text  B text  C text  D text' from one line.
        Need at least A and B on the line."""
        # Find all positions of " <letter> " markers
        positions = [(m.start(), m.group(1).upper())
                     for m in INLINE_OPTS_RE.finditer(s)]
        if len(positions) < 2:
            return []
        # Validate: starts with A or near start (within 2 chars of stripped start)
        # AND letters are sequential (A, B, C, D)
        letters = [p[1] for p in positions]
        if letters[0] != "A":
            return []
        opts = []
        for j, (pos, letter) in enumerate(positions):
            # Text starts after letter+space (which is 2 chars: letter + space)
            text_start = pos + 2  # skip "A " (counted from start of letter, which is at pos+1 if there's a leading space, but match starts at the leading space)
            # Recompute: re finds " A " — m.start() = position of leading space (or 0)
            # m.end() = position after letter+space
            m_end = pos + len(positions[j][1]) + 2  # space + letter + space
            text_end = positions[j+1][0] if j+1 < len(positions) else len(s)
            opt_text = s[m_end:text_end].strip()
            if opt_text:
                opts.append((letter, opt_text))
        return opts

    cards = []
    i = 0
    n = len(lines)
    while i < n:
        ln = lines[i]
        m = NUM_Q_RE.match(ln)
        if not m:
            i += 1
            continue

        question_parts = [m.group(2).strip()]
        i += 1

        # Sobiraem prodolzhenie voprosa do pervogo varianta
        # Variant: a) liniya nachinayushchayasya s "A " (vozmozhno pred-probel)
        #          b) liniya soderzhashchaya inline opciya " A xxx  B xxx"
        while i < n:
            nxt = lines[i].strip()
            if NUM_Q_RE.match(lines[i]):
                break
            # Inline options on this line?
            inline_opts = _extract_inline_opts(" " + nxt)
            if inline_opts and len(inline_opts) >= 2:
                break
            # Block-style option line?
            if LETTER_OPT_RE.match(lines[i]):
                break
            # Skip-line?
            if SKIP_LINE_RE.match(nxt):
                break
            question_parts.append(nxt)
            i += 1

        question = " ".join(question_parts).strip()

        # Sobiraem opciya — poprobuem inline ili block
        options = []
        while i < n:
            cur = lines[i]
            if NUM_Q_RE.match(cur):
                break
            cur_s = cur.strip()
            # Try inline first
            inline_opts = _extract_inline_opts(" " + cur_s)
            if inline_opts:
                options.extend(inline_opts)
                i += 1
                continue
            # Try block-style "A text"
            opt_m = LETTER_OPT_RE.match(cur)
            if opt_m:
                options.append((opt_m.group(1).upper(), opt_m.group(2).strip()))
                i += 1
                continue
            # Possible continuation of last option
            if options and not SKIP_LINE_RE.match(cur_s):
                # Heuristic: if line is short and doesn't look like new question, append
                options[-1] = (options[-1][0], options[-1][1] + " " + cur_s)
                i += 1
                continue
            break

        # Validuem
        unique_letters = {o[0] for o in options}
        if len(unique_letters) < 2 or not question:
            continue

        # Sortiruem po bukve
        order = {"A": 0, "B": 1, "C": 2, "D": 3}
        options.sort(key=lambda x: order.get(x[0], 99))

        note = "\n".join(f"{l}) {t}" for l, t in options)
        back = note  # nash format — uchitel' otmetit pravil'nyy

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


def is_scanned_pdf(filepath: Path) -> bool:
    """Esli iz PDF udayotsya izvlech' < 100 simvolov teksta — eto skan (kartinki)."""
    try:
        text = parse_pdf_raw(filepath)
        return len(text.strip()) < 100
    except Exception:
        return False


def parse_pdf(filepath: Path, delimiter: str = "|") -> list[dict]:
    """Probuyem v poryadke: text-format → MCQ → MCQ-textbook → Q/A blocks → Vision (esli skan)."""
    text = parse_pdf_raw(filepath)
    cards = parse_text(text, delimiter)
    if not cards:
        cards = parse_mcq(text)
    if not cards:
        cards = parse_mcq_textbook(text)
    if not cards:
        cards = parse_qa_blocks(text)

    # Esli ni odin parser ne vyshel — proveryaem ne skan li eto.
    # Esli skan — pust' vyzyvayushchiy kod sam reshayet (ai_gen.vision_pdf_to_cards).
    # No esli teksta dostatochno a kart net — verno format ploxoy, ne skan.
    return cards


def parse_excel(filepath: Path) -> list[dict]:
    """Razbiraet .xlsx / .xls fayly. Format:
       Stolbets A = vopros (front)
       Stolbets B = otvet (back)
       Stolbets C = obyasnenie / note (optional)

    Esli est' MCQ — popytayemsya razobrat' format:
       Stolbets A = vopros
       Stolbets B-E = varianty A/B/C/D
       Stolbets F = pravilnyy otvet (bukva)
    """
    suffix = filepath.suffix.lower()
    # Avto-determinim format po magic bytes (.xls mozhet byt' xlsx s nepravilnym razshireniyem)
    is_old_xls = False
    try:
        with open(filepath, "rb") as fh:
            magic = fh.read(8)
        if magic.startswith(b"\xd0\xcf\x11\xe0"):
            is_old_xls = True   # OLE format = staryy xls
        elif magic.startswith(b"PK\x03\x04"):
            is_old_xls = False  # ZIP = xlsx
        else:
            is_old_xls = (suffix == ".xls")
    except Exception:
        is_old_xls = (suffix == ".xls")

    rows_per_sheet = []   # [(sheet_name, [list_of_row_lists]), ...]
    if is_old_xls:
        # Staryy xls cherez xlrd
        try:
            import xlrd
        except ImportError:
            raise RuntimeError("Trebuetsya: pip install xlrd (dlya .xls fayloв)")
        try:
            wb = xlrd.open_workbook(str(filepath))
        except Exception as e:
            raise RuntimeError(f"Ne udalos' otkryt' .xls fayl: {e}")
        for sheet in wb.sheets():
            rows = []
            for r in range(sheet.nrows):
                row = [sheet.cell_value(r, c) for c in range(sheet.ncols)]
                rows.append(row)
            rows_per_sheet.append((sheet.name, rows))
    else:
        # Sovremennyy xlsx cherez openpyxl
        try:
            import openpyxl
        except ImportError:
            raise RuntimeError("Trebuetsya: pip install openpyxl")
        try:
            wb = openpyxl.load_workbook(str(filepath), read_only=True, data_only=True)
        except Exception as e:
            raise RuntimeError(f"Ne udalos' otkryt' Excel-fayl: {e}")
        for sheet in wb.worksheets:
            rows = []
            for row in sheet.iter_rows(values_only=True):
                rows.append(list(row))
            rows_per_sheet.append((sheet.title, rows))

    # Dlya kazhdogo lista probuyem 2 strategii (s zagolovkom i bez), berem maksimum
    best_cards = []
    for sheet_name, rows in rows_per_sheet:
        if not rows:
            continue
        for skip_header in (False, True):
            data_rows = rows[1:] if skip_header else rows
            cards = _parse_excel_rows(data_rows)
            if len(cards) > len(best_cards):
                best_cards = cards
        if len(best_cards) >= 5:
            break   # uzhe nashli khoroshiy variant — net smysla iskat' v drugih listah

    return best_cards


def _parse_excel_rows(rows: list) -> list[dict]:
    """Vnutrenniy parser strok. Probuyem:
       1. MCQ format: vopros + 4 varianta + pravilnaya bukva (6 kolonok)
       2. Prostoy format: front | back | note (2-3 kolonki)
    """
    if not rows:
        return []

    # Otsekayem pustye stroki srazu
    rows = [r for r in rows if r and any(_cell_to_str(c) for c in r)]
    if not rows:
        return []

    n_cols = max(len(r) for r in rows)
    cards = []

    # MCQ-format: 6 kolonok (vopros + 4 varianta + otvet)
    if n_cols >= 6:
        header_keywords = {
            "вопрос", "question", "savol", "front", "term",
            "ответ", "answer", "javob", "back", "definition",
            "правильный", "correct", "toʻgʻri", "togri"
        }
        for row in rows:
            vals = [_cell_to_str(row[i]) if i < len(row) else "" for i in range(n_cols)]
            question = vals[0]
            opts = vals[1:5]
            answer_raw = vals[5] if n_cols > 5 else ""
            if not question or sum(1 for o in opts if o) < 2:
                continue
            # Otsekayem zagolovochnye stroki: esli vse 6 yacheek korotkie i sovpadayut s
            # tipichnymi nazvaniyami header'a (вопрос, A, B, C, D, правильный)
            short_vals = [v.lower().strip() for v in vals[:6]]
            if (short_vals[0] in header_keywords and
                all(len(v) <= 25 for v in short_vals) and
                short_vals[5] in header_keywords):
                continue
            # Esli kolonok B-E vse iz 1 simvola (A/B/C/D) — eto header
            if all(len(v) <= 2 for v in short_vals[1:5]) and short_vals[1:5] == ["a", "b", "c", "d"]:
                continue
            # Pytayemsya nayti pravil'nuyu bukvu
            ans_letter = ""
            ans_match = re.match(r"^\s*([A-Da-d1-4А-Гa-г])", answer_raw)
            if ans_match:
                ans_letter = ans_match.group(1).upper()
                if ans_letter in "1234":
                    ans_letter = "ABCD"["1234".index(ans_letter)]
                if ans_letter in "АБВГ":
                    ans_letter = "ABCD"["АБВГ".index(ans_letter)]
            options = []
            correct_text = ""
            for i, opt in enumerate(opts):
                if not opt:
                    continue
                letter = "ABCD"[i]
                options.append(f"{letter}) {opt}")
                if letter == ans_letter:
                    correct_text = f"{letter}) {opt}"
            if len(options) < 2:
                continue
            back = correct_text if correct_text else "\n".join(options)
            note = "\n".join(options) if correct_text else ""
            cards.append({"front": question, "back": back, "note": note})
        if cards:
            return cards

    # Prostoy format: front | back | note
    if n_cols >= 2:
        for row in rows:
            front = _cell_to_str(row[0]) if len(row) > 0 else ""
            back = _cell_to_str(row[1]) if len(row) > 1 else ""
            note = _cell_to_str(row[2]) if len(row) > 2 else ""
            # Filtruem zagolovochnye stroki
            if front.lower() in ("вопрос", "question", "savol", "front", "term") and \
               back.lower() in ("ответ", "answer", "javob", "back", "definition"):
                continue
            if not front or not back:
                continue
            cards.append({"front": front, "back": back, "note": note})

    return cards


def _cell_to_str(val) -> str:
    """Konvertiruem znacheniye yacheyki v strochku, obrabatyvaem pustye/None/NaN."""
    if val is None:
        return ""
    try:
        import math
        if isinstance(val, float) and math.isnan(val):
            return ""
        # Excel sokhranyaet tselye chisla kak floati (5.0 vmesto 5) — uberyom .0
        if isinstance(val, float) and val.is_integer():
            return str(int(val))
    except Exception:
        pass
    s = str(val).strip()
    if s.lower() in ("nan", "none", "null"):
        return ""
    return s


def _is_na(val) -> bool:
    """Proverka NaN/None/пусто."""
    if val is None:
        return True
    try:
        import math
        if isinstance(val, float) and math.isnan(val):
            return True
    except Exception:
        pass
    s = str(val).strip().lower()
    return s in ("", "nan", "none", "null")


def auto_parse(filepath: Path, delimiter: str = "|") -> list[dict]:
    """Avto-opredeleniye po rasshireniyu."""
    suffix = filepath.suffix.lower()
    if suffix == ".docx":
        return parse_docx(filepath, delimiter)
    if suffix == ".pdf":
        return parse_pdf(filepath, delimiter)
    if suffix in (".xlsx", ".xls", ".xlsm"):
        return parse_excel(filepath)
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
