# QuizAIPro — Design System v2

Reference for the web redesign. The five `*_v2_prototype.html` files are the
living implementation; this doc is the spec by which they (and the production
integration) are cut. Goal: one product, one language — fix the old "two
products" dissonance (premium gamified pages vs. flat SaaS-admin pages).

---

## 1. Foundations

### Color tokens
| Token | Light | Dark |
|---|---|---|
| `--page-bg` | `#f6f5fb` | `linear-gradient(180deg,#0f1729,#141c38)` |
| `--surface` (card) | `#ffffff` | `rgba(30,41,75,.65)` |
| `--surface-strong` | `#ffffff` | `rgba(20,28,56,.95)` |
| `--border` | `rgba(99,102,241,.12)` | `rgba(99,102,241,.18)` |
| `--text` | `#0f172a` | `#e2e8f0` |
| `--text-2` | `#334155` | `#cbd5e1` |
| `--text-muted` | `#64748b` | `#94a3b8` |
| sidebar | `#ffffff` | `#111a2e` |
| topbar | `rgba(255,255,255,.9)` | `rgba(15,23,41,.92)` |
| input bg | `#ffffff` | `rgba(15,23,41,.7)` |

**Brand:** `#6366f1` → `#8b5cf6` → `#ec4899` (tri-gradient). **Semantic:**
success `#10b981`, warning `#f59e0b`, danger `#ef4444`. Brand gradients and
semantic colors are identical in both themes.

> Rule: never hardcode `#0f172a`/`text-slate-900` for body text — use `var(--text)`
> so dark flips automatically. (This was the #1 dark-mode bug.)

### Type
- Headings/display: **Space Grotesk** (700–800, letter-spacing −0.02em).
- Body/UI: **Inter**.
- Overline: uppercase, tracked (`.08em`), 11px, `--text-muted` — used above every section title.

### Shape & elevation
- Card radius: **20px** (tiles/buttons keep their own scale; pills = 999px).
- Shadow (light): `0 4px 20px -6px rgba(100,90,70,.12)`.
- Shadow (dark): `0 12px 40px -8px rgba(0,0,0,.5)`.
- Motion ease: `cubic-bezier(0.16,1,0.3,1)`; hover lift `translateY(-2…4px)`.

---

## 2. App shell (identical on every page)

**Left sidebar (~240px, sticky, full height)** — the ONLY primary navigation:
Logo → Dashboard · My Library · Marketplace · AI Tutor · AI Generator ·
Flashcards · Quizzes · Notes · Analytics · Achievements → divider → Settings →
"Upgrade to Pro" card → mini user row (avatar + name + plan + kebab).
Active item = brand-tinted bg + brand text + left accent.

**Top bar (slim, utility only)** — search field (`⌘K`), notifications bell,
🔥 streak chip, ⭐ XP chip, theme toggle (sun/moon), round gradient avatar.
**No navigation links/pills in the top bar.** No logo (sidebar owns it).

Active-state map: Dashboard→Dashboard; Deck→My Library; Marketplace→Marketplace;
Profile & Levels→none (reached via avatar / streak chip).

---

## 3. Components

- **Buttons — exactly three roles.** `primary` = brand-gradient pill (one per
  view, the main action). `ghost` = translucent/white, subtle border, indigo
  text (all secondary/peer actions share this — e.g. the 4 deck study modes are
  identical ghosts). `overflow` = quiet round icon `⋯` for the long tail.
  A 4th "tinted" weight (indigo-tint bg) is allowed for a single distinct
  secondary like "+ Add card". **Never** color peer actions differently
  (the old green/orange/purple button salad is banned).
- **Card** — `--surface`, radius 20, 1px `--border`, one shadow. Same everywhere.
- **Stat card** — icon chip (rounded-square tinted) + value (Space Grotesk) +
  overline label. Give one hero stat visual priority; don't ship 4 identical boxes.
- **Image tile** (marketplace subjects, level stages) — full-bleed art,
  `object-fit:cover`, bottom-up scrim, white label + small caption pill. Shared
  language across marketplace & levels so they read as kin.
- **Cover card** (marketplace decks, dashboard courses) — cover image + top
  scrim for badge legibility, body (title 2-line clamp, meta), one primary +
  ghost action. Hover: lift + 5–7% image zoom.
- **Badge medallion** (achievements) — circular gradient disc + glow ring +
  emoji + name; locked = grayscale + lock. (Replaces bare emoji.)
- **"World" card** (profile Growth Journey) — stays dark in both themes; uses
  the real tree art to pull the gamified world into utilitarian pages.
- **Icon chips** — one style: rounded-square tinted bg + a clean line SVG or a
  single emoji. Don't mix three icon languages on one screen.

---

## 4. Principles (the "what was off")

1. **One temperature.** Stable tinted surface; never fade out to empty white —
   fill voids with intentional content (e.g. the Growth Journey card replaced an
   empty "no collections" box).
2. **One button system.** primary / ghost / overflow. Color = meaning, not decoration.
3. **Reuse real art.** Subject art on decks/marketplace; tree art on profile/levels.
4. **Hierarchy.** Every section: overline + title; one focal element per block.
5. **Gamified world bleeds everywhere.** The premium tree/level/marketplace energy
   is the brand — utilitarian screens inherit it, not the other way around.

---

## 5. Real assets
- Subject art: `static/subjects/{english,mathematics,programming,business,history,science}.jpg`
- Tree/level art: `static/trees/{1_seed…9_eternal}{,_wide}.webp` (square + wide)
- Dashboard hero: `static/dashboard/hero_ai.webp` (Imagen-generated)

## 6. Status / next
Design phase complete across 5 screens, light + dark. Next = production
integration into Flask/Jinja behind **preview routes** (prod untouched, no push):
real data binding, `t()` i18n keys, then local QA → staging. See memory
`project_web_redesign_v2`.
