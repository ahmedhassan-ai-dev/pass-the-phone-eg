# Google Play release checklist — v0.7

- [x] Owner-approved permanent applicationId: `com.ahmedhassan.passthephone` (retain for future upgrades; historical cross-package data access is not supported).
- [ ] Target SDK >= 36 per Google Play requirement for new apps after Aug 31 2026.
- [ ] Version code incremented for every Play upload.
- [ ] App icon, adaptive icon, app label, screenshots, feature graphic reviewed.
- [ ] Signed release `.aab`, upload key stored privately and backed up.
- [ ] Sensitive files ignored (`*.jks`, `*.keystore`, `key.properties`, `.env`).
- [ ] Privacy policy hosted at accessible URL; app Data Safety answers checked against actual SDKs.
- [ ] Target audience/content rating reviewed, especially surprise and romantic prompts.
- [ ] Native permissions reviewed; no unnecessary permissions or SDKs.
- [ ] Minimum 2 Android devices tested incl. small screen + newest API emulator.
- [ ] Custom question persistence, existing unseen queue, settings survive update/restart.
- [ ] TalkBack/large text/RTL and reduce-motion checked.
- [ ] No bugs/crashes in release-mode sessions.
- [ ] Internal test rollout; if eligible personal account, closed test with 12 opted-in testers for 14 continuous days.
- [ ] Store listing and content reviewed by humans.

Official sources:
- https://support.google.com/googleplay/android-developer/answer/11926878
- https://support.google.com/googleplay/android-developer/answer/14151465
- https://docs.flutter.dev/deployment/android
