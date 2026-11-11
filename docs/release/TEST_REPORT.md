# v0.7 hardening test report

Executed 2026-11-11 (Africa/Cairo) on branch `chore/v07-production-hardening`, starting from e0db3d6 with the supplied uncommitted v0.7 overlay. Main was not modified. Existing overlay changes were preserved.

## Readiness

**Not ready for store release.** Signed AAB verification, official bundletool validation/APK generation and static 16 KB ELF/ZIP alignment checks have passed; see the follow-ups below. The JarInputStream discrepancy is explained and byte-equivalence checked without altering the archive. The owner has now reported manual PASS results on a Samsung SM-A225F release APK, recorded separately from tool-executed evidence in the latest follow-up and [REAL_DEVICE_QA.md](REAL_DEVICE_QA.md). Same-package upgrade, TalkBack, maximum font scaling, Android 15/16 edge-to-edge, process death and 16 KB runtime remain unverified, alongside final icon, Play validation and owner policy/listing review. Earlier unsigned artifact evidence is historical. CI is configured but no green hosted run is claimed here.

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
