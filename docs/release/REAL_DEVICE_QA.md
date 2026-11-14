# Real-device release QA checklist

Status: **PARTIALLY COMPLETE — owner-reported manual results**. The owner confirmed the Samsung SM-A225F release APK results below; these were not executed or independently observed by the agent. Unchecked detailed cases remain unverified and are not implied by the broader owner confirmations. Use test questions only; exclude personal question content, device serials and credentials from shared logs.

## Owner-reported manual evidence

Report received 2026-11-11 (Africa/Cairo) through the owner's chat confirmation. Device: Samsung SM-A225F; build type reported: release APK. Actual test date, installed APK hash/version/certificate, font scale, navigation mode and detailed steps were not supplied. Earlier read-only tool queries identified this model as API 33 with 4096-byte pages; they do not independently verify the manual tests or tie the installed APK to the validated AAB.

| Check | Result | Evidence source / scope |
| --- | --- | --- |
| App launch | PASS | Owner-reported manual confirmation on release APK. |
| Quick Play | PASS | Owner-reported manual confirmation. |
| Question rotation | PASS | Owner-reported manual confirmation; exact sequence/full-cycle coverage not supplied. |
| Custom questions | PASS | Owner-reported manual confirmation; per-category validation/deletion coverage not supplied. |
| Persistence | PASS | Owner-reported manual confirmation; restart method and exact saved values not supplied. Does not establish upgrade or process-death behavior. |
| Handoff ON/OFF | PASS | Owner-reported manual confirmation for both modes. |
| Light/dark themes | PASS | Owner-reported manual confirmation for both themes; system-theme behavior not confirmed. |
| Surprise cards | PASS | Owner-reported manual confirmation; detailed toggle/restart sequence not supplied. |
| UI quality | PASS | Owner-reported manual confirmation; does not establish the detailed RTL/accessibility/scaling/device matrix below. |

**No PASS evidence supplied** for same-package upgrade, TalkBack, maximum font/display scaling, Android 15/16 edge-to-edge, process death or 16 KB runtime. These remain NOT RUN / unverified in this report. Detailed RTL, system theme, lifecycle/background tests and other unchecked criteria also remain unverified unless separately evidenced. No screenshots or test logs were supplied with the owner's confirmation.

## Test record and devices

Record tester/date (Africa/Cairo), model, Android/API level, ABI, screen size/resolution, font/display scale, navigation mode, system/app theme, memory page size, app version/code, artifact SHA-256 and public signer fingerprint. Record each case as PASS / FAIL / BLOCKED with steps, expected/actual behavior and evidence reference.

- [ ] Small-screen physical phone: normal and maximum supported font/display sizes.
- [ ] Larger physical phone/tablet: light/dark, portrait and available landscape behavior.
- [ ] Android 15/16+ device: gesture and three-button navigation; edge-to-edge safe insets/contrast.
- [ ] 16 KB page-size runtime: Android device or emulator with `adb shell getconf PAGE_SIZE` returning 16384; record result. Static ELF/ZIP checks do not complete this test.

An SM-A225F, API 33, 4096-byte pages was detected during artifact validation. Tool activity on it was limited to read-only model/API/page-size queries. The later owner-reported manual PASS results are recorded above separately. This device observation cannot provide Android 15/16 or 16 KB runtime evidence.

## Release installation and identity

- [ ] Obtain an owner-provided, properly signed APK or APK set derived from the approved AAB. Verify hash and public signer certificate before installation. The generated validation APK sets in build/release_validation are UNSIGNED and cannot be installed; do not attempt to sign them with another key as a shortcut.
- [ ] On a spare test device, install the signed release artifact; confirm package `com.ahmedhassan.passthephone`, version 0.7.0/code 7 (or the exact later candidate recorded above), correct Arabic label, successful cold launch and no startup crash.
- [ ] On a separate same-package baseline installation, create test data and install a compatible-signed, higher-version candidate in place (`adb install -r <owner-provided-release.apk>` or an approved split-install flow). Preserve the installation and its data. Stop on certificate/version mismatch; never uninstall, clear data or force a downgrade to make the test pass.
- [ ] Treat installations under com.example.pass_the_phone / com.passthephone.pass_the_phone as separate apps. Their data is not automatically accessible under the permanent ID. Do not report cross-package migration as passing.
- [ ] Test offline launch and full play with networking disabled on the test device, then restore the device setting.

## Layout, RTL and accessibility

- [ ] Arabic RTL: home, categories, rounds, game/handoff, settings, custom-question editor/list and dialogs have correct reading order, back/close behavior, alignment and no clipped punctuation or mixed Arabic/Latin labels.
- [ ] Maximum font and display scaling: scroll to every control; inspect long 180-character test questions, keyboard open/closed, dialog actions and bottom buttons. No overflow, inaccessible text or controls obscured by keyboard/system bars.
- [ ] Light, dark and system theme: apply each, restart and verify the selection persists. In system mode, change device theme while foregrounded and backgrounded; confirm the app follows it.
- [ ] Check contrast and safe areas with gesture/three-button navigation on API 35/36+, including handoff and finish screens.
- [ ] TalkBack: meaningful labels, focus order, question text and button announcements. Test reduced-motion setting and verify usable interactions.

