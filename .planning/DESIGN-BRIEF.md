# Repwise design brief

This file is written to be pasted into Google Stitch. First paste **Global style** on its own. Then paste one **screen prompt** at a time. Each screen prompt stands alone, so it can be regenerated without the others. Design for an Android phone (412 × 915) in light mode first, then ask Stitch for the dark version of each screen.

## Design goal: one thing per screen

Repwise is used in a gym, between sets, with sweaty thumbs and a few seconds of attention. Every screen answers one question and has one main button. If something isn't needed for that answer, it goes behind a tap. When unsure, leave it out.

## Global style (paste this first)

> A calm, uncluttered Android gym logbook app called Repwise, in Material 3. Light mode uses a cool chalk off-white background #F3F4F1 (not cream). Cards are white #FFFFFF with a thin #DADDD6 border and no shadows. Text is dark blue-grey #1C2230, and secondary text is #5A6170. The single brand colour is cobalt blue #2348C8, used only for the main button on each screen and for selected states. Plate yellow #F2C230 appears only when the user beats their previous best. Green #2F8A4E means a set or exercise is done. Red #D33A2C is only for delete and errors. Typeface: DM Sans for everything. Numbers use tabular figures and are large and bold. Sentence case everywhere, with no all-caps labels. Generous whitespace, 16 dp side margins, and left-aligned text. Each screen has one obvious primary action as a full-width pill-shaped cobalt button at the bottom. Icons are Material Symbols Rounded. Bottom navigation has three tabs: Today, Plan, Progress. No gradients, no illustrations of people, no stock photos, no decorative graphics.

Dark mode version, to request after each light screen:

> Make a dark mode version of this screen. Use background #161B26 (deep blue-graphite, not pure black), cards #1F2533 with border #2E3546, text #ECEEF2, secondary text #A3AAB8, cobalt #4467E6, yellow #F5CB45, green #4CB873 and red #EF5B4C. Keep everything else identical.

## Colour tokens

These names match the Flutter `AppColors` class. Stitch only needs the hex values in the global style above.

| Token | Light | Dark | Used for |
|-------|-------|------|----------|
| `background` | `#F3F4F1` | `#161B26` | Screen background |
| `surface` | `#FFFFFF` | `#1F2533` | Cards, sheets |
| `surfaceMuted` | `#E9EBE7` | `#272E3E` | Input fields, chips |
| `text` | `#1C2230` | `#ECEEF2` | Main text |
| `textSecondary` | `#5A6170` | `#A3AAB8` | Supporting text, the "Last time" column |
| `border` | `#DADDD6` | `#2E3546` | Card outlines, row dividers |
| `primary` | `#2348C8` | `#4467E6` | Main button, selected tab, links |
| `primarySoft` | `#E2E8FA` | `#22305A` | Selected chip background |
| `onPrimary` | `#FFFFFF` | `#FFFFFF` | Text on cobalt |
| `secondary` | `#F2C230` | `#F5CB45` | Personal best only |
| `secondarySoft` | `#FCF2CF` | `#3A3216` | Personal best row tint |
| `success` | `#2F8A4E` | `#4CB873` | Done tick |
| `error` | `#D33A2C` | `#EF5B4C` | Errors, delete |
| `warningSoft` | `#FBF0DC` | `#3A2C14` | Offline banner |

Colour rules:
- Each screen has one cobalt button. Other buttons are outlined or text buttons.
- Yellow means "you beat last time" and nothing else.
- Body text meets WCAG AA contrast (4.5:1).

## Type scale (DM Sans)

| Role | Weight | Size / line height (sp) | Used for |
|------|--------|-------------------------|----------|
| Number XL | 700 | 48 / 52 | Rest timer, workout summary totals |
| Number L | 700 | 28 / 32 | Reps and weight in set rows |
| Title L | 700 | 26 / 32 | Screen titles |
| Title M | 600 | 18 / 24 | Exercise names, card titles |
| Body | 400 | 16 / 24 | General text |
| Body strong | 600 | 16 / 24 | Buttons |
| Small | 500 | 13 / 18 | Column labels, captions |

Numbers always use tabular figures. The minimum text size is 13 sp. Layouts must not clip at 1.3× system font scale.

## Layout rules

- 16 dp side margins and a 4 dp spacing grid.
- Corner radius by role: inputs and chips 8 dp, cards 14 dp, bottom sheets 24 dp, buttons fully rounded.
- Set rows are plain lines with dividers, not cards.
- Touch targets are at least 48 dp. Set inputs and the main button are 56 dp tall.
- A screen holds one card, one list and one main button at most. Anything more goes on another screen or behind a tap.

## Navigation

Three bottom tabs: **Today**, **Plan**, **Progress**. The settings gear sits at the top right of Today only. During a workout, the bottom tabs are replaced by the workout screen itself. Leaving it shows a slim bar above the tabs, for example "Bench press, set 2 of 3 · Resume", until the workout ends.

## Screen prompts

### 1. Sign in

