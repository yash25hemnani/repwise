# Requirements: Repwise

**Defined:** 2026-11-20
**Core Value:** At the gym, the user can see their current exercise and what they lifted last time, log it, and move to the next one. It works from the home-screen widget, without digging through the app.

## v1 Requirements

### Authentication

- [ ] **AUTH-01**: User can sign in with Google
- [ ] **AUTH-02**: User can create an account and sign in with email and password
- [ ] **AUTH-03**: User can reset their password via an email link
- [ ] **AUTH-04**: User stays signed in across app restarts
- [ ] **AUTH-05**: User can sign out

### Exercise Library

- [ ] **LIB-01**: User can browse exercises grouped by major muscle group
- [ ] **LIB-02**: User can filter exercises by target muscle and by equipment
- [ ] **LIB-03**: User can search exercises by name
- [ ] **LIB-04**: User can open an exercise and see its GIF, guide, notes, muscle group, target muscle and equipment
- [ ] **LIB-05**: User can favourite exercises and see their favourites list
- [ ] **LIB-06**: User can keep their own persistent notes on any exercise
- [ ] **LIB-07**: User can create private custom exercises and use them like library exercises
- [ ] **LIB-08**: Exercise GIFs load as optimised Cloudinary formats and are cached for offline viewing

### Admin Panel

- [ ] **ADMN-01**: Only admins can sign in to the Express admin panel
- [ ] **ADMN-02**: Admin can list, search and filter exercises
- [ ] **ADMN-03**: Admin can create and edit an exercise (name, muscle group, target muscle, equipment, guide, notes)
- [ ] **ADMN-04**: Admin can upload an exercise GIF, which is stored on Cloudinary
- [ ] **ADMN-05**: Admin can archive an exercise, which hides it from the library without breaking existing plans or history
- [ ] **ADMN-06**: Admin can run a one-time import that seeds the library from an open exercise dataset
- [ ] **ADMN-07**: Admin can manage the lists of muscle groups, target muscles and equipment

### Weekly Plan

- [ ] **PLAN-01**: User can build a weekly plan by assigning exercises to days, with any day left as a rest day
- [ ] **PLAN-02**: User can set the number of sets and the target reps and weight for each set
- [ ] **PLAN-03**: User can reorder, edit and remove exercises in a day
- [ ] **PLAN-04**: User can see which muscles their weekly plan covers

### Workout Session

- [ ] **SESS-01**: User can start today's session from their plan
- [ ] **SESS-02**: User can log the actual reps and weight for each set, prefilled from their last session
- [ ] **SESS-03**: User sees what they did last time for each exercise
- [ ] **SESS-04**: User can add or remove sets during a session
- [ ] **SESS-05**: User can swap an exercise for another for this session only
- [ ] **SESS-06**: User can skip an exercise
- [ ] **SESS-07**: User can start an ad-hoc session that isn't tied to the plan
- [ ] **SESS-08**: User can add a note to an exercise within a session
- [ ] **SESS-09**: A rest timer starts after a set is completed
- [ ] **SESS-10**: Finishing a session saves it with a summary (volume, duration, muscles hit)
- [ ] **SESS-11**: Sessions can be logged fully offline and sync when back online

### Home-Screen Widget

- [ ] **WIDG-01**: Android home-screen widget shows the current exercise and its sets (reps × weight)
- [ ] **WIDG-02**: User can add a set from the widget
- [ ] **WIDG-03**: "Mark done" completes the exercise and advances to the next one
- [ ] **WIDG-04**: Widget shows the rest timer after a completion
- [ ] **WIDG-05**: Widget and app stay in sync both ways, offline included
- [ ] **WIDG-06**: Widget shows a sensible state for no plan, a rest day, and a finished session, and tapping it opens the app

### Progress

- [ ] **PROG-01**: User can view session history and open any past session
- [ ] **PROG-02**: User can view an exercise's full history and personal best
- [ ] **PROG-03**: User can see weight and volume progression charts per exercise
- [ ] **PROG-04**: User sees weekly stats: workouts done, streak and total volume
- [ ] **PROG-05**: User sees which muscles they've hit this week, based on completed sessions

### Theme

- [ ] **THEM-01**: App supports light and dark mode (follows the system, with a manual override)
- [ ] **THEM-02**: A design brief (pages, content, states, fonts, light/dark tokens) is produced for external screen design

### Release

- [ ] **REL-01**: App checks the latest GitHub Release and prompts when an update is available
- [ ] **REL-02**: User can download and install the update in-app via `ota_update`
- [ ] **REL-03**: Release APKs are signed with one persistent key, so updates install over the old version without data loss

