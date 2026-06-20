# -*- coding: utf-8 -*-
"""FSRS-5 spaced-repetition scheduler.

Modern replacement for SM-2 (sm2.calc_sm2). Models each card with two latent
variables instead of a single ease factor:

  • stability  (S)  — days for recall probability to fall from 100% to 90%.
  • difficulty (D)  — 1..10, intrinsic hardness; nudged by every answer.

From S and the elapsed time it computes retrievability R (probability you'd
recall the card right now) and schedules the next review so R lands on the
target retention (default 0.90). This adapts intervals to the card AND the
person far better than SM-2's fixed 1→6→×EF ladder.

calc_fsrs() is a drop-in for sm2.calc_sm2(): same call shape, and the returned
dict is a SUPERSET of SM-2's (still carries ef / interval_days / reviews /
lapses / due_at) so existing persistence, smart-queue and difficulty labels
keep working unchanged — it just adds `stability` and `difficulty`.

Default weights are the public FSRS-4.5/5 defaults; they work well out of the
box and can later be optimised per-user from the `reviews` log.
"""
import math
from datetime import datetime, timedelta

# --- Model constants -------------------------------------------------------
# 19 default parameters (FSRS-4.5/5). w[0..3] = initial stability per rating.
W = [
    0.40255, 1.18385, 3.173, 15.69105, 7.1949, 0.5345, 1.4604, 0.0046,
    1.54575, 0.1192, 1.01925, 1.9395, 0.11, 0.29605, 2.2698, 0.2315,
    2.9898, 0.51655, 0.6621,
]
DECAY = -0.5
FACTOR = 0.9 ** (1.0 / DECAY) - 1.0   # = 19/81 ≈ 0.2345679
TARGET_RETENTION = 0.90               # schedule so recall prob ≈ 90% at due

MIN_D, MAX_D = 1.0, 10.0
MIN_S = 0.01
MAX_INTERVAL = 36500                  # 100y cap

# Ratings (FSRS scale)
AGAIN, HARD, GOOD, EASY = 1, 2, 3, 4


# --- Helpers ---------------------------------------------------------------
def _clamp(x, lo, hi):
    return lo if x < lo else hi if x > hi else x


def grade_to_rating(grade: int) -> int:
    """Map the app's 0-5 grade scale to an FSRS rating (1-4).

    0-2 = forgot → Again, 3 = Сложно → Hard, 4 = Хорошо → Good, 5 = Лёгко → Easy.
    """
    if grade <= 2:
        return AGAIN
    if grade == 3:
        return HARD
    if grade == 4:
        return GOOD
    return EASY


def retrievability(elapsed_days: float, stability: float) -> float:
    """Probability of recalling the card now, given days since last review."""
    if stability <= 0:
        return 0.0
    return (1.0 + FACTOR * max(elapsed_days, 0.0) / stability) ** DECAY


def _interval_for(stability: float, retention: float = TARGET_RETENTION) -> int:
    """Days until retrievability decays to `retention`."""
    ivl = (stability / FACTOR) * (retention ** (1.0 / DECAY) - 1.0)
    return int(_clamp(round(ivl), 1, MAX_INTERVAL))


def _init_difficulty(rating: int) -> float:
    d = W[4] - math.exp(W[5] * (rating - 1)) + 1.0
    return _clamp(d, MIN_D, MAX_D)


def _next_difficulty(d: float, rating: int) -> float:
    delta = -W[6] * (rating - 3)
    d_new = d + delta * (10.0 - d) / 9.0          # linear damping near the edges
    # Mean-reversion toward the "Easy" anchor keeps D from drifting forever.
    d_new = W[7] * _init_difficulty(EASY) + (1.0 - W[7]) * d_new
    return _clamp(d_new, MIN_D, MAX_D)


def _next_stability_recall(d, s, r, rating):
    hard_penalty = W[15] if rating == HARD else 1.0
    easy_bonus = W[16] if rating == EASY else 1.0
    inc = (math.exp(W[8]) * (11.0 - d) * (s ** -W[9])
           * (math.exp(W[10] * (1.0 - r)) - 1.0) * hard_penalty * easy_bonus)
    return s * (1.0 + inc)


def _next_stability_forget(d, s, r):
    s_f = (W[11] * (d ** -W[12]) * ((s + 1.0) ** W[13] - 1.0)
           * math.exp(W[14] * (1.0 - r)))
    return min(s_f, s)   # forgetting must not increase stability


# --- Legacy bridge ---------------------------------------------------------
def _seed_from_sm2(card: dict):
    """Approximate FSRS state (S, D) from a card that only has SM-2 fields, so
    existing progress carries over instead of restarting from scratch."""
    interval = card.get("interval_days") or 0
    ef = card.get("ef") or 2.5
    stability = max(float(interval), 1.0)
    # ef 1.3 (hard) → D≈10 ; ef 2.5 (easy) → D≈2.
    difficulty = _clamp(11.0 - ((ef - 1.3) / 1.2) * 9.0, MIN_D, MAX_D)
    return stability, difficulty


