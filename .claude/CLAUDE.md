<!-- GSD:project-start source:PROJECT.md -->

## Project

**Repwise**

Repwise is a public Android gym app (Flutter). Users build a weekly workout plan from a large, admin-curated exercise library. While training, they log each exercise's sets (reps × weight), and a home-screen widget walks them through today's exercises one at a time. Each session shows what they did last time. A later phase adds a protein tracker with manual entry and AI-parsed entry ("type what you ate").

**Core Value:** At the gym, the user can see their current exercise and what they lifted last time, log it, and move to the next one. It works from the home-screen widget, without digging through the app.

### Constraints

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

<!-- GSD:project-end -->

<!-- GSD:stack-start source:STACK.md -->

## Technology Stack

Technology stack not yet documented. Will populate after codebase mapping or first phase.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->

## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->

## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->

## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->

## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-fast` for a trivial task inline, with no subagents and no PLAN.md
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->

<!-- GSD:profile-start -->

## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
