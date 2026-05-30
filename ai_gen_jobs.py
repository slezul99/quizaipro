# -*- coding: utf-8 -*-
"""Background jobs dlya AI generatsii kart (text/topic/pdf).
Analogichno vision_jobs.py — khranim sostoyanie v pamyati + disk.
"""
import threading
import time
import uuid
import json as _json
from pathlib import Path
from datetime import datetime, timedelta

_BASE = Path(__file__).resolve().parent
_JOBS_DIR = _BASE / "vision_jobs_data"  # reuse same dir
_JOBS_DIR.mkdir(exist_ok=True)

_jobs: dict[str, dict] = {}
_lock = threading.Lock()


def _job_file(jid: str) -> Path:
    return _JOBS_DIR / f"aigen_{jid}.json"


def _save_to_disk(jid: str, job: dict):
    try:
        safe = {k: (v.isoformat() if isinstance(v, datetime) else v)
                for k, v in job.items() if k != "result_cards"}
        safe["result_cards_count"] = len(job.get("result_cards") or [])
        _job_file(jid).write_text(
            _json.dumps(safe, ensure_ascii=False, indent=2), encoding="utf-8"
        )
    except Exception as e:
        print(f"[ai_gen_jobs] disk save err: {e}")


def create_job(user_id: int, kind: str, count: int, label: str = "") -> str:
    """Sozdayom novyy job, vozvrashchayem job_id."""
    jid = uuid.uuid4().hex
    job = {
        "id": jid,
        "user_id": user_id,
        "kind": kind,          # text / topic / pdf
        "count": count,
        "label": label,        # tema ili pervye slova teksta
        "status": "pending",   # pending / running / done / error
        "progress": 0,
        "cards_done": 0,
        "cards_total": count,
        "stage_msg": "Подготовка...",
        "result_cards": None,
        "result_deck_id": None,
        "error": None,
        "created_at": datetime.utcnow(),
    }
    with _lock:
        _jobs[jid] = job
    _save_to_disk(jid, job)
    return jid


def get_job(jid: str) -> dict | None:
    with _lock:
        return _jobs.get(jid)


def update_job(jid: str, **kwargs):
    with _lock:
        if jid in _jobs:
            _jobs[jid].update(kwargs)
            _save_to_disk(jid, _jobs[jid])


def start_ai_gen_job(jid: str, gen_fn, save_fn):
    """Zapuskaem generatsiyu v fone.
    gen_fn(count) → list[dict] (karty)
    save_fn(cards) → deck_id (int)
    """
    job = get_job(jid)
    total_needed = job["count"] if job else 25

    def _run():
        update_job(jid, status="running", stage_msg="AI генерирует карточки...", progress=5)
        try:
            all_cards = []

            # Gemini returns max ~25-30 per call reliably.
            # For large counts, split into batches of 25.
            BATCH_SIZE = 25
            if total_needed <= BATCH_SIZE:
                batches = [total_needed]
            else:
                full = total_needed // BATCH_SIZE
                remainder = total_needed % BATCH_SIZE
                batches = [BATCH_SIZE] * full
                if remainder > 0:
                    batches.append(remainder)

            for i, batch_count in enumerate(batches):
                pct = int(5 + (i / len(batches)) * 60)
                update_job(jid,
                           stage_msg=f"Батч {i+1}/{len(batches)}: генерирую {batch_count} карточек...",
                           progress=pct)
                batch = gen_fn(batch_count)
                if batch:
                    all_cards.extend(batch)
                    update_job(jid, cards_done=len(all_cards), progress=pct + 5)

            if not all_cards:
                update_job(jid, status="error",
                           error="AI не смог сгенерировать карточки. Попробуйте конкретнее или повторите через минуту.",
                           progress=0)
                return

            update_job(jid, cards_done=len(all_cards), cards_total=len(all_cards),
                       progress=75, stage_msg=f"Создано {len(all_cards)} карточек, сохраняем...")

            deck_id = save_fn(all_cards)
            update_job(jid, status="done", result_cards=all_cards,
                       result_deck_id=deck_id, progress=100,
                       cards_done=len(all_cards),
                       stage_msg=f"Готово! {len(all_cards)} карточек сохранено.")
        except Exception as e:
            err = str(e)[:300]
            print(f"[ai_gen_jobs:{jid}] error: {err}")
            update_job(jid, status="error", error=f"Ошибка AI: {err}", progress=0)

    t = threading.Thread(target=_run, daemon=True)
    t.start()
