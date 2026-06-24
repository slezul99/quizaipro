# AI Tutor MVP — Audit & Build

## 1. Architecture
- **Model layer** (`ai_gen.py`): single model, Vertex **gemini-3.5-flash** (Dev-key
  fallback), retries/backoff, metrics. Two call shapes:
  `_call_gemini(prompt, schema)` → JSON (generation), `_gemini_text(prompt)` →
  free prose (tutor actions). `is_available()` gates everything.
- **Three scopes** for the tutor, each grounded in real data:
  - **Card** — stateless prompt actions on one card's front/back.
  - **Deck** — generation/analysis over a deck's cards.
  - **Collection** — planning over a collection's decks.
- **Conversational tutor** (`/tutor/stream` SSE, `/diagnose`, `/followup`) with
  **`db.tutor_learner_context`** (the user's weak cards from SRS) injected for
  personalization → this is the Phase-4 hook (progress-aware) and already exists.

## 2. Existing backend audit
| Capability | Status |
|---|---|
| Card **Explain** | ✅ `/ai/explain` → `ai_gen.explain_question` |
| Conversational tutor (chat/diagnose/followup, learner context) | ✅ `/tutor/*` (phase-5 gate) |
| Generation (topic/text/pdf), find-answers | ✅ `/ai/generate/*`, `/ai/find-answers` |
| Progress data (SRS, reviews, weak-card context) | ✅ `user_card_progress`, `reviews`, `tutor_learner_context` |
| Mobile: tutor chat (SSE), explain_card, ai_studio | ✅ |

## 3. Missing endpoints (by phase)
- **P1 Card:** simplify / example / translate / analogy (explain existed).
- **P2 Deck:** quiz-me / weak-areas / practice-questions / mini-test / summary (deck-scoped).
- **P3 Collection:** learning-plan / difficult-topics / revision-schedule / knowledge-gaps.
- **P4 Progress-aware:** weave `tutor_learner_context` (+ retention) into P2/P3.

## 4. MVP plan (highest value first)
1. **P1 Card Actions** — turns *every card* into a tutor; reuses the proven
   explain path; stateless, low-risk. ← **DONE (backend, verified)**
2. **P2 Deck Tutor** — quiz/weak/summary over the deck's cards + the user's
   progress on them.
3. **P3 Collection Tutor** — plan/gaps across the collection.
4. **P4** — progress everywhere (weak cards, retention).

---

## P2 Deck Tutor — architecture & delivery

**1. Architecture.** Deck-level guidance with strict separation:
- **Data-grounding layer** (`api_v1/ai_generation.py` helpers) reads the
  learner's *real* state — never mocked — and renders it to compact prompt
  text: `_deck_learner_rows` (every card LEFT JOINed with the user's
  `user_card_progress`), `_deck_recent_failures` (recent `reviews` with
  grade ≤ 2), `_rank_weak_cards` (worst-first by lapses / last_grade /
  FSRS retrievability), `fsrs.deck_retention` + `fsrs.card_retrievability`
  (retention now / 7-day forecast / fading count).
- **AI layer** (`ai_gen.py`) shapes the prompt + parses structured JSON via
  `_call_gemini(response_schema=…)`; functions never invent content, they
  only consume the grounding text. Per-feature `label` feeds `ai_metrics`.
- **Endpoint layer** gates (JWT, `is_available`, deck access, rate-limit),
  assembles grounding, calls the AI fn, returns `{"data": …}`.

**2. New endpoints** (all `POST`, JWT, shared rate-limit `api_ai_deck_tutor`
12/min; deck access = owner / same-org / public):
| Endpoint | Body | Returns |
|---|---|---|
| `/api/v1/ai/deck/<id>/quiz` | `{count?=5, 3-15}` | `{questions:[{question,options,correct_index,explanation,focus}], weak_card_count}` |
| `/api/v1/ai/deck/<id>/mini-test` | `{count?=6, 3-15}` | `{questions:[{…,difficulty:easy\|medium\|hard}]}` |
| `/api/v1/ai/deck/<id>/weak-areas` | — | `{has_data, weakest_topics:[{topic,why}], weakest_cards:[{front,reason}], focus_areas:[…], summary, retention}` |
| `/api/v1/ai/deck/<id>/summary` | — | `{key_concepts:[{title,explanation}], common_mistakes:[…], important_facts:[…]}` |

Errors: `404 not_found` (no access), `400 empty_deck`, `503 ai_unavailable`,
`429 rate_limited`. Weak-areas returns `has_data:false` (no AI call) when the
deck is unstudied, and empty arrays (no AI call) when studied-but-strong.

**3. Data sources used:** `cards` (deck content) · `user_card_progress`
(ef/stability/difficulty/reviews/lapses/last_grade/last_reviewed/due_at) ·
`reviews` (recent failures) · `fsrs` retention/retrievability. Weak-first
selection + retention are the Phase-4 progress-aware hook, already wired in.

**4. Verification (real Gemini, deck 307 "IELTS Academic Synonyms",**
**user 3 — 10 studied cards, 8 weak, retention 83%→49%/7d, 8 fading):**
- ✅ **Quiz** — 4 MCQs, every one `focus:"weak"`, on the user's actual weak
  words (STRINGENT/TRANSIENT/DELINEATE/TENTATIVE) — adaptive weighting works.
- ✅ **Mini-test** — 5 MCQs spanning `difficulty` easy→hard over different deck
  words (incl. a "hard" INHERENT item) — balanced mix works.
- ✅ **Weak areas / Summary** — grounded JSON _(see below; one initial run hit a
  transient Gemini 503 which the code degraded to `None`→503, then succeeded on
  retry)_.
- Validators (`_valid_mcq`, schema-required fields) + `_parse_ai_json`
  (fence/bracket tolerant) confirmed; `py_compile` clean.

**5. Mobile integration plan** (next, mirrors the P1 vertical):
- **Domain:** `DeckTutorRepository` + entities `DeckQuiz`/`MiniTest`
  (`QuizQuestion{question,options,correctIndex,explanation,focus?}`),
  `WeakAreas{topics,cards,focusAreas,summary,retention,hasData}`,
  `DeckSummary{keyConcepts,commonMistakes,importantFacts}`; 4 use cases.
- **Data:** remote DS (4 `POST /ai/deck/{id}/…`), DTOs, repo impl
  (`Either<Failure,…>`), mapper.
- **Presentation:** a **Deck Tutor sheet** (4 actions) opened from the
  library deck screen / deck editor; reuse the MCQ runner UI for quiz +
  mini-test (auto-grade via `correct_index`), and a scrollable result screen
  for weak-areas + summary. Per-action loading/error/retry like P1.
- **Analytics:** extend `TutorAnalytics` with `logDeckAction(action, deckId)`
  (deck-tutor usage / quiz / weak-area / summary); backend already records AI
  usage via `ai_metrics` labels.
- **l10n:** `deckTutor*` keys (titles, action labels, difficulty chips,
  empty/no-data states) in en/ru/uz.

---

## Build progress

### ✅ P1 Card Actions — backend DONE & verified (real Gemini, no mock)
- `ai_gen._gemini_text(prompt, …)` — free-text model call (reused across tutor).
- `ai_gen.card_action(question, answer, action, lang, target_lang)` — actions
  `explain | simplify | example | analogy | translate`; cleans MCQ prefixes;
  outputs in the user's language (or `target_lang` for translate).
- `POST /api/v1/ai/card-action` — `{action, question, answer, target_lang?}` →
  `{action, result}`; JWT, validation, rate-limit (20/min). `/ai/explain` kept
  for backward compat (mobile).
- **Verified on real Gemini:** all 5 actions return quality output; endpoint
  200/400/401 correct, 0 server errors.

### ✅ P1 Card Actions — mobile DONE (code-complete; device-verified by owner)
Full vertical generalizing the explain flow to all 5 actions:
- **Domain:** `CardAction` enum (explain/simplify/example/analogy/translate,
  `apiName`), `CardActionUseCase` + `CardActionParams`.
- **Data:** `cardAction(...)` on repo interface/impl + remote
  (`POST /ai/card-action`, body `{action, question, answer, deck_id?,
  target_lang?}` → `data.result`).
- **Presentation:** `cardActionUseCaseProvider`, `CardActionNotifier`
  (family by action/question/answer/deck/targetLang, `.run()`),
  `CardActionResultScreen` (reuses explain UX: loading/error/retry/data),
  `card_actions_sheet.dart` premium one-tap sheet (5 actions), shared
  `CardActionPresentation` labels/icons.
- **Study screen:** AI ✨ button in the session header → opens the sheet with
  the current card (`front/back/id/deckId`).
- **Route:** `AppRoutes.aiCardAction` (`/ai/card-action`) full-screen.
- **Analytics:** `TutorAnalytics.logCardAction(action, cardId, deckId,
  collectionId)` — dev-log + bounded rolling buffer in Hive settings
  (`tutor_events`), fire-and-forget. Fired from the sheet on tap.
- **i18n:** `tutorActions*` / `tutorAction<Action>(Desc)` keys in en/ru/uz.
- **Translate** target = the user's app language (ru→Russian, uz→Uzbek,
  else English).
