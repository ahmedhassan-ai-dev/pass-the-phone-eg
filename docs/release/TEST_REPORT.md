# v0.7 hardening test report

Executed 2026-11-11 (Africa/Cairo) on branch `chore/v07-production-hardening`, starting from e0db3d6 with the supplied uncommitted v0.7 overlay. Main was not modified. Existing overlay changes were preserved.

## Readiness

**Not ready for store release.** The owner has confirmed production native vibration perceptibility and Haptics OFF suppression PASS on Samsung SM-A225F; these are owner-reported manual results, recorded in the latest follow-up below. Fresh signed APK/AAB build/signature evidence is recorded separately. Exact cooldown timing, action-by-action duration tuning and process-death persistence remain unverified on hardware. Earlier gameplay/bundletool/16 KB evidence applies to its recorded artifacts, not automatically to the rebuilt candidate. Same-package upgrade, TalkBack, maximum font scaling, Android 15/16 edge-to-edge and 16 KB runtime remain unverified, alongside final icon, Play validation and owner policy/listing review. The JarInputStream ordering discrepancy remains explained; fresh JarFile verification and byte comparison passed. GitHub CI status must be checked against the pushed commit; earlier results are not evidence for that commit.

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

## Original required manual evidence (status at initial audit)

No real Android device or emulator was connected. On small and larger Android devices, including API 35/36+, record model/API/build and results for light/dark/system, large text, RTL, TalkBack, reduced motion, gesture/three-button navigation contrast, edge-to-edge insets, offline play, background/foreground and process restart.

For each v0.5/v0.6 upgrade: install a compatible historical signed build, save custom questions and non-default settings, reveal several cards and record unseen queue; install v0.7 in-place with the SAME ID and compatible certificate (never uninstall or clear data). Confirm custom text/IDs/settings and unseen order after upgrade and process restart. Binary/certificate compatibility is not established here.

## Remaining release blockers

- Permanent application ID approved in the follow-up below. Distribution history was inspected with no release evidence found; private distribution/Play Console remain unverified.
- Local upload signing and signed AAB verification completed below. The archive-reader discrepancy is explained in the bundletool follow-up; Play Console upload-certificate registration/match and Play acceptance are not verified. The owner supplied the key; no credentials were generated or committed by this work.
- Physical device matrix beyond the owner's limited Samsung confirmations, actual same-package in-place upgrades, TalkBack, maximum font scaling, Android 15/16 edge-to-edge, process-death and 16 KB runtime tests remain unverified. Static native/ZIP alignment checks passed in the artifact-validation follow-up.
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

## Signed release AAB follow-up — 2026-11-11 (Africa/Cairo)

Starting commit: 28cc302 (`chore: finalize Android application identity`), on `chore/v07-production-hardening`. Owner supplied a local upload keystore and android/key.properties. No app, gameplay, storage, signing configuration or dependency changes were needed. Only this report was updated.

### Signing configuration and secret handling

Inspected the Gradle script, not credential contents. It loads local android/key.properties internally using java.util.Properties, selects signingConfigs.upload for normal release builds, requires storeFile/storePassword/keyAlias/keyPassword, resolves storeFile relative to android/ (absolute paths also supported), and has no debug-key fallback. The exact application ID guard remains in force. The signed build command below had no unsignedSmokeBuild flag.

`gradlew.bat -q :app:signingReport` (Android Studio JDK 25) succeeded. Its output was captured and filtered to non-secret metadata: release selected the upload configuration, the configured keystore exists, and it resides outside this repository. The keystore cannot be tracked by this repository; it does not need a repository ignore rule. Neither its path nor alias is included here. The inspection did not open android/key.properties or the keystore directly; Gradle alone consumed them for signing/reporting. No password or private-key contents were read into tool output or documentation.

`git check-ignore -v -- android/key.properties` confirms android/.gitignore rule `key.properties`; it is untracked. Root and Android ignore rules also cover *.jks and *.keystore. A tracked-file check covering key.properties, *.jks, *.keystore, *.p12 and *.pfx returned zero files. `git check-ignore` confirms the built AAB is excluded by /build/. No keys or credentials were generated, changed, staged or committed.

### Executed results

| Command | Actual result |
| --- | --- |
| `flutter analyze` | Exit 0, no issues (1.7 seconds). |
| `flutter test` | Exit 0, all 23 tests passed, including preferences upgrade fixtures and gameplay flows. |
| `flutter build appbundle --release` | Exit 0, 15.5 seconds; signed release AAB, reported 48.1 MB (50,446,952 bytes). No smoke flag used. |
| `jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab` | Exit 0 and explicit `jar verified.`; `jar is unsigned` absent. Signature-present checks and warning details below. |
| Temporary JDK JarFile/protobuf audit of the AAB | Exit 0; all 391/391 non-directory payload entries verified and signed by one certificate; zero duplicate ZIP entries. Parsed base/manifest/AndroidManifest.xml directly from this AAB using cached aapt2-proto 9.1.0-14792394 and protobuf-java 3.25.5. |
| Release signingReport certificate comparison | Exit 0; AAB signer SHA-256 equals the configured release/upload certificate fingerprint. No private key was inspected. |
| `Get-FileHash build/app/outputs/bundle/release/app-release.aab -Algorithm SHA256` | SHA-256 recorded below. |

The temporary Java audit ran from the OS temporary directory, outside the repository, using java --class-path with the two cached jars. It opened JarFile with verification enabled, read every entry fully (triggering signature/digest verification), checked getCodeSigners() on every payload entry, rejected missing/multiple signer identities and duplicate names, and decoded the bundled protobuf manifest. Only top-level META-INF signature metadata was excluded from the payload count; base/root/META-INF content was included. This independently confirms signed content rather than accepting jarsigner exit 0 alone. A diagnostic attempt to invoke the cached bundletool library with java -jar failed because that library has no Main-Class; it was not used as verification evidence.

Verified directly from the signed AAB:

- Application ID: `com.ahmedhassan.passthephone`.
- Target SDK: **36**; minimum SDK: **24**.
- Version name: **0.7.0**; version code: **7**, matching pubspec.yaml.
- Public signer certificate SHA-256: `68F696A7F48ED756C42543A0D3AE22D66F4EC758FF863AC92F2FD367F0679575`.
- Artifact: `build/app/outputs/bundle/release/app-release.aab`.
- Artifact SHA-256: `370F152F315EA1973D64D8CA869E897C3FEB7D63DABD4D6E0646F91FA66C3CEA`.

This signed artifact replaces the old unsigned AAB at the same local path; earlier AAB hashes in this report describe historical outputs.

### Warnings and remaining readiness limits

jarsigner was NOT warning-free: the signer is self-signed, its chain is not trusted by the default JDK trust store (PKIX path building failed), and there is no timestamp. It reports certificate expiry on 2054-03-29. It also reports internal archive inconsistencies, with 392 entries considered signed through JarFile but not through JarInputStream. These warnings were retained, not treated as a clean verification or silently ignored. The additional JarFile audit confirms all 391 payload entries have valid signatures/digests and the expected configured upload certificate, but does not resolve the JarInputStream behavior. Validate archive/tool compatibility and the bundle in the release process before publication; do not modify the signed archive to suppress warnings without rebuilding and re-verifying.

The public fingerprint matches the locally configured upload certificate. No Play Console certificate/registration or existing store signing history was available for comparison. This work does not establish Play acceptance, a green hosted CI run, physical-device behavior, compatibility with historical package IDs, device upgrade/process-death behavior, 16 KB native-library readiness, final branding or owner policy approval. Existing blockers and the cross-package data boundary remain as documented. No credentials were committed, no PR was merged and nothing was uploaded or published.

## Official bundletool and 16 KB artifact validation — 2026-11-11 (Africa/Cairo)

Continued on chore/v07-production-hardening, commit 28cc302, preserving the preceding uncommitted signing report. Validated the existing signed AAB; no rebuild, credential access, keystore operation or signing was performed. No app/storage/gameplay changes were made. Generated validation artifacts and helper sources are local under ignored build/release_validation/.

### Official tool and executed validation

