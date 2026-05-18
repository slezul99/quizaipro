# -*- coding: utf-8 -*-
"""SM-2 spaced repetition algoritm + smart-mix queue 50/30/20."""
import random
from datetime import datetime, timedelta


def calc_sm2(card: dict, grade: int) -> dict:
    """Vozvraschayet obnovlennuyu kartu posle ocenki (0-5).
    grade 0-2 = lapse (sbros), 3 = sloznо, 4 = horosho, 5 = legko."""
    ef = card.get("ef") or 2.5
    reviews = (card.get("reviews") or 0) + 1
    interval = card.get("interval_days") or 0
    lapses = card.get("lapses") or 0

    # SM-2 EF update
    ef = ef + (0.1 - (5 - grade) * (0.08 + (5 - grade) * 0.02))
    if ef < 1.3:
        ef = 1.3

    if grade < 3:
        # Lapse - sbros
        interval = 0
        lapses += 1
    else:
        if reviews == 1:
            interval = 1
        elif reviews == 2:
            interval = 6
        else:
            interval = max(1, round(interval * ef))

    due_at = (datetime.utcnow() + timedelta(days=interval)).isoformat()

    return {
        "ef": round(ef, 3),
        "interval_days": interval,
        "reviews": reviews,
        "lapses": lapses,
        "due_at": due_at,
    }


def build_smart_queue(cards: list, count: int = 0) -> list:
    """Smart-mix: 50% novyh, 30% s lapses, 20% repetition.
    count=0 - vse dostupnye."""
    now = datetime.utcnow().isoformat()

    new_cards = [c for c in cards if (c.get("reviews") or 0) == 0]
    lapse_cards = [
        c for c in cards
        if (c.get("lapses") or 0) > 0 and (c.get("reviews") or 0) > 0
        and (not c.get("due_at") or c["due_at"] <= now)
    ]
    review_cards = [
        c for c in cards
        if (c.get("lapses") or 0) == 0 and (c.get("reviews") or 0) > 0
        and (not c.get("due_at") or c["due_at"] <= now)
    ]

    random.shuffle(new_cards)
    random.shuffle(lapse_cards)
    random.shuffle(review_cards)

    if count == 0:
        return new_cards + lapse_cards + review_cards

    n_new = round(count * 0.5)
    n_lap = round(count * 0.3)
    n_rev = count - n_new - n_lap

    queue = new_cards[:n_new] + lapse_cards[:n_lap] + review_cards[:n_rev]
    if len(queue) < count:
        used_ids = {c["id"] for c in queue}
        rest = [c for c in (new_cards + lapse_cards + review_cards)
                if c["id"] not in used_ids]
        queue += rest[:count - len(queue)]

    random.shuffle(queue)
    return queue[:count]


def card_level(card: dict) -> str:
    """Krat. opisanie urovnya karty."""
    if not (card.get("reviews") or 0):
        return "new"
    interval = card.get("interval_days") or 0
    if interval < 1: return "learning"
    if interval < 7: return "young"
    if interval < 30: return "mature"
    return "mastered"


def card_difficulty(card: dict) -> dict:
    """Avto-opredelenie slozhnosti karty po istorii otvetov.
    Vozvrashaet {key, label, icon, color}."""
    reviews = card.get("reviews") or 0
    lapses = card.get("lapses") or 0
    interval = card.get("interval_days") or 0
    last_grade = card.get("last_grade")

    if reviews == 0:
        return {"key": "new", "label": "Новая", "icon": "🌱", "color": "slate"}

    # Otnoshenie lapses k reviews
    lapse_rate = lapses / reviews if reviews else 0

    # Trudnaya: chasto putaesh' ili posledny otvet ploho
    if lapse_rate > 0.3 or (last_grade is not None and last_grade < 3):
        return {"key": "hard", "label": "Трудная", "icon": "💪", "color": "red"}

    # Usvoyena: davno znaesh', interval bol'shoy
    if interval >= 30 and lapses == 0:
        return {"key": "mastered", "label": "Усвоена", "icon": "🎓", "color": "emerald"}

    # Lyogkaya: stabil'no pravil'no
    if reviews >= 5 and lapses == 0 and interval >= 7:
        return {"key": "easy", "label": "Лёгкая", "icon": "✨", "color": "blue"}

    # Izuchayetsya
    return {"key": "learning", "label": "Изучается", "icon": "📖", "color": "amber"}
