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
