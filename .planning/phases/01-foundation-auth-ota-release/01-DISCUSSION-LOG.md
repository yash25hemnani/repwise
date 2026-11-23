# Phase 1: Foundation, Auth & OTA Release - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-11-23
**Phase:** 01-foundation-auth-ota-release
**Areas discussed:** Release pipeline, Update prompt UX, Sign-up & account data

---

## Release pipeline

| Option | Description | Selected |
|--------|-------------|----------|
| Separate releases repo | Code private, APKs in a public releases repo | |
| Make repwise public | Releases on the code repo itself | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| com.yashhemnani.repwise | Matches shelf_snap convention | ✓ |

| Option | Description | Selected |
|--------|-------------|----------|
| New keystore for Repwise | Separate key per app | ✓ |
| Reuse shelf_snap's key | One key to back up | |

| Option | Description | Selected |
|--------|-------------|----------|
| Manual build + gh release | Local build, key never leaves machine | ✓ |
| GitHub Actions on tag | CI builds/signs with keystore secret | |

**Notes:** Tag format, versionCode and release notes source left to Claude.

---

## Update prompt UX

| Option | Description | Selected |
|--------|-------------|----------|
| Launch + Settings | Silent check on start + manual row | ✓ |
| Settings only | Never interrupts | |
| Launch, max once a day | Throttled | |

| Option | Description | Selected |
|--------|-------------|----------|
| Always dismissible | 'Later' always available | ✓ |
| Support a forced flag | Marker in release notes hides 'Later' | |

| Option | Description | Selected |
|--------|-------------|----------|
| Defer until workout ends | Never interrupt a session | ✓ |
| Same everywhere | Simpler | |

---

## Sign-up & account data

| Option | Description | Selected |
|--------|-------------|----------|
| Send but don't block | Verification email, immediate access | ✓ |
| Block until verified | Check-inbox screen | |
| No verification | Skip | |

| Option | Description | Selected |
|--------|-------------|----------|
| users/{uid} doc on first sign-in | Name, email, createdAt, settings | ✓ |
| Local prefs only | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Local + Firestore | SharedPreferences + mirrored to user doc | ✓ |
| Local only | | |

| Option | Description | Selected |
|--------|-------------|----------|
| Firebase default: one account per email | Clear error pointing to Google | ✓ |
| You decide | | |

---

## Claude's Discretion

- Shell scope: placeholder Today/Plan/Progress tabs + Settings (not selected for discussion)
- Versioning/tag format, Firebase project layout, error copy

## Deferred Ideas

- Mid-workout update guard wiring (Phase 3)
- Weight unit / Rest timer settings rows (Phase 3)
- GitHub Actions release CI (later)
