# Repwise design brief

Paste this whole file into the design tool. It describes every screen, its states, the type, the colour tokens and the home-screen widget. Design for Android phones (360–412 dp wide), light and dark mode for every screen.

## The product in one paragraph

Repwise is a gym logbook for Android. People build a weekly plan from an exercise library, then log each set (reps × weight) while they train. The app always shows what they lifted last time, so the next set has a target. A home-screen widget walks them through today's exercises one at a time, so they rarely need to open the app mid-workout. It is used standing in a gym: sweaty thumbs, glances between sets, bright overhead light or a dim corner, poor signal.

## Design direction: chalk and iron

The look comes from the gym floor itself, not from fitness-app clichés (no black-and-neon-green, no all-caps shouty type, no gradients on everything).

- **Light mode is chalk.** A cool, slightly grey off-white, like a chalked palm. Not cream.
- **Dark mode is rubber flooring.** A deep blue-graphite, like a gym floor with blue fleck. Not pure black.
- **Colour comes from competition plates.** Cobalt blue (the 20 kg plate) is the brand colour. Plate yellow marks personal bests. Plate red is for errors and destructive actions. Plate green confirms completion. Colour is never decoration; each one means something.
- **Numbers are the hero.** Reps and weights are big, condensed and tabular, so they read at arm's length.

### The one memorable thing: ghost numbers

Every set row shows last session's numbers as a faint "ghost" in the same position and size as the live numbers. As the user types, the live numbers sit on top of the ghost. When a set beats last time (more weight, or same weight with more reps), the row gets a plate-yellow left edge and a small "Best" badge. That is the app's signature moment; keep everything else around it calm.

```
 Set   Reps    Weight
 1      8   ×  60 kg        ← done (green tick)
 2      8   ×  62.5 kg  ▌Best   ← beat last time (yellow edge)
 3     (8)  × (60) kg       ← ghost from last time, not yet logged
 + Add set
```

## Typography

One family: **Archivo** (Google Fonts, variable, with a width axis 62–125 and weight 100–900). Bundle the variable TTF in the app so the width axis works in Flutter. The width does the work that a second typeface usually would:

| Role | Width | Weight | Size / line height (sp) | Use |
|------|-------|--------|-------------------------|-----|
| Numeral XL | 75 (condensed) | 700 | 56 / 60 | Rest timer, session summary totals |
| Numeral L | 75 | 700 | 32 / 36 | Set rows (reps, weight) |
| Numeral M | 75 | 600 | 20 / 24 | Stats, chart labels, history rows |
| Title L | 112 (expanded) | 700 | 28 / 34 | Screen titles |
| Title M | 112 | 600 | 20 / 26 | Exercise names, card titles |
| Body | 100 | 400 | 16 / 24 | Guides, notes, general text |
| Body strong | 100 | 600 | 16 / 24 | Buttons, emphasis |
| Small | 100 | 500 | 13 / 18 | Supporting text, field labels, captions |

Rules:
- Numbers always use tabular figures so columns of sets line up.
- Sentence case everywhere. No all-caps labels, no letter-spaced eyebrows.
- Keep body text to about 60–70 characters per line (exercise guides especially).
- Minimum text size 13 sp. Respect the system font scale up to 1.3× without clipping.

## Colour tokens

Token names match the Flutter `AppColors` class (same naming as the shelf_snap app). Every token has a light and a dark value.

| Token | Light | Dark | Meaning |
|-------|-------|------|---------|
| `background` | `#F3F4F1` chalk | `#161B26` rubber floor | Screen background |
| `surface` | `#FFFFFF` | `#1F2533` | Cards, sheets, the active exercise panel |
| `surfaceMuted` | `#E9EBE7` | `#272E3E` | Input fields, chips, image placeholders |
| `text` | `#1C2230` | `#ECEEF2` | Primary text |
| `textSecondary` | `#5A6170` | `#A3AAB8` | Supporting text |
| `hint` | `#969CA8` | `#6E7687` | Placeholders, disabled |
| `ghost` | `#B9BEC7` | `#465066` | Last-time numbers behind live entries |
| `border` | `#DADDD6` | `#2E3546` | Dividers, outlines |
| `primary` | `#2348C8` cobalt | `#4467E6` | Brand, main buttons, selected states, filled muscles |
| `primaryDark` | `#17318F` | `#3355CC` | Pressed state |
| `primarySoft` | `#E2E8FA` | `#22305A` | Selected chip background, light muscle fill |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text on primary |
| `secondary` | `#F2C230` plate yellow | `#F5CB45` | Personal bests, streak |
| `secondarySoft` | `#FCF2CF` | `#3A3216` | Best badge background |
| `onSecondary` | `#1C2230` | `#161B26` | Text on yellow (always dark) |
| `success` | `#2F8A4E` plate green | `#4CB873` | Completed set, done exercise |
| `successSoft` | `#E1F1E6` | `#1B3526` | Done row tint |
| `error` | `#D33A2C` plate red | `#EF5B4C` | Errors, delete, end session early |
| `errorSoft` | `#FBE6E3` | `#3D1F1F` | Error banner background |
| `warning` | `#C9821B` | `#E6A23C` | Offline, unsynced |
| `warningSoft` | `#FBF0DC` | `#3A2C14` | Offline banner background |