## v2 Requirements

Deferred to the next milestone. Tracked but not in the current roadmap.

### Protein Tracker

- **PROT-01**: User can log food manually with protein grams
- **PROT-02**: User can type what they ate in free text and get an itemised protein estimate from AI
- **PROT-03**: AI calls go through the Express backend, with Groq first and Gemini as fallback. No keys in the app
- **PROT-04**: User sees their daily protein total against a goal
- **PROT-05**: User can view their protein history

### Trainers

Idea noted 2026-11-26. Not scoped yet; the details below are a first draft.

- **TRNR-01**: An account can be a trainer. The role is granted by an admin, never self-set by the user
- **TRNR-02**: A trainer can link to clients, and the client accepts the link
- **TRNR-03**: A trainer can create and edit workout plans for their clients
- **TRNR-04**: A client trains from a trainer-made plan like their own, widget included

Keep in mind before then:
- Plans live under the client and record who authored them, so trainer-made plans need no migration
- The user doc's role field must not be writable by the user (Firestore rules or custom claims)
- Firestore rules will need a trainer → linked-client write exception to "each user accesses only their own data"

### Platform

- **PLAT-01**: iOS release with Sign in with Apple
- **PLAT-02**: Google Play Store release

## Out of Scope

| Feature | Reason |
|---------|--------|
| Guest / anonymous mode | User decided an account is required |
| Google Drive media hosting | Unreliable for hotlinking (rate limits, interstitials). Cloudinary chosen |
| SQL / Postgres backend | Firestore fits the data, works offline, matches shelf_snap |
| Social features (friends, sharing, leaderboards) | Not part of the vision |
| Calling Groq/Gemini directly from the app | Keys would be extractable from the APK |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| AUTH-01 | Phase 1 | Pending |
| AUTH-02 | Phase 1 | Pending |
| AUTH-03 | Phase 1 | Pending |
| AUTH-04 | Phase 1 | Pending |
| AUTH-05 | Phase 1 | Pending |
| THEM-01 | Phase 1 | Pending |
| THEM-02 | Phase 1 | Pending |
| REL-01 | Phase 1 | Pending |
| REL-02 | Phase 1 | Pending |
| REL-03 | Phase 1 | Pending |
| ADMN-01 | Phase 2 | Pending |
| ADMN-02 | Phase 2 | Pending |
| ADMN-03 | Phase 2 | Pending |
| ADMN-04 | Phase 2 | Pending |
| ADMN-05 | Phase 2 | Pending |
| ADMN-06 | Phase 2 | Pending |
| ADMN-07 | Phase 2 | Pending |
| LIB-01 | Phase 2 | Pending |
| LIB-02 | Phase 2 | Pending |
| LIB-03 | Phase 2 | Pending |
| LIB-04 | Phase 2 | Pending |
| LIB-08 | Phase 2 | Pending |
| PLAN-01 | Phase 3 | Pending |
| PLAN-02 | Phase 3 | Pending |
| PLAN-03 | Phase 3 | Pending |
| SESS-01 | Phase 3 | Pending |
| SESS-02 | Phase 3 | Pending |
| SESS-03 | Phase 3 | Pending |
| SESS-04 | Phase 3 | Pending |
| SESS-09 | Phase 3 | Pending |
| SESS-10 | Phase 3 | Pending |
| SESS-11 | Phase 3 | Pending |
| WIDG-01 | Phase 4 | Pending |
| WIDG-02 | Phase 4 | Pending |
| WIDG-03 | Phase 4 | Pending |
| WIDG-04 | Phase 4 | Pending |
| WIDG-05 | Phase 4 | Pending |
| WIDG-06 | Phase 4 | Pending |
| SESS-05 | Phase 5 | Pending |
| SESS-06 | Phase 5 | Pending |
| SESS-07 | Phase 5 | Pending |
| SESS-08 | Phase 5 | Pending |
| LIB-05 | Phase 5 | Pending |
| LIB-06 | Phase 5 | Pending |
| LIB-07 | Phase 5 | Pending |
| PLAN-04 | Phase 6 | Pending |
| PROG-01 | Phase 6 | Pending |
| PROG-02 | Phase 6 | Pending |
| PROG-03 | Phase 6 | Pending |
| PROG-04 | Phase 6 | Pending |
| PROG-05 | Phase 6 | Pending |

**Coverage:**
- v1 requirements: 51 total
- Mapped to phases: 51
- Unmapped: 0

---
*Requirements defined: 2026-11-20*
*Last updated: 2026-11-26 after noting trainers as a v2 idea*
