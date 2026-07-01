# -*- coding: utf-8 -*-
"""Background jobs dlya AI generatsii kart (text/topic/pdf).
Analogichno vision_jobs.py — khranim sostoyanie v pamyati + disk.
"""
import os
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

# === Optional Redis mirror — ACTIVE ONLY when REDIS_URL is set ==============
# Makes job STATE readable across gunicorn workers and after a restart (the
# in-memory _jobs dict above is per-process and cleared on restart, so the
# progress page could not find a job whose worker had recycled). The running
# generation thread still uses the in-memory dict as the source of truth; Redis
# is a best-effort shared mirror that get_job() falls back to. Soft-fail: if
# REDIS_URL is unset / the package is missing / the server is down, everything
# behaves exactly as before (memory + disk only).
_REDIS_TTL = 86400  # keep job state for 24h
_redis = None
_REDIS_URL = os.environ.get("REDIS_URL", "").strip()
if _REDIS_URL:
    try:
        import redis as _redis_lib
        _redis = _redis_lib.from_url(
            _REDIS_URL, socket_timeout=1.5, socket_connect_timeout=1.5,
            decode_responses=True,
        )
        _redis.ping()
    except Exception as _e:
        _redis = None
        print(f"[ai_gen_jobs] Redis mirror disabled: {type(_e).__name__}: {_e}")


def _rk(jid: str) -> str:
    return f"aigen:job:{jid}"


def _serialize(job: dict) -> str:
    safe = {k: (v.isoformat() if isinstance(v, datetime) else v) for k, v in job.items()}
    return _json.dumps(safe, ensure_ascii=False)


def _deserialize(s: str) -> dict:
    d = _json.loads(s)
    ca = d.get("created_at")
    if isinstance(ca, str):
        try:
            d["created_at"] = datetime.fromisoformat(ca)
        except ValueError:
            pass
    return d


def _mirror_to_redis(jid: str, job: dict):
    """Best-effort mirror; never let a Redis hiccup break job processing."""
    if _redis is None:
        return
    try:
        _redis.set(_rk(jid), _serialize(job), ex=_REDIS_TTL)
    except Exception as e:
        print(f"[ai_gen_jobs] redis mirror err: {e}")


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
    _mirror_to_redis(jid, job)
    return jid


def get_job(jid: str) -> dict | None:
    with _lock:
        j = _jobs.get(jid)
    if j is not None:
        return j
    # Not in this process's memory — the worker may have restarted or a sibling
    # worker owns it. Fall back to the shared Redis mirror so the progress page
    # still resolves the job's status.
    if _redis is not None:
        try:
            v = _redis.get(_rk(jid))
            if v:
                return _deserialize(v)
        except Exception as e:
            print(f"[ai_gen_jobs] redis get err: {e}")
    return None


def update_job(jid: str, **kwargs):
    snapshot = None
    with _lock:
        if jid in _jobs:
            _jobs[jid].update(kwargs)
            _save_to_disk(jid, _jobs[jid])
            snapshot = dict(_jobs[jid])
    if snapshot is not None:
        _mirror_to_redis(jid, snapshot)


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

            # === AUTO-FIND ANSWERS: AI opredelyaet pravil'nye otvety ===
            try:
                import ai_gen as _ai_gen
                if _ai_gen.is_available() or _ai_gen.is_deepseek_available():
                    _job_lang = (get_job(jid) or {}).get("lang", "ru")
                    update_job(jid, stage_msg="AI проверяет правильные ответы...")
                    all_cards = _ai_gen.auto_find_answers(all_cards, lang=_job_lang)
                    update_job(jid, stage_msg=f"Создано {len(all_cards)} карточек, сохраняем...")
            except Exception as _afa_err:
                print(f"[ai_gen_jobs] auto_find_answers err (ignorируем): {_afa_err}")

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


def start_ai_photo_job(jid: str, topic: str, count: int, lang: str, save_fn):
    """Zapuskaem generatsiyu s fotografiyami v fone."""
    def _run():
        update_job(jid, status="running", stage_msg="AI генерирует вопросы...", progress=5)
        try:
            import ai_gen as _ai_gen

            def _progress(done, total, msg):
                pct = int(10 + (done / max(total, 1)) * 75)
                update_job(jid, cards_done=done, progress=pct, stage_msg=msg)

            cards = _ai_gen.generate_with_photos(topic, count, lang, progress_cb=_progress)

            if not cards:
                update_job(jid, status="error",
                           error="AI не смог сгенерировать карточки с фото. Попробуйте другую тему.",
                           progress=0)
                return

            update_job(jid, cards_done=len(cards), cards_total=len(cards),
                       progress=88, stage_msg=f"Сохраняем {len(cards)} карточек...")

            deck_id = save_fn(cards)
            photos_count = sum(1 for c in cards if c.get("image_url"))
            update_job(jid, status="done", result_cards=cards,
                       result_deck_id=deck_id, progress=100,
                       cards_done=len(cards),
                       stage_msg=f"Готово! {len(cards)} карточек, {photos_count} с фото.")
        except Exception as e:
            err = str(e)[:300]
            print(f"[ai_gen_jobs:{jid}] photo error: {err}")
            update_job(jid, status="error", error=f"Ошибка: {err}", progress=0)

    t = threading.Thread(target=_run, daemon=True)
    t.start()
