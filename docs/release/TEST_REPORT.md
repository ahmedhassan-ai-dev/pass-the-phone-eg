# v0.7 hardening test report

Executed 2026-11-11 (Africa/Cairo) on branch `chore/v07-production-hardening`, starting from e0db3d6 with the supplied uncommitted v0.7 overlay. Main was not modified. Existing overlay changes were preserved.

## Readiness

**Not ready for store release.** The owner has now approved `com.ahmedhassan.passthephone`; see the identity follow-up below. Upload signing, physical-device upgrade testing, final icon and owner policy/listing review remain blocked. Earlier unsigned APK/AAB build evidence below predates the identity change. CI is configured but no green hosted run is claimed here.

## Original hardening commands (before permanent identity approval)

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

## Original artifacts (before identity change; local, ignored; do not upload to Play)

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

- Permanent application ID approved in the follow-up below. Distribution history was inspected with no release evidence found; private distribution/Play Console remain unverified.
- Private upload key/signing config and successful signed AAB certificate verification. No keystore/password/secret was generated or committed.
- Physical device matrix, actual in-place upgrades and Play native 16 KB compatibility validation.
- Replace/approve Flutter placeholder launcher icon; adaptive icon absent.
- Owner-approved data safety/privacy URL/contact, content rating/audience and store listing; see STORE_DRAFTS.md.
- Hosted CI result and Play internal/closed testing evidence. No rollout or legal/policy compliance assertion.

## Permanent identity follow-up — 2026-11-11

Requested and explicitly approved by owner: `com.ahmedhassan.passthephone`. Work performed only on `chore/v07-production-hardening`, starting from caa5b07.

### Inspection before edits

Reviewed applicationId, namespace, MainActivity package/path, relative `.MainActivity` manifest declaration, release identity/signing guards, all reachable Android/README history, remote branches/tags, tracked artifact/signing-file history and GitHub releases.

- e8da8b7 used `com.passthephone.pass_the_phone` for applicationId/namespace/MainActivity, with release debug signing.
- 3e58181 reset these to `com.example.pass_the_phone`, also with release debug signing. v0.5/v0.6 retained that identity.
- caa5b07 removed release debug signing and added explicit unsigned smoke builds and private upload signing guards.
- `git ls-remote --heads --tags origin` listed main and the hardening branch, with no tags. GitHub releases API returned `[]`. Historical tracked APK/AAB/keystore/key.properties search returned no records. Repository/README history supplied no evidence of a Play listing or distributed signed version. Existing local release smoke artifacts were previously verified unsigned.
- Historical identities and the sandbox limitation were reported before editing the app. No evidence requiring the conditional stop was found. This audit cannot verify private distribution or Play Console; absence of repository evidence is not proof that distribution never occurred.

### Changes and data boundary

applicationId and namespace now equal `com.ahmedhassan.passthephone`. MainActivity was moved to `android/app/src/main/kotlin/com/ahmedhassan/passthephone/MainActivity.kt` and its package declaration updated. The existing relative manifest activity resolves correctly against the new namespace, verified in both merged manifest and APK. Release guards require this exact identity for both signed and unsigned builds; signed builds still require local upload signing configuration and never fall back to debug signing.

No Dart/gameplay/storage code, assets, tests, dependency versions or preference keys were modified in this follow-up. No data was cleared, uninstalled, renamed or deleted. **Changing the Android ID creates a new sandbox: data under either historical package remains with that package and is not automatically accessible to the new ID.** The earlier AppStore regression tests prove storage-format continuity within the same package, not migration between package IDs. Do not claim an in-place upgrade from a historical package; resolve any discovered distributed version before release. Future upgrades must retain this permanent ID and compatible signing identity.

### Executed validation after identity changes

| Command | Actual result |
| --- | --- |
| `flutter analyze` | Exit 0, no issues (1.3 seconds). |
| `flutter test` | Exit 0, all 23 tests passed, including historical preferences fixtures and gameplay widget flows. |
| `flutter build apk --release -PunsignedSmokeBuild=true` | Exit 0, 40.1 seconds; unsigned release APK, 49.0 MB. |
| `aapt dump badging build/app/outputs/flutter-apk/app-release.apk` | Exit 0; ID com.ahmedhassan.passthephone, launch activity com.ahmedhassan.passthephone.MainActivity, compile/target SDK 36, min SDK 24, version 0.7.0+7. |
| `apksigner verify --print-certs build/app/outputs/flutter-apk/app-release.apk` | Exit 1, DOES NOT VERIFY / Missing META-INF/MANIFEST.MF, expected for unsigned smoke output. Signing has not passed. |
| `Get-FileHash build/app/outputs/flutter-apk/app-release.apk -Algorithm SHA256` | SHA-256 D76F48DA53428820FFA512CB2F8EDFF303FB862F00DAFA33EF204DA6EBE844FD. Replaces the earlier APK at this local ignored path. |
| `flutter build appbundle --release` | Exit 1 as intended: `Release requires local android/key.properties and an upload key. No debug signing fallback.` Confirms approved identity passes the guard; signing remains blocked. |

No new unsigned AAB build was requested/executed in this follow-up; the earlier AAB/hash belongs to the old package and is not evidence for the new ID. No physical-device upgrade or process-death check was run. Release signing, devices, icon and owner policy/listing reviews remain outstanding. No signing keys/secrets were created, no PR merge or publication was performed.
