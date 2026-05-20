# -*- coding: utf-8 -*-
"""Background jobs dlya Vision PDF (chtoby polzovatel ne zhdal sinhronno).

Khranim sostoyanie v in-memory dict (rabotaet pri --workers 1 v gunicorn).
Esli Railway perezapustit kontayner — job propadyot, no eto OK: polzovatel zalivit zanovo.
"""
import threading
import time
import uuid
from pathlib import Path
from datetime import datetime, timedelta

# Job: {
#   "id": "uuid",
#   "user_id": int,
#   "fpath": str,
#   "filename_stem": str,
#   "deck_id": int|None,           # esli sushchestvuyushchaya
#   "new_deck_name": str,
#   "category_id": int|None,
#   "lang": str,
#   "status": "pending"|"running"|"done"|"failed",
#   "progress": 0-100 (%),
#   "pages_done": int,
#   "pages_total": int,
#   "cards_found": int,
#   "result_cards": list[dict] | None,
#   "error": str | None,
#   "created_at": datetime,
#   "finished_at": datetime | None,
#   "deck_id_created": int | None,    # ID koldoy gde sokhraneny karty
# }
_jobs: dict[str, dict] = {}
_lock = threading.Lock()


def _cleanup_old_jobs():
    """Udalyayem zavershyonnyye/upavshie jobs starshe 1 chasa."""
    cutoff = datetime.utcnow() - timedelta(hours=1)
    with _lock:
        to_drop = [jid for jid, j in _jobs.items()
                   if j.get("finished_at") and j["finished_at"] < cutoff]
        for jid in to_drop:
            _jobs.pop(jid, None)


def create_job(user_id: int, fpath: Path, filename_stem: str,
               deck_id: int | None, new_deck_name: str,
               category_id: int | None, lang: str) -> str:
    """Sozdaem zapis ob job. Vozvrashchaem job_id."""
    _cleanup_old_jobs()
    jid = uuid.uuid4().hex
    with _lock:
        _jobs[jid] = {
            "id": jid,
            "user_id": user_id,
            "fpath": str(fpath),
            "filename_stem": filename_stem,
            "deck_id": deck_id,
            "new_deck_name": new_deck_name,
            "category_id": category_id,
            "lang": lang,
            "status": "pending",
            "progress": 0,
            "pages_done": 0,
            "pages_total": 0,
            "cards_found": 0,
            "result_cards": None,
            "error": None,
            "created_at": datetime.utcnow(),
            "finished_at": None,
            "deck_id_created": None,
        }
    return jid


def get_job(jid: str) -> dict | None:
    with _lock:
        j = _jobs.get(jid)
        if j is None:
            return None
        # Kopiya chtoby ne otdat' ssylku na obshchiy state
        return dict(j)


def update_job(jid: str, **fields):
    with _lock:
        if jid in _jobs:
            _jobs[jid].update(fields)


def get_user_jobs(user_id: int) -> list[dict]:
    """Posledniye 10 jobs polzovatelya."""
    with _lock:
        return sorted(
            [dict(j) for j in _jobs.values() if j.get("user_id") == user_id],
            key=lambda j: j.get("created_at") or datetime.min,
            reverse=True,
        )[:10]


