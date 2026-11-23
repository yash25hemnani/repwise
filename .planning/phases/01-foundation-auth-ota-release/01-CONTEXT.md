# Phase 1: Foundation, Auth & OTA Release - Context

**Gathered:** 2026-11-23
**Status:** Ready for planning

<domain>
## Phase Boundary

Phase 1 delivers a signed-in, themed Repwise app shell that installs from a GitHub Release APK and updates itself in-app. It covers these requirements:

- **AUTH-01 to AUTH-05:** Google sign-in, email/password sign-in, password reset, a persistent session, and sign-out.
- **THEM-01:** system light/dark mode, with a manual override that persists.
- **REL-01 to REL-03:** a GitHub Release check, in-app download and install through `ota_update`, and one persistent signing key.

**Design pending (THEM-02):** the earlier design brief was removed on 2026-11-23. The user will supply a design update later. Until it arrives, colours, type, layout and screen copy are open. Plan the auth, theme and OTA logic now, and keep screen visuals easy to restyle. Where decisions below mention dialog or screen copy, treat it as a placeholder until the new design lands.

Exercise library, plans, sessions and the widget are out of scope here. They belong to Phases 2 to 4.

</domain>

<decisions>
## Implementation Decisions

### Release pipeline
- **D-01:** The `yash25hemnani/repwise` repo is made public, and release APKs are published as GitHub Releases on that same repo. The update check reads `https://api.github.com/repos/yash25hemnani/repwise/releases/latest`.
  - **Reversibility:** one-way. Installed apps check this URL. Moving releases elsewhere means shipping a build that points to the new location, and older installs never find it.
  - Because the repo is public, `android/key.properties`, the keystore and any `.env` file must stay out of git. `google-services.json` may be committed.
- **D-02:** The application ID is `com.yashhemnani.repwise`, replacing `com.example.repwise`. The Android namespace changes to match.
  - **Reversibility:** one-way. Android treats a different application ID as a different app, so existing users could not update over it.
- **D-03:** Repwise gets its own new release keystore, stored in `C:\Users\it\keys`. Signing comes from `android/key.properties`, which is gitignored and falls back to the debug key when missing, using the same Gradle pattern as shelf_snap.
  - **Reversibility:** one-way. Losing the key or changing it breaks OTA updates for every installed user, so it must be backed up.
- **D-04:** Releases are built and published by hand. Run `flutter build apk --release` locally, then `gh release create vX.Y.Z <apk>` with release notes in the body. There is no CI in v1.

### Update prompt UX
- **D-05:** The app checks for updates silently on launch. If a newer release exists, it shows the update dialog described in the design brief. Settings also has an "App version · Check for updates" row for manual checks.
- **D-06:** Updates can always be dismissed with "Later". There is no forced-update mechanism in v1.
- **D-07:** The launch check must not interrupt an active workout. Phase 1 builds the check so a "session active" guard can be added later, and Phase 3 wires that guard in.
- **D-08:** Placeholder dialog copy, to be replaced by the incoming design update:
  - Prompt: "Version X is available", with the release notes and "Update now" / "Later" buttons.
  - While downloading: a progress bar with a percentage.
  - On failure: "Download failed. Check your connection and try again."

### Sign-up & account data
- **D-09:** Email/password sign-up collects name, email and password. The name is written to the Firebase Auth `displayName`.
- **D-10:** After sign-up the app sends a verification email but does not block the user. They go straight into the app.
- **D-11:** On first sign-in, through either Google or email, the app creates a Firestore `users/{uid}` doc with name, email, createdAt and settings (theme, plus room for later settings such as weight unit). Firestore security rules allow only the owner to read and write their own user doc.
  - **Reversibility:** costly. Later phases hang user data off this doc path, so changing it means migrating documents and rules.
- **D-12:** The theme override (System, Light or Dark) is stored in SharedPreferences, so it applies instantly at start-up with no flash. It is also mirrored to `users/{uid}.settings`, so it survives a reinstall.
- **D-13:** Account linking keeps Firebase's default of one account per email. If someone tries password sign-up with an email that is already a Google account, they get a clear error that points them to "Continue with Google".