def _elapsed_days(card: dict, now: datetime) -> float:
    """Days since the card was last reviewed (0 if unknown / first FSRS review).
    Must NOT fall back to due_at — that is the FUTURE due date, not the past."""
    last = card.get("last_reviewed")
    if not last:
        return 0.0
    try:
        dt = datetime.fromisoformat(str(last).replace("Z", ""))
        return max((now - dt).total_seconds() / 86400.0, 0.0)
    except Exception:
        return 0.0


# --- Public API ------------------------------------------------------------
def calc_fsrs(card: dict, grade: int, now: datetime = None) -> dict:
    """Drop-in replacement for sm2.calc_sm2.

    `card` is the current user_card_progress row (dict). `grade` is 0-5.
    Returns the updated state (superset of SM-2's output).
    """
    now = now or datetime.utcnow()
    rating = grade_to_rating(grade)

    reviews = (card.get("reviews") or 0) + 1
    lapses = card.get("lapses") or 0
    stability = card.get("stability")
    difficulty = card.get("difficulty")

    first_review = not (card.get("reviews") or 0)

    if first_review and not stability:
        # Brand-new card: initialise from the rating.
        stability = max(W[rating - 1], MIN_S)
        difficulty = _init_difficulty(rating)
    else:
        if not stability:
            # Legacy SM-2 card meeting FSRS for the first time — seed it.
            stability, difficulty = _seed_from_sm2(card)
        elapsed = _elapsed_days(card, now)
        r = retrievability(elapsed, stability)
        difficulty = _next_difficulty(difficulty, rating)
        if rating == AGAIN:
            stability = _next_stability_forget(difficulty, stability, r)
            lapses += 1
        else:
            stability = _next_stability_recall(difficulty, stability, r, rating)

    stability = max(stability, MIN_S)

    if rating == AGAIN:
        interval = 0                       # relearn today (mirrors SM-2 lapse)
    else:
        interval = _interval_for(stability)

    due_at = (now + timedelta(days=interval)).isoformat()

    out = dict(card)                       # preserve unrelated fields
    out.update({
        "stability": round(stability, 4),
        "difficulty": round(difficulty, 4),
        "interval_days": interval,
        "reviews": reviews,
        "lapses": lapses,
        "due_at": due_at,
        "last_grade": grade,
        "last_reviewed": now.isoformat(),
        # keep `ef` populated for backward compat (not used by FSRS scheduling)
        "ef": card.get("ef") or 2.5,
    })
    return out


def deck_retention(cards: list, now: datetime = None, horizon_days: int = 7) -> dict:
    """Aggregate memory state for a deck (list of user_card_progress dicts).

    Returns a small summary the UI can show to make invisible forgetting
    visible and actionable:
      • now       — average recall probability across studied cards (%, 0-100)
      • forecast  — what it drops to in [horizon_days] with no review (%)
      • fading    — studied cards already below target retention (due to slip)
      • studied   — how many cards have been reviewed at least once
      • total     — total cards in the deck
    Returns now/forecast = None when nothing has been studied yet.
    """
    now = now or datetime.utcnow()
    studied = [c for c in cards if (c.get("reviews") or 0) > 0]
    if not studied:
        return {"now": None, "forecast": None, "fading": 0,
                "studied": 0, "total": len(cards)}

    sum_now = 0.0
    sum_future = 0.0
    fading = 0
    for c in studied:
        s = c.get("stability")
        if not s:
            s, _ = _seed_from_sm2(c)        # estimate for legacy SM-2 cards
        elapsed = _elapsed_days(c, now)
        r_now = retrievability(elapsed, s)
        sum_now += r_now
        sum_future += retrievability(elapsed + horizon_days, s)
        if r_now < TARGET_RETENTION:
            fading += 1

    n = len(studied)
    return {
        "now": round(sum_now / n * 100),
        "forecast": round(sum_future / n * 100),
        "fading": fading,
        "studied": n,
        "total": len(cards),
    }


if __name__ == "__main__":
    # Quick sanity check: a fresh card answered Good a few times should grow
    # its interval, and a lapse should collapse it.
    from copy import deepcopy
    c = {"ef": 2.5, "interval_days": 0, "reviews": 0, "lapses": 0}
    t = datetime(2026, 1, 1)
    print("rating  S       D      interval(d)")
    for i in range(5):
        c = calc_fsrs(c, 4, now=t)          # answer "Хорошо"
        print(f"Good   {c['stability']:<7} {c['difficulty']:<6} {c['interval_days']}")
        t = datetime.fromisoformat(c["due_at"])  # study exactly when due
    lap = calc_fsrs(deepcopy(c), 1, now=t)      # forgot
    print(f"Again  {lap['stability']:<7} {lap['difficulty']:<6} {lap['interval_days']}")
