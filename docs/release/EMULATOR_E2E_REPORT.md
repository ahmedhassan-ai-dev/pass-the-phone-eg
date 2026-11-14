# v0.8.0+8 emulator E2E and signed-release smoke — 2026-11-14

Agent-executed results on release/v080-preparation. These are separate from the owner's Samsung/API 35/TalkBack confirmations. All device commands explicitly targeted emulator-5554. The physical Samsung was not used. No credentials were accessed; no commit, push, merge or publication performed.

## Executed matrix

| Environment | Runtime verification | Flutter integration E2E (debug test target) | Existing signed release APK smoke |
| --- | --- | --- | --- |
| Android 16 / API 36; Pixel_9a_2; sdk_gphone16k_x86_64 | Boot=1, PAGE_SIZE=16384 | PASS, 5/5, exit 0 | PASS, exit 0 |
| Android 15 / API 35; isolated PTP_API35_v080_QA; sdk_gphone64_x86_64 | Boot=1, PAGE_SIZE=4096 | PASS, 5/5, exit 0 | PASS on rerun, exit 0; first attempt retained as FAIL |

API 36 was tested first (E2E, then signed release smoke), then shut down before starting API 35. between-emulators.txt records no attached emulator between runs. Both use serial emulator-5554 at different times. API 35 uses a new disposable AVD under ignored build storage with the existing SDK image; the owner's original Pixel_9a data was not used or cleared. API 36 had no pre-existing app; both Flutter test-created debug installations were removed by the test runner before release installation. No owner installation was uninstalled. These emulator installations do not independently establish a v0.7-to-v0.8 upgrade PASS.

## E2E coverage

Implemented integration_test/release_e2e_test.dart with real Android channels and SharedPreferencesAsync, no mocked storage/channels or preference clearing:

1. App launch/RTL, native installed version 0.8.0 (8), Settings switches, dark/light themes and settings reloaded from Android storage.
2. Custom question added through the UI and retained on a new AppStore load through the real storage backend.
3. Quick Play, handoff, next-question reveal, cancel exit and confirmed exit.
4. Full Family deck cycle without repeats, three reveals in the second cycle, exact saved unseen order after AppStore reload, then consumption of every saved unseen ID in order.
5. Finite ten-round game completion and return to Home.

SDK integration_test was added as a dev dependency because flutter_test alone does not execute an instrumented app on Android. Its SDK/tool transitive dependencies were resolved in pubspec.lock; existing package versions were not upgraded. No application Dart/Kotlin, gameplay, branding, package ID, manifest, signing configuration, preference keys or questions were changed for this task. No new signed APK/AAB was generated.

## Separate signed-release smoke

tool/emulator_release_smoke.py uses Python's standard library, Android SDK apksigner and serial-scoped adb/UIAutomator. It rejects physical-device serials and requires evidence inside build/. It never clears data, uninstalls, signs, changes system settings or accesses a keystore.

Verified before installing the preserved release APK:

- SHA-256 B601237EDDA7A421B10C67B784A2EF01D3E01D1053080D2359F6186068FE1386.
- APK signature verification exit 0; v2=true; public signer SHA-256 68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575.
- Installed package com.ahmedhassan.passthephone, version 0.8.0/code 8, target SDK 36, not DEBUGGABLE.

Smoke assertions: launch/process/Home, Quick Play, handoff/reveal, confirmed exit, installed-version footer, external Chrome browser activity after the Privacy Policy tap, return to app, force-stop/relaunch, and saved Haptics OFF still visible after relaunch. UI XML dumps/screenshots accompany these checks. No fatal exception/native abort was observed in the captured final 2,000-line logcat windows. This is bounded log evidence, not a guarantee about all future sessions. Browser activity launch does not prove remote page loading or the unavailable-browser clipboard branch.

API 36 ran the signed production native binaries on an actual 16 KB x86_64 emulator, beyond static alignment checks. Physical vibration, ARM64 16 KB hardware and the complete Android 16 manual matrix are not established by this result.

