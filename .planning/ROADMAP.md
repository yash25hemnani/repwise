# Roadmap: Repwise

## Overview

Repwise ships as a series of vertical slices, and each slice goes to real users through the OTA pipeline. Phase 1 delivers a signed-in, themed app shell that updates itself from GitHub Releases. It also produces the design brief, so screens can be designed externally while the code is built. Phase 2 stands up the Express admin panel (a separate Node project in its own folder), seeds the library from an open dataset, and lets users browse it. Phase 3 adds the weekly plan and the offline-first session engine, so users can log against last time. Phase 4 delivers the core value: the home-screen widget, which drives today's session without opening the app. Phases 5 and 6 add the v1 extras after the core loop is live. Phase 5 covers flexible sessions and a personal library. Phase 6 covers progress, stats and muscle coverage. Phases 5 and 6 don't depend on each other and can be swapped.

## Phases

**Phase Numbering:**
- Integer phases (1, 2, 3): Planned milestone work
- Decimal phases (2.1, 2.2): Urgent insertions (marked with INSERTED)

Decimal phases appear between their surrounding integers in numeric order.

- [ ] **Phase 1: Foundation, Auth & OTA Release** - Signed-in, themed app shell that installs and updates itself from GitHub Releases, plus the design brief
- [ ] **Phase 2: Exercise Library & Admin Panel** - Express admin panel seeds and curates the library; users browse, filter, search and view exercises
- [ ] **Phase 3: Weekly Plan & Workout Logging** - Users build a weekly plan and log today's session offline against what they did last time
- [ ] **Phase 4: Home-Screen Widget** - Android widget shows the current exercise, adds sets, marks exercises done and stays in sync with the app
- [ ] **Phase 5: Flexible Sessions & Personal Library** - Swap, skip, ad-hoc sessions and session notes; favourites, personal notes and custom exercises
- [ ] **Phase 6: Progress & Muscle Coverage** - Session and exercise history, personal bests, progression charts, weekly stats and muscle coverage

## Phase Details

### Phase 1: Foundation, Auth & OTA Release
**Goal:** As a lifter, I want to install Repwise, sign in and get updates in-app, so that I always run the latest build without losing my account.
**Mode:** mvp
**Depends on**: Nothing (first phase)
**Requirements**: AUTH-01, AUTH-02, AUTH-03, AUTH-04, AUTH-05, THEM-01, THEM-02, REL-01, REL-02, REL-03
**Success Criteria** (what must be TRUE):
  1. User can install the release APK and sign in with Google, or create an account and sign in with email and password. The app can't be used without an account
  2. User can reset a forgotten password through an emailed link, stays signed in after closing and reopening the app, and can sign out
  3. App follows the system light/dark mode, and a manual override stays in place across restarts
  4. When a newer GitHub Release is published, the app prompts the user, then downloads and installs the APK in-app over the old version. The user is still signed in afterwards, with their settings intact
  5. The user has a design brief covering every v1 screen and the widget (pages, content, empty/loading/error states, fonts, light/dark tokens), ready for the external design tool
**Plans**: TBD
**UI hint**: yes

### Phase 2: Exercise Library & Admin Panel
**Goal:** As a lifter, I want to browse, filter and study an admin-curated library of hundreds of exercises, so that I know what each movement trains and how to do it.
**Mode:** mvp
**Depends on**: Phase 1
**Requirements**: ADMN-01, ADMN-02, ADMN-03, ADMN-04, ADMN-05, ADMN-06, ADMN-07, LIB-01, LIB-02, LIB-03, LIB-04, LIB-08
**Success Criteria** (what must be TRUE):
  1. Only admin accounts can sign in to the Express admin panel. After the admin runs the one-time seed import, the app's library holds hundreds of exercises, which app users can read but never modify
  2. Admin can list, search and filter exercises. Admin can create and edit them (name, muscle group, target muscle, equipment, guide, notes), upload a GIF that is stored on Cloudinary, and manage the muscle group, target muscle and equipment lists
  3. Admin can archive an exercise. It disappears from the app's library, but its record is kept, not deleted
  4. User can browse exercises by major muscle group, filter by target muscle and equipment, and search by name
  5. User can open an exercise and see its GIF (as an optimised Cloudinary format), guide, notes, muscle group, target muscle and equipment. A GIF the user has viewed before still plays with no connection