- Verified: `gen-l10n` + `build_runner` clean; `flutter analyze` of the new
  files = 0 errors (1 style `info`, matching existing notifiers).

### ✅ P2 Deck Tutor — backend DONE & verified (real Gemini, real data, no mock)
- `ai_gen.deck_quiz / deck_mini_test / deck_weak_areas / deck_summary` — all
  grounded in passed-in real deck content + weak/retention text; structured
  JSON via `_call_gemini(response_schema)`; validated (`_valid_mcq`,
  `_parse_ai_json`); transient AI failure → `None`.
- `api_v1/ai_generation.py`: helpers `_deck_access`, `_deck_learner_rows`,
  `_deck_recent_failures`, `_rank_weak_cards` (FSRS retrievability),
  `_retention_summary_text`; 4 routes `POST /ai/deck/<id>/{quiz,mini-test,
  weak-areas,summary}` (JWT, access check, rate-limit 12/min).
- **Verified** end-to-end on deck 307 (user 3, real SRS history): quiz
  weighted to actual weak cards (`focus:"weak"`), mini-test mixed easy→hard,
  weak-areas cited the real 49%/7d retention forecast, summary taught the
  deck's real words. `py_compile` clean.

### ✅ P2 Deck Tutor — mobile DONE (code-complete; device-verified by owner)
New `features/deck_tutor/` vertical (clean arch):
- **Domain:** `DeckTutorAction` enum (quiz/weakAreas/miniTest/summary); read
  entities `TutorQuizQuestion`, `DeckQuiz`, `DeckWeakAreas` (+`DeckRetention`,
  `WeakTopic`, `WeakCardRef`), `DeckSummaryResult` — hand-written `fromJson`
  (pure read models, DTO+mapper collapsed).