Rules:
- Yellow means "personal best" and nothing else. Don't use it for generic highlights.
- Red appears only for errors and destructive actions.
- Body text on any background must meet WCAG AA (4.5:1).

## Layout and shape

- 4 dp spacing grid, 16 dp side gutter.
- Shape follows hierarchy rather than one radius everywhere: chips and inputs 8 dp, cards 14 dp, bottom sheets 24 dp on the top corners, primary buttons fully rounded (pill).
- Set rows are not cards. They are full-width rows separated by `border` dividers, like lines in a logbook.
- Touch targets at least 48 dp; the set row inputs and "Mark done" at least 56 dp, because they're used mid-workout.
- Left-align text. Centre only the rest timer and empty states.
- Elevation: no drop shadows on cards in light mode; use `surface` on `background` plus a `border` hairline. Bottom sheets and dialogs get one soft shadow.
- Icons: Material Symbols Rounded, weight 400, 24 dp.

## Motion

Keep it to moments that answer the user's action:
- **Mark done:** the finished exercise slides up and out, and the next one slides in from below (250 ms). This is the main transition in the app.
- **Personal best:** the yellow edge sweeps in once (300 ms) with a light haptic.
- **Rest timer:** a ring empties around the countdown; a haptic and sound when it hits zero.
- Respect "remove animations" in system settings.

## Navigation

Bottom navigation bar with four tabs: **Today**, **Plan**, **Library**, **Progress**. Profile and settings open from an avatar button at the top right of each tab. A running session shows as a persistent mini-bar above the bottom navigation ("Bench press, set 2 of 3"), and tapping it returns to the session.

## Screens

Each screen lists its content and the states to design. "All states" means: loading (skeleton, not a spinner), empty, error and offline.

### Auth

1. **Splash.** Logo mark on `background`. Holds while the sign-in state loads.
2. **Sign in.** App name and a one-line description ("Log every set. Beat last time."). "Continue with Google" button, then an email and password form with "Sign in". Links: "Forgot password?" and "Create an account". States: wrong password inline error, no connection, loading on the button.
3. **Create account.** Name, email, password (with show/hide), "Create account". States: email already used, weak password.
4. **Reset password.** Email field, "Send reset link". Success state: "Check your email for a link to reset your password."

### Today (home tab)

5. **Today.** Greeting and date. The main card is today's session:
   - Planned day: day name (e.g. "Push day"), list of exercises with set counts, estimated duration, and a big "Start workout" button.
   - Session in progress: progress (3 of 6 exercises) and "Resume workout".
   - Rest day: "Rest day" with tomorrow's plan as a preview, and a secondary "Start a workout anyway" button (ad-hoc session).
   - No plan yet: "Build your weekly plan" call to action.
   - Finished today: summary of what was done, with a link to the session.

   Below the card: this week's strip (seven day dots: done, planned, rest), streak, total volume this week, and a small front/back body figure showing muscles hit this week.

### Workout session

6. **Active session.** The core screen. Top: exercise name, target muscle, position ("Exercise 2 of 6") and a thin progress bar. A small GIF thumbnail that expands to full size on tap. "Last time" summary line (e.g. "Last time 3 sets, best 8 × 62.5 kg").
   - Set table as in the ghost-number sketch above. Tapping reps or weight opens a large numeric keypad sheet with +/− steppers (weight steps of 2.5 kg, reps steps of 1). Ticking a set marks it done and starts the rest timer.
   - Actions: "+ Add set", swipe a set row to remove it, a note field for this exercise, an overflow menu with "Swap exercise" and "Skip exercise".
   - Bottom: full-width "Mark done" button, which moves to the next exercise. An exercise list button opens the session outline.
   - States: set beat last time (yellow edge, Best badge), first time doing this exercise (no ghosts, "First time, set a baseline"), offline (small "Saved on this phone, will sync" note), skipped exercise.
7. **Rest timer.** An overlay sheet over the session: large countdown in Numeral XL, ring, "−15 s", "+15 s", "Skip rest". Shows the next set's target (ghost numbers). Collapses to a chip at the top of the session screen if dismissed.
8. **Session outline sheet.** All exercises in today's session with status (done, current, upcoming, skipped). Reorder by drag. Tap to jump.
9. **Swap exercise sheet.** Suggestions for the same target muscle first, then search across the library. Copy: "Swap for this session only."
10. **Finish session.** Confirmation if exercises are left ("2 exercises not done. Finish anyway?").
11. **Session summary.** Duration, total volume, sets done, muscles hit (body figure), personal bests listed with yellow badges. Optional session note. "Done" returns to Today.

### Plan

12. **Weekly plan.** Seven rows, Monday to Sunday. Each day shows its name (editable, e.g. "Pull day"), exercise count and the muscle groups it hits, or "Rest day". At the bottom: a muscle coverage panel with the front/back body figure shaded by weekly sets per muscle, plus a list of muscles with no work this week.
    - States: empty plan ("Build your week. Add exercises to the days you train."), offline.