### Claude's Discretion
- **Shell scope after sign-in.** This was not discussed. The recommendation is to build the bottom-nav shell with Today, Plan and Progress as minimal placeholder screens, plus a Settings screen. Final navigation follows the incoming design update.
  - Settings rows in Phase 1: account (name and email), Theme, App version / Check for updates, and Sign out.
  - Weight unit and Rest timer rows wait until the phases that use them.
- **Versioning.** Tags use the `vX.Y.Z` format. `pubspec` `version` is the single source for versionName and versionCode, and the update check compares semver against the tag.
- **Firebase project setup.** The approach (a single project or dev/prod) is open, and a single project is fine for v1. The user creates the Firebase project and adds the SHA-1/SHA-256 fingerprints of both the debug and release keys for Google sign-in.
- **Error copy and loading states.** Use plain placeholder copy until the design update arrives.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Product & scope
- `.planning/PROJECT.md`: project constraints, shelf_snap conventions, key decisions
- `.planning/REQUIREMENTS.md`: AUTH-01 to AUTH-05, THEM-01, THEM-02, REL-01 to REL-03
- `.planning/ROADMAP.md` §Phase 1: goal and success criteria
- `.planning/STATE.md` §Blockers/Concerns: keystore backup and public release assets

### Design
- Pending: the user will supply a design update (tokens, type, screens). The previous `.planning/DESIGN-BRIEF.md` was removed and must not be used.

### Reference implementation (shelf_snap: mirror structure and code flow)
- `C:\Users\it\StudioProjects\shelf_snap\lib\features\auth\`: auth_provider, auth_gate, login_screen, signup_screen, auth_service, password_field
- `C:\Users\it\StudioProjects\shelf_snap\lib\features\update\`: app_release model, update_provider, update_service (GitHub releases/latest + ota_update), update_card
- `C:\Users\it\StudioProjects\shelf_snap\lib\core\`: layout (app_shell, bottom_navbar, nav_item_model), theme (app_colors, app_theme), utils (snackbar), widgets (confirm_dialog)
- `C:\Users\it\StudioProjects\shelf_snap\android\app\build.gradle.kts`: key.properties signing config with the debug fallback
- `C:\Users\it\StudioProjects\shelf_snap\pubspec.yaml`: dependency versions (firebase_core, firebase_auth, cloud_firestore, flutter_riverpod, ota_update, package_info_plus, http)

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/core/theme/app_theme.dart`: an existing theme file from the scaffold with DM Sans through google_fonts. Add light and dark variants through an `AppColors` class whose values can be swapped when the design update arrives.
- shelf_snap's `auth/` and `update/` features map almost 1:1 onto AUTH-* and REL-*. Change the repo URL and the branding.

### Established Patterns
- Data flows Firestore → Repository (`watchX`) → Riverpod providers gated on `currentUidProvider` → screen.
- Models are immutable with `fromMap(id, map)` / `toMap()`, and enums are stored by `.name`.
- Colours come only from `AppColors`/`AppTheme`. Feedback uses SnackBars. Imports are absolute package imports.

### Integration Points
- `lib/main.dart`: Firebase init, ProviderScope, AuthGate as home, and theme mode from the theme provider.
- `android/app/build.gradle.kts`: the applicationId/namespace change, the signing config, and the google-services plugin.
- The Android manifest needs `REQUEST_INSTALL_PACKAGES` and the FileProvider that `ota_update` requires.

</code_context>

<specifics>
## Specific Ideas

- Sign in, Create account and Reset password share one layout.
- Visual design is on hold until the user's design update arrives.

</specifics>

<deferred>
## Deferred Ideas

- The "skip the update prompt during an active workout" guard is wired in Phase 3, once sessions exist.
- The Weight unit and Rest timer settings rows are added in the phases that introduce them (Phase 3).
- A CI release pipeline with GitHub Actions is a possible later improvement.

</deferred>

---

*Phase: 01-foundation-auth-ota-release*
*Context gathered: 2026-11-23*
