# Google Play release checklist — v0.8.0 RC (0.8.0+8)

Final release scope: **original 220 questions only** (155 friends, 25 love, 25 family, 15 surprise). All content expansions are postponed. See [FINAL_RELEASE_READINESS.md](FINAL_RELEASE_READINESS.md) for the final artifact checks, exact 27-path commit allowlist and remaining publication gates. Do not include the deferred expansion audit or any expanded-bank file in this release.

Status: built and statically validated; owner confirmed RC Samsung upgrade/seven functional checks, API 35 eight manual checks, physical TalkBack and large text, plus Android 16/API 36/16 KB manual QA PASS (5/5). Separate agent-executed E2E and signed-release smoke pass on API 36/16 KB x86_64 and API 35/4 KB x86_64. Owner approved the exact local release commit; remaining Play gates and residual QA are listed in FINAL_RELEASE_READINESS.md. See EMULATOR_E2E_REPORT.md for automated scope and the retained initial API 35 smoke failure/passing rerun.

- [x] Branch release/v080-preparation starts at approved branding b62211e and contains production hardening through ancestry; no merge required.
- [x] Permanent package com.ahmedhassan.passthephone and existing signing identity retained.
- [x] Owner confirmed first Play release and unused code 8; source/APK/AAB report 0.8.0+8.
- [x] Target/compile SDK 36 and min SDK 24 verified in both artifacts.
- [x] Approved icon, adaptive icon, splash, Home hero, bank and categories preserved.
- [x] Original-bank byte hash/counts/IDs/categories verified against b62211e; APK and AAB both contain the same 220-entry JSON. No expanded bank loaded or bundled.
- [x] Native policy action, browser-unavailable/copy fallback and installed version metadata implemented and mock-tested.
- [x] SDK Arabic localization, RTL, selected-category/tap and single-round semantics tested.
- [x] Second-cycle queue bug reproduced red, then fixed; exact restored sequence and uninterrupted shuffle tests pass.
- [x] Ordered/failing writes and custom data retention tested; seven keys/backend unchanged.
- [x] Backup behavior retained; no new rules, data clearing or migrations.
- [x] Formatting, analysis and 57-test suite pass; 200% portrait/landscape widget coverage included. Final regression update adds second deck-write failure/reload, failed toggle/reload and exact clipboard URL assertions.
- [x] Signed APK/AAB built with existing configuration; signatures verify and match baseline public signer.
- [x] Permissions/dependencies reviewed: no Internet/AD_ID or collection SDK in the verified release. SDK localization/intl added; SDK integration_test and test-tool transitive dependencies added for emulator E2E as dev support. No existing package versions upgraded.
- [x] Bundletool validates new AAB and produces default/universal validation APK sets.
- [x] Native ELF/ZIP static 16 KB alignment and generated native-content checks pass.
- [x] Signing secrets remain ignored; none directly read, created, replaced, staged or committed.
- [x] Agent-executed signed-release external browser launch and actual version footer pass on both emulators. Clipboard-unavailable fallback remains mock-tested only.
- [ ] Physical unavailable-browser/copy fallback verification.
- [x] Owner-confirmed Samsung RC upgrade and seven functional QA checks passed; not independently repeated by the agent.
- [x] Owner-confirmed Android 15 (API 35): all eight manual checks passed; not independently repeated by the agent.
- [x] Owner-confirmed physical TalkBack accessibility and large-text checks passed. Exact maximum device font/display settings were not supplied.
- [x] Owner confirms force-stop and app relaunch commands executed successfully; command execution alone does not verify restored persisted state.
- [ ] Abrupt process-death save timing/state verification, reboot and backup/restore device checks; maximum display/font limits not explicitly confirmed.
- [x] OWNER-CONFIRMED API 36/16 KB manual QA (5/5): gesture/three-button navigation; portrait/landscape; light/dark/system bars; custom questions/keyboard/large text; force-stop/relaunch/persisted state. No ARM64 hardware, backup/restore or interrupted-write PASS inferred.
- [x] Agent-executed integration E2E: 5/5 on each of API 36 and API 35; host suite remains 57/57 with clean analysis.
- [x] Signed release runtime on API 36 x86_64 PAGE_SIZE=16384: launch/play/settings/browser and saved Haptics OFF after force-stop pass. This is runtime evidence, not only static alignment; ARM64 16 KB runtime remains unverified.
- [x] Same signed APK smoke on API 35 x86_64 PAGE_SIZE=4096 passes on rerun; initial harness interaction failure retained and documented.
- [ ] Owner finalizes Data Safety, audience/IARC, support/contact, screenshots/feature graphic and listing.
- [ ] Play App Signing/upload certificate setup and Play-delivered update compatibility confirmed.
- [ ] Hosted CI, Play pre-launch and account-specific testing after separately approved push/upload.
- [x] Owner approved original-bank implementation/artifacts and the exact 27-path local release commit after final checks.
- [ ] Separate owner authorization before push, PR, merge, tag, upload or publication. None authorized by the local-commit approval.
