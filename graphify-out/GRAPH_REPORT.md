# Graph Report - repwise  (2026-11-23)

## Corpus Check
- Corpus is ~10,831 words - fits in a single context window. You may not need a graph.

## Summary
- 137 nodes · 159 edges · 17 communities (10 shown, 7 thin omitted)
- Extraction: 84% EXTRACTED · 16% INFERRED · 1% AMBIGUOUS · INFERRED: 25 edges (avg confidence: 0.89)
- Token cost: 91,354 input · 0 output

## Community Hubs (Navigation)
- Pubspec Dependencies
- Architecture & Design System
- Core Workout Loop
- Flutter Starter App
- Exercise Library & Backend
- Foundation, Auth & Release
- iOS Scenes & Tests
- iOS App Delegate
- App Theme & Widget Test
- Progress & Summaries
- Lint Config
- Out of Scope & Platforms
- Android MainActivity

## God Nodes (most connected - your core abstractions)
1. `Repwise v1 Requirements (51)` - 10 edges
2. `Phase 3: Weekly Plan & Workout Logging` - 7 edges
3. `Express backend (admin panel + AI proxy)` - 6 edges
4. `Repwise Roadmap (6 vertical MVP phases)` - 6 edges
5. `Phase 1: Foundation, Auth & OTA Release` - 6 edges
6. `Phase 2: Exercise Library & Admin Panel` - 6 edges
7. `Phase 4: Home-Screen Widget` - 6 edges
8. `AppDelegate` - 5 edges
9. `Exercise Library requirements (LIB-01..08)` - 5 edges
10. `Weekly Plan requirements (PLAN-01..04)` - 5 edges

## Surprising Connections (you probably didn't know these)
- `Launch Screen Assets (iOS)` --conceptually_related_to--> `Platform requirements (PLAT-01 iOS, PLAT-02 Play Store, v2)`  [AMBIGUOUS]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md → .planning/REQUIREMENTS.md
- `repwise README (Flutter starter)` --conceptually_related_to--> `Repwise (Android gym app)`  [INFERRED]
  README.md → .planning/PROJECT.md
- `Plan: my week screen` --implements--> `Weekly Plan requirements (PLAN-01..04)`  [INFERRED]
  .planning/DESIGN-BRIEF.md → .planning/REQUIREMENTS.md
- `Repwise Claude Instructions (CLAUDE.md)` --references--> `Repwise (Android gym app)`  [EXTRACTED]
  .claude/CLAUDE.md → .planning/PROJECT.md
- `Repwise Claude Instructions (CLAUDE.md)` --references--> `shelf_snap code conventions`  [EXTRACTED]
  .claude/CLAUDE.md → .planning/PROJECT.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Core loop: library -> plan -> session -> widget** — _planning_roadmap_phase_2_library_admin, _planning_roadmap_phase_3_plan_logging, _planning_roadmap_phase_4_widget, _planning_project_core_value [EXTRACTED 1.00]
- **Offline session and widget sync** — _planning_project_offline_first, _planning_state_widget_shared_storage, _planning_project_firebase_backend, _planning_requirements_widg, _planning_requirements_sess [INFERRED 0.85]
- **Server-side secrets via Express backend** — _planning_project_express_admin_backend, _planning_project_cloudinary_gif_hosting, _planning_project_ai_proxy_groq_gemini, _planning_requirements_prot [INFERRED 0.85]

## Communities (17 total, 7 thin omitted)

### Community 0 - "Pubspec Dependencies"
Cohesion: 0.11
Nodes (17): dependencies, cupertino_icons, flutter, google_fonts, description, dev_dependencies, flutter_lints, flutter_test (+9 more)

### Community 1 - "Architecture & Design System"
Cohesion: 0.12
Nodes (13): Repwise Claude Instructions (CLAUDE.md), AppColors colour tokens (light/dark), Global style (Material 3, cobalt brand, DM Sans), Layout rules (16dp margins, 4dp grid, 48/56dp targets), Bottom navigation: Today, Plan, Progress, Offline banner, DM Sans type scale (tabular figures), Firebase (Firestore + Auth) (+5 more)