Downloaded the standalone **bundletool-all-1.18.3.jar** from [Google's official release](https://github.com/google/bundletool/releases/tag/1.18.3). GitHub release metadata identified this stable version; its SHA-256 asset digest matched the downloaded JAR exactly: `A099CFA1543F55593BC2ED16A70A7C67FE54B1747BB7301F37FDFD6D91028E29`. `java -jar ... version` returned 1.18.3. This also matches the producing bundletool version recorded in the AAB's BundleConfig. Commands used Android Studio JDK 25. A non-fatal sun.misc.Unsafe deprecation warning was emitted by bundled protobuf code.

| Executed operation | Actual result |
| --- | --- |
| `java -jar build/release_validation/bundletool-all-1.18.3.jar validate --bundle=build/app/outputs/bundle/release/app-release.aab` | Exit 0; base feature module validated. Full output saved to build/release_validation/bundletool-validate.log. |
| `java -jar ... dump manifest --bundle=... --module=base` | Exit 0; stdout captured to build/release_validation/manifest.xml. Package com.ahmedhassan.passthephone, versionName 0.7.0, versionCode 7, minSdkVersion 24, targetSdkVersion 36, MainActivity com.ahmedhassan.passthephone.MainActivity. |
| `java -jar ... dump config --bundle=...` | Exit 0; stdout captured to build/release_validation/bundle-config.json. Native library uncompression enabled with PAGE_ALIGNMENT_16K. |
| Official BuildApksCommand API, DEFAULT mode | Exit 0; release-default-unsigned.apks generated with 255 split APKs and toc.pb. |
| Official BuildApksCommand API, UNIVERSAL mode | Exit 0; release-universal-unsigned.apks generated with one universal.apk and toc.pb. |
| `bundletool extract-apks --apks=... --device-spec=... --output-dir=...` | Exit 0 for all five synthetic profiles below. Each selected five APKs: master, matching ABI, Arabic, English and xxhdpi resources. This is artifact selection, not execution on devices. |
| SDK 36 aapt2 dump badging on universal.apk | Exit 0; permanent application ID, version 0.7.0+7, min SDK 24, target/compile SDK 36, intended launch activity and all three supported ABIs confirmed. |
| `apksigner verify .../universal.apk` | Exit 1, Missing META-INF/MANIFEST.MF: generated validation APKs are deliberately unsigned, not installable or distribution candidates. The input AAB remains signed. |
| `jarsigner -verify -verbose -certs .../app-release.aab` | Exit 0, explicit jar verified; jar is unsigned absent. Original certificate/timestamp/stream-reader warnings remain visible in saved jarsigner-verification.log. |

The CLI's build-apks command can automatically read a debug keystore when --ks is absent. To obey the no-credentials instruction, generation instead invoked **the official JAR's public BuildApksCommand API** through a small local Java launcher, with no signing configuration/provider or stamp. The launcher asserts getSigningConfiguration().isPresent() is false before execution. No debug/upload keystore was loaded, and no key was generated. Source: build/release_validation/BuildUnsignedApks.java. Its essential invocation was:

```java
var command = BuildApksCommand.builder()
    .setBundlePath(Path.of(aab))
    .setOutputFile(Path.of(apks))
    .setApkBuildMode(mode) // DEFAULT, then UNIVERSAL
    .setOverwriteOutput(true)
    .build();
if (command.getSigningConfiguration().isPresent()) throw new IllegalStateException();
command.execute();
```

Executed via `java --class-path build/release_validation/bundletool-all-1.18.3.jar build/release_validation/BuildUnsignedApks.java <aab> <apks> <mode>`. All output paths are validation derivatives; the signed input archive was not rewritten.

Synthetic extraction profiles used ar/en locales and density 420:

| SDK / ABI | Result |
| --- | --- |
| API 24 / armeabi-v7a | Five matching splits selected, exit 0. |
| API 28 / arm64-v8a | Five matching splits selected, exit 0. |
| API 35 / arm64-v8a | Five matching splits selected, exit 0. |
| API 36 / arm64-v8a | Five matching splits selected, exit 0. |
| API 36 / x86_64 | Five matching splits selected, exit 0. |

### Native 16 KB static checks

The AAB contains 12 native shared libraries: libapp.so, libflutter.so, libdartjni.so and libdatastore_shared_counter.so for each of arm64-v8a, armeabi-v7a and x86_64. Therefore native compatibility checks apply.

- NDK 28.2.13676358 `llvm-objdump -p <library.so>` executed for **all 12 libraries**. All **39 LOAD segments** have alignment >=2**14 and congruent file-offset/virtual-address values modulo 16384. libapp.so uses 2**16 on 64-bit ABIs and 2**14 on armeabi-v7a; libflutter.so uses 2**16; both JNI/DataStore libraries use 2**14 throughout.
- SDK Build Tools 36 `zipalign -c -P 16 -v 4 <apk>` executed on **all 256 generated APKs**, with zero failures; each reported Verification successful. This was check-only: no APK was realigned or modified.
- A Java ZIP audit examined all generated APKs: **48 native-library occurrences**, covering the same **12 unique libraries**, were uncompressed and byte-for-byte identical to their source AAB libraries. Together with PAGE_ALIGNMENT_16K and the ELF checks, this provides static packaging/alignment evidence for 64-bit ABIs (32-bit libraries were checked too).

These checks follow [Android's ELF and ZIP alignment guidance](https://developer.android.com/guide/practices/page-sizes) and [zipalign documentation](https://developer.android.com/tools/zipalign). They do not establish runtime correctness on a 16 KB kernel; a 16384-byte page-size device/emulator test remains NOT RUN.

### JarInputStream warning investigation

Archive enumeration found 391 payload entries before the signature records. Zero-based positions: META-INF/UPLOAD.SF at 391, META-INF/UPLOAD.RSA at 392 and META-INF/MANIFEST.MF at 393. The first entry is native debug-symbol metadata, not the manifest.

A read-only Java comparison used JarFile with verification enabled and JarInputStream on the same original AAB. It read every entry fully and compared SHA-256 of each entry by name:

- JarInputStream.getManifest() initially returned null.
- Both readers enumerated **394 entries**, with **identical per-entry content digests** and no duplicate names.
- JarFile verified **392 signed entries** (391 payload entries plus the manifest); JarInputStream recognized **zero** signed entries.
- The public signer SHA-256 remained `68F696A7F48ED756C42543A0D3AE22D66F4EC758FF863AC92F2FD367F0679575`; jarsigner reports SHA-256 digests and SHA256withRSA archive signing, 2048-bit RSA. The certificate itself uses SHA384withRSA.

[Oracle's JDK 25 JarInputStream documentation](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/util/jar/JarInputStream.html) requires the manifest first (or immediately after META-INF/) and signature entries immediately after it for stream signature verification. The observed ordering explains why that reader cannot recognize the signatures. The comparison found no differing payload bytes between the two readers. Bundletool validation and APK generation succeeded on the unmodified signed archive. The remaining warning is a streaming-signature-reader compatibility limitation, not evidence from these tests that the payload differs or that the AAB is unsigned. Do not rely on JarInputStream alone for verifying this archive. The self-signed-chain and missing-timestamp warnings remain separate; no Play acceptance claim is made.

Sources/tools used locally for reproduction: build/release_validation/CompareArchiveReaders.java and VerifyGeneratedApks.java; outputs/logs are ignored build artifacts. No ZIP entry was reordered, removed, patched or re-signed.

### Hashes, device state and outstanding checks

AAB SHA-256 was checked before and after validation and is unchanged:
`370F152F315EA1973D64D8CA869E897C3FEB7D63DABD4D6E0646F91FA66C3CEA`.

Generated, unsigned validation APK sets:

- release-default-unsigned.apks: `9038901D4664AF9CBEA8122FE0AA3CCE848A3CD1E2F23A0B970FA2BE93B8DAEF`.
- release-universal-unsigned.apks: `5FC4DBFB92B6D7962D14123198001337A35DE53CA228B30250FAD4AD1641E351`.

Read-only adb devices/getprop/getconf checks detected an SM-A225F, API 33, PAGE_SIZE 4096. No installation, launch, force-stop, data read/write or gameplay QA was performed on it. [REAL_DEVICE_QA.md](REAL_DEVICE_QA.md) now provides unexecuted release-install, same-package update, RTL, large-text, themes, persistence, rotation, background/resume and process-restart cases, plus 16 KB runtime coverage. Each must be recorded with actual evidence before being marked PASS.

No flutter rebuild/analyze/test was needed or run in this artifact-only follow-up; the prior executed results remain historical. No credentials were accessed, no upload key was changed, no PR was merged and nothing was published. Play upload-certificate registration/acceptance, real-device execution, 16 KB runtime behavior, branding and owner policy review remain outstanding.

## Owner-reported Samsung release APK QA — report received 2026-11-11 (Africa/Cairo)

Evidence source: the owner's manual confirmation supplied in chat, not agent-executed device tests. Device: Samsung SM-A225F. The owner identified the tested artifact as a release APK and confirmed the following results:

| Manual check | Owner-reported result |
| --- | --- |
| App launch | PASS |
| Quick Play | PASS |
| Question rotation | PASS |
| Custom questions | PASS |
| Persistence | PASS |
| Handoff ON and OFF | PASS |
| Light and dark themes | PASS |
| Surprise cards | PASS |
| UI quality | PASS |

These confirmations are accepted as owner-reported evidence within those stated scopes. They do not replace or extend the earlier tool-executed analysis/tests, signing verification, bundletool checks or static 16 KB evidence. Earlier adb metadata identified an SM-A225F at API 33 / 4096-byte pages; no new device commands were run for this documentation update.

The actual manual execution date, installed APK hash/version/certificate, detailed steps, font scale, screenshots and logs were not supplied. The tested APK cannot therefore be independently tied to the previously validated AAB. General persistence PASS does not establish same-package upgrade, process-death timing, every saved value or exact unseen-queue order. General rotation PASS does not establish full-cycle or every-category coverage. Light/dark PASS does not establish system-theme switching, and UI quality PASS does not establish all RTL/accessibility or display configurations.

**Still NOT RUN / unverified in this record:** same-package upgrade, TalkBack, maximum font/display scaling, Android 15/16 edge-to-edge, process death and 16 KB runtime. Other unchecked detailed cases in [REAL_DEVICE_QA.md](REAL_DEVICE_QA.md), including explicit background/foreground and system-theme sequences, remain open until supported by specific evidence. No such case was marked PASS based on a broader confirmation. Release readiness remains incomplete.

Only non-secret documentation was edited. No application/gameplay/storage changes, credential access, new tests/builds, merge or app publication were performed for this update. The documentation updates, including the preceding uncommitted signed-AAB/bundletool evidence and QA plan, are the only files intended for commit/push to the existing hardening branch.

## BUG-001 — Samsung SM-A225F haptic feedback — 2026-11-11

Status: **implementation and automated checks complete; physical-device retest pending**. Owner reported that haptic feedback was not perceptible in v0.7 on Samsung SM-A225F. This overrides any assumption that the earlier general UI/gameplay PASS covered vibration. Physical vibration has not been confirmed after this change.

### Inspection and change

Reviewed every application HapticFeedback call and HomeScreen, GameScreen, SettingsScreen and AppStore. Existing category/round/Quick Play and question-transition feedback mostly used selectionClick; normal game start used mediumImpact. The haptics switch already loads/saves the existing `ptp_haptics_enabled_v5` boolean, defaulting to true when absent. No broken preference key was found. GameScreen previously received a bool snapshot; it now receives the store's shared HapticService, which reads the current value on every request.

Added lib/core/services/haptic_service.dart using Flutter built-in APIs only. No dependency, Android permission, upload-signing or application ID change was made. The service gates all app-requested pulses behind the current saved setting and tolerates unsupported-platform/channel errors without interrupting play.

| Deliberate action | Requested feedback |
| --- | --- |
| Changed category or round selection | One lightImpact. Tapping an already-selected value is silent. |
| Quick Play / normal game start | One lightImpact from the initiating button; no additional pulse when the first question builds. |
| Pass-phone action with handoff ON | One mediumImpact when entering handoff. |
| Reveal next question / next question with handoff OFF | One lightImpact when a new question is displayed. |
| Screen build, reload, theme/settings changes, finite-session finish | No app-requested pulse. |
| Any action with haptics OFF | No app-requested pulse. |

There are no vibration loops, heavy impacts or stacked pulses. AppTheme disables tooltip long-press feedback so Flutter's default tooltip vibration cannot bypass the persisted OFF setting. SettingsScreen's existing switch and persistence method remain unchanged. GameSession, question content, queue logic, saved keys and preference backend are unchanged.

This selects different platform feedback types; it does not prove a minimum physical amplitude or diagnose Samsung firmware/system settings. Flutter maps [lightImpact](https://api.flutter.dev/flutter/services/HapticFeedback/lightImpact.html) to Android VIRTUAL_KEY and [mediumImpact](https://api.flutter.dev/flutter/services/HapticFeedback/mediumImpact.html) to KEYBOARD_TAP. Hardware/platform policy controls whether/how those effects are felt. No lower-level vibration dependency was added because a built-in API retest has not yet demonstrated that one is necessary.

### Executed automated evidence

New test/haptic_feedback_test.dart mocks SystemChannels.platform and checks HapticFeedback.vibrate method arguments, not a motor:

- Exact action sequence lightImpact / mediumImpact / lightImpact, once per request.
- All service actions suppressed while OFF; live setting changes respected without replacing an existing game route.
- Both ON and OFF persisted through the original preference key and reload, including interaction with the actual settings switch.
- Home category/round/start and game pass/reveal actions emit the intended sequence while enabled and no pulse while disabled.
- Quick Play emits one initial pulse, with no automatic build/reveal pulse, with handoff both ON and OFF.
- Finite-session endings do not emit a fake reveal pulse in either handoff mode.
- Theme/preference rebuilds and loading are silent; tooltip long press cannot vibrate while OFF.
- Missing/unsupported platform implementations do not fail gameplay callbacks.

| Command | Actual result |
| --- | --- |
| `flutter test test/haptic_feedback_test.dart` | Exit 0, nine new tests passed (initial focused run). |
| `dart format lib test` | Final run: 20 files, zero changes. |
| `dart format --output=none --set-exit-if-changed lib test` | Exit 0, 20 files, zero changes. |
| `flutter analyze` | Exit 0, no issues (1.3 seconds). |
| `flutter test` | Exit 0, all **32 tests passed**, including nine haptic tests and existing storage/gameplay regressions. The final full run includes the additional persisted-ON reload assertion. |
| `git diff --check` | Exit 0. |

**Unit/widget tests cannot confirm actual physical vibration, intensity or perceptibility on Samsung SM-A225F.** They prove requested platform calls and suppression logic only. No device test or release build was run in this task. Existing release artifacts are unchanged and do not contain this source fix; their prior build/signature evidence must not be presented as validation of BUG-001.

Read-only artifact references: AAB SHA-256 `370F152F315EA1973D64D8CA869E897C3FEB7D63DABD4D6E0646F91FA66C3CEA`; existing APK SHA-256 `BA63987C9E98CDF724886CDCDB1447C500DE5C1819D34735ABA0E154921CB479`. No artifact was rewritten. No credentials were accessed, no keys generated, no merge or publication performed.

### Owner-device retest steps — NOT RUN

1. Obtain a separately authorized release candidate built from this fix. Record source revision, APK hash/version, permanent package ID and compatible public signer certificate. The unchanged APK/AAB currently on disk predate this fix. Install the candidate in place on the Samsung SM-A225F without uninstalling or clearing data; retain existing custom questions/settings/rotation progress.
2. Record Android/One UI version and device vibration/touch-feedback settings/intensity. Test with system touch feedback enabled at a comfortable level; do not override the owner's preferences. Note any power-saving/DND setting if relevant. Confirm the phone's system haptics work outside the app as a hardware baseline.
3. In app settings, enable haptics. Change category and round choice: expect one brief light pulse per changed selection. Tap the already-selected category/round: expect none. Start via Quick Play and normal start: expect one brief start pulse and none from subsequent idle frames/rebuilds.
4. With handoff ON, tap pass phone: expect one medium pulse. Tap reveal: expect one light pulse. With handoff OFF in a new game, each next-question tap should give one light pulse. Confirm the final finish/home action does not cause an extra reveal vibration. Record whether each effect is perceptible and comfortable; medium need not feel stronger than light on every device.
5. Turn app haptics OFF. Repeat category/round/start/pass/reveal/next and long-press a tooltip: expect no app-requested vibration. Repeat several taps at an ordinary pace; confirm no duplicate/burst feedback. Verify gameplay still works identically.
6. Leave and reopen the app with haptics OFF; confirm the switch stays OFF and the actions stay silent. Enable it, reopen, and confirm it stays ON and pulses return. Confirm retained custom questions and normal unseen-question rotation are unaffected. This ordinary persistence check does not by itself establish process-death or same-package upgrade coverage.
7. If feedback remains imperceptible with the built-in effects, report exact candidate hash, system settings and which actions fail, without credentials or personal questions. Keep BUG-001 open for device-specific investigation; only then consider whether a lower-level approach/dependency is justified. Record PASS/FAIL separately for perceptibility, OFF suppression and persistence; do not infer a hardware PASS from these automated tests.

## BUG-001 connected Samsung investigation — 2026-11-11 (Africa/Cairo)

Status: **latest centralized Flutter feedback is installed; native comparison prepared; physical perceptibility not confirmed**. Work continues on chore/v07-production-hardening with the preceding source fix preserved. The owner reports that feedback remains imperceptible. No uninstall, data clear, production preference read/edit or signed release replacement was performed.

### Installed release identity and code evidence

Read-only `adb shell pm path` / filtered `dumpsys package` and `adb pull <public base APK path>` collected the installed application binary, not private user storage. Package is `com.ahmedhassan.passthephone`, versionName 0.7.0 / versionCode 7, min SDK 24, target SDK 36. Package flags do not include DEBUGGABLE.

Installed APK SHA-256 is `2FCE4F44D57CCD13048B864E51231E1E4B18EA156CF8A608603BE265753A1B8A`, identical to the current local app-release.apk. It differs from the pre-fix APK recorded in the preceding report, so the owner has supplied a later build. `apksigner verify --verbose --print-certs` succeeded: one signer, APK v2 verified. Public certificate SHA-256 is `68F696A7F48ED756C42543A0D3AE22D66F4EC758FF863AC92F2FD367F0679575`, matching the previously documented upload certificate. This establishes compatibility with that local release signing identity, not Play's possibly separate app-signing certificate.

The installed arm64 libapp.so SHA-256 is `C2738E398A3A411EE8D093928CFAA736E5226DAA62BDFCD1CC650013F2FA3DB0`, identical to the local stripped release library. ELF build ID `489586309727de14643bd72177fec9fa` matches the local release symbol file. llvm-nm lists HapticService._emit, HapticService.passPhone, HapticService.selection and Flutter lightImpact/mediumImpact symbols. Disassembly of _GameScreenState.advance calls HapticService.passPhone for handoff and the light selection implementation for reveal (the optimizer shares the identical light methods). The binary also contains HapticService and both effect strings. Together these checks establish that the installed release contains the centralized feedback fix, rather than inferring it from unchanged versionCode 7 alone. There is no embedded Git revision marker, so no claim of immutable commit provenance is made.

### Non-destructive device inspection

Observed Samsung SM-A225F, Android 13 / API 33, One UI property 50100. Commands read settings and a filtered vibrator-manager capability dump; no system settings were written and no shell vibration command was executed.

| Observed setting/capability | Actual value / limit |
| --- | --- |
| system haptic_feedback_enabled | 1 (enabled) |
| Samsung VIB_FEEDBACK_MAGNITUDE | 1; OEM-specific value, not a calibrated amplitude measurement. |
| SEM_VIBRATION_FORCE_TOUCH_INTENSITY | 4; OEM-specific scale. |
| SEM_VIBRATION_NOTIFICATION_INTENSITY / VIB_RECVCALL_MAGNITUDE | 5 / 5; notification/ringing settings do not prove touch effects work. |
| generic haptic_feedback_intensity, touch_vibration_intensity, vibration_intensity | null (these keys are absent; not evidence that all vibration is disabled). |
| global zen_mode / low_power | 0 / 0. |
| vibrator-manager hardware report | Vibrator ID 0 loaded successfully, capabilities flags 0, no predefined supported effects/braking, only PRIMITIVE_NOOP, no frequency profile; not vibrating at inspection time. |

The capability report suggests no programmable amplitude/composition capability exposed by this device. It does not prove the motor is absent, broken, or unable to execute a timed one-shot. The release app's private persisted haptics toggle was not retrieved; the owner should confirm it is ON through the app UI. Earlier mocked tests establish the source storage/gating logic, not the installed motor's behavior.

### Why compare APIs

Flutter HapticFeedback requests platform semantic UI effects through SystemChannels.platform. On Android, lightImpact maps to VIRTUAL_KEY and mediumImpact to KEYBOARD_TAP via View.performHapticFeedback; those constants do not promise a particular amplitude/duration or perceptible difference on Samsung firmware. They require no application VIBRATE permission and follow platform touch-feedback behavior.

Native Vibrator/VibrationEffect can request a timed one-shot instead of relying on an OEM's semantic-effect mapping. It requires VIBRATE permission. Hardware capability checks matter: without amplitude control, choosing a fractional amplitude does not guarantee a quieter pulse. The diagnostic therefore uses one fixed **50 ms**, DEFAULT_AMPLITUDE touch/sonification request, with no waveform, repetition or escalating intensity. It also respects the system touch-feedback switch. No physical superiority or perceptibility is inferred from an accepted API call.

Official references: [Flutter lightImpact](https://api.flutter.dev/flutter/services/HapticFeedback/lightImpact.html), [Flutter mediumImpact](https://api.flutter.dev/flutter/services/HapticFeedback/mediumImpact.html), [Android haptic feedback](https://developer.android.com/develop/ui/views/haptics/haptic-feedback), [Vibrator capabilities](https://developer.android.com/reference/android/os/Vibrator), [VibrationEffect](https://developer.android.com/reference/android/os/VibrationEffect).

### Isolated opt-in diagnostic implementation

Added a separate Dart entrypoint, lib/diagnostics/haptic_diagnostic_main.dart, which is debug-only and does not load AppStore or preferences. An explicit `-PhapticDiagnostic=true` adds `.hapticdiagnostic` to the **debug** application ID only and selects a separately labelled diagnostic launcher. Production applicationId, namespace, main activity, upload signing settings and persisted keys are unchanged. Native HapticDiagnosticActivity and VIBRATE permission exist only in android/app/src/debug; the main/release manifest has no new permission or diagnostic activity.

The screen defaults OFF. Capability lookup/build/opt-in alone never vibrate. The owner must tap Light, Medium or Native to request a comparison. Dart gates all three through opt-in and an 800 ms cooldown. The debug-only native MethodChannel independently requires enabled=true, system touch feedback enabled, foreground focus and cooldown; it accepts no caller-supplied duration/amplitude/repeat. It caps the single request at 50 ms, checks hasVibrator(), reports errors and cancels its own vibration on pause. No runtime dependency was added.

Production native fallback is **not implemented or enabled**: the requested condition is owner confirmation that native feedback is better. A device-capability report, passing unit test or submitted request is insufficient. If confirmed later, integrate a minimal production bridge with the persisted OFF gate, capped one-shot and no repeated pulses, then test and revalidate the resulting release permission. Until that confirmation, the production service remains built-in Flutter only.

### Executed diagnostic checks and deployment

| Command/check | Actual result |
| --- | --- |
| `flutter test` | Exit 0, all 35 tests passed, including existing storage/gameplay/haptics regressions and three diagnostic tests. |
| `flutter analyze` | Initial one brace lint in new test corrected; final exit 0, no issues (1.9 seconds). |
| `flutter test test/haptic_diagnostic_test.dart` | Final focused run exit 0, three tests passed: default-OFF suppression/capability lookup, exact light/medium/native calls with cooldown and OFF gate, and no vibration from widget build or enabling alone. |
| `flutter build apk --debug --target=lib/diagnostics/haptic_diagnostic_main.dart -PhapticDiagnostic=true -PunsignedSmokeBuild=true` | Exit 0, assembleDebug 155.5 seconds. Native Kotlin diagnostic compiled successfully. Existing upload-signing configuration was not changed; the smoke property bypasses upload signing for this debug build. Gradle's existing properties-loading code is unchanged; no credential contents were printed or manually inspected. |
| aapt2 / apksigner inspection of app-debug.apk | Confirmed isolated package com.ahmedhassan.passthephone.hapticdiagnostic, DEBUGGABLE, version 0.7.0-hapticdiagnostic+7, VIBRATE permission and a valid debug-signed APK. Public debug certificate SHA-256: 39C0E4432425161E87FCF3DCB5F567FFE09CE9EF12942A9836BD40369C414C4A. Different from the release certificate, as expected. |
| `adb install <app-debug.apk>` | Success; installed the separate diagnostic package, not an update to the release package. No uninstall or clear-data command was used. |
| Explicit am start of diagnostic package/HapticDiagnosticActivity | Succeeded; dumpsys window confirmed the diagnostic activity in foreground. Launcher resolution independently resolves to HapticDiagnosticActivity; the ordinary MainActivity is disabled for this opt-in debug variant. |
| Post-install public release APK sha256sum / pm path | Original release path unchanged; SHA-256 still 2FCE4F44D57CCD13048B864E51231E1E4B18EA156CF8A608603BE265753A1B8A. It remains separately installed and signed with the original certificate. |
| Release manifest/source inspection | Main/release manifest and MainActivity unchanged; VIBRATE is absent from the installed release APK. No production native fallback or release rebuild was performed. |
| `git diff --check` | Exit 0. |

Debug APK SHA-256: `832F8F4BD450CC586DCC3655836AC0E160F33DFC3EC7D25E91EBB3ED04036FB4`. Existing signed AAB remains `370F152F315EA1973D64D8CA869E897C3FEB7D63DABD4D6E0646F91FA66C3CEA`.

The attempted read-only UI capability extraction did not produce capability values (/dev/tty returned only its completion message); a subsequent foreground guard detected that the diagnostic was no longer foreground and skipped reading another screen. No hasVibrator()/hasAmplitudeControl() result from the app UI is claimed. The filtered system dumpsys capability observations above remain the actual device evidence. No automated tap or shell command triggered a comparison pulse.

### Required owner comparison and remaining blocker

A comparison question was sent to the owner after the diagnostic installed/launched. **No physical result has yet been received.** In the separate “Pass The Phone · Haptic Diagnostic” app:

1. Enable manual vibration tests (no pulse should occur just from enabling).
2. Tap Flutter light, Flutter medium and Native one 50 ms pulse, leaving at least one second between them. Read any blocked/error result; a submitted/completed message is not proof of physical vibration.
3. Report separately which effects are physically felt and whether native is more perceptible/comfortable. Turn OFF and confirm further test buttons are disabled/silent.
4. Confirm the production game's haptics switch is ON using its UI before comparing production behavior. Do not uninstall it or clear its settings/custom questions/queues. No private preferences were accessed during this investigation.

Until the owner confirms the native effect is better, BUG-001 remains open and adding native VIBRATE behavior to production is intentionally pending that required evidence. If neither effect is felt, examine the diagnostic capability/error display and Samsung settings/hardware before selecting a fallback. No hardware PASS, device-compatibility fix, native superiority, same-package upgrade test or production release approval is claimed. No PR was merged or anything published; changes remain local on the hardening branch.

## BUG-001 production native feedback — 2026-11-11 (Africa/Cairo)

The owner explicitly confirmed that the isolated native 50 ms diagnostic pulse is physically perceptible on Samsung SM-A225F while Flutter built-in feedback remains imperceptible. This is **owner-reported diagnostic evidence**, satisfying the condition for native integration. It is not confirmation of the production release or of the shorter 20/30 ms effects. This section supersedes the earlier pending-comparison status.

### Production implementation

HapticService now uses the minimal Android channel `com.ahmedhassan.passthephone/haptics`, method pulse with enabled=true and durationMs. It reads the existing live AppStore haptics setting before every request; OFF sends no pulse. No preference key/backend changed. Built-in Flutter feedback remains the gated path on non-Android platforms only; Android errors or missing hardware do not trigger a second fallback pulse.

| Action | Initial one-shot duration |
| --- | --- |
| Changed category / round selection | 20 ms |
| Quick Play / normal game start | 30 ms |
| Pass-phone action | 50 ms |
| Question reveal / next question without handoff | 30 ms |

These are initial timing values, not guaranteed physical intensity or confirmed perceptibility. Same-selection taps, builds, settings/theme changes, navigation dialogs and finished-session return actions do not add feedback. The service uses a monotonic clock and a 120 ms cooldown; rapid requests are dropped, never delayed, retried or repeated. A test-only clock seam makes suppression deterministic in tests without changing production timing.

MainActivity implements the native channel. It accepts only the 20/30/50 ms values (maximum 50 ms), enabled=true, foreground focus and enabled system touch feedback; it checks hasVibrator(), uses a second monotonic 120 ms cooldown and performs exactly one VibrationEffect.createOneShot(duration, DEFAULT_AMPLITUDE) on API 26+. API 24/25 retain a short legacy timed fallback for the existing minimum SDK. It uses touch/sonification audio attributes and cancels its own request on activity pause. Missing hardware, permission/vendor runtime errors and unavailable channels do not interrupt gameplay. A true result means only that the request was submitted.

The main manifest adds only the necessary normal Android VIBRATE permission. Application ID/namespace and upload-signing configuration are unchanged. Diagnostic Dart UI/entrypoint, debug Kotlin activity/channel, diagnostic test and debug package-suffix/launcher configuration were removed from the working source. The separate diagnostic installation was not uninstalled or touched; it is not part of the production release. No runtime dependency, question content, queue/session logic, stored preference key or gameplay rule changed. The existing centralized-tooltip feedback suppression remains in place so OFF is not bypassed by tooltips.

### Automated checks

Updated test/haptic_feedback_test.dart mocks both the production native MethodChannel and SystemChannels.platform. It covers all four action durations, enabled/disabled behavior, saved ON/OFF reload, live toggle changes in an existing game route, the 120 ms cooldown boundary and burst dropping, no queued pulse after OFF, missing-hardware false responses, PlatformException/MissingPluginException with no Android Flutter fallback, Quick Play/normal navigation, handoff ON/OFF, silence on build/settings/tooltip/finish, and cancel/confirm exit flow. Existing storage migration and question-bank tests remain included.

The first focused run exposed a test-harness invariant violation from unnecessarily setting a Flutter global platform override; the override was removed. Final executed results:

- `dart format lib test`: exit 0, final 20 files / zero changes.
- `dart format --output=none --set-exit-if-changed lib test`: exit 0, 20 files / zero changes.
- `flutter analyze`: exit 0, no issues (1.3 seconds).
- `flutter test`: exit 0, all **35 tests passed** (23 existing tests plus 12 haptic tests; obsolete diagnostic-only tests removed).
- `git diff --check`: exit 0.

These tests verify requested native calls/gating and navigation logic, not physical vibration or native hardware runtime behavior. The native implementation is also compiled by the release builds recorded below.

### Fresh signed release build and artifact evidence

Built locally using the existing private signing configuration, with no unsigned smoke flag. No credential file or private key was opened for inspection or printed; Gradle consumed the existing configuration internally for the requested signing. Upload signing blocks and application ID/namespace are unchanged. key.properties remains ignored/untracked; a tracked-credential filename check returned zero files. No new key was created. Nothing was installed on the Samsung in this production-fix task.

| Command / inspection | Actual result |
| --- | --- |
| `flutter build apk --release` | Exit 0, assembleRelease 104.4 seconds; 49.0 MB, 51,390,336-byte signed APK. Kotlin native production handler compiled successfully. |
| `flutter build appbundle --release` | Exit 0, bundleRelease 14.5 seconds; 48.1 MB, 50,461,014-byte signed AAB. |
| SDK 36 `apksigner verify --verbose --print-certs .../app-release.apk` | Exit 0, Verifies, one signer, APK Signature Scheme v2 verified. Public certificate matches the existing owner upload certificate. v1/v3/v3.1/v4 were reported false; these are not assertions that those schemes were enabled. |
| SDK 36 aapt2 badging/permission dump | Package com.ahmedhassan.passthephone, version 0.7.0 / code 7, min SDK 24, target/compile SDK 36, MainActivity launcher, not DEBUGGABLE. Permissions: VIBRATE plus the existing app-scoped signature-level DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION; no INTERNET/AD_ID added to release. |
| Compiled APK classes.dex string inspection | Production /haptics channel present; /haptic_diagnostic and HapticDiagnosticActivity absent. No diagnostic UI entrypoint is referenced by the production Dart main. |
| `jarsigner -verify -verbose -certs .../app-release.aab` | Exit 0 and explicit jar verified; jar is unsigned absent. Full non-secret output saved under build/bug001_production_verification/jarsigner.log. |
| Read-only JarFile/JarInputStream comparison on fresh AAB | Exit 0; 394 entries in each reader with identical per-entry SHA-256, 392 signed entries recognized by JarFile (391 payload entries plus manifest); no signed entries recognized by JarInputStream because of the previously documented late-manifest ordering. Signer fingerprint matches the APK. |
| Official bundletool 1.18.3 `dump manifest` / `validate` on fresh AAB | Both exit 0; package/version/SDK values match APK, only MainActivity declared. Captured manifest and validation log under build/bug001_production_verification/. |
| `zipalign -c -P 16 4 .../app-release.apk` | Exit 0, check-only on fresh APK. Full ELF/native runtime and APK-set evidence from earlier sections has not been rerun for this candidate. |

Public signer certificate SHA-256 for both fresh artifacts: `68F696A7F48ED756C42543A0D3AE22D66F4EC758FF863AC92F2FD367F0679575`. This also matches the previously inspected installed release, supporting same-package signer compatibility; an actual device update was not performed here.

New artifacts (local, ignored, not published):

- `build/app/outputs/flutter-apk/app-release.apk`: SHA-256 `7AE92911107F62EDEE000E5CF0E1D2F4647D93C2664E876138897E7CB1575918`.
- `build/app/outputs/bundle/release/app-release.aab`: SHA-256 `38621BE1881816CA35240BA9455DD7E76A1D56B3C4F446C6D90496B4EDF9F4D2`.

These replace previous local release artifacts at those paths. Version labels remain 0.7.0+7, so identify this candidate by the **new APK hash**, not version text alone. Earlier device reports, hashes, APK sets and static native checks must not be attributed to this rebuilt candidate.

jarsigner still reports the self-signed/untrusted certificate chain, missing timestamp (certificate expiry 2054-03-29) and JarFile/JarInputStream ordering warnings. These were not suppressed or repaired by manually altering the signed archive. Fresh cryptographic verification, signer identity, byte-equivalence and bundletool validation succeeded; no Play acceptance or full release readiness is claimed.

### Original production-build retest plan — before the owner confirmation below

1. Verify the new APK hash above and public signer fingerprint, then install this signed release APK **in place** on Samsung SM-A225F using the same package/signing identity (`adb install -r <verified-apk>` or the owner's usual compatible update flow). Do not uninstall or clear data. Record the exact hash, device/One UI version and system touch-feedback setting. The isolated diagnostic app or a previous 0.7.0+7 APK is not this candidate.
2. With app haptics ON and system touch feedback enabled, compare changed category/round choices (20 ms), Quick Play/normal start (30 ms), pass-phone with handoff ON (50 ms), and reveal/next-question with handoff OFF (30 ms). Report each as perceptible/not perceptible and comfortable/excessive. The diagnostic 50 ms PASS does not establish production or 20/30 ms perceptibility; these remain tuning candidates.
3. Confirm one pulse per deliberate action. Already-selected category/round choices, idle frames/builds, theme/settings changes, exit/cancel dialogs and finite-session completion should not add pulses. Rapid requests inside 120 ms may intentionally be dropped; gameplay progression must still work normally and no delayed pulse should appear later.
4. Turn app haptics OFF and repeat all actions. Confirm no optional feedback, including tooltip long press. Leave/reopen with OFF and verify persistence; turn ON, reopen and verify it remains enabled. Check that custom questions, other settings and question rotation are preserved without clearing data.
5. Exercise handoff ON/OFF, finite/unlimited play, navigation and background/foreground. Confirm no crash when system touch feedback is disabled, and no unexpected pulse on return. Restore the owner's preferred system settings afterward. This does not substitute for the separate unverified process-death, accessibility, 16 KB runtime or upgrade QA matrix.
6. Report production results against the exact new APK hash. The subsequent owner confirmation below establishes general production perceptibility and OFF suppression only; it does not close every detailed case in this plan. If shorter effects are not felt, collect action-specific observations before any further duration tuning; do not automatically increase intensity or add repeats.

Changes remain local on chore/v07-production-hardening. No private credentials were committed, PR #1 was not merged and nothing was uploaded or published.

## Owner-confirmed production BUG-001 result and commit checks — 2026-11-11

Evidence source: the owner's explicit confirmation in chat, not an agent-observed motor test. Device: Samsung SM-A225F; artifact described by the owner as the production native-feedback release APK.

| Production manual check | Owner-reported result |
| --- | --- |
| Native vibration perceptibility | **PASS** |
| Haptics OFF suppression | **PASS** |

This confirms the production path at the reported scope and supersedes the earlier physical-confirmation-pending statements. It does not imply that every step in the original production retest plan was executed. No additional device commands or manual motor tests were performed by the agent for this update. The owner did not supply a fresh installed-APK hash, measured duration/amplitude, detailed action-by-action results or instrumented timing evidence with this confirmation; the preceding local artifact hashes remain separate tool evidence.

**Explicitly unverified on hardware:** exact 120 ms cooldown timing, every 20/30/50 ms action-specific tuning value, minimum perceptible duration, exhaustive duplicate/burst timing, process-death persistence/timing and all other unexecuted detailed cases. The mocked cooldown/ON/OFF tests are automated request-logic evidence, not physical timing or process-death evidence. Same-package upgrade, TalkBack, maximum font scaling, Android 15/16 edge-to-edge and 16 KB runtime remain unverified unless separately evidenced. General persistence/rotation confirmations from earlier reports are not upgraded to process-death PASS.

Executed again before committing the native fix and its tests/documentation:

- `flutter analyze`: exit 0, no issues (1.6 seconds).
- `flutter test`: exit 0, all **35 tests passed**.
- `git diff --check`: exit 0.

Reviewed the application/native changes, new HapticService/tests and documentation for secrets. Release notes include only public artifact hashes/certificate fingerprints; no credential values are needed. The release setup document now correctly identifies VIBRATE as the added optional native-feedback permission. Commit preparation excludes local key.properties, keystores, APK/AAB/build logs and all ignored build artifacts. Signing keys/configuration, permanent application ID, preference keys, question content and gameplay rules were not changed in this update. No new release build or installation was performed for this documentation/commit step.

The intended commit/push contains the accumulated production native fix, its centralized gating/navigation changes, tests and non-secret investigation/test documentation. GitHub CI must be read for the pushed commit; local PASS results above do not establish hosted CI success. PR #1 remains unmerged and no app/store publication is authorized or performed.

## Task 04 Branding & Adaptive Icon Sizing — 2026-11-11 (Africa/Cairo)

Branch: `task/04-branding`, based on `chore/v07-production-hardening` (commit `aa30d2d`).

### Changes
1. **Application Identity & Display Name**:
   - `android:label` updated to `"Pass The Phone"` in `android/app/src/main/AndroidManifest.xml`.
   - Permanent package ID `com.ahmedhassan.passthephone` preserved.
2. **Branding Assets & Adaptive Launcher Icons**:
   - Legacy launcher icons generated across all densities (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) from `assets/branding/launcher_icon_1024.png`.
   - Android Adaptive icons (`mipmap-anydpi-v26/ic_launcher.xml`) generated using `adaptive_foreground_1024.png` and `adaptive_background_1024.png`.
   - **Adaptive Icon Visual Sizing**: Configured `adaptive_icon_foreground_inset: 7` in `flutter_launcher_icons.yaml` and `android:inset="7%"` in `ic_launcher.xml` (reduced from the default 16%). This scales up the graphic by ~26% to fill Samsung's squircle mask naturally without excess border padding, while ensuring that hands, phone, motion lines, and sleeves remain fully inside the circular mask safe zone without clipping.
   - Note on source asset: As documented in handoff, `adaptive_foreground_1024.png` contains an embedded flattened purple squircle rather than separated layers.
3. **Android 12+ SplashScreen API**:
   - Added `values/colors.xml` (`splash_background` = `#FF2C087B`, sampled from approved background).
   - Added `values-v31/styles.xml` and `values-night-v31/styles.xml` using `android:windowSplashScreenBackground` and `android:windowSplashScreenAnimatedIcon` (`@mipmap/ic_launcher`).
   - Updated `drawable/launch_background.xml` and `drawable-v21/launch_background.xml` to use `@color/splash_background`.
   - No synthetic or artificial splash delays introduced.
4. **Preservation of Game Integrity**:
   - Zero changes to gameplay, question bank (220 questions preserved), stored preference keys, haptics service, signing configuration, or application ID.

### Verification Results
| Verification Step | Result |
| --- | --- |
| `flutter analyze` | Exit 0, 0 issues |
| `flutter test` | Exit 0, all 35 tests passed |
| `flutter build apk --release` | Exit 0, 49.3 MB |
| `flutter build appbundle --release` | Exit 0, 48.4 MB |
| `apksigner verify --print-certs` | Exit 0, signed by Ahmed Hassan Mohamed Masoud (`68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575`) |
| `adb install -r` on Samsung SM-A225F | Exit 0, Success (installed in place, user data preserved) |

Rebuilt Artifact Hashes:
- APK (`build/app/outputs/flutter-apk/app-release.apk`): SHA-256 `611C23A6D08549471133E8154977BD23ECBC8C5B6B5C95F2D950DD32083AD80E`
- AAB (`build/app/outputs/bundle/release/app-release.aab`): SHA-256 `0317D8A07181230F3E8390F8628DEFABDD88C4EB8819C50DB9B0931A37646A72`

## Task 04 Branding & Adaptive Icon Sizing — 2026-11-11 (Africa/Cairo)

Branch: `task/04-branding`, based on `chore/v07-production-hardening` (commit `aa30d2d`).

### Changes
1. **Application Identity & Display Name**:
   - `android:label` updated to `"Pass The Phone"` in `android/app/src/main/AndroidManifest.xml`.
   - Permanent package ID `com.ahmedhassan.passthephone` preserved.
2. **Branding Assets & Adaptive Launcher Icons**:
   - Legacy launcher icons generated across all densities (`mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, `xxxhdpi`) from `assets/branding/launcher_icon_1024.png`.
   - Android Adaptive icons (`mipmap-anydpi-v26/ic_launcher.xml`) generated using `adaptive_foreground_1024.png` and `adaptive_background_1024.png`.
   - **Adaptive Icon Visual Sizing**: Configured `adaptive_icon_foreground_inset: 7` in `flutter_launcher_icons.yaml` and `android:inset="7%"` in `ic_launcher.xml` (reduced from the default 16%). This scales up the graphic by ~26% to fill Samsung's squircle mask naturally without excess border padding, while ensuring that hands, phone, motion lines, and sleeves remain fully inside the circular mask safe zone without clipping.
   - Note on source asset: As documented in handoff, `adaptive_foreground_1024.png` contains an embedded flattened purple squircle rather than separated layers.
3. **Android 12+ SplashScreen API**:
   - Added `values/colors.xml` (`splash_background` = `#FF2C087B`, sampled from approved background).
   - Added `values-v31/styles.xml` and `values-night-v31/styles.xml` using `android:windowSplashScreenBackground` and `android:windowSplashScreenAnimatedIcon` (`@mipmap/ic_launcher`).
   - Updated `drawable/launch_background.xml` and `drawable-v21/launch_background.xml` to use `@color/splash_background`.
   - No synthetic or artificial splash delays introduced.
4. **Preservation of Game Integrity**:
   - Zero changes to gameplay, question bank (220 questions preserved), stored preference keys, haptics service, signing configuration, or application ID.

### Verification Results
| Verification Step | Result |
| --- | --- |
| `flutter analyze` | Exit 0, 0 issues |
| `flutter test` | Exit 0, all 35 tests passed |
| `flutter build apk --release` | Exit 0, 49.3 MB |
| `flutter build appbundle --release` | Exit 0, 48.4 MB |
| `apksigner verify --print-certs` | Exit 0, signed by Ahmed Hassan Mohamed Masoud (`68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575`) |
| `adb install -r` on Samsung SM-A225F | Exit 0, Success (installed in place, user data preserved) |

Rebuilt Artifact Hashes:
- APK (`build/app/outputs/flutter-apk/app-release.apk`): SHA-256 `611C23A6D08549471133E8154977BD23ECBC8C5B6B5C95F2D950DD32083AD80E`
- AAB (`build/app/outputs/bundle/release/app-release.aab`): SHA-256 `0317D8A07181230F3E8390F8628DEFABDD88C4EB8819C50DB9B0931A37646A72`

## Owner-supplied transparent branding integration — 2026-11-12

Current feature branch: `task/04-branding`. Existing uncommitted report content was preserved. No commit, push, merge, store upload or device installation was performed for this update.

The owner explicitly supplied replacement images and requested saving them in assets before integration. Copied the three local download files byte-for-byte first, preserving their alpha and their actual 1254x1254 dimensions:

| Active asset | SHA-256 |
| --- | --- |
| `assets/branding/adaptive_foreground.png` | `0F0233EA823B7ED34C3D2B85477253603A6007135940C6B351F3A01A58D911DD` |
| `assets/branding/adaptive_background.png` | `FBA794DFD2AB8DFEE00F90381FED4CD78D07C96CBE11ED5B2271692A7B46ED57` |
| `assets/branding/splash_logo.png` | `7A02E6601DCFEBF630D96CF08A7C19AA519CC407FB118EEEBE1C6890F03631B1` |

The historical `_1024.png` adaptive/splash sources are retained but no longer used by generation. The existing legacy launcher source and Play Store candidate are unchanged. The owner clarified that the full-background store image is for Play Store only; it is not used as the new foreground or splash.

### Implemented behavior

- Adaptive resources now use the owner's transparent foreground and purple background. A 20% inset per side replaces the old 7% setting, which was tuned for a different, flattened source. This source-specific padding retains the complete cuffs within the central adaptive safe area instead of leaving a second purple square inside the icon.
- Added a dedicated native splash drawable using the owner's `splash_logo.png`, copied exactly into `drawable-nodpi`. The source/resource SHA-256 values match.
- Android 12+ day/night launch themes now reference `@drawable/splash_icon` instead of the launcher icon. Earlier Android launch backgrounds center the same padded emblem in a 288dp square over the existing purple color. No Flutter splash widget, route, dependency, forced delay or game-start behavior was introduced.
- `tool/sync_android_branding.ps1` reproduces the splash copy and launcher generation. Android consumes these images as native resources; a redundant Flutter asset-bundle entry is unnecessary.
- `docs/branding/preview.html` shows circle/rounded launcher approximations and light/dark splash placement. Rendered with headless Chrome and visually inspected `build/branding-preview.png`; this is browser evidence, not Samsung or Android system rendering evidence.

### Executed verification

| Check | Actual result |
| --- | --- |
| Branding sync / `dart run flutter_launcher_icons` | Exit 0; regenerated all Android launcher densities and adaptive XML with 20% inset |
| `flutter analyze` | Exit 0; no issues, 30.1 seconds |
| `flutter test` | Exit 0; all 35 tests passed, including existing upgrade/persistence and haptics tests |
| `flutter build apk --debug --no-pub` | Exit 0; `build/app/outputs/flutter-apk/app-debug.apk`, Gradle 46.2 seconds |
| `git diff --check` | Exit 0; Windows line-ending notices only |
| Source/resource integrity | Owner download hashes match the three saved assets; splash resource matches its source |
| Read-only PNG geometry audit | Python/Pillow inspection, alpha >=16: padded maximum radius 0.291108 for foreground and 0.290580 for splash, normalized to canvas width |

The measured artwork radii after 20% padding are smaller than the adaptive central safe radius 33/108 (~0.305556) and the Android 12 splash radius 96/288 (~0.333333), respectively. This checks static geometry above the stated alpha threshold, not launcher motion or every device mask. Earlier optional C# inspection attempts failed because of local System.Drawing assembly references; the successful read-only measurements above used Pillow instead. No image pixels were edited by these checks. Sizing references: [Android adaptive icons](https://developer.android.com/develop/ui/compose/system/icon_design_adaptive), [Android splash screens](https://developer.android.com/develop/ui/views/launch/splash-screen).

### Remaining visual checks and release limits

The supplied transparent sources retain visible pale residue near motion strokes and some colored edge fringe at full resolution. They were integrated as requested without silently redrawing the approved illustration. The small browser preview was reviewed, but clean production artwork and device appearance still require owner review. A clean export from layered artwork can replace the PNGs later through the same generation script.

Owner retest: after a separately verified same-signer release build/install in place (never uninstall or clear data), inspect Samsung One UI icon size/margins, circle-mask fit if available, cold launch in light/dark mode, and absence of a nested purple tile or clipped cuffs. Confirm saved settings/custom questions remain present. Android 12+ launch appearance, pre-12 launch appearance, launcher cache behavior and actual Samsung visual quality are not marked PASS by this update. Do not clear launcher storage to refresh the icon.

This update built a debug APK only; no fresh signed release APK/AAB or signing verification is claimed. Existing release files do not contain these new changes merely because the debug build passed. Application ID, upload signing configuration, credentials, question bank, gameplay, haptics and persisted preference keys were not modified. No private credential file was read or printed, and no key was created. The build uses the existing Gradle configuration internally. Git diff inspection found no changes to `lib`, `test`, `assets/data`, the app Gradle script or AndroidManifest.xml.

Additional packaged-APK evidence: `aapt dump badging` succeeded and reported package `com.ahmedhassan.passthephone`, versionName `0.7.0`, versionCode `7`, minSdk `24`, targetSdk `36` and compileSdk `36`. `aapt2 dump resources` succeeded and showed `drawable/splash_icon`, `drawable/splash_logo`, the adaptive launcher, and both Android 12 theme references to the dedicated splash icon. Debug APK SHA-256: `197B640856BAF747F933CC05894445B66A1DFFF2B5ACFB3C276011AC292A978C`.

## Current assets-only branding refresh — 2026-11-12

The owner requested using the current `assets/branding` files. Inspection found four supplied PNGs and owner removals of the previous flattened launcher/store sources and README.txt. Those removals were preserved. The foreground, splash and dark background hashes are unchanged from the preceding integration; the newly added vivid `adaptive_background2.png` is SHA-256 `C545A370D8F73006AA8A41EDD68649FB2B36F9BCC02D37757D684FFA477C9D47`. No source image was redrawn or edited.

Changes superseding the earlier asset mapping:

- Adaptive launcher now uses `adaptive_background2.png` with `adaptive_foreground.png`. Retained the measured 20% foreground inset, rather than reducing padding on the same artwork and risking cuff clipping.
- Fixed the generator's missing `launcher_icon_1024.png` reference. Its raster fallback now uses the existing foreground. Added `mipmap-anydpi/ic_launcher.xml` to compose the generated background and foreground natively for Android 24/25; this default density-independent drawable supplies the complete legacy icon. Its inset is 7% because legacy icons do not have the adaptive layer viewport. Android 26+ retains the separate adaptive drawable and 20% inset. The PNG fallbacks were regenerated too.
- Native splash continues to use the owner's dedicated transparent emblem in both themes and all supported Android versions. Background color is now `#2D037F`, sampled from the supplied dark background. The vivid gradient is used for the launcher; the native Android 12+ splash uses a uniform color. No extra Flutter splash screen or artificial delay was introduced.
- Branding sync validates all four source files before regenerating resources. Added `assets/branding/README.md` documenting current inputs. Repository search outside historical test reports found no remaining references to removed source filenames.
- Updated the HTML preview for the vivid gradient, legacy layout and current splash color. Rendered via headless Chrome and visually inspected `build/branding-preview.png`; this remains a static browser approximation, not a device screenshot.

Executed after this refresh:

| Check | Actual result |
| --- | --- |
| `powershell -NoProfile -ExecutionPolicy Bypass -File tool/sync_android_branding.ps1` | Exit 0; resources regenerated successfully |
| `flutter analyze` | Exit 0; no issues, 1.7 seconds |
| `flutter test` | Exit 0; all 35 tests passed |
| `flutter build apk --debug --no-pub` | Exit 0; Gradle 10.1 seconds |
| `git diff --check` | Exit 0; line-ending notices only |
| `aapt dump badging` | Exit 0; package `com.ahmedhassan.passthephone`, version `0.7.0+7`, min SDK 24, target/compile SDK 36 |
| `aapt2 dump resources` | Exit 0; packaged launcher and dedicated splash resources/theme references found |

Current debug APK: `build/app/outputs/flutter-apk/app-debug.apk`, SHA-256 `BE019F71D803761035F6504D4D3C3D3058E8A365547A85187F4F364D51342C6D`. The preceding debug APK hash describes an older build and is superseded by this one.

No signed release build, device installation, Samsung visual PASS or process-death test was performed in this refresh. Source edge residue remains present and was not claimed to be corrected by configuration changes. Review circle/Samsung masks and cold launch on actual devices before approving visual quality; Android 24/25 native rendering remains unverified on hardware. Use only a separately verified same-signer release for a later in-place device upgrade, without uninstalling or clearing data. Existing release artifacts have not been refreshed by the debug build.

No changes to gameplay, preferences, question data, haptics, app ID, manifest or upload signing configuration. No new dependencies or credentials, no key access/creation, no commit/push/merge/publication. Work remains local on the existing `task/04-branding` feature branch; main was not modified. Prior report content was preserved.

## Home hero background only — 2026-11-13 (Africa/Cairo)

Request: add `assets/branding/purple_pass_the_phone_hero.png` behind the existing HomeScreen hero without a redesign. Inspected the original HomeScreen first: content-sized Container, radius 32, horizontal padding 25, vertical padding 31, existing theme primaryContainer background at 70% alpha, unchanged Column/Row/text/phone badge. Existing unrelated working-tree branding changes and owner deletions were preserved.

Implementation adds only a DecorationImage to that same BoxDecoration and one explicit asset declaration in pubspec.yaml. Uses BoxFit.cover and the existing border radius's image clipping. Background decoration painting creates no widget, pointer target or semantic node; the content tree, natural sizing, hit testing, layout and text styles remain unchanged. No Stack, extra height, route or splash widget was introduced. All original text, including YOUR TURN, Arabic title/subtitle, and phone badge is untouched. Only the requested hero image is registered; `purple_pass_the_phone_hero_2.png` is not used.

Overlay tuning: evaluated the requested 35% theme-purple tint with read-only sampled pixel compositing. Its minimum sampled contrast against the existing opaque text color was approximately 1.25:1 in light mode and 1.62:1 in dark mode. Selected an 85% primaryContainer tint via ColorFilter/BlendMode.srcOver, yielding approximately 5.23:1 and 4.91:1 for those sampled opaque text colors. These are conservative image-sample calculations, not full rendered accessibility certification (YOUR TURN retains its original 74%-alpha foreground). The stronger tint keeps the photograph faint and readable without changing foreground colors or either theme.

Executed verification so far:

- `dart format lib/features/home/home_screen.dart`: exit 0, no formatting changes needed.
- `flutter analyze`: exit 0, no issues, 1.6 seconds.
- `flutter test`: exit 0, all 35 existing tests passed.
- Temporary before/after widget probe: eight identical snapshots across light/dark, widths 360/600, text scales 1.0/1.8 with RTL. Compared card and text rectangles, icon rectangle, original text styles, padding and base background color. Initial baseline probe surfaced an existing narrow-view RenderFlex overflow; after recording baseline exceptions, both before/after geometry comparison runs passed with the same two baseline error cases. This is not a claim that those pre-existing layout cases are overflow-free. No unrelated layout change was made. Probe and JSON evidence are local ignored build files (`build/hero_visual_probe_test.dart`, `build/hero-layout-before.json`, `build/hero-layout-after.json`), not permanent test-suite additions.
- Exact source comparison against the pre-edit copy: removing the 12 added decoration lines reproduces the entire original HomeScreen source. Pubspec has only the one new asset entry; dependency lock file unchanged.
- `git diff --check`: exit 0.

Image SHA-256: `A506112A58254F57E1EB3B6DA651BF3DAB433959F4CBDEDD867FD178C2A11240`. Source pixels unchanged. This task did not edit launcher/splash resources, gameplay, haptics, saved preference keys, questions, application ID, signing setup or keys. The requested release build uses the existing private signing configuration internally; no credential contents were inspected or printed. No merge or publication is authorized/performed. Owner visual review remains pending.

Completed release evidence for this hero update:

| Check | Actual result |
| --- | --- |
| `flutter build apk --release` | Exit 0; Gradle 87.4 seconds, reported 51.8 MB |
| `apksigner verify --verbose --print-certs` via installed apksigner.jar | Exit 0, Verifies, APK v2=true, one signer |
| Signer continuity | Certificate SHA-256 `68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575`; matches pre-build release APK |
| `aapt dump badging` | Exit 0; `com.ahmedhassan.passthephone`, version `0.7.0+7`, min SDK 24, target/compile SDK 36 |
| APK asset integrity | Bundled `assets/flutter_assets/assets/branding/purple_pass_the_phone_hero.png` equals source bytes and SHA-256 |

Fresh signed APK: `build/app/outputs/flutter-apk/app-release.apk`. SHA-256: `E3E05C0A618A3E146D6F8D2CA9768676DCEE83EDD7B95D966694E81E079B2E1E`.

The APK is built from the current working tree, including earlier pending owner-approved branding integration; no launcher or splash source/configuration was edited by the hero task itself. No new AAB was built. APK not installed on a device in this task. Owner retest: install the verified release as an in-place update with no uninstall/data clearing; inspect the Home hero in light/dark mode, confirm identical title/subtitle/YOUR TURN and phone badge placement, image cover crop and rounded edges, unchanged scrolling/taps and legibility. Actual device visual approval remains pending. No new maximum-font-scaling, TalkBack or process-death PASS is claimed. No commit, push, merge or publication performed.

## v0.8.0+8 consolidated release candidate — 2026-11-13 (Africa/Cairo)

Full changed-file/before-after/evidence record: [V080_RC.md](V080_RC.md). Dedicated branch release/v080-preparation from approved branding b62211e; production hardening is already an ancestor. Owner's CODEX_TASKS.md deletion and output/untracked files preserved. Owner explicitly confirmed no prior Play uploads and code 8 unused; no Play Console query was available.

Implemented Settings privacy intent/version metadata, exact later-cycle queue snapshots, ordered preference writes with failure/data-preservation handling, SDK Arabic localization, category/round semantics, and two reproduced large-text overflow fixes. No approved branding/hero, questions/categories, controls, haptics, package/signing/backup configuration or preference keys changed. No credential contents accessed directly or new keys created. Gradle signed internally using the existing approved private configuration.

Executed: formatting (25 files, zero further changes), flutter analyze exit 0/no issues (9.2s), flutter test exit 0/all 54 tests, signed APK build exit 0 (155.3s), signed AAB build exit 0 (15.9s). The second-cycle test was run before the fix and failed expected 22 vs actual 0, then passed after correction. Additional focused semantics/tap test run passed all 7 cases. Upgrade fixtures cover v0.5/v0.6/v0.7 shapes; native binary replacement remains untested. Error tests use synthetic preferences, never real owner data.

APK SHA-256: B601237EDDA7A421B10C67B784A2EF01D3E01D1053080D2359F6186068FE1386 at build/app/outputs/flutter-apk/app-release.apk.
AAB SHA-256: A20479CFDCAD116B73B4F615E35103855DD3794C310CDCCA1E57A649FEA33249 at build/app/outputs/bundle/release/app-release.aab.

Both artifacts report com.ahmedhassan.passthephone, versionName 0.8.0, code 8, min SDK 24, target/compile SDK 36. APK v2 verifies and matches pre-build signer; AAB jarsigner explicitly reports jar verified and signed payloads were independently checked. Public certificate SHA-256 for both: 68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575. Permission review found only VIBRATE plus AndroidX's app-scoped signature permission; no Internet/AD_ID. Dependency diff adds only SDK localization and its intl dependency.

Official bundletool 1.18.3 validates/dumps the new AAB and generates default/universal UNSIGNED validation sets (255/1 APKs). All 12 unique native entries are byte-identical to source AAB and 16 KB ZIP-aligned in generated APKs (36/12 occurrences). ELF LOAD alignment in each owner artifact is 16/64 KB with congruent offsets. Official ZIP alignment checks on signed APK and generated universal APK pass. AAB config is PAGE_ALIGNMENT_16K. This is static evidence, not runtime PASS.

AAB self-signed/no-timestamp/JarInputStream warnings remain: JarFile verifies 407 signed entries among 409; stream sees 409 identical payloads but recognizes zero signatures because of manifest placement. No manual archive edits. Signature identity, bundletool validation and generation pass; Play acceptance not tested. Logs/unsigned sets remain ignored under build/release_validation/v080/.

No connected device was present. Available emulator image is API 37.2, not a verified API 35/36 or 16 KB runtime environment. Native browser intent/version display, physical TalkBack/display scaling, Android 15/16 system bars/navigation/landscape, same-package upgrade, process-death timing and backup/restore remain pending owner/device checks. Historical Samsung gameplay/haptics confirmation remains owner-reported baseline evidence. Follow the v0.8 safe procedure in REAL_DEVICE_QA.md; never uninstall/clear data or rotate keys to bypass an upgrade mismatch. Owner policy/listing/Play signing/account-specific testing and hosted CI remain pending. No commit, push, PR, merge, upload or publication performed.

Final post-review recheck: dart format --output=none --set-exit-if-changed lib test exited 0 (25 files, 0 changes); flutter analyze exited 0/no issues (3.6s); flutter test exited 0/all 54 tests passed. APK/AAB hashes rechecked unchanged. Git diff --check passed; no staged files or tracked signing credentials. Owner deletion/output directory preserved. Application/native resources/branding/manifest/signing configuration remain unchanged outside the documented fixes.

## Final pre-commit regression coverage and owner QA — 2026-11-14

Branch: release/v080-preparation; version remains 0.8.0+8. Added three automated regressions, without modifying production source:

- Second deck persistence write: inject failure specifically at ptp_known_decks_v4 after ptp_remaining_decks_v4 commits. Assert error state and exact write order, clone the resulting disk snapshot immediately without a retry on the original store, then reload and consume the exact saved unseen prefix without repeating seen questions. Existing known-ID metadata remains intact. This covers an established known map, not atomic durability for every possible interrupted initialization.
- Failed settings toggle: seed durable haptics ON, fail the OFF write, assert immediate live OFF and save-error state, then reload without retry and verify the durable ON value remains. The operation does not falsely become durable merely because its handled future/flush completes.
- Privacy fallback: simulate unavailable browser, tap نسخ الرابط, and assert one Clipboard.setData call containing exactly https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/ . Platform handler is cleaned up after the test.

Executed by the agent: dart format on both changed test files; focused flutter test run (12 passed, exit 0); flutter analyze (no issues, exit 0, 33.3 seconds); full flutter test --reporter expanded (57 passed, exit 0; previously 54). These tests revealed no defect requiring a production correction. No new signed release artifact generated; the previously verified APK/AAB remain applicable because production source is unchanged by this update.

Owner-confirmed manual evidence, supplied explicitly in this session and not independently repeated by the agent:

- Samsung SM-A225F release upgrade and all seven functional QA checks: PASS.
- Android 15 / API 35, all eight manual checks: PASS for the owner's stated matrix; detailed per-check settings were not supplied here.
- Physical TalkBack accessibility and large-text checks: PASS; unspecified maximum display/font settings are not inferred.
- Force-stop and app relaunch commands: successful execution confirmed. This is not by itself evidence that all saved state survived abrupt termination.

Pending: Android 16 / API 36 and actual PAGE_SIZE=16384 runtime; interrupted-write/process-death state assertions, reboot/backup/restore, unspecified maximum display/font configurations, and physical unavailable-browser fallback. Existing Play signing/listing/Data Safety/account-specific testing gates remain. Multi-key writes remain non-atomic; failed setting saves retain their previous durable values. No additional device tests or Play acceptance claimed.

Only the two test files and release documentation were edited during this update. No production source, dependencies, preference keys, stored data, branding, gameplay, package ID or signing configuration changed. Credentials were not accessed. Owner output/ and qa/ directories and intentional CODEX_TASKS.md deletion preserved. Nothing staged, committed, pushed or merged.

## Sequential Android 16/16 KB and Android 15 emulator execution — 2026-11-14

Full current matrix, commands, artifact identity, failures and evidence index: [EMULATOR_E2E_REPORT.md](EMULATOR_E2E_REPORT.md). These are agent-executed emulator results, separate from prior owner-reported Samsung/API 35/TalkBack confirmations.

1. Verified running emulator-5554 as API 36, sdk_gphone16k_x86_64, boot=1, PAGE_SIZE=16384; no existing app installation. Added SDK integration_test dev support and five real-channel/real-storage E2E cases. Executed flutter test integration_test/release_e2e_test.dart -d emulator-5554 --reporter expanded: exit 0, 5/5 passed (75 seconds test phase; initial debug build 248.1 seconds).
2. Separately verified and installed the existing signed production APK. APK SHA-256 remains B601237EDDA7A421B10C67B784A2EF01D3E01D1053080D2359F6186068FE1386; apksigner exit 0, v2=true, approved signer unchanged. Release identity 0.8.0/code 8, target 36, non-debuggable. API 36 signed-release smoke exit 0/PASS: Home/Quick Play, handoff/reveal/exit, installed version, external Chrome launch, force-stop/relaunch and persisted Haptics OFF. The signed native x86_64 runtime actually ran on 16 KB pages.
3. Shut down API 36 and recorded no emulator attached before starting a new isolated API 35 AVD from the installed system image. Original owner AVD data and physical Samsung were not used. Verified API 35, sdk_gphone64_x86_64, boot=1, PAGE_SIZE=4096. Same E2E command: exit 0, 5/5 passed (107 seconds test phase; debug build 53.1 seconds).
4. API 35 first release-smoke attempt exited 1 at Quick Play transition: empty Flutter UI dump, screenshot remained Home. Diagnostic tap then opened gameplay normally. Preserved all failed evidence. Corrected only the automation harness: bounded populated/expected UI waits, 120 ms gestures and an initial force-stop to establish Home. Full API 35 release-smoke rerun exited 0/PASS with the same APK/signature and all assertions above. No production defect/fix was established.

Additional executed validation: flutter pub get exit 0 (six test-tool dependencies added, existing versions retained); integration test dart format and final no-change check exit 0; flutter analyze exit 0/no issues (6.8 seconds); full flutter test test --reporter expanded exit 0/57 passed; Python smoke-runner syntax compile passed; git diff --check passed. Five E2E cases were executed on each emulator in addition to the 57 host tests.

Raw evidence is local and ignored under build/release_validation/v080_emulator/: api36-e2e.log and api35-e2e.log plus exit files; api36-release-smoke/result.json (PASS); api35-release-smoke/result.json (first FAIL); api35-release-smoke-retry/result.json (PASS); APK signature/install/package records, numbered UI XML/screenshots, browser activity/logcat captures, boot/environment/shutdown logs and host validation logs. No failed attempt was deleted or relabeled. Final 2,000-line logcat windows had no fatal exception/native abort; this is bounded observation, not a universal crash guarantee.

This supersedes Android 16/16 KB pending status only for the exercised x86_64 E2E and signed-release smoke. Pending: full Android 16 navigation/orientation/keyboard/theme/system-bar/max-display matrix, ARM64 16 KB runtime, interruption during pending saves, full retained content/deck state after OS death, reboot/backup/restore, physical browser-unavailable fallback and Play/owner release gates. Real AppStore reload is not OS process death; release force-stop verified Haptics OFF only. Browser activity opening is not proof of remote policy loading. No physical vibration perceptibility result was inferred from emulators.

No production app source, gameplay, branding, question bank, preference keys, package ID, signing configuration or owner data was changed in this task. No new signed APK/AAB was generated; the existing artifact was preserved and reverified. Only E2E dev support, automation and release documentation were added/updated. No credentials accessed. Owner output/, qa/, untracked files and CODEX_TASKS.md deletion preserved; nothing staged, committed, pushed, merged or published.

## Final original-bank first-release review — 2026-11-14

Owner postponed content expansion. [FINAL_RELEASE_READINESS.md](FINAL_RELEASE_READINESS.md) is the current release verdict/27-path commit allowlist; the previous 800-question audit is a deferred proposal, not release content. Only original assets/data/questions.json is loaded: 155 friends, 25 love, 25 family, 15 surprise, total 220. Source JSON is byte-identical to b62211e with SHA-256 CDD2B34BED02D7E67F0DAC902DD15CCEFBE61ECBF736D3E617DE6175C732EA71. Schema, IDs, nonempty fields and global Arabic-normalized exact uniqueness assertions pass. No question text, ID, category, ordering or data key changed, and questions_900_expanded.json was not imported/used/bundled.

Executed again: flutter analyze exit 0/no issues (5.2s); flutter test test --reporter expanded exit 0/all 57 unit/widgets passed. Existing emulator and owner manual evidence remain separately attributed and were not rerun in this task. Read-only content/source/archive checks pass; no new production code, tests or signed build introduced.

Existing AAB SHA-256 remains A20479CFDCAD116B73B4F615E35103855DD3794C310CDCCA1E57A649FEA33249. Official bundletool 1.18.3 validation/manifest dump pass; identity com.ahmedhassan.passthephone, 0.8.0/code 8, min24/target36/compile36, non-debuggable. jarsigner explicitly reports jar verified, exit 0; independent JarFile audit verifies 407/409 entries with approved signer 68f696a7f48ed756c42543a0d3ae22d66f4ec758ff863ac92f2fd367f0679575. Documented streaming/self-signed/timestamp warnings persist; both archive readers return identical 409 payload hashes. No manual archive edits or Play acceptance claim.

APK/AAB question JSON and hero bytes match source. All 15 imported production Dart sources are embedded unchanged in the release kernel; its cached digest matches. All allocated ELF sections for libapp.so match compiled release outputs on three ABIs, and stripped release intermediates match AAB bytes. All 12 native payloads and DEX match the already smoke-tested APK; MainActivity release/debug executable disassembly matches. Raw cache/class byte comparisons alone were not used as proof because non-runtime metadata/debug sections differ. Local build-record provenance supports the approved production payload; this is not a new reproducible build of later test-only dependencies.

Privacy URL direct HTTPS GET returns HTTP 200 HTML and policy content is consistent with reviewed local storage/vibration/backup behavior; the web reader itself could not access it. Raw final evidence remains ignored under build/release_validation/v080_final_220/. Final source and content unchanged; previous evidence, output/, qa/ and CODEX_TASKS.md deletion preserved. Signing credentials not accessed. No files staged, committed, pushed, merged or published. No known application/bundle blocker; owner/Play Console setup, review/testing requirements and residual QA gates remain as documented in FINAL_RELEASE_READINESS.md.

## Approved local release commit — 2026-11-14

The owner explicitly approved one local commit of the original-bank v0.8.0+8 candidate on release/v080-preparation. The owner also confirmed Android 16/API 36/16 KB manual QA PASS (5/5): gesture and three-button navigation; landscape/portrait transitions; light/dark themes and system bars; custom questions, keyboard and large-text layouts; force-stop, relaunch and persisted state. These are OWNER-CONFIRMED results, separate from the existing agent-executed emulator E2E and signed-release smoke evidence. They supersede the earlier pending status for these five manual cases. No new device execution occurred in this final commit review.

ARM64 16 KB hardware, interruption during pending writes, reboot/backup/restore, exact maximum font/display configurations and physical browser-unavailable fallback remain unverified. The confirmation does not establish atomic multi-key writes or interrupted-write safety.

Executed pre-commit validation again: flutter analyze exit 0/no issues (3.7 seconds); flutter test test --reporter expanded exit 0/57 passed. Read-only content assertions confirm 155 Crew, 25 Crush, 25 Family and 15 Surprise Cards, total 220, byte-identical to the approved bank with SHA-256 CDD2B34BED02D7E67F0DAC902DD15CCEFBE61ECBF736D3E617DE6175C732EA71. The existing AAB hash remains A20479CFDCAD116B73B4F615E35103855DD3794C310CDCCA1E57A649FEA33249; a fresh official bundletool manifest dump succeeded. Current production Dart sources match the saved release kernel; question/hero assets match the AAB and all 12 native payloads plus DEX match the tested signed APK. No production mismatch was found and no signed artifact was rebuilt or altered.

Approved branding b62211e and production-hardening aa30d2d are ancestors of HEAD; local main is also an ancestor, with no unresolved index entries. Remote branch changes were not queried. Documentation corrections are confined to the seven already-allowlisted release documents. The approved staging scope remains the 26 listed files plus the intentional CODEX_TASKS.md deletion. Final diff, staged-scope and secret checks precede the local commit; its SHA is reported from Git rather than embedded in this self-referential document. New raw validation logs remain ignored under build/release_validation/v080_local_commit/. No push, merge, tag, upload or publication is authorized.
