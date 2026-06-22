# -*- coding: utf-8 -*-
"""Add a "Математика с нуля" learning path under the Mathematics subject, so the
subject page shows the Учебные пути section like English/Programming.

Slug-based + idempotent (INSERT OR IGNORE). Steps link the math collections in
a sensible learning order.
"""
import db

conn = db.get_conn()
c = conn.cursor()

subj = c.execute("SELECT id FROM mp_subjects WHERE slug='mathematics'").fetchone()
if not subj:
    print("[math_path] mathematics subject missing — skip")
    conn.close()
    raise SystemExit
SUBJ = subj[0]


def upsert_path(slug, ru, en, uz, dru, den, duz, icon, c1, c2, diff, hours, sort):
    c.execute("""INSERT OR IGNORE INTO learning_paths
        (slug,subject_id,title_ru,title_en,title_uz,desc_ru,desc_en,desc_uz,
         icon,color,color2,difficulty,estimated_hours,sort_order,is_active)
        VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,1)""",
        (slug, SUBJ, ru, en, uz, dru, den, duz, icon, c1, c2, diff, hours, sort))
    return c.execute("SELECT id FROM learning_paths WHERE slug=?", (slug,)).fetchone()[0]


def coll_id(slug):
    r = c.execute("SELECT id FROM collections WHERE slug=?", (slug,)).fetchone()
    return r[0] if r else None


def add_step(path_id, order, coll_slug, ru, en, uz):
    cid = coll_id(coll_slug)
    if not cid:
        return
    c.execute("""INSERT OR IGNORE INTO learning_path_steps
        (path_id,step_order,step_type,collection_id,title_ru,title_en,title_uz)
        VALUES (?,?,?,?,?,?,?)""",
        (path_id, order, "collection", cid, ru, en, uz))


p = upsert_path("math-basics-path",
    "Математика с нуля", "Mathematics from Scratch", "Matematika noldan",
    "Полный путь: алгебра, геометрия, статистика и подготовка к экзамену.",
    "Full path: algebra, geometry, statistics and exam preparation.",
    "To'liq yo'l: algebra, geometriya, statistika va imtihonga tayyorgarlik.",
    "🔢", "#10b981", "#059669", "beginner", 6, 1)

add_step(p, 1, "math-algebra", "Шаг 1: Алгебра", "Step 1: Algebra", "1-bosqich: Algebra")
add_step(p, 2, "math-geometry", "Шаг 2: Геометрия", "Step 2: Geometry", "2-bosqich: Geometriya")
add_step(p, 3, "math-statistics", "Шаг 3: Статистика", "Step 3: Statistics", "3-bosqich: Statistika")
add_step(p, 4, "math-calculus", "Шаг 4: Математический анализ", "Step 4: Calculus", "4-bosqich: Matematik tahlil")
add_step(p, 5, "math-exam-prep", "Шаг 5: Подготовка к экзамену", "Step 5: Exam prep", "5-bosqich: Imtihonga tayyorgarlik")

conn.commit()
conn.close()
print("[math_path] done — 'Математика с нуля' path added.")