13. **Day editor.** Day name, list of planned exercises with sets summary ("3 × 8 at 60 kg"), drag handles to reorder, swipe to remove, "Add exercises" button, toggle "Rest day".
14. **Add exercises (picker).** The library browser in multi-select mode with a counter and "Add 3 exercises" button.
15. **Planned exercise sheet.** Exercise name and thumbnail, set list where each set has target reps and weight, "+ Add set", "Copy set 1 to all", remove set. "Save".

### Library

16. **Library browse.** Search bar at the top. Muscle group tiles (Chest, Back, Shoulders, Biceps, Triceps, Legs, Glutes, Core, and so on), each with a muscle illustration and exercise count. Shortcuts row: Favourites, My exercises.
17. **Exercise list.** Results for a muscle group or a search. Each row: GIF thumbnail (still frame), name, target muscle, equipment, favourite star. Filter chips for target muscle and equipment, opening a filter sheet. States: no results ("No exercises match. Try another name or clear filters."), loading skeleton.
18. **Exercise detail.** Large looping GIF (MP4) at the top. Name, muscle group, target muscle, equipment chips. Sections: How to do it (numbered steps, since this is a real sequence), Notes from the coach, My notes (editable), Your history (best set, last done, link to the full history). Actions: favourite, "Add to plan".
19. **Favourites.** Same row style as the exercise list. Empty: "Star exercises to keep them here."
20. **My exercises / custom exercise form.** Name, muscle group, target muscle, equipment, notes, optional photo. Custom exercises show a small "Custom" tag in lists.

### Progress

21. **Progress overview.** This week's stats (workouts, streak, volume) at the top, the muscles-hit body figure, then session history grouped by week. Each session row: date, day name, duration, volume, number of personal bests.
22. **Session detail.** A past session's exercises and sets, read-only, with notes and the summary.
23. **Exercise history.** Personal best card (heaviest set and estimated one-rep max), chart with a toggle between top weight and volume over time (line chart in `primary`, best points marked in `secondary`), then a list of every session's sets for this exercise.

### Settings and system

24. **Profile and settings.** Name, email, avatar. Theme: System, Light, Dark. Weight unit (kg / lb). Rest timer default length. App version with "Check for updates". Sign out (destructive, confirm first).
25. **Update available.** Dialog: "Version 1.4.0 is available" with the release notes, "Update now" and "Later". During download: progress bar with percentage. Failure: "Download failed. Check your connection and try again."
26. **Offline banner.** A slim `warningSoft` bar: "You're offline. Workouts save on this phone and sync later."

## Home-screen widget

The widget is native Android (built with `home_widget`), so it has limits the design must respect:
- It uses the system font (`sans-serif`, and `sans-serif-condensed` for numbers), not Archivo.
- No free text entry. Buttons and taps only.
- Use the same colour tokens, switching with the system light/dark setting.

**Sizes:** 4×2 (minimum) and 4×3 (shows more sets). Resizable.

**Active state (4×2):**
```
┌──────────────────────────────────────┐
│ Bench press             2 of 6   ⋯   │
│ 1   8 × 60 kg     ✓                  │
│ 2   8 × 62.5 kg   ✓                  │
│ 3  (8 × 60 kg)                       │
│ [ + Set ]            [ Mark done ]   │
└──────────────────────────────────────┘
```
- Header: exercise name and position.
- Set rows: done sets in `text` with a green tick; upcoming sets as ghost numbers.
- Tapping a set row ticks it done using the planned or last-time numbers and starts the rest timer.
- "+ Set" adds a set that copies the previous set's numbers.
- "Mark done" (filled `primary`) completes the exercise and shows the next one.
- Tapping the exercise name opens the app on that exercise for editing numbers.

**Other states to design:**
- **Resting:** countdown in large numerals, "Next: set 3, 8 × 60 kg", "Skip rest".
- **Ready to start:** today's day name, number of exercises, "Start workout".
- **Rest day:** "Rest day. Next: Push day tomorrow."
- **No plan:** "Set up your weekly plan" and a tap opens the Plan tab.
- **Session finished:** "Workout done", duration and volume, and any personal bests in yellow.
- **Signed out:** "Sign in to Repwise".

## Assets needed

- App icon (adaptive Android icon, foreground and background layers) and a monochrome icon for themed icons.
- Logo mark for the splash and sign-in screens.
- Front and back body figure with separately fillable muscle regions (chest, front delts, side delts, rear delts, biceps, triceps, forearms, abs, obliques, traps, lats, upper back, lower back, glutes, quads, hamstrings, calves, adductors). SVG, so the app can colour each region.
- Muscle group tile illustrations (one per group, same style as the body figure).
- Widget preview image for the Android widget picker.

## Admin panel (web, lower priority)

A server-rendered web panel for the admin only. Same colour tokens and Archivo. Screens: sign in, exercise table with search and filters, exercise create/edit form with GIF upload and preview, archive confirmation, lists of muscle groups / target muscles / equipment, seed import page with progress and a result count. Functional and dense; no marketing polish needed.
