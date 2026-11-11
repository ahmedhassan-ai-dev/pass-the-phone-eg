# Codex work order — Pass The Phone v0.7

## Goal
Turn a working Flutter Android party game into a reproducible beta build. Keep local data and user-facing gameplay unchanged. No ad SDK in this milestone.

## Rules
- Work in a feature branch `chore/v07-production-hardening` and open a pull request.
- Do not delete/rename SharedPreferences keys or wipe users' saved questions or unseen-deck queues.
- Never commit release keystores, passwords, `key.properties`, or environment secrets.
- Do not push directly to main.
- Do not fabricate test or build results.
- Inspect existing Android Gradle scripts and manifests before modifying them.

## Task A — audit and fix
1. Run `flutter doctor -v`, `flutter pub get`, `dart format --output=none --set-exit-if-changed lib test`, `flutter analyze`, `flutter test`.
2. Fix build blockers and lint issues. Avoid scope creep or modifying question text.
3. Confirm all supported flows: Quick Play, finite/unlimited, handoff on/off, custom questions, light/dark/system, surprise setting, state after restart, and back navigation.
4. Add regression tests for the real storage migration between v0.5 and v0.7 using a test-friendly preferences adapter if needed. Confirm custom questions and remaining queues survive.
5. Verify the 155+ bank with data validation and no duplicated IDs.

## Task B — Android production configuration
1. Review `android/app/build.gradle.kts` or `build.gradle`; set `applicationId` to a unique permanent reverse-domain ID agreed with owner (DO NOT auto-choose).
2. Check effective targetSdk >= 36, compatible compileSdk, and minSdk supported by dependencies. Keep Flutter/Gradle/AGP compatible.
3. Set user-facing app label and icon, assess Android 15/16 edge-to-edge and system navigation contrast.
4. Set up Play App Signing upload-key configuration using local, ignored secrets; give owner a checklist, never generate or print a key in public CI logs.
5. `flutter build appbundle --release` and record bundle path/hash and signing verification results.

## Task C — release readiness
1. Test release mode on a real Android device: small display, larger display, dark/light, large text, RTL, background/foreground, offline mode, and process restart.
2. Audit permissions; do not add Internet/AD_ID or tracking permissions unless needed.
3. Prepare draft data safety, privacy policy, content rating and audience declarations for OWNER review; do not assert legal compliance automatically.
4. Save evidence in `docs/release/TEST_REPORT.md` (actual commands, outcomes, devices, remaining issues).

## Definition of done
- Clean analysis and tests; green CI.
- Release AAB signed using a securely managed upload key; target API 36+ confirmed.
- No user-data loss migrating from v0.5/v0.6.
- Owner-reviewed store listing, policy declarations and internal/closed testing plan.
