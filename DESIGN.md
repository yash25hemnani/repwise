# Repwise UI guideline

The app shares one look with the landing page (`repwise-admin/public/css/site.css`). This file puts that look into Flutter terms. It covers colour, type, shape, components, motion and copy. When a screen isn't covered here, take the closest pattern from the landing page.

## The idea

Competition bumper plates. Each plate has a fixed colour, a thick black edge, and its weight printed big in a wide, heavy face. The UI borrows exactly that:

- **Plate colours** are the only accents.
- **Black outlines and hard offset shadows** make light-mode surfaces look like solid objects you could pick up.
- **Archivo, wide and heavy**, for names and numbers, like the print on a plate.

Spend the boldness on numbers and the one primary action per screen. Everything else stays quiet: chalk background, black text, grey metadata.

## Colour

### Plate colours (same in both modes)

| Token | Hex | Plate | Text on it | Used for |
|---|---|---|---|---|
| `red` | `#E5534B` | 25 kg | black | The widget, personal bests, destructive actions |
| `blue` | `#2B52EB` | 20 kg | **white** | Workout logging |
| `yellow` | `#F9C356` | 15 kg | black | The weekly plan, "in progress" states |
| `green` | `#5DF0A6` | 10 kg | black | The library, primary buttons, "done" and "hit" states |
| `white` | `#FFFFFF` | 5 kg | black | Progress and stats |

Only blue takes white text. Black on red is 5.7:1, while white on red is only 3.7:1, so red never takes white text.

Each feature area keeps its plate colour everywhere it appears: on the nav dot, the screen's header card and any empty-state illustration. Use one plate colour as a large fill per screen. The other plate colours can appear small (dots, chips, chart markers).

`purple` (`#A78BFA`) in `AppColors` isn't a plate colour. Don't use it anywhere new.

### Neutrals

| Token | Light | Dark | Used for |
|---|---|---|---|
| `background` | `#F4F5F3` chalk | `#000000` iron | Scaffold |
| `card` | `#FFFFFF` paper | `#1C1C1F` panel | Cards, sheets, dialogs |
| `surface` | `#E6E8E5` | `#1C1C1F` | Nav circles, input fills, rows inside cards |
| `border` | `#D5D8D4` | `#2A2A2E` | Dividers, chart grid, set rows in dark mode |
| `ink` | `#000000` | `#FFFFFF` | Outlines and hard shadows |
| `text` | `#000000` | `#FFFFFF` | Body and titles |
| `textSecondary` | `#5C6066` | `#A1A1A8` | Metadata, labels, captions |
| `steel` | `#B4B8B2` | `#B4B8B2` | Bar and collar art only |

Text colours for the two modes:

- **Green as text:** use `greenText` (`#0A7A4B` on chalk, mint on black). Mint is too pale on chalk.
- **Red as text in light mode:** use `#C7362F`.

Use pure black for black. Don't swap in a tinted near-black like `#111`.

Small fills from the logging screen:

- **Done set rows:** `#D9FBE9` in light mode, and `green` at 15% on panel in dark mode.
- **Library thumbnail background:** `#DDFBEA`.
- **Empty check circles and dashed "add" rows:** a `#C9CCC7` border.

### Add to `AppColors`

`card` and `ink` are new. Dart can't have a static and an instance member with the same name, so red as text is `redText` (the same pattern as `greenText`). `AppColors.red` is the plate fill.

```dart
static const red = Color(0xFFE5534B); // plate red, fill only
static const white = Color(0xFFFFFFFF);
static const steel = Color(0xFFB4B8B2);
static const onBlue = Color(0xFFFFFFFF);

final Color card;    // light: 0xFFFFFFFF, dark: 0xFF1C1C1F
final Color ink;     // light: 0xFF000000, dark: 0xFFFFFFFF
final Color redText; // light: 0xFFC7362F, dark: 0xFFE5534B
```

## Type

**Archivo** for everything, as on the landing page. Its width axis does the work: heavy and wide for names and numbers, normal width for reading. This replaces DM Sans.

`google_fonts` can't set the width axis, so bundle the variable font. It's `Archivo[wdth,wght].ttf` from Google Fonts. Rename it to `Archivo-Variable.ttf`.

```yaml
flutter:
  fonts:
    - family: Archivo
      fonts:
        - asset: assets/fonts/Archivo-Variable.ttf
```

In Flutter 3.41, `fontWeight` sets the variable font's `wght` axis, so put only the width in `fontVariations`. That way `copyWith(fontWeight: ...)` still works on theme styles. `AppTheme.archivo` builds every style:

```dart
static TextStyle archivo(double size, FontWeight weight, {double width = 100, double? height, double spacing = 0}) =>
    TextStyle(
      fontFamily: 'Archivo',
      fontSize: size,
      height: height,
      letterSpacing: size * spacing,
      fontWeight: weight,
      fontVariations: [FontVariation.width(width)],
      fontFeatures: const [FontFeature.tabularFigures()],
    );
```

### Scale (base 16)