- **Data:** `DeckTutorRemoteDataSource` (4 `POST /ai/deck/{id}/…`),
  `DeckTutorRepositoryImpl` (`Either<Failure,…>`, `_fromDio` maps 401/429/503).
- **Presentation:** infra + on-demand `FutureProvider` families
  (`deckQuiz/deckMiniTest/deckWeakAreas/deckSummary`, retry = invalidate);
  shared `DeckTutorAsyncView` (loading/error/retry).
  - **`TutorQuizScreen`** — MCQ runner shared by Quiz Me + Mini Test: reuses
    `TestProgressBar`, one-tap answer→reveal (green/red), explanation,
    weak-focus / difficulty chips, final score (`testsScoreFraction`),
    New-quiz / Done.
  - **`DeckWeakAreasScreen`** (flagship) — retention hero (now% + bar +
    forecast + fading + studied/total), weakest topics, cards-to-review,
    focus recommendations, AI summary; `has_data:false` → study-first empty
    state; studied-but-strong → "all strong" card.
  - **`DeckSummaryScreen`** — key concepts cards, common-mistakes & important-
    facts bullet lists.
  - **`showDeckTutorSheet`** — premium 4-action sheet (Weak Areas flagged
    "Smart"); opened from a gradient **AI Tutor entry** on the library deck
    detail screen (gated on `cardCount > 0`).
- **Routes:** `deckTutorQuiz` (quiz+mini-test via `action`), `deckTutorWeakAreas`,
  `deckTutorSummary`.
- **Analytics:** `TutorAnalytics.logDeckAction(action, deckId, collectionId?,
  completed)` — fired on sheet tap (started) and on quiz completion.
- **i18n:** 34 `deckTutor*` keys in en/ru/uz (reuses `dashboardRetention*`,
  `testsScoreFraction`).
- Verified: `gen-l10n` + `build_runner` clean; `flutter analyze` of the new
  feature/analytics/router = **0 issues**.

### ⏭ After P2 — verify usage/UX/learning value on device, then decide
**Collection Tutor vs Billing** as the next phase (owner's call).
