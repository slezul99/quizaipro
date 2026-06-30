# HANDOFF — QuizAIPro web redesign (production integration)

Continue this work. Read `DESIGN_SYSTEM_v2.md` and memory `project_web_redesign_v2` first.
Everything is **additive and local** — new `…/v2` routes + new `*_v2.html` templates.
**NEVER push, NEVER touch prod routes/templates** (working tree has a half-done
Postgres migration). Test user: `sunni` / `t5312011` (id 1). Local DB: `quizpro.db`.

## Goal
Roll out one unified design (sidebar shell + slim utility topbar, light+dark) to all
core screens, behind preview routes, with REAL data. Prod stays untouched until a later
switchover stage.

## Design language (locked) — full detail in DESIGN_SYSTEM_v2.md
- Page bg `#f6f5fb` (dark `linear-gradient(180deg,#0f1729,#141c38)`). Cards radius 20,
  one soft shadow, 1px border. Fonts: Space Grotesk (headings) + Inter (body).
  Brand `#6366f1/#8b5cf6/#ec4899`. ONE primary (gradient pill) + ONE ghost button.
- Shell: slim left sidebar = the only nav (Dashboard, My Library, Marketplace, AI Tutor,
  AI Generator, Flashcards, Quizzes, Notes, Analytics, Achievements + Settings + Upgrade
  card + mini user row). Slim topbar = utility only (search, bell, 🔥 streak, ⭐ XP,
  theme toggle, avatar). NO nav pills in the topbar.
- The 5 standalone prototypes (repo root, light+dark DONE) are the visual base:
  `dashboard_v2_prototype.html`, `profile_v2_prototype.html`, `deck_v2_prototype.html`,
  `marketplace_v2_prototype.html`, `levels_v2_prototype.html`.

## Integration pattern (how each screen is done)
1. Add a preview route in `app.py` (named `…_v2…`) that REUSES the existing route's data
   query and passes a clean context. Insert it **right before** the matching prod route.
2. Create `templates/<screen>_v2.html`: start from the matching `*_v2_prototype.html`,
   keep its chrome/CSS/dark-toggle EXACTLY, replace mock content with Jinja `{{ }}` from
   the context, `url_for('static', …)` for all assets. STANDALONE page (own `<html>`,
   Tailwind Play CDN + Google fonts) — do NOT extend base.html.
3. Verify live (see "Verify" below), light + dark.

## STATUS
ALL 5 SCREENS DONE + verified live (real data, light+dark):
- **Profile** — route `/u/<username>/v2` = `public_profile_v2()` in app.py;
  template `templates/profile_v2.html`. Verified at `/u/sunni/v2`.
- **Levels** — route `/growth/v2` = `growth_page_v2()`; template `templates/growth_v2.html`.
- **Marketplace** — route `/marketplace/v2` = `marketplace_v2_page()`;
  template `templates/marketplace_v2.html`. (Featured cover `<img>` now has an
  `onerror` gradient fallback for collections whose subject has no art.)
- **Deck** — route `/deck/<int:deck_id>/v2` = `deck_view_v2()`;
  template `templates/deck_v2.html` (DONE 2026-06-29). Built from `deck_v2_prototype.html`.
  Cover = deck `.icon` emoji on brand-gradient tile; title/meta/retention pill bound;
  one primary "▶ Study" + ghost group + tinted "+ Add card" + "⋯"; segmented filter with
  real counts; card loop with q/a + tag pill (new=indigo/learning=amber/hard=red).
  Display-only (prototype inline-edit row dropped). Verified at `/deck/21/v2`.
- **Dashboard** — route `/dashboard/v2` = `dashboard_v2_page()` (inserted right before
  prod `/dashboard`), reuses `_student_dashboard_data(user)`;
  template `templates/dashboard_v2.html` (DONE 2026-06-29). Built from
  `dashboard_v2_prototype.html`. Hero tiles → total/total_xp/streak_days/retention.now;
  Continue Learning → real `decks` (emoji tiles, learned/total %); Weekly Goal →
  week_done/week_days; Recent Activity → real `recent_activity`; Learning Analytics →
  `series`; Study Activity card → `by_category` progress bars. AI-Recommendations DROPPED
  (no data); Achievements = "Coming soon" placeholder (no fabricated numbers).
  Verified at `/dashboard/v2`.

## Remaining seams (cosmetic, pre-switchover)
- **Sidebar not unified across screens.** Each template kept its own prototype sidebar:
  deck/marketplace show the full 10-item nav; dashboard shows only 4. — DONE 2026-06-29:
  all 5 templates now carry the identical full shell (Dashboard · My Library · Marketplace ·
  AI Tutor · AI Generator · Flashcards · Quizzes · Notes · Analytics · Achievements · sep ·
  Settings · promo · user row). Sidebar Dashboard/Marketplace links point at the v2 routes
  (`dashboard_v2_page` / `marketplace_v2_page`) so the preview ring stays inside v2.
- **Deck list row 3 "icons"** — NOT a bug: `.row-actions` is `opacity:0`, shown on `:hover`
  (deck_v2.html:505/538). The earlier screenshot just had the cursor parked on row 3.
