# Android release setup

The existing `com.example.pass_the_phone` ID is retained pending owner approval, as required by CODEX_TASKS.md. Do not invent a replacement. In-place upgrades require the same application ID and compatible signing certificate. Establish the identity/certificate of any distributed build first. A new ID creates a separate data sandbox; preference tests cannot prove cross-ID upgrades.

Normal release APK/AAB builds are blocked until identity and signing are configured. There is no debug-key fallback. The owner must securely provision an upload key outside the repository, back it up and enroll in Play App Signing. No key was generated during this work.

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

Source review: no permissions in main manifest; INTERNET is only in debug/profile. No ad, analytics, account or networking SDK is declared. Inspect merged release permissions after dependency changes.

SafeArea is used throughout; Android 15/16 edge-to-edge insets, gesture/three-button navigation contrast and large text need device verification. Existing raster launcher icons remain; no adaptive icon is supplied. Owner icon approval/replacement remains open.

Sources checked 2026-11-11: [Flutter release/signing](https://docs.flutter.dev/deployment/android), [Play API requirements](https://support.google.com/googleplay/android-developer/answer/11926878), [Android signing](https://developer.android.com/studio/publish/app-signing).
