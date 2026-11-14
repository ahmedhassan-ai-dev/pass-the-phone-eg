# First Google Play release — v0.8.0+8, original 220-question bank

Reviewed 2026-11-14 (Africa/Cairo), branch release/v080-preparation. **Owner approved the original-bank candidate and the exact local release commit below. Publication, push, merge, tags and uploads remain unauthorized; Play Console gates remain unverified.**

## Frozen release scope

The owner postponed the expanded question bank to a future update. The earlier 800-question audit is an unimplemented historical proposal; neither it nor the proposed 900-question file belongs in this release commit. No audit rewrite suggestions were applied.

| Original stored category | Count |
| --- | ---: |
| friends / The Crew | 155 |
| love / Crush Club | 25 |
| family / Family Time | 25 |
| surprise / optional Surprise Cards | 15 |
| **Total** | **220** |

assets/data/questions.json is byte-for-byte identical to approved branding commit b62211e. SHA-256: CDD2B34BED02D7E67F0DAC902DD15CCEFBE61ECBF736D3E617DE6175C732EA71. All original texts, IDs, categories and order are intact. Schema, nonempty fields, unique IDs and global Arabic-normalized exact uniqueness pass. Semantic overlap noted by the earlier editorial audit is not a reason to alter this owner-approved release bank.

The app loads only assets/data/questions.json; its exact asset declaration is retained. assets/data contains no expanded bank, there is no questions_900_expanded reference in application/test configuration, and no expanded bank occurs in APK/AAB ZIP entries. No expansion file was imported, opened as content, or used.

No production source, bank, branding, version, signing configuration, saved preference keys or persistence behavior was edited during this final review. Existing approved pre-release fixes remain in the working tree. No owner data or device was touched; output/, qa/, previous evidence and the intentional CODEX_TASKS.md deletion are preserved.

## Existing signed artifact correspondence

Release candidate: build/app/outputs/bundle/release/app-release.aab.

- AAB SHA-256: A20479CFDCAD116B73B4F615E35103855DD3794C310CDCCA1E57A649FEA33249.
- Existing smoke-tested APK: build/app/outputs/flutter-apk/app-release.apk; SHA-256 B601237EDDA7A421B10C67B784A2EF01D3E01D1053080D2359F6186068FE1386.
- Public signer SHA-256: 68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575. No private key/password was read or printed.
- Official bundletool 1.18.3 validate and manifest dump succeeded again. AAB identity: com.ahmedhassan.passthephone, versionName 0.8.0, versionCode 8, min SDK 24, target/compile SDK 36, non-debuggable. Owner previously confirmed code 8 unused; no Play Console query was performed.
- jarsigner exited 0 with explicit `jar verified.`; unsigned marker absent. Independent Java JarFile verification finds 407 signed entries among 409 with one approved signer. Known self-signed/no-timestamp/JarInputStream manifest-order warnings remain: streaming recognizes zero signatures, but both readers return all 409 identical payload hashes. No archive was edited; Play acceptance remains untested.
- AAB and APK both contain the exact original question-bank bytes and the current approved hero PNG. Android resources, launcher/splash configuration and Gradle identity/signing files have no diff from approved HEAD.
- All **15 imported production Dart files**, including Settings/privacy, persistence and haptics, occur byte-for-byte in the saved release kernel. That kernel's cached output digest matches. section_label.dart is an unused file and is not a release entry-point dependency.
- For arm64-v8a, armeabi-v7a and x86_64, **every allocated ELF section** of compiled release app.so matches the corresponding AAB libapp.so; stripped release intermediates match the AAB byte-for-byte. All 12 native payloads and the DEX payload match the already smoke-tested APK. Debug and release MainActivity javap executable disassembly is identical, consistent with the unchanged Kotlin source and E2E build.

These are direct content/payload comparisons plus local build-record provenance, not a new reproducible build or supply-chain attestation. Preliminary raw cache/class comparisons were not used as the verdict: debug/symbol sections, build metadata, an unused source and a stale individual cache digest require the direct kernel/ELF/disassembly comparisons described above. The added integration_test dev tooling postdates the signed artifacts; it does not imply those artifacts contain the debug E2E runner or are a byte-for-byte rebuild of every current test-tool input. No new signing/rebuild was required or performed; the approved 220-question production payload is current.

## Executed validation and evidence

| Check run in this final review | Result |
| --- | --- |
| flutter analyze | PASS, exit 0, no issues (5.2s) |
| flutter test test --reporter expanded | PASS, exit 0, **57/57** unit/widget tests |
| Content schema/counts/ID/global-normalized-uniqueness and baseline-byte assertions | PASS, 220 original entries |
| AAB question/hero/payload/source correspondence | PASS with the provenance scope above |
| jarsigner, signed-entry/certificate audit, bundletool validation and manifest identity | PASS; documented warnings remain |
| Public privacy URL HTTPS GET | HTTP 200, HTML, no login from this host; reviewed policy matches local/offline storage and vibration behavior |

Privacy URL: https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/ . Web-reader access failed, but an independent direct HTTPS GET succeeded; that tool failure is not treated as site downtime. Current policy mentions local preferences/custom questions/rotation, optional vibration, no app advertising/analytics/server collection and device-dependent backup. It currently offers a public GitHub issue contact and notes that a private support email is forthcoming; owner should provide an appropriate support contact in the store listing and may improve the privacy contact separately.

