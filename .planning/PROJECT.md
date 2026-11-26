# Repwise

## What This Is

Repwise is a public Android gym app (Flutter). Users build a weekly workout plan from a large, admin-curated exercise library. While training, they log each exercise's sets (reps × weight), and a home-screen widget walks them through today's exercises one at a time. Each session shows what they did last time. A later phase adds a protein tracker with manual entry and AI-parsed entry ("type what you ate").

## Core Value

At the gym, the user can see their current exercise and what they lifted last time, log it, and move to the next one. It works from the home-screen widget, without digging through the app.

## Requirements

### Validated

(None yet — ship to validate)

### Active

**Exercise library (admin-managed)**
- [ ] Exercise library of hundreds of exercises. Each has a major muscle group (back, chest, triceps, …), a specific target muscle, a GIF, a guide (how to perform), and notes
- [ ] Library seeded from an open dataset (e.g. public-domain free-exercise-db), then curated by the admin
- [ ] GIFs hosted on Cloudinary. The app loads optimised formats (MP4/WebP) through Cloudinary transformations
- [ ] Users can browse and search the library, filtered by muscle group and target muscle

**Admin panel**
- [ ] Express backend with server-rendered HTML pages (no separate SPA)
- [ ] Admin can create, edit and delete exercises (muscle group, target muscle, guide, notes, GIF upload to Cloudinary)
- [ ] Admin panel writes to Firestore through the `firebase-admin` SDK. Access is restricted to admins

**Auth**
- [ ] Sign in with Google
- [ ] Sign in with email and password (incl. password reset)
- [ ] No guest mode. An account is required

**Weekly plan**
- [ ] User builds a weekly plan: assigns exercises to days of the week
- [ ] Each planned exercise defines its sets, with target reps and weight per set
- [ ] User can edit, reorder and remove exercises in the plan

**Sessions / logging**
- [ ] User starts today's session from the plan and logs actual reps × weight per set
- [ ] Each exercise in a session shows what the user did last time for that exercise
- [ ] User can add sets during a session
- [ ] Session history is saved per user. Each session doc stores a small summary (e.g. total volume) for later stats

**Home-screen widget (main feature)**
- [ ] Android home-screen widget shows the current exercise of today's session with its sets (reps × weight)
- [ ] User can add a set from the widget
- [ ] "Mark done" completes the whole exercise and advances the widget to the next exercise
- [ ] Widget works offline and stays in sync with the app

**App shell & theming**
- [ ] Light and dark mode
- [ ] Screens designed externally. Claude supplies a design brief (pages, content, states, fonts, light/dark tokens) via /frontend-design

**Release**
- [ ] In-app updates via the `ota_update` package, downloading APKs published as GitHub Releases
- [ ] App checks the latest GitHub Release and prompts the user to update

**v1 extras (from scoping)**
- [ ] Rest timer, session notes, swap/skip exercise, ad-hoc sessions
- [ ] Session history, exercise history with personal bests, progression charts, weekly stats and streak
- [ ] Custom exercises, favourites, equipment filter, personal exercise notes
- [ ] Weekly muscle coverage: which muscles the plan covers and which were hit this week

**Protein tracker (v2, next milestone)**
- [ ] User logs food manually with protein grams
- [ ] User types what they ate in free text, and AI returns an itemised protein estimate
- [ ] AI calls go through the Express backend: Groq (free tier) first, Gemini as fallback. No AI keys in the app
- [ ] Daily protein total against a goal

**Trainers (later, not scoped yet)**
- [ ] Trainers create and manage workout plans for their clients (see TRNR-* in REQUIREMENTS.md)

### Out of Scope

- Guest / anonymous mode: the user decided an account is required
- iOS in v1: planned in about a year. Code should avoid Android-only shortcuts except the widget. Sign in with Apple is required at that point
- Google Play Store distribution in v1: OTA via GitHub Releases ships faster. Play Store is a later step for a large audience
- Google Drive for media: unreliable for hotlinking (rate limits, interstitials). Cloudinary chosen
- SQL / Postgres backend: Firestore fits the data, gives offline support, and matches shelf_snap's code flow
- Social features (friends, sharing, leaderboards): not part of the vision. The trainer → client link is a separate, planned feature
- Calling Groq/Gemini directly from the app: keys would be extractable from the APK

