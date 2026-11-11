# v0.7 hardening test report

Executed 2026-11-11 (Africa/Cairo) on branch `chore/v07-production-hardening`, starting from e0db3d6 with the supplied uncommitted v0.7 overlay. Main was not modified. Existing overlay changes were preserved.

## Readiness

**Not ready for store release.** Automated analysis, 23 tests and unsigned APK/AAB smoke builds pass. Permanent application ID, upload signing, physical-device upgrade testing, final icon and owner policy/listing review remain blocked. CI is configured but no green hosted run is claimed here.

## Executed commands

| Command | Actual result |
| --- | --- |
| `flutter doctor -v` | Exit 0; Flutter 3.47.7/Dart 3.13.5, Android SDK/build-tools 36, JDK 25.0.3, licenses accepted. Warning: incomplete Visual Studio installation (Windows desktop). No Android device connected; Windows/Chrome/Edge only. Overall doctor is not all green. |
| `flutter pub get` | Exit 0. Five newer incompatible package versions noted; lockfile unchanged. |
| `dart format --output=none --set-exit-if-changed lib test` | Final exit 0, 18 files, zero changes. |
| `flutter analyze` | Initial five brace lint findings fixed with `dart fix --apply --code=curly_braces_in_flow_control_structures`; final exit 0, no issues. |
| `flutter test --timeout 60s` | Final exit 0, 23 tests passed. Initial baseline `flutter test`: 13 passed; intermediate 21 passed before widget coverage. |
| `flutter build apk --release -PunsignedSmokeBuild=true` | Exit 0, 78.8 seconds, 49.0 MB unsigned APK. |
| `flutter build appbundle --release -PunsignedSmokeBuild=true` | Exit 0, 13.3 seconds, 48.1 MB unsigned AAB. |
| `flutter build appbundle --release` | Final exit 1 as intended: owner-approved permanent applicationId required. Signed production release remains blocked. |
| `apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk` | Exit 1: DOES NOT VERIFY / Missing META-INF/MANIFEST.MF. Confirms smoke APK is unsigned; signing has not passed. |
| `jarsigner -verify build/app/outputs/bundle/release/app-release.aab` | Exit 0 but explicitly reports `jar is unsigned` / no manifest. This is NOT successful signing verification. |
| `aapt dump badging build/app/outputs/flutter-apk/app-release.apk` | Confirmed compileSdk 36, targetSdk 36, minSdk 24, ID com.example.pass_the_phone, version 0.7.0 / code 7, Arabic app label. |
| `aapt dump permissions build/app/outputs/flutter-apk/app-release.apk` | Only app-scoped signature-level DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION. No INTERNET, AD_ID or tracking permission. Merged manifest also reviewed. |
| `Get-FileHash ... -Algorithm SHA256` | Artifact hashes recorded below. |

## Failures encountered and fixes

Initial plain APK build failed in Kotlin incremental compilation because Pub plugin source paths on C: cannot be relativized against this project on D:. Concurrent attempts also reported registered incremental cache errors. Set `kotlin.incremental=false`; the subsequent APK and AAB builds succeeded. No application data was cleared. Initial AAB attempt also failed downloading Android SDK Platform 35 (required by a dependency); another attempt installed it successfully. CMake 3.22.1 was installed by Gradle. Use sequential builds.

An intermediate environment-variable smoke invocation hit the identity guard; the final supported invocation uses explicit `-PunsignedSmokeBuild=true`, successfully exercised above. A direct Gradle diagnostic without Flutter selected system Java 8 and failed; Flutter builds correctly select Android Studio JDK 25.

An initial finite-flow widget test tried to locate a lazily built offscreen chip; corrected the harness to scroll first. Widget asset loading uses tester.runAsync to avoid hanging between test cases. The final full suite passed.

## Artifacts (local, ignored; do not upload to Play)

- `build/app/outputs/flutter-apk/app-release.apk`: SHA-256 `709AA333920D9E3F8F67141473C1F18D1D8AEC2F8089B317EFAA28A1B695D315`
- `build/app/outputs/bundle/release/app-release.aab`: SHA-256 `67279F99533F89DF8269ACB867434B3A74BF8B411C55635D6F4C0B5CCE058DB2`

## Persistence and flow coverage

Read all Dart sources/tests, historical AppStore implementations at ad31aad (v0.5) and e0db3d6 (v0.6), bank data, Android Gradle/wrapper/manifests/resources/activity, web scaffolding, dependency manifest/lockfile and automation/docs. No question text or IDs were changed. Bank validation passes with 220 entries (>=155), unique IDs, valid categories/text and no same-category duplicate text. Launcher image inspected: still Flutter placeholder, not approved branding.

Regression tests execute real AppStore load/migration with an injected in-memory SharedPreferencesAsync adapter and the historical key/JSON shapes. They verify both prior versions across light/dark/system themes, false handoff/haptics, v0.5 surprise default and v0.6 saved surprise, custom IDs/text including legacy savage category, and exact first/second unseen queue order across a new AppStore instance. Legacy custom-category conversion is checked twice for idempotence. New custom questions/settings also survive reload. Existing backend and every persisted key remain unchanged. This proves storage logic with fixtures, not on-device binary replacement, process-death timing or OS backup/restore.

Widget tests cover Quick Play/unlimited, handoff reveal, system-back dialog cancellation/confirmation, finite ten-round play without handoff, finish and return home. GameSession tests cover no-repeat cycles, finite limits and invalid input. Remaining device verification is explicit below.

## Required manual evidence (all NOT RUN)

No real Android device or emulator was connected. On small and larger Android devices, including API 35/36+, record model/API/build and results for light/dark/system, large text, RTL, TalkBack, reduced motion, gesture/three-button navigation contrast, edge-to-edge insets, offline play, background/foreground and process restart.

For each v0.5/v0.6 upgrade: install a compatible historical signed build, save custom questions and non-default settings, reveal several cards and record unseen queue; install v0.7 in-place with the SAME ID and compatible certificate (never uninstall or clear data). Confirm custom text/IDs/settings and unseen order after upgrade and process restart. Binary/certificate compatibility is not established here.

## Remaining release blockers

- Owner-approved permanent application ID and history of distributed builds/certificates. CODEX_TASKS.md prohibits choosing it automatically.
- Private upload key/signing config and successful signed AAB certificate verification. No keystore/password/secret was generated or committed.
- Physical device matrix, actual in-place upgrades and Play native 16 KB compatibility validation.
- Replace/approve Flutter placeholder launcher icon; adaptive icon absent.
- Owner-approved data safety/privacy URL/contact, content rating/audience and store listing; see STORE_DRAFTS.md.
- Hosted CI result and Play internal/closed testing evidence. No rollout or legal/policy compliance assertion.