## Gameplay and navigation

- [ ] Quick Play starts The Crew in unlimited mode. Each reveal advances once; repeated rapid taps do not crash or skip into invalid state.
- [ ] Play each available category with finite and unlimited sessions. Verify finite counts (10/20/30/50), final round, finish screen and return home.
- [ ] Handoff ON hides the next question until reveal; OFF advances directly. Changes apply to new games as described by the app.
- [ ] Toggle surprise and haptics; verify new sessions follow the selection, including after restart. Surprise OFF excludes surprise cards; ON permits them in The Crew without altering other category behavior.
- [ ] System back and close: cancel exit to continue; confirm exit to return home. No duplicate dialog, route trap or unintended loss of saved preferences/custom questions.

## Persistence and question rotation

Use distinctive, non-personal test prompts. Keep before/after notes or screenshots; do not retrieve or edit private preference files to manufacture a passing result.

- [ ] Add custom questions to each category; verify text/category and visibility in the list after leaving/reopening it. Test validation and cancel the deletion dialog; no unwanted deletion. Exercise confirmed deletion only on a designated disposable test question.
- [ ] Set non-default theme/handoff/haptics/surprise values. Relaunch and verify all settings and retained custom questions match the baseline exactly.
- [ ] Record revealed questions for a category across several short sessions. Exit while unseen questions remain; start again and confirm previously revealed questions do not recur ahead of the remaining unseen deck. Include custom questions and independently check the other categories.
- [ ] Exhaust a full category cycle; verify each eligible question appears before reuse, and the cycle boundary does not immediately repeat the last question when there is more than one question. Repeats after exhaustion are expected.
- [ ] Add a test question while a category has an unfinished deck; verify earlier unseen progress survives and the new question becomes eligible without resetting all prior progress.
- [ ] Perform the in-place update case above and repeat settings/custom/rotation checks. Record same application ID, compatible signer and baseline/candidate version codes as evidence.

## Lifecycle and process restart

- [ ] Home/background/foreground while on home, a question, handoff, settings and custom editor; wait at least 30 seconds. Check resume, text layout and route behavior. Do not assume unsaved editor text or active game round is persisted across process death.
- [ ] Lock/unlock and background under memory pressure; return to the app and check usability plus saved data.
- [ ] After saving settings/custom questions and revealing cards, terminate the app process and relaunch (`adb shell am force-stop com.ahmedhassan.passthephone` on the test device, then open the launcher icon). Verify settings/custom content and unseen-deck progression; starting a fresh game on relaunch is acceptable because active-session restoration is not implemented.
- [ ] Repeat process termination shortly after a reveal to test persistence timing; record any repeated card or lost save as a failure with timing details.
- [ ] Reboot the test device and relaunch; verify settings/custom questions/remaining queue behavior again.

## Evidence and exit criteria

- [ ] Run release mode without a debug service attached. Record crashes/ANRs, layout defects and data discrepancies with reproduction steps; sanitize logs before sharing.
- [ ] Repeat core launch/play/persistence on the 16 KB runtime and both physical display classes. Static alignment passes alone are insufficient.
- [ ] Mark unexecuted or unavailable cases NOT RUN/BLOCKED with the reason. Do not tick a case merely because automated tests cover similar logic.
- [ ] Owner reviews remaining defects, icon/listing/policy content, signing identity and testing evidence before authorizing any release. This checklist authorizes no upload, merge or publication.

## v0.8.0+8 RC — safe owner upgrade procedure (2026-11-13)

This procedure was initially pending on 2026-11-13. See the owner-confirmed update below for current status; automated RC checks in V080_RC.md do not constitute device PASS.