### Community 2 - "Core Workout Loop"
Cohesion: 0.18
Nodes (13): All exercises sheet, Plan: edit a day screen, Home-screen widget mock-up and states, Today screen (workout planned/in progress/rest/done), Workout logging screen (core screen, Last time column), Weekly Plan requirements (PLAN-01..04), Workout Session requirements (SESS-01..11), Home-Screen Widget requirements (WIDG-01..06) (+5 more)

### Community 3 - "Flutter Starter App"
Cohesion: 0.15
Nodes (9): build, _counter, createState, _incrementCounter, main, MyApp, MyHomePage, _MyHomePageState (+1 more)

### Community 4 - "Exercise Library & Backend"
Cohesion: 0.21
Nodes (12): Admin panel design (web, dense), Exercise detail screen, Exercise library (add exercises) screen, Plan: my week screen, AI proxy: Groq first, Gemini fallback, Cloudinary GIF hosting, Express backend (admin panel + AI proxy), Library seeded from open dataset (free-exercise-db) (+4 more)

### Community 5 - "Foundation, Auth & Release"
Cohesion: 0.22
Nodes (9): Repwise Design Brief (Google Stitch prompts), Settings screen (theme, unit, rest timer, update), Sign in screen, OTA updates via ota_update + GitHub Releases, Authentication requirements (AUTH-01..05), Release requirements (REL-01..03), Theme requirements (THEM-01..02), Repwise v1 Requirements (51) (+1 more)

### Community 6 - "iOS Scenes & Tests"
Cohesion: 0.22
Nodes (5): Flutter, SceneDelegate, RunnerTests, UIKit, XCTest

### Community 9 - "Progress & Summaries"
Cohesion: 0.40
Nodes (4): Assets needed (icon, logo, body outline SVG, widget preview), Progress screen (stats, body outline, history), Workout summary screen, Progress requirements (PROG-01..05)

### Community 10 - "Lint Config"
Cohesion: 0.50
Nodes (3): include, linter, rules

### Community 11 - "Out of Scope & Platforms"
Cohesion: 0.67
Nodes (3): Out of Scope (guest mode, iOS v1, Play Store v1, Drive, SQL, social, direct AI calls), Platform requirements (PLAT-01 iOS, PLAT-02 Play Store, v2), Launch Screen Assets (iOS)

## Ambiguous Edges - Review These
- `Platform requirements (PLAT-01 iOS, PLAT-02 Play Store, v2)` → `Launch Screen Assets (iOS)`  [AMBIGUOUS]
  ios/Runner/Assets.xcassets/LaunchImage.imageset/README.md · relation: conceptually_related_to

## Knowledge Gaps
- **26 isolated node(s):** `XCTest`, `AppTheme`, `title`, `_counter`, `main` (+21 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 65 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **7 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `Repwise v1 Requirements (51)` connect `Foundation, Auth & Release` to `Progress & Summaries`, `Core Workout Loop`, `Exercise Library & Backend`?**
  _High betweenness centrality (0.084) - this node is a cross-community bridge._
- **Are the 2 inferred relationships involving `Express backend (admin panel + AI proxy)` (e.g. with `Admin panel design (web, dense)` and `Library seeded from open dataset (free-exercise-db)`) actually correct?**
  _`Express backend (admin panel + AI proxy)` has 2 INFERRED edges - model-reasoned connections that need verification._
- **What connects `XCTest`, `AppTheme`, `title` to the rest of the system?**
  _26 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Pubspec Dependencies` be split into smaller, more focused modules?**
  _Cohesion score 0.1111111111111111 - nodes in this community are weakly interconnected._
- **Why does `Express backend (admin panel + AI proxy)` connect `Exercise Library & Backend` to `Architecture & Design System`?**
  _High betweenness centrality (0.028) - this node is a cross-community bridge._
- **Should `Architecture & Design System` be split into smaller, more focused modules?**
  _Cohesion score 0.11764705882352941 - nodes in this community are weakly interconnected._

### Low-confidence Hints
_AMBIGUOUS edges — the extractor was unsure. Verify before acting on these._

- **What is the exact relationship between `Platform requirements (PLAT-01 iOS, PLAT-02 Play Store, v2)` and `Launch Screen Assets (iOS)`?**
  _Edge tagged AMBIGUOUS (relation: conceptually_related_to) - confidence is low._