**Plans**: TBD
**UI hint**: yes

### Phase 3: Weekly Plan & Workout Logging
**Goal:** As a lifter, I want to build a weekly plan and log today's session against it, so that I can see what I lifted last time and beat it.
**Mode:** mvp
**Depends on**: Phase 2
**Requirements**: PLAN-01, PLAN-02, PLAN-03, SESS-01, SESS-02, SESS-03, SESS-04, SESS-09, SESS-10, SESS-11
**Success Criteria** (what must be TRUE):
  1. User can assign library exercises to days of the week, leave any day as a rest day, and set the number of sets and the target reps and weight for each set
  2. User can reorder, edit and remove exercises within a day
  3. User can start today's session from the plan and sees what they did last time for each exercise. They log actual reps and weight per set (prefilled from last time) and can add or remove sets
  4. A rest timer starts when the user completes a set
  5. Finishing a session saves it with a summary (volume, duration, muscles hit). A whole session logged in airplane mode syncs once the phone is back online
**Plans**: TBD
**UI hint**: yes

### Phase 4: Home-Screen Widget
**Goal:** As a lifter, I want to run today's session from a home-screen widget, so that I can train without digging through the app.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: WIDG-01, WIDG-02, WIDG-03, WIDG-04, WIDG-05, WIDG-06
**Success Criteria** (what must be TRUE):
  1. During a session, the home-screen widget shows the current exercise and its sets (reps × weight)
  2. User can add a set from the widget. Tapping "Mark done" completes the exercise, shows the rest timer and moves to the next exercise
  3. Changes made in the widget show up in the app and the other way round, including with no connection
  4. The widget shows a clear state for no plan, a rest day and a finished session, and tapping it opens the app
**Plans**: TBD
**UI hint**: yes

### Phase 5: Flexible Sessions & Personal Library
**Goal:** As a lifter, I want to adapt sessions on the fly and personalise the exercise library, so that the app fits how I actually train.
**Mode:** mvp
**Depends on**: Phase 4
**Requirements**: SESS-05, SESS-06, SESS-07, SESS-08, LIB-05, LIB-06, LIB-07
**Success Criteria** (what must be TRUE):
  1. User can swap an exercise for another for this session only, leaving the plan unchanged, and can skip an exercise. The widget follows either change
  2. User can start an ad-hoc session that isn't tied to the plan and log it like a planned one
  3. User can add a note to an exercise during a session, and the note is saved with the session
  4. User can favourite exercises, open a favourites list, and keep persistent personal notes on any exercise
  5. User can create private custom exercises and add them to plans and sessions just like library exercises
**Plans**: TBD
**UI hint**: yes

### Phase 6: Progress & Muscle Coverage
**Goal:** As a lifter, I want to see my history, personal bests, weekly stats and muscle coverage, so that I know I'm progressing and training evenly.
**Mode:** mvp
**Depends on**: Phase 3
**Requirements**: PLAN-04, PROG-01, PROG-02, PROG-03, PROG-04, PROG-05
**Success Criteria** (what must be TRUE):
  1. User can view their session history and open any past session to see every set they logged
  2. User can open an exercise's full history with its personal best, and see weight and volume progression charts for it
  3. User sees weekly stats: workouts done, current streak and total volume
  4. User can see which muscles their weekly plan covers and which they've actually hit this week in completed sessions
**Plans**: TBD
**UI hint**: yes

## Progress

**Execution Order:**
Phases execute in numeric order: 1 → 2 → 3 → 4 → 5 → 6

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Foundation, Auth & OTA Release | 0/TBD | Not started | - |
| 2. Exercise Library & Admin Panel | 0/TBD | Not started | - |
| 3. Weekly Plan & Workout Logging | 0/TBD | Not started | - |
| 4. Home-Screen Widget | 0/TBD | Not started | - |
| 5. Flexible Sessions & Personal Library | 0/TBD | Not started | - |
| 6. Progress & Muscle Coverage | 0/TBD | Not started | - |