API 35 first smoke attempt failed at the Quick Play transition: its next UIAutomator dump contained only an empty Flutter host view, and the screenshot still showed Home. A diagnostic adb tap subsequently opened the game normally. No production defect was established. The harness was changed to use 120 ms tap gestures, poll for populated/expected UI state with a five-attempt bound, and force-stop before initial launch to establish a known starting screen. The rerun passed every smoke assertion. Original failed XML/screenshots/result.json/log/exit=1 remain under api35-release-smoke/; the passing rerun is separate under api35-release-smoke-retry/. No initial failure was overwritten or silently counted as PASS. API 36 passed before this harness timing refinement with the same functional assertions.

## Evidence and reproduction

All raw files remain local/ignored under build/release_validation/v080_emulator/:

| Evidence | Relative files |
| --- | --- |
| Environment | api36-sdk.txt, api36-page-size.txt, api36-boot.txt, api36-model.txt; equivalent api35-* files |
| E2E | api36-e2e.log / api36-e2e.exit.txt; api35-e2e.log / api35-e2e.exit.txt |
| Release smoke | api36-release-smoke/result.json (PASS), api35-release-smoke/result.json (initial FAIL), api35-release-smoke-retry/result.json (final PASS); corresponding host .log and .exit.txt files |
| Release verification | Each smoke directory: apk-signature.txt, install.txt, package.txt, privacy-activities.txt, logcat.txt, numbered XML/PNG captures |
| Sequential lifecycle | api36-shutdown.txt, between-emulators.txt, api35-avd-create.log, api35-emulator.* logs |
| Host checks | flutter-analyze.log / .exit.txt and flutter-test.log / .exit.txt |
| Preserved candidate | approved-release.apk, same hash as build/app/outputs/flutter-apk/app-release.apk |
| Consolidated status | summary.json retains both final passes and the initial API 35 smoke failure |

Run only on a designated emulator without an owner installation. Flutter's test runner removes its debug test installation; do not use it on the physical Samsung or an emulator containing data that must be preserved. Check API/page size/boot before each run, and stop the first emulator before starting the next:

```powershell
flutter test integration_test/release_e2e_test.dart -d emulator-5554 --reporter expanded
python tool/emulator_release_smoke.py --serial emulator-5554 --api 36 --page-size 16384 --apk build/release_validation/v080_emulator/approved-release.apk --evidence build/release_validation/v080_emulator/api36-release-smoke
# After shutting down API 36 and booting the isolated API 35 emulator:
flutter test integration_test/release_e2e_test.dart -d emulator-5554 --reporter expanded
python tool/emulator_release_smoke.py --serial emulator-5554 --api 35 --page-size 4096 --apk build/release_validation/v080_emulator/approved-release.apk --evidence build/release_validation/v080_emulator/api35-release-smoke-retry
```

Host checks executed after adding E2E support: flutter pub get exit 0, dart format on the integration test and final no-change formatting check exit 0, flutter analyze exit 0/no issues (6.8s), flutter test test --reporter expanded exit 0/all 57 passed. The E2E suite contains five additional cases, executed on each emulator, not 67 distinct unit tests.

## Remaining verification

Subsequent OWNER-CONFIRMED evidence (2026-11-14): API 36/16 KB manual QA PASS (5/5), covering gesture/three-button navigation, portrait/landscape, light/dark/system bars, custom questions/keyboard/large text, force-stop/relaunch/persisted state. This supersedes the manual-matrix pending items below for those five cases only. These are not new agent-executed tests and do not establish ARM64 hardware, interrupted-write, reboot/backup/restore or unspecified maximum display/font settings. See REAL_DEVICE_QA.md. The automated results and initial API 35 failure above are preserved as originally executed.

Android 16 gesture/three-button navigation matrix, landscape, keyboard/system-bar contrast across themes, maximum font/display settings, ARM64 16 KB runtime, abrupt interruption during pending writes, full custom/settings/deck state after OS process death, reboot and backup/restore remain unverified by these automated runs. E2E AppStore reload is not OS process death; the release force-stop check establishes saved Haptics OFF only. Physical TalkBack/large text and Samsung upgrade remain owner-confirmed evidence. Play-delivered signing/update compatibility, listing/Data Safety/account-specific gates and owner approval remain separate requirements.

Preserved output/, qa/, all untracked owner files and the intentional CODEX_TASKS.md deletion. Exclude raw evidence, AVD images, temporary files and all credentials from any future commit.

Final formatting and git diff --check exited 0; no files staged. Both original release APK and AAB hashes remain unchanged. The isolated API 35 emulator remains running with the tested release APK; API 36 remains stopped.