1. Use a designated test device with its existing v0.7 installation. Do not uninstall, clear app/launcher storage, force a downgrade or replace signing keys. Preserve any existing owner data and backup settings.
2. Record installed package/version, model/API, font/display settings and navigation mode. Use `adb shell pm path com.ahmedhassan.passthephone` to locate the installed base APK; if needed pull only that program APK into ignored local build storage and inspect its public certificate with apksigner. This does not require access to private app data or a keystore. Compare it with the verified RC signer in V080_RC.md. Stop on a mismatch.
3. Record retained custom questions and non-default theme/handoff/haptics/surprise settings. Reveal a few non-sensitive built-in questions while unseen cards remain. Optionally add one clearly designated disposable test question, without deleting originals.
4. Verify candidate APK SHA-256 and version 0.8.0/code 8, then install in place: `adb install -r "build/app/outputs/flutter-apk/app-release.apk"`. Stop on failure; never use uninstall, clear-data or downgrade flags as a workaround. The AAB and generated UNSIGNED validation APKs are not direct installation candidates.
5. Open Settings. Verify actual `0.8.0 (8)` metadata, Arabic framework controls, policy URL in an external browser and normal return/back navigation. Browser-unavailable/copy fallback requires a suitable isolated device setup; do not disable the owner's browser to force this case.
6. Confirm every retained custom question and saved setting, plus continued unseen progression in each category. Test a subsequent deck cycle as well as initial-cycle progress. Existing active-game restoration is not implemented: a fresh game after process death is expected.
7. After confirmed saves, background/foreground, lock/unlock, restart and reboot on the test device. A deliberate `adb shell am force-stop com.ahmedhassan.passthephone` may be used after recording state; relaunch and verify saved content/queue. Test abrupt post-reveal timing separately. Do not mark process-death persistence PASS based on an in-memory fixture.
8. On API 35 and 36, inspect all screens/dialogs with gesture and three-button navigation, system bars/cutouts, keyboard, landscape, both themes and maximum font/display settings. Keep approved visual design; record any reproducible defect before changing UI.
9. With TalkBack, confirm category selection state/action, Arabic announcements, one round announcement and logical focus order. Test long questions, reachable bottom controls and reduced motion.
10. On a separate actual 16 KB device/emulator, record `adb shell getconf PAGE_SIZE` = 16384, then run release launch/play/custom/settings/lifecycle checks. Existing 4 KB or API 37.2-only observations do not establish API 35/36 or 16 KB PASS.

Play signing note: the upload certificate and Play distribution app-signing certificate are distinct roles and may differ. Verify intended delivery compatibility before testing a Play-served update over a local APK. Stop on INSTALL_FAILED_UPDATE_INCOMPATIBLE; preserve the installation and its data. No wipe or signing change is authorized by this checklist.

## Owner-confirmed RC QA update — 2026-11-14

Source: owner's explicit confirmation in this session, not independent agent execution or inference from generated QA logs.

| Verification | Status and limits |
| --- | --- |
| Samsung SM-A225F RC upgrade and seven functional QA checks | Owner-confirmed PASS. No new agent installation performed. |
| Android 15 / API 35, eight manual checks | Owner-confirmed PASS for the owner's eight-check matrix. Per-check settings/device details were not supplied here; do not infer additional scenarios. |
| Physical TalkBack accessibility and large text | Owner-confirmed PASS. Do not extend this to unspecified maximum display/font settings. |
| Force-stop and relaunch commands | Owner confirms successful execution. Retained content and queue assertions after termination, especially interrupted writes, are not established by command success alone. |
| Android 16 / API 36 and 16 KB runtime | Subsequently agent-executed PASS for five E2E cases and the signed-release smoke on x86_64 PAGE_SIZE=16384; see EMULATOR_E2E_REPORT.md. Full Android 16 manual matrix and ARM64 16 KB remain pending. |
| Browser-unavailable clipboard fallback | Automated tap/clipboard assertion; physical unavailable-browser path remains unverified. |
| Abrupt save termination, reboot, backup/restore | PENDING unless separately confirmed with state assertions. |

No changes to the owner's output/ or qa/ files were made for this update. Prior dated checklists remain historical; the confirmations above do not retroactively establish unobserved tests.

## Agent-executed emulator update — 2026-11-14

See [EMULATOR_E2E_REPORT.md](EMULATOR_E2E_REPORT.md) for the exact matrix, commands and ignored raw evidence. API 36/16 KB was completed and stopped before isolated API 35/4 KB started. Five integration E2E cases passed on each; signed production APK smoke passed on API 36 and on an API 35 rerun after a retained UI-automation timing failure. Both release smokes verified saved Haptics OFF after force-stop/relaunch, external browser activity launch and actual version display. This supersedes the earlier pending status only for these exercised cases. It does not establish abrupt-write durability, complete custom/deck state after process death, reboot/restore, maximum display scaling or all Android 16 navigation/orientation combinations. No physical Samsung command or new physical-device test was performed.

## Final OWNER-CONFIRMED Android 16 manual QA — 2026-11-14

Owner explicitly confirmed Android 16 / API 36 / 16 KB manual QA **PASS (5/5)**. These results supersede earlier pending labels for the following cases only; they were not independently repeated by the agent:

| Owner manual case | Result |
| --- | --- |
| Gesture and three-button navigation | OWNER-CONFIRMED PASS |
| Landscape/portrait transitions | OWNER-CONFIRMED PASS |
| Light/dark themes and system bars | OWNER-CONFIRMED PASS |
| Custom questions, keyboard and large-text layouts | OWNER-CONFIRMED PASS |
| Force-stop, relaunch and persisted state | OWNER-CONFIRMED PASS |

This is not evidence of ARM64 hardware testing, interruption while writes are pending, reboot or backup/restore. Exact maximum font/display settings were not specified. Existing automated E2E/signed-release evidence and the initial API 35 harness failure are retained unchanged. No additional device commands were run for this owner-confirmation update.