| Role | Material slot | Size | Weight | Width | Line height | Tracking |
|---|---|---|---|---|---|---|
| Wordmark | `displayLarge` | 52 | 900 | 125 | 0.85 | −0.035em |
| Big number (rest timer, clock) | `displayMedium` | 56 | 900 | 125 | 1.0 | −0.02em |
| Screen title | `headlineLarge` | 32 | 900 | 118 | 0.98 | −0.025em |
| Card or section title | `titleLarge` | 22 | 800 | 110 | 1.1 | −0.015em |
| Exercise or item name | `titleMedium` | 20 | 800 | 108 | 1.15 | 0 |
| Stat value | `titleSmall` | 20 | 900 | 112 | 1.1 | 0 |
| Body | `bodyLarge` | 16 | 400 | 100 | 1.5 | 0 |
| Secondary body | `bodyMedium` | 14.5 | 400 | 100 | 1.45 | 0 |
| Button | `labelLarge` | 16 | 800 | 100 | 1.2 | 0 |
| Meta, column headers, chips | `labelMedium` | 13.5 | 600 | 100 | 1.3 | 0 |

Rules:

- **Numbers:** anything that counts (reps, kg, timer, sets, volume) uses `FontFeature.tabularFigures()`, so digits don't jump as they change.
- **Case:** sentence case everywhere. No all-caps labels, and no extra label above a heading that already says what it is.
- **Emphasis:** don't pick out one word in a heading with a different colour or weight. Emphasis comes from size and width.
- **Fonts:** no monospace, not even for numbers. Archivo with tabular figures covers it.
- **Line length:** keep paragraphs under about 46 characters on phones. On tablets, cap the width at 520.

## Shape and depth

Light mode: things that sit on chalk are solid objects.

| Element | Radius | Outline | Shadow |
|---|---|---|---|
| Primary button | 14 | 3 `ink` | 5,5 `ink`, no blur |
| Small button | 12 | 3 `ink` | 3,3 `ink` |
| Card | 22 | 3 `ink` | 6,6 `ink` |
| Day card (plan) | 20 | 3 `ink` | 5,5 `ink` |
| Search field | 12 | 3 `ink` | none |
| Set row, input inside a card | 12 | none (2 `ink` when current) | none |
| Thumbnail | 13 | 2 `ink` | none |
| Chip, tag, status | pill | 2 `ink` | none |
| Bottom sheet, dialog | 26 top | 3 `ink` | none |

Dark mode: cards become flat `card` (panel) fills with no outline and no shadow, like the widget. Two things keep their solid look, both drawn in white:

- the primary button: a white outline and a 5,5 white shadow
- the selected chip: a white fill with black text

Never use a blurred shadow. Never use gradients, with one exception: the hatching on rest days.

```dart
BoxDecoration plateCard(BuildContext context, {Color? fill}) {
  final c = context.colors;
  final dark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: fill ?? c.card,
    borderRadius: BorderRadius.circular(22),
    border: dark ? null : Border.all(color: c.ink, width: 3),
    boxShadow: dark ? null : [BoxShadow(color: c.ink, offset: const Offset(6, 6))],
  );
}
```

### Spacing

Use multiples of 2, mostly from: 4, 6, 8, 12, 14, 16, 18, 22, 28, 40.

- **Screen gutter:** 16
- **Card padding:** 18 to 22
- **Gaps:** 12 between cards, 4 to 6 between set rows
- **Card offset:** cards with a hard shadow need 6 extra on the right and bottom, so the shadow isn't clipped

## Components

### Primary button

Green fill, black 3 outline, black 800 label, 5,5 hard shadow. On press it moves down into its shadow, so the shadow goes to 0, over 120 ms. One primary button per screen.

The secondary action is a bold text link with a 2 underline, not a second filled button.

```dart
class PlateButton extends StatefulWidget {
  const PlateButton({super.key, required this.label, required this.onPressed, this.fill = AppColors.green});
  final String label;
  final VoidCallback? onPressed;
  final Color fill;
  @override
  State<PlateButton> createState() => _PlateButtonState();
}

class _PlateButtonState extends State<PlateButton> {
  bool _down = false;

  void _set(bool v) => setState(() => _down = v);

  @override
  Widget build(BuildContext context) {
    final ink = context.colors.ink;
    final lift = _down ? 0.0 : 5.0;
    final off = widget.onPressed == null;
    return Semantics(
      button: true,
      enabled: !off,
      child: GestureDetector(
        onTapDown: off ? null : (_) => _set(true),
        onTapUp: off ? null : (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: Opacity(
          opacity: off ? 0.4 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(5 - lift, 5 - lift, 0),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            decoration: BoxDecoration(
              color: widget.fill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ink, width: 3),
              boxShadow: [BoxShadow(color: ink, offset: Offset(lift, lift))],
            ),
            child: Text(widget.label, textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.onAccent)),
          ),
        ),
      ),
    );
  }
}
```

### Nav

The selected destination is a pill with a white (light) or panel (dark) fill. Each destination has an 11 px dot in its plate colour with a 2 `ink` ring, as in the landing page's header:

- Today: blue
- Plan: yellow
- Library: green
- Progress: white
- Widget and settings: red

### Workout logging (blue)