> Sign in screen for Repwise. Small cobalt logo mark and the word "Repwise" near the top, with one line under it: "Log every set. Beat last time." Below that, an outlined "Continue with Google" button with the Google G icon, a thin divider with "or", then email and password fields and a full-width cobalt "Sign in" button. Underneath are two text links on separate lines: "Forgot password?" and "Create an account". Lots of empty space and nothing else.

Other states: an inline error under the password field ("Wrong password. Try again or reset it."), and a spinner inside the button while signing in. Create account (name, email, password, "Create account") and Reset password (email, "Send reset link", then "Check your email for a reset link.") use the same layout.

### 2. Today: workout planned

> Home screen of a gym app. Top left: "Thursday" as the title, with "Good morning, Alex" in small grey text under it. Top right: a settings gear icon. Under the header, one white card shows today's workout: the title "Push day", then "5 exercises · about 50 min" in grey, then a short plain list of the five exercise names (Bench press, Overhead press, Incline dumbbell press, Lateral raise, Triceps pushdown), each with "3 sets" on the right in grey. Below the card, a row of seven small circles labelled M T W T F S S: filled green for done days, a cobalt ring for today, and empty grey for rest days. At the bottom, a full-width cobalt "Start workout" button above the bottom navigation (Today selected, Plan, Progress). No charts, stats or other cards.

Other states, with the same layout and only the card changing:
- **Workout in progress:** the card reads "Push day · 2 of 5 done" and the button reads "Resume workout".
- **Rest day:** the card reads "Rest day" with "Tomorrow: Pull day" in grey. There is an outlined button, "Start a workout anyway", and no cobalt button.
- **No plan yet:** the card reads "Plan your week" with "Pick the days you train and the exercises for each." The cobalt button reads "Build my plan".
- **Done today:** the card reads "Workout done" with duration and sets, plus a yellow "2 new bests" line if any. The button reads "See workout".

### 3. Workout: logging an exercise (the core screen)

> Workout logging screen in a gym app, focused on one exercise. Top bar: a back arrow, the small grey text "Exercise 2 of 5" in the centre, and a ⋮ menu on the right. Below that: a small square thumbnail of an exercise animation on the left and the large title "Bench press" beside it, with "Chest" under it in grey. Then a set table with four columns and small grey column labels: "Set", "Last time", "Reps", "kg", plus a narrow tick column. Each row is a plain line with a divider. The "Last time" column shows last session's numbers in grey, such as "8 × 60". Reps and kg are large rounded input boxes with big bold numbers. Row 1 is done: green tick, values 8 and 60. Row 2 is done and beat last time: values 8 and 62.5, a pale yellow row background, a thin yellow left edge and a small yellow "New best" pill. Row 3 is not done yet: the inputs show 8 and 60 as grey placeholder text and an empty tick circle. Under the table is a text button, "+ Add set". At the bottom is a full-width cobalt "Next exercise" button. No bottom navigation on this screen.

States:
- **Resting:** a slim bar appears directly above "Next exercise". It shows a large countdown "1:24" on the left, "Rest" in grey, and "−15", "+15" and "Skip" text buttons on the right. The bar's background slowly fills with pale cobalt as time runs out. The set table stays visible above it.
- **First time doing this exercise:** the "Last time" column shows "—" and a grey line above the table reads "First time. Today sets your baseline."
- **Last exercise:** the button reads "Finish workout".
- **Offline:** a small grey line under the title reads "Saved on this phone. Will sync when you're online."

The ⋮ menu holds "Add a note", "Swap exercise", "Skip exercise" and "See all exercises". Tapping the thumbnail opens the animation full screen.

### 4. Workout: all exercises sheet

> Bottom sheet over a workout screen, titled "Today's exercises". A simple list of five exercises, each with a status icon on the left: green tick for done, a cobalt dot for current, and an empty circle for upcoming. Each row shows the exercise name and "3 of 3 sets" in grey. The current row is highlighted with a pale cobalt background. Tapping a row jumps to it. No other controls.

### 5. Workout summary

> Workout complete screen. Title "Workout done". Three big bold numbers in a row with small grey labels under them: "52 min", "18 sets" and "4,320 kg". Below that, a "New bests" section with two rows, each with a yellow left edge: "Bench press · 8 × 62.5 kg" and "Lateral raise · 12 × 10 kg". Then an optional text field, "Add a note about this workout". A full-width cobalt "Done" button sits at the bottom. Calm and clean, with no confetti or illustrations.

If exercises were skipped, show a dialog before this screen: "2 exercises not done. Finish anyway?" with "Keep going" and "Finish" buttons.

### 6. Plan: my week

> Weekly plan screen titled "My plan". A plain list of seven rows, Monday to Sunday. Each row shows the day name on the left ("Monday"), and under it the workout name and count in grey ("Push day · 5 exercises"). Rest days show "Rest" in grey. A chevron sits on the right of each row. Rows are separated by thin dividers inside one white card. Top right: a search icon labelled "Exercises" that opens the exercise library. Bottom navigation with Plan selected. No body diagrams or charts.

Empty state: an empty card reading "No plan yet. Tap a day to add exercises."

### 7. Plan: edit a day