- **Stages 2 & 4 DONE 2026-06-29:**
  - i18n chrome — full RU/EN/UZ via `t()`. 147 `v2_*` keys (isolated namespace) added to
    i18n.py, present in all three langs (lens 1999/1999/1999, prod keys intact). 219 `t()`
    calls across the 5 templates. Dynamic hero line + "Review N due" pills localized via
    pre/post keys around the number (keeps `<strong>`). Switch language: `/set-lang/<ru|en|uz>`.
  - QA — all 5 screens shot in RU + dashboard in UZ, light/dark; no raw `v2_` keys, layout
    intact. Fixed a marketplace i18n-overflow: collection-card actions now `flex-wrap` +
    `flex:1` so "В библиотеку"/"Просмотр" stack full-width instead of clipping.
- **Art-director polish pass DONE 2026-06-29** (10-point review, via ui-designer agents):
  - dashboard_v2.html: (1) Continue-Learning tiles now big initial-letter on cycling brand
    gradients (was 3 identical 📥 placeholders); (2) hero stats given hierarchy — XP is the
    full-width hero stat, others compact, semantic icon colors (DESIGN_SYSTEM §3); (3) removed
    duplicated Weekly-Goal day labels; (4) analytics empty-states (real text via 3 new keys
    `v2_empty_no_reviews|no_xp|no_goal_progress`); (5) dark-mode `.hero-illus` panel darkened
    so the illustration stops glowing as a light block; (9) Recent-Activity icons now one
    neutral tint + a small grade-color dot. i18n total now 150 `v2_*` keys (2002/2002/2002).
  - marketplace_v2.html: (6) collection covers get a per-index brand tint + large corner
    initial watermark so same-art collections (Геогр/Анат/Биол) are distinguishable.
  - (8) topbar avatar unified to "S" across all 5 (dashboard was "Me").
  - (7) hero illustration KEPT as-is: it is NOT stock — it's Imagen-generated in the dashboard's
    coherent 3D art language (`tools/gen_dashboard_art.py`, same generator as subject art).
    Replacing it would break that artboard; AD call = leave it. (gen attempt in scratchpad unused.)
  - (10) deck "Новый вопрос" rows = 5 of 105 real user cards (data, not design); BD not touched.
- **Switchover via feature-flag DONE 2026-06-29 (owner said "do everything").** Added
  `_use_v2()` helper (after `set_lang` in app.py): reads `?v2=1`/`?v2=0`, persists in
  `session['use_v2']`, **default OFF** so prod behaviour is byte-identical without the flag.
  The 5 prod routes (`dashboard`, `deck_view`, `growth_page`, `marketplace`, `public_profile`)
  each delegate to their `*_v2*` function when `_use_v2()` is true. Verified live: `/dashboard?v2=1`
  → v2; clean `/dashboard` → old prod. NOT pushed. To make v2 the default for everyone, flip
  the default in `_use_v2()` (or gate by a user/beta field) — that is the real switchover.
- **STILL pending:**
  - **Commit is BLOCKED:** app.py mixes the 5 v2 routes with the half-done Postgres migration
    (+872/−88, many non-v2 hunks: register/api_card_grade/study_grade/marketplace_search…).
    No clean `git add -p` in this env. Committing app.py wholesale would drag the migration in.
    Resolve the migration first, OR commit only the untracked design files (templates/*_v2.html,
    *_v2_prototype.html, *.md) on a branch and leave routes for later.
  - **Tailwind prod build** — only needed to drop the Play CDN for prod performance; v2 works
    on CDN via the flag today. Optimization, not a blocker (memory `project_tailwind_rebuild`).
  - **Screen gaps** — sidebar items Flashcards/Quizzes/Notes/Analytics/AI Tutor are dead (no v2
    screens, no prototypes). Each is a NEW product screen (design+route+data+i18n), not polish —
    needs prototypes/requirements before building.
- `scratchpad/shoot_route.py` now takes an optional 3rd arg `lang` (ru|en|uz):
  `MSYS_NO_PATHCONV=1 python scratchpad/shoot_route.py "/dashboard/v2" dash en`.

## Verify (Windows, Git Bash + Playwright using system Chrome)
- Start server: `cd c:/Scripts/quizpro && PORT=5050 python app.py`
  (Flask dev server, **no autoreload** — restart after editing app.py.)
- Syntax check before restart: `python -c "import ast; ast.parse(open('app.py',encoding='utf-8').read())"`
- Screenshot script: `scratchpad/shoot_route.py` (logs in as sunni, shoots light+dark).
  Run: `MSYS_NO_PATHCONV=1 python <scratchpad>/shoot_route.py "/deck/21/v2" deck`
  → writes `rt_deck_light.png` / `rt_deck_dark.png`. The `MSYS_NO_PATHCONV=1` is REQUIRED
  so Git Bash doesn't mangle the leading-slash URL arg.
- Playwright launches with `channel="chrome"` (no playwright browser is installed).
- Kill server: taskkill the PID listening on :5050.

## Known seams (later stages, NOT blockers now)
- Mixed language: chrome strings are hardcoded English; data is localized by the routes
  via `t()`/DB. Full chrome i18n (RU/EN/UZ via `t()` keys) is a later stage.
- Tailwind: templates use the Play CDN. Production must compile classes into
  `static/tailwind.css` (purged build) — see memory `project_tailwind_rebuild`.
- After all 5 verified: i18n → Tailwind prod build → full QA → switchover (flip routes
  or feature-flag) → staging per roadmap.

## Assets
- Subject art: `static/subjects/{english,mathematics,programming,business,history,science}.jpg`
- Tree/level art: `static/trees/{1_seed…9_eternal}{,_wide}.webp`
- Dashboard hero: `static/dashboard/hero_ai.webp`