- **Header:** the exercise name in `titleMedium`. On the right, a black pill showing the rest countdown in green tabular figures.
- **Last time:** one line under the name, in `textSecondary`, for example "Last time: 4 × 8 × 77.5 kg".
- **Set rows:** columns for set, reps, kg and a check, with a radius of 12.
  - Pending rows have a `surface` fill.
  - Done rows have the mint fill and a black check circle with a green tick.
  - The current row has a `card` fill and a 2 `ink` outline.
- **Add set:** a dashed `#C9CCC7` row reading "Add set" in `textSecondary`.
- **Session summary:** a card showing volume, duration, sets and muscles hit as a 2 × 2 grid of stat values.

### Weekly plan (yellow)

Seven day cards in a grid: 2 columns on phones, 4 on tablets.

- **Day name:** `titleMedium` at width 118.
- **Workout name:** 700 weight.
- **Exercise count:** pinned to the bottom, in `textSecondary`.
- **Today:** the card is filled with `ink`, with the text in the opposite colour.
- **Rest days:** a dashed outline, no shadow, and 45° hatching at 9% black, with lines 2 px wide and 11 px apart.

### Library (green)

- **Search field:** 3 `ink` outline with a `surface` fill.
- **Result rows:** split by 2 `background` lines.
- **Each row:** a 58 × 58 thumbnail (the GIF still) with a 2 `ink` outline, then the name in 700 weight and "muscle · equipment" in `textSecondary`.
- **Filter chips:** off is a `card` fill with a 2 `ink` outline. On is an `ink` fill with the text in the opposite colour.

### Progress (white)

- **Line chart:**
  - Black line, 3.5 wide, with round joins.
  - Points are white dots with a 3 black ring.
  - The personal best is a red dot with a 3 black ring, plus an 800 label.
  - Grid lines are 2 wide in `border`, and the target line is dashed 4/6.
- **Stats list:** label on the left in `textSecondary`, value on the right as a stat value. Rows are split by 2 `background` lines.
- **Muscle coverage:** a grid of 16 px dots with 2 `ink` rings. A black dot means planned, a green dot means hit this week, and an empty dot means neither.

### Weight plates as icons

Draw a weight as a plate face rather than writing it as plain text in feature headers and empty states. A plate face is:

- a rim in the plate colour with a 4 `ink` stroke
- a faint groove
- a chalk hub with a black bore
- the number in Archivo 900 at width 125

Use `CustomPaint`, or port the SVG from `repwise-site/index.html`.

### Home-screen widget (red)

The widget is always dark, whatever theme the app uses:

- **Fill:** panel `#1C1C1F`, radius 26.
- **Set rows:** `#2A2A2E`, radius 10.
- **Meta text:** `#A1A1A8`.
- **Buttons:** radius 15 with a 2 `#3A3A40` outline. "Mark done" is filled green with black text.
- **Rest view:** a big number for the countdown, an 8 px green progress bar on `#2A2A2E`, then "Up next" and the next exercise.
- **States:**
  - **No plan:** "No plan yet", with "Tap to build your week".
  - **Rest day:** "Rest day", with "Next: Push, tomorrow".
  - **Finished:** "Session done", showing volume and sets.

If the widget layer can't load Archivo, bold system sans is fine. Keep the tabular figures.

## Motion

One signature moment, plus feedback on taps. Nothing moves on its own except a running timer.

| Moment | What moves | Duration and curve |
|---|---|---|
| Plates load (sign-in or splash, once) | Plates slide in from the right onto the bar, one after another | 550 ms each, 120 ms apart, `Cubic(0.2, 0.9, 0.3, 1.12)` |
| Button press | Moves down into its shadow | 120 ms, `easeOut` |
| Set added | The new row drops 6 px and fades in | 280 ms, `easeOut` |
| Rest bar | Width follows the timer | 1 s, linear, per tick |
| Theme switch | Colours blend (`AppColors.lerp`) | Material default |

When `MediaQuery.disableAnimationsOf(context)` is true, skip the plate load and the row drop, and show the end state.

## Copy

- **Voice:** plain verbs and sentence case. A button says what happens: "Mark done", "Add set", "Skip rest", "Start session".
- **Consistent names:** an action keeps its name from button to confirmation. "Mark done" leads to "Done", and "Save plan" leads to "Plan saved".
- **Units:**
  - Weight is written as "80 kg", with a space.
  - Sets use a real multiplication sign: "8 × 80 kg" and "4 × 8 × 80 kg".
  - Thousands get a comma: "12,480 kg".
- **Empty states** say what to do next. For example, "No exercises on Monday. Add one from the library."
- **Errors** say what happened and how to fix it, and don't apologise. For example, "Couldn't sync. Your sets are saved on this phone and will upload when you're back online."
- **Separators:** a middle dot is fine between two facts in a row ("Chest · Barbell"). Don't chain three or more.

## Don't

- Blurred shadows, gradients, or glass effects.
- White text on red, yellow or green.
- More than one large plate-colour fill per screen.
- New uses of purple.
- All-caps labels, or eyebrow labels above headings.
- Motion that runs without a tap, apart from the timer and the one-time plate load.
