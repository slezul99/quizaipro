# -*- coding: utf-8 -*-
"""Background jobs dlya Vision PDF (chtoby polzovatel ne zhdal sinhronno).

Khranim sostoyanie v in-memory dict + persistim na disk (chtoby perezhival restart Railway).
"""
import threading
import time
import uuid
import json as _json
from pathlib import Path
from datetime import datetime, timedelta

# Disk persistence (chtoby debugit posle restarta containera)
_BASE = Path(__file__).resolve().parent
_JOBS_DIR = _BASE / "vision_jobs_data"
_JOBS_DIR.mkdir(exist_ok=True)


def _job_file(jid: str) -> Path:
    return _JOBS_DIR / f"{jid}.json"


def _save_to_disk(jid: str, job: dict):
    """Sokhranyaem job na disk dlya post-mortem debug."""
    try:
        # datetime → string
        safe = {}
        for k, v in job.items():
            if isinstance(v, datetime):
                safe[k] = v.isoformat()
            elif k == "result_cards":
                # Cards mogut byt' bolshie — sokhranyayem tol'ko kolichestvo
                safe["result_cards_count"] = len(v) if v else 0
            else:
                safe[k] = v
        _job_file(jid).write_text(_json.dumps(safe, ensure_ascii=False, indent=2),
                                   encoding="utf-8")
    except Exception as e:
        print(f"[vision_jobs] disk save err: {e}")


_jobs: dict[str, dict] = {}
_lock = threading.Lock()


def _cleanup_old_jobs():
    """Udalyayem zavershyonnyye/upavshie jobs starshe 1 chasa iz pamati.
    Disk-faily chistim starshe 7 dney (dlya istorii)."""
    cutoff_mem = datetime.utcnow() - timedelta(hours=1)
    cutoff_disk = datetime.utcnow() - timedelta(days=7)
    with _lock:
        to_drop = [jid for jid, j in _jobs.items()
                   if j.get("finished_at") and j["finished_at"] < cutoff_mem]
        for jid in to_drop:
            _jobs.pop(jid, None)
    # Disk cleanup
    try:
        for f in _JOBS_DIR.glob("*.json"):
            try:
                if f.stat().st_mtime < cutoff_disk.timestamp():
                    f.unlink()
            except Exception:
                pass
    except Exception:
        pass


def create_job(user_id: int, fpath: Path, filename_stem: str,
               deck_id: int | None, new_deck_name: str,
               category_id: int | None, lang: str) -> str:
    """Sozdaem zapis ob job. Vozvrashchaem job_id."""
    _cleanup_old_jobs()
    jid = uuid.uuid4().hex
    job = {
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
        "stage_msg": "",
        "result_cards": None,
        "error": None,
        "created_at": datetime.utcnow(),
        "finished_at": None,
        "deck_id_created": None,
    }
    with _lock:
        _jobs[jid] = job
    _save_to_disk(jid, job)
    return jid


def get_job(jid: str) -> dict | None:
    """Vozvrashchaem job: snachala iz pamati, esli net — iz fayla na diske."""
    with _lock:
        j = _jobs.get(jid)
        if j is not None:
            return dict(j)
    # Tryem disk (esli container perezapuskalsya)
    fpath = _job_file(jid)
    if fpath.exists():
        try:
            data = _json.loads(fpath.read_text(encoding="utf-8"))
            # Konvertiruem datetime obratno
            for k in ("created_at", "finished_at"):
                if data.get(k) and isinstance(data[k], str):
                    try:
                        data[k] = datetime.fromisoformat(data[k])
                    except Exception:
                        pass
            return data
        except Exception as e:
            print(f"[vision_jobs] disk load err for {jid}: {e}")
    return None


def update_job(jid: str, **fields):
    with _lock:
        if jid in _jobs:
            _jobs[jid].update(fields)
            job_copy = dict(_jobs[jid])
        else:
            return
    _save_to_disk(jid, job_copy)


def get_user_jobs(user_id: int) -> list[dict]:
    """Posledniye 10 jobs polzovatelya."""
    with _lock:
        return sorted(
            [dict(j) for j in _jobs.values() if j.get("user_id") == user_id],
            key=lambda j: j.get("created_at") or datetime.min,
            reverse=True,
        )[:10]


def list_recent_jobs_from_disk(limit: int = 50) -> list[dict]:
    """Posledniye job'y vklyuchaya s diska (dlya super-admin debug)."""
    try:
        files = sorted(_JOBS_DIR.glob("*.json"),
                       key=lambda f: f.stat().st_mtime, reverse=True)[:limit]
        out = []
        for f in files:
            try:
                data = _json.loads(f.read_text(encoding="utf-8"))
                out.append(data)
            except Exception:
                continue
        return out
    except Exception:
        return []


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

    def status_cb(msg):
        # Tekstoviy stage dlya UI
        update_job(jid, stage_msg=msg)

    cards = []
    try:
        cards = ai_gen.vision_pdf_to_cards(
            fpath,
            lang=job["lang"],
            max_pages=30,
            chunk_size=1,        # POSTRANICHNAYA — kachestvo > skorost'
            audit=False,         # OTKLYUCHENO chtoby ne udvaivat' vremya (pri 14 stranitsah eto bylo 12 minut)
            progress_cb=progress_cb,
            status_cb=status_cb,
        )
    except Exception as e:
        tb = traceback.format_exc()
        print(f"[vision_jobs] vision_pdf_to_cards err:\n{tb}")
        err_msg = f"AI vision ошибка: {type(e).__name__}: {e}".strip()
        # Garantiya chto error nikogda ne pustoy
        if not err_msg or err_msg.endswith(": "):
            err_msg = f"AI vision упал без сообщения. Тип: {type(e).__name__}. Stack trace в логах сервера."
        update_job(jid, status="failed",
                   error=err_msg,
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
