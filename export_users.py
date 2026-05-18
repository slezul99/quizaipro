# -*- coding: utf-8 -*-
"""Eksport spiska zaregistrirovannykh polzovateley QuizPro v fayl."""
import csv
from datetime import datetime
from pathlib import Path

import db

OUT_DIR = Path(__file__).parent / "users_export"
OUT_DIR.mkdir(exist_ok=True)


def export():
    conn = db.get_conn()
    users = conn.execute("""
        SELECT u.id, u.username, u.role, u.full_name, u.lang,
               u.xp, u.streak, u.last_study, u.created_at,
               o.name AS org_name
        FROM users u
        LEFT JOIN organizations o ON o.id = u.org_id
        ORDER BY u.created_at DESC
    """).fetchall()
    conn.close()

    if not users:
        print("[!] Net zaregistrirovannykh polzovateley")
        return

    stamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")

    # CSV (otkroetsya v Excel)
    csv_path = OUT_DIR / f"users_{stamp}.csv"
    with open(csv_path, "w", newline="", encoding="utf-8-sig") as f:
        w = csv.writer(f, delimiter=";")
        w.writerow([
            "ID", "Имя пользователя", "Роль", "Полное имя", "Язык",
            "XP", "Streak", "Последнее изучение", "Регистрация",
            "Организация"
        ])
        for u in users:
            w.writerow([
                u["id"], u["username"], u["role"], u["full_name"] or "",
                u["lang"], u["xp"], u["streak"],
                (u["last_study"] or "")[:19],
                (u["created_at"] or "")[:19],
                u["org_name"] or "—"
            ])
    print(f"[OK] CSV: {csv_path.name}")

    # Tekstovyy otchet (chitaemyy)
    txt_path = OUT_DIR / f"users_{stamp}.txt"
    with open(txt_path, "w", encoding="utf-8") as f:
        f.write(f"=== Полzоvateli QuizPro ({len(users)} chelovek) ===\n")
        f.write(f"Otchet: {datetime.now().strftime('%d.%m.%Y %H:%M')}\n\n")

        # Razdelyaem po rolyam
        by_role = {}
        for u in users:
            by_role.setdefault(u["role"], []).append(u)

        for role, group in by_role.items():
            f.write(f"\n--- {role.upper()} ({len(group)}) ---\n")
            for i, u in enumerate(group, 1):
                org = f" [{u['org_name']}]" if u["org_name"] else " [individual]"
                full = f" - {u['full_name']}" if u["full_name"] else ""
                created = (u["created_at"] or "")[:10]
                f.write(f"{i}. {u['username']}{full}{org}\n")
                f.write(f"   Reg: {created} · XP: {u['xp']} · 🔥 {u['streak']}\n")

    print(f"[OK] TXT: {txt_path.name}")
    print(f"\n[INFO] Vsego: {len(users)} polzovateley")
    print(f"[INFO] Papka: {OUT_DIR}")


if __name__ == "__main__":
    export()