## Context

- Greenfield: fresh Flutter template (`repwise`, Dart SDK ^3.11.4). The init flag for "brownfield" was a false positive.
- The user's reference app is **shelf_snap** (`C:\Users\it\StudioProjects\shelf_snap`). Repwise copies its structure, code flow, naming and theme approach.
- Audience: a public app built for a large audience, not a personal or friends-only tool.
- Used in gyms, where signal is often poor. Offline behaviour matters for the plan, the last-session data and the widget.
- The user designs screens with a separate AI tool. Claude provides the design brief, not the visuals.
- The Express backend serves two roles: admin panel (HTML pages) and AI proxy for the protein tracker. It may live in its own folder or repo.

## Constraints

- **Tech stack (app)**: Flutter + Riverpod + Firebase (Firestore, Firebase Auth). This matches shelf_snap
- **Tech stack (backend)**: Node.js Express with server-rendered HTML and `firebase-admin`. Cloudinary for GIF upload. Groq → Gemini for AI
- **Code conventions**: follow shelf_snap exactly:
  - Layout is `lib/core/{config,layout,theme,utils,widgets}` and `lib/features/<feature>/{models,providers,repositories,services,screens,sheets,forms,widgets}`
  - File names are snake_case with role suffixes (`_model`, `_provider`, `_repository`, `_service`, `_screen`, `_sheet`, `_form`), and classes match file names
  - Data flows Firestore → Repository (`watchX` streams) → Riverpod providers gated on `currentUidProvider` → screen
  - Models are immutable with `fromMap(id, map)` / `toMap()`, and enums are stored by `.name`
  - Colours come only from `AppColors`/`AppTheme`, with no raw `Colors.*`. SnackBars give feedback
  - Imports are absolute package imports. Comments are short, with no divider comments
- **Platform**: Android only for v1. The home-screen widget is native Android (likely via `home_widget`)
- **Distribution**: direct APK and OTA (`ota_update` + GitHub Releases). Users must allow installs from unknown sources
- **Security**: AI keys and Cloudinary secrets stay server-side. Firestore security rules make the exercise library read-only for users, and each user can access only their own data
- **Timeline**: ship to production as soon as possible. Prioritise the core loop (library → plan → session → widget) over extras
- **AI cost**: Groq free tier as the primary provider, with Gemini fallback
- **Agent models**: Opus for planning, research, roadmap and debugging. Sonnet (lighter model) for code-writing and verification agents

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Firebase (Firestore + Auth) over SQL | Same flow as shelf_snap, offline cache for gym and widget use, data fits documents, no API or DB hosting needed | — Pending |
| Express admin panel with server-rendered HTML, writing via `firebase-admin` | Simple, no separate frontend. Admin bypasses client rules safely | — Pending |
| Express backend proxies AI (Groq → Gemini) | Keeps API keys out of the APK, and one place to switch providers | — Pending |
| Cloudinary for exercise GIFs | CDN delivery and GIF → MP4/WebP conversion. Google Drive rejected as unreliable | — Pending |
| Seed library from an open dataset | Avoids typing hundreds of exercises by hand. Admin curates afterwards | — Pending |
| OTA via `ota_update` + GitHub Releases | Fastest path to production. Android-only, Play Store later | — Pending |
| Google + email/password sign-in, no guest mode | User's choice. Apple sign-in added with iOS | — Pending |
| Widget "done" = whole exercise, with add-set from widget | User's definition of the core interaction | — Pending |
| Per-session summary fields | Lets stats work without heavy Firestore aggregation queries | — Pending |
| Protein tracker as a later phase | Core workout loop ships first | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-11-20 after initialization*