Existing agent-executed emulator evidence is retained, not rerun or expanded in this task: five E2E cases per API 36/16 KB x86_64 and API 35/4 KB x86_64, plus signed-release smoke PASS on both. Initial API 35 smoke failure and passing harness-adjusted rerun remain documented. Samsung upgrade/seven functional checks, API 35 manual checks, physical TalkBack/large text remain **owner-confirmed**. See EMULATOR_E2E_REPORT.md and REAL_DEVICE_QA.md.

Subsequent owner confirmation, 2026-11-14: **Android 16 / API 36 / 16 KB manual QA PASS (5/5)**: gesture and three-button navigation; landscape/portrait transitions; light/dark themes and system bars; custom questions/keyboard/large-text layouts; force-stop/relaunch/persisted state. This is OWNER-CONFIRMED evidence, not newly agent-executed testing. It supersedes the previously pending Android 16 manual matrix for those five cases. ARM64 hardware, interrupted-write timing, reboot and backup/restore were not confirmed. Exact maximum font/display settings were not specified.

New raw evidence stays ignored in build/release_validation/v080_final_220/: analysis/test logs and exit files; content-and-source.json (preliminary probe), compiled-source-correspondence.json, native-source-correspondence.json, release-identity.json, final-verification.json; AAB signature/bundletool logs; public policy HTTP response; MainActivity disassembly. Do not commit these files. Prior build/release_validation/v080/ and v080_emulator/ evidence remains intact.

## Exact recommended release commit allowlist

Include only the following modified/new files, plus the deliberate deletion noted after the list. Do not use blanket staging. Existing unchanged assets/data/questions.json and approved branding are already tracked and need no new change.

```text
android/app/src/main/kotlin/com/ahmedhassan/passthephone/MainActivity.kt
lib/app/app.dart
lib/core/services/app_info.dart
lib/core/services/app_store.dart
lib/core/services/game_session.dart
lib/features/game/game_screen.dart
lib/features/home/home_screen.dart
lib/features/questions/custom_questions_screen.dart
lib/features/settings/settings_screen.dart
pubspec.yaml
pubspec.lock
test/accessibility_layout_test.dart
test/app_store_upgrade_test.dart
test/deck_cycle_persistence_test.dart
test/game_session_test.dart
test/persistence_writes_test.dart
test/settings_info_test.dart
integration_test/release_e2e_test.dart
tool/emulator_release_smoke.py
docs/release/ANDROID_RELEASE.md
docs/release/REAL_DEVICE_QA.md
docs/release/RELEASE_CHECKLIST.md
docs/release/TEST_REPORT.md
docs/release/V080_RC.md
docs/release/EMULATOR_E2E_REPORT.md
docs/release/FINAL_RELEASE_READINESS.md
```

Also include **deletion of CODEX_TASKS.md**, intentionally requested by the owner: 26 included files plus one deletion, 27 paths total.

Exclude output/, qa/, build/, .dart_tool/, generated logs/reports/screenshots/APK/AAB/AVD data, temporary files, credentials/key.properties/keystores/.env files, any questions_900_expanded.json, and docs/release/QUESTION_BANK_800_PHASE1_AUDIT.md (deferred expansion proposal). Preserve these owner/local files; do not delete them. No tracked signing credentials were found; signing ignore patterns are effective. No staging was performed.

## Remaining gates

**No known application/content/signing/bundle-validation blocker was found for this original-bank candidate.** Remaining publication gates are not confirmed in Play Console:

1. Owner approved the final source/artifact and exact local commit scope. Push, merge, tags, upload and publication still require separate authorization.
2. Complete and review listing/contact/screenshots/graphics, Data Safety, ads/access declarations, target audience and IARC rating for the actual romantic/party content. The app cannot be described as having 800/900 questions. [Official app-content review guidance](https://support.google.com/googleplay/android-developer/answer/9859455?hl=en).
3. Confirm Play App Signing/upload certificate setup and Play-served update compatibility; upload/pre-launch/Console checks and Google review have not run. The local upload signer and Play distribution signer may differ. [Official release preparation guidance](https://developer.android.com/studio/publish/preparing).
4. If this is a personal developer account created after 2023-11-13, confirm the required closed test (at least 12 continuously opted-in testers for 14 days) and production-access approval. Account applicability/completion is unverified; local tests do not replace it. [Official testing requirements](https://support.google.com/googleplay/android-developer/answer/14151465?hl=en).

**Residual QA coverage, not an assertion of a Play rejection:** ARM64 16 KB hardware runtime; interruption during pending writes; reboot/backup restore; unspecified maximum display/font configurations; physical unavailable-browser clipboard fallback. The owner-confirmed Android 16 force-stop/relaunch/persisted-state PASS does not prove interrupted-write or every possible OS-death timing scenario. Existing tests cover serialized writes and established-deck second-write failure, not atomic multi-key durability. Hosted CI awaits separately approved push.

No questions, production code, IDs, gameplay, saved data, branding or signing identity were changed during this final documentation/commit task. The owner authorized one local commit, release: finalize Pass The Phone v0.8.0+8, after successful checks and exact staging review. Its resulting SHA is recorded by Git and reported to the owner; no self-referential commit hash is embedded here. No push, merge, tag, upload or publication is authorized.