> Edit day screen titled "Monday". An editable text field at the top holds the workout name, "Push day". A switch row reads "Rest day". Below is a list of planned exercises. Each row has a drag handle on the left, the exercise name, "3 × 8" in grey, and a remove (×) icon on the right. Under the list is an outlined button, "+ Add exercises". At the bottom is a full-width cobalt "Save" button.

Tapping an exercise row opens a small bottom sheet with two steppers, "Sets" (− 3 +) and "Reps" (− 8 +), and a "Save" button. Weight is not set here, because it comes from last time.

### 8. Exercise library (add exercises)

> Exercise picker screen titled "Add exercises". A search field at the top with the placeholder "Search exercises". Below it, one horizontal scrolling row of muscle filter chips: All, Chest, Back, Shoulders, Arms, Legs, Core. "All" is selected in pale cobalt. Then a list of exercises. Each row has a small square grey thumbnail, the exercise name, the muscle and equipment in grey ("Chest · Barbell"), and a checkbox on the right. Three rows are checked. At the bottom is a full-width cobalt button, "Add 3 exercises".

States:
- **No results:** "No exercises match. Try another name or pick All."
- **Loading:** grey skeleton rows.

Tapping a row's name (not the checkbox) opens exercise detail.

### 9. Exercise detail

> Exercise detail screen. A large looping exercise animation fills the top in a rounded frame. Below it, the title "Bench press" with "Chest · Barbell" in grey. Then a "How to do it" section with four short numbered steps, followed by a "Your best" line: "8 × 62.5 kg on 12 Nov". At the bottom is a full-width cobalt "Add to plan" button. A star icon in the top bar adds the exercise to favourites.

### 10. Progress

> Progress screen titled "Progress". At the top, a white card with three numbers in a row: "3 workouts", "5 day streak" and "12,800 kg", each with a small grey label for this week. Below it, a simple front-and-back body outline where muscles worked this week are shaded cobalt (darker for more sets). Then a "History" list grouped by week. Each row shows the date and workout name ("Thu 20 Nov · Push day"), "52 min · 18 sets" in grey, and a small yellow "2 bests" pill when there are new bests. Bottom navigation with Progress selected.

Tapping a session opens a read-only view of its exercises and sets. Tapping an exercise name anywhere opens **exercise history**: a "Best set" card, a simple line chart of top weight over time in cobalt with best points in yellow, and a list of past sessions.

### 11. Settings

> Settings screen titled "Settings". Simple grouped list rows: the user's name and email at the top, then "Theme" (System, Light, Dark), "Weight unit" (kg / lb), "Rest timer" (1:30), "App version 1.0.0 · Check for updates", and "Sign out" in red at the bottom. Plain rows with dividers and no icons except chevrons.

The update dialog reads "Version 1.4.0 is available", with short release notes and "Update now" and "Later" buttons. While downloading, it shows a progress bar with a percentage. If the download fails, it reads "Download failed. Check your connection and try again."

### 12. Offline banner (any screen)

> A slim pale amber bar under the top bar: "You're offline. Workouts save on this phone and sync later."

## Home-screen widget

Stitch can't build Android widgets, so use this section as a mock-up reference only. The widget is native Android. It uses the system font, the same colour tokens and light/dark switching, and only takes taps (no typing). It comes in 4×2 and 4×3 sizes and can be resized.

Prompt for a mock-up:

> An Android home-screen widget, 4 cells wide by 2 tall, on a phone wallpaper. White rounded card. The top row reads "Bench press" in bold with "2 of 5" in grey on the right. Three compact set rows follow: "1   8 × 60 kg ✓" and "2   8 × 62.5 kg ✓" with green ticks, then "3   8 × 60 kg" in grey with an empty circle. The bottom row has an outlined "+ Set" button and a cobalt "Next" button.

Widget states:
- **Active:** as above. Tapping a grey row marks that set done with last time's numbers and starts rest. "+ Set" copies the previous set. "Next" moves to the next exercise. Tapping the exercise name opens the app on that exercise.
- **Resting:** a big countdown "1:24", "Next: set 3, 8 × 60 kg" and a "Skip" button.
- **Ready:** "Push day · 5 exercises" and "Start workout".
- **Rest day:** "Rest day. Tomorrow: Pull day."
- **No plan:** "Set up your plan". Tapping it opens the Plan tab.
- **Done:** "Workout done", duration and sets, and new bests in yellow.
- **Signed out:** "Sign in to Repwise".

## Assets needed

- App icon (adaptive Android icon with foreground and background layers) and a monochrome icon for themed icons.
- Logo mark for the sign-in screen.
- Front and back body outline as SVG, with separately fillable muscle regions (chest, front delts, side delts, rear delts, biceps, triceps, forearms, abs, obliques, traps, lats, upper back, lower back, glutes, quads, hamstrings, calves, adductors).
- Widget preview image for the Android widget picker.

## Admin panel (web, lower priority)

This is a server-rendered web panel for the admin only, not for Stitch. It uses the same colours and DM Sans. Screens: sign in, an exercise table with search and filters, an exercise form with animation upload and preview, archive confirmation, lists of muscle groups and equipment, and a seed import page that shows progress and a result count. It should be functional and dense, with no marketing polish.