def run_vision_job(jid: str, save_cards_callback):
    """Background-zapusk: chitaem PDF cherez Gemini Vision i sokhranyaem v BD.

    save_cards_callback(job_id, cards) — funktsiya kotoraya sokhranyaet karty v deck.
    Vozvrashchaet (deck_id_created, error_msg).
    """
    import traceback
    import ai_gen
    job = get_job(jid)
    if not job:
        return
    fpath = Path(job["fpath"])

    # Proverka 1: fayl est'?
    if not fpath.exists():
        update_job(jid, status="failed",
                   error=f"Файл не найден на сервере: {fpath.name}",
                   finished_at=datetime.utcnow())
        return

    # Proverka 2: Gemini API klyuch est'?
    if not ai_gen.is_available():
        update_job(jid, status="failed",
                   error="Gemini API ключ не настроен на сервере. Свяжитесь с поддержкой.",
                   finished_at=datetime.utcnow())
        try: fpath.unlink(missing_ok=True)
        except Exception: pass
        return

    # Proverka 3: PyMuPDF ustanovlen?
    try:
        import pymupdf  # type: ignore
    except ImportError:
        try:
            import fitz as pymupdf  # type: ignore
        except ImportError:
            update_job(jid, status="failed",
                       error="PyMuPDF не установлен на сервере. Свяжитесь с поддержкой.",
                       finished_at=datetime.utcnow())
            try: fpath.unlink(missing_ok=True)
            except Exception: pass
            return

    # Schitaem total pages dlya progress
    try:
        doc = pymupdf.open(str(fpath))
        total = min(len(doc), 30)  # max 30 stranits
        doc.close()
    except Exception as e:
        print(f"[vision_jobs] open PDF err: {type(e).__name__}: {e}")
        update_job(jid, status="failed",
                   error=f"Не удалось открыть PDF: {type(e).__name__}: {e}",
                   finished_at=datetime.utcnow())
        try: fpath.unlink(missing_ok=True)
        except Exception: pass
        return

    update_job(jid, status="running", pages_total=total)

    def progress_cb(done, total_pages, found):
        pct = int(done / max(total_pages, 1) * 90)  # 90% — vision, 10% — sohranenie
        update_job(jid, pages_done=done, pages_total=total_pages,
                   cards_found=found, progress=pct)

    cards = []
    try:
        cards = ai_gen.vision_pdf_to_cards(
            fpath,
            lang=job["lang"],
            max_pages=30,
            chunk_size=3,
            progress_cb=progress_cb,
        )
    except Exception as e:
        tb = traceback.format_exc()
        print(f"[vision_jobs] vision_pdf_to_cards err:\n{tb}")
        update_job(jid, status="failed",
                   error=f"AI vision ошибка: {type(e).__name__}: {e}",
                   finished_at=datetime.utcnow())
        try: fpath.unlink(missing_ok=True)
        except Exception: pass
        return

    if not cards:
        update_job(jid, status="failed",
                   error="AI прошёл все страницы, но не нашёл закрытых тестовых вопросов "
                         "(с вариантами A/B/C/D). Возможные причины: "
                         "(1) в PDF только открытые вопросы или эссе, "
                         "(2) качество скана слишком низкое (текст нечитаемый), "
                         "(3) вопросы оформлены нестандартно. "
                         "Попробуйте более чёткий скан с явными вариантами.",
                   finished_at=datetime.utcnow())
        try: fpath.unlink(missing_ok=True)
        except Exception: pass
        return

    update_job(jid, progress=95, cards_found=len(cards))

    # Сохраняем в БД через callback (nuzhen Flask app context)
    try:
        deck_id_created = save_cards_callback(jid, cards)
        update_job(jid, status="done", progress=100, result_cards=cards,
                   deck_id_created=deck_id_created,
                   finished_at=datetime.utcnow())
    except Exception as e:
        tb = traceback.format_exc()
        print(f"[vision_jobs] save err:\n{tb}")
        update_job(jid, status="failed",
                   error=f"Не удалось сохранить карты: {type(e).__name__}: {e}",
                   finished_at=datetime.utcnow())

    try:
        fpath.unlink(missing_ok=True)
    except Exception:
        pass


def start_vision_job(jid: str, save_cards_callback):
    """Zapuskaet job v fonovom potoke. Lyubaya neperekhvachennaya oshibka popadet v job.error."""
    import traceback as _tb
    def _wrapper():
        try:
            run_vision_job(jid, save_cards_callback)
        except Exception as e:
            tb = _tb.format_exc()
            print(f"[vision_jobs] FATAL in thread:\n{tb}")
            update_job(jid, status="failed",
                       error=f"Внутренняя ошибка: {type(e).__name__}: {e}",
                       finished_at=datetime.utcnow())
    th = threading.Thread(target=_wrapper, daemon=True)
    th.start()
