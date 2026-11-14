# Android release setup

The owner approved permanent application ID `com.ahmedhassan.passthephone`. The namespace and MainActivity package/path match it. The release identity guard enforces this exact ID for signed releases and unsigned smoke builds.

Historical source identities were `com.passthephone.pass_the_phone` and `com.example.pass_the_phone`, both previously configured with debug signing. Inspection found no release tags, GitHub releases, committed APK/AAB artifacts or distribution records; Play Console and private distribution were not accessible for verification. A different ID creates a separate Android data sandbox. Old data is not deleted, but is not accessible to this new package. There is no automatic cross-package migration. Do not uninstall or clear any old installation to try to migrate it. If a previously distributed build is discovered, establish its identity/certificate and a data migration plan before release. Future in-place upgrades must retain the approved permanent ID and compatible signing certificate.

Normal release APK/AAB builds require private upload signing configuration. There is no debug-key fallback. The owner must securely provision an upload key outside the repository, back it up and enroll in Play App Signing. No key was generated during this work.

Create ignored `android/key.properties` locally with properties `storeFile`, `storePassword`, `keyAlias`, `keyPassword`. Use an absolute keystore path with forward slashes (or a path relative to android/). Never paste credentials into commands, CI logs, comments or tracked files. Signed CI needs a separately configured secret-delivery process.

Compilation-only checks: run `flutter build apk --release -PunsignedSmokeBuild=true` and `flutter build appbundle --release -PunsignedSmokeBuild=true`. This explicitly disables signing even if private signing properties exist. Omit this flag before building an upload artifact. Unsigned outputs are not release candidates.

Before upload:

1. Confirm identity and historical certificate compatibility; increment version code beyond previous uploads.
2. Run preflight and complete the device matrix in TEST_REPORT.md.
3. Run `flutter build appbundle --release` without the smoke flag.
4. Record SHA-256 of `build/app/outputs/bundle/release/app-release.aab` with `Get-FileHash`.
5. Run JDK `jarsigner -verify -verbose -certs` and `keytool -printcert -jarfile` against the AAB. Compare the signer SHA-256 fingerprint with the approved upload certificate; self-signed certificates need this comparison.
6. Inspect the final merged manifest: target >=36, intended ID/version/min SDK and permissions. Validate native library 16 KB page size support in Play internal testing.

compileSdk and targetSdk have an explicit floor of 36. Flutter 3.47.7 defaults to 36 and minSdk 24. Existing AGP 9.1.0, Gradle 9.3.1, Kotlin 2.4.0 and Flutter compatibility flags are retained; repeat builds after any toolchain change.

Source review: the main manifest requests VIBRATE for optional capped native haptic feedback, gated by the persisted haptics setting. INTERNET is only in debug/profile. No ad, analytics, account or networking SDK is declared. Inspect merged release permissions after dependency changes.

SafeArea is used throughout; Android 15/16 edge-to-edge insets, gesture/three-button navigation contrast and large text need device verification. Owner-approved launcher/adaptive icons, native splash and Home hero are integrated and preserved in v0.8. Do not regenerate branding during release checks.

2026-11-14 update: owner-confirmed API 35/TalkBack/large-text results and agent-executed API 36/16 KB plus API 35 emulator E2E/release smoke are documented in EMULATOR_E2E_REPORT.md and REAL_DEVICE_QA.md. The full Android 16 manual navigation/inset/orientation matrix remains separate from these core automated passes.

Final owner confirmation on the same date: Android 16/API 36/16 KB manual QA PASS (5/5) for gesture/three-button navigation, portrait/landscape, light/dark/system bars, custom questions/keyboard/large text and force-stop/relaunch/persisted state. This closes the corresponding manual gates above using OWNER-CONFIRMED evidence; it does not claim ARM64 hardware, interrupted-write, reboot or backup/restore verification.

RC version is `0.8.0+8`. The owner confirmed no previous Play uploads and unused code 8; this is owner evidence, not a Play Console API query. Existing private signing configuration is reused unchanged. Do not regenerate/replace keys. See V080_RC.md for artifact verification and remaining device gates.

Sources checked 2026-11-11: [Flutter release/signing](https://docs.flutter.dev/deployment/android), [Play API requirements](https://support.google.com/googleplay/android-developer/answer/11926878), [Android signing](https://developer.android.com/studio/publish/app-signing).
