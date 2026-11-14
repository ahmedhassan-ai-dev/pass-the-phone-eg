<div align="center">

# Pass The Phone

**One phone. Good company. Conversations in Egyptian Arabic.**

<img src="assets/branding/purple_pass_the_phone_hero.png" alt="Pass The Phone artwork: two hands passing a phone against a purple background" width="800">

**v0.8.0+8 · Flutter & Dart · Android-first · Offline gameplay**

[Get started](#local-development) · [Quality assurance](#testing-and-quality-assurance) · [Privacy Policy](https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/)

</div>

Pass The Phone is an offline Egyptian Arabic party game for friends, couples, crush conversations and family gatherings. Pick a category, answer a question and pass the phone to keep the conversation going. No account required.

## Key features

- **220 built-in prompts** written in conversational Egyptian Arabic.
- **Quick Play** and category selection, with a round limit or open-ended play.
- **Optional handoff mode** between questions and optional Surprise Cards.
- **Your own questions**, saved locally alongside preferences and question-rotation progress.
- **Light and dark themes**, Arabic localization and right-to-left layouts.
- **Optional native Android haptic feedback**, controlled from Settings.
- **Offline play** with no ads, analytics, accounts or backend services.

## Game categories

| Category | Made for | Built-in questions |
| --- | --- | ---: |
| **The Crew** | Funny stories, friendships and lively group conversations | 155 |
| **Crush Club** | Playful romantic conversations, first impressions and preferences | 25 |
| **Family Time** | Shared memories and warm, lighthearted family gatherings | 25 |
| **Surprise Cards** *(optional)* | Unexpected prompts mixed into The Crew games only | 15 |
| **Total** | | **220** |

Enable Surprise Cards in Settings for extra variety within The Crew games; they do not appear in Crush Club or Family Time. The original approved question bank ships with this release; a larger content expansion is deferred to a future update.

## How the game works

1. Choose Quick Play or a category and set the number of rounds.
2. Read the question aloud and share your answer.
3. Pass the phone to the next player. With handoff mode enabled, reveal the next question when they are ready.
4. Keep playing until the round limit, or continue with open-ended play.

Questions rotate through shuffled decks, and unseen-question progress is saved locally between sessions. Add custom questions to make the game your group's own.

## Technology stack

- **Flutter / Dart** for the interface and game logic.
- **Flutter SDK localization** for Arabic, with RTL layouts.
- **SharedPreferencesAsync** for local questions, settings and deck progress.
- **Kotlin / Android platform channels** for native haptics, installed-version metadata and opening the Privacy Policy in a browser.

Android configuration: **min SDK 24**, **target SDK 36**, package ID `com.ahmedhassan.passthephone`. Dependencies are locked in [pubspec.lock](pubspec.lock).

## Local development

Use the verified Flutter **3.47.7** / Dart **3.13.5** toolchain, Android SDK and a configured Android device or emulator. The SDK constraint is recorded in [pubspec.yaml](pubspec.yaml).

```sh
git clone https://github.com/ahmedhassan-ai-dev/pass-the-phone-eg.git
cd pass-the-phone-eg
flutter doctor -v
flutter pub get
flutter run
```

### Build checks

Compilation-only release checks explicitly disable signing:

```sh
flutter build apk --release -PunsignedSmokeBuild=true
flutter build appbundle --release -PunsignedSmokeBuild=true
```

For the complete Windows preflight:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tool/release_preflight.ps1
```

These commands produce unsigned compilation checks, not upload-ready releases. Normal signed builds use `flutter build apk --release` and `flutter build appbundle --release` with the owner's existing private signing configuration. See [Android release setup](docs/release/ANDROID_RELEASE.md); never commit signing credentials or keystores. Builds replace local outputs, so preserve any approved artifacts separately before running them.

## Testing and quality assurance

```sh
flutter analyze
flutter test test --reporter expanded
```

The documented **v0.8.0+8** validation includes:

| Check | Recorded result |
| --- | --- |
| Static analysis | No issues |
| Unit and widget tests | **57 passed**, including persistence, deck cycles, haptics, accessibility layouts and privacy fallback |
| Emulator E2E | **5/5 passed on each** of Android 15/API 35 and Android 16/API 36 |
| Signed-release APK smoke | Passed on both emulator environments |
| Android 16 page size | Signed release executed on an **x86_64 emulator with 16 KB pages**; Android 15 used 4 KB pages |
| Owner-confirmed manual QA | Samsung upgrade/gameplay; Android 15 checks; TalkBack/large text; Android 16 navigation, orientation, themes, keyboard and persisted state |

These are recorded release results, not a live CI badge. ARM64 16 KB hardware, backup/restore and interrupted-write runtime verification remain pending.

Run E2E only on a disposable emulator without owner data:

```sh
flutter test integration_test/release_e2e_test.dart -d emulator-5554 --reporter expanded
```

Flutter's integration runner manages its debug installation. Run emulators sequentially and keep release smoke testing separate. See the [emulator report](docs/release/EMULATOR_E2E_REPORT.md), [manual QA checklist](docs/release/REAL_DEVICE_QA.md) and [test evidence](docs/release/TEST_REPORT.md) for coverage, limitations and retained failed attempts.

## Privacy Policy

Gameplay works offline. Custom questions, preferences and rotation progress are stored locally; device backup behavior depends on Android settings. The app has no account system, ads or analytics. Opening the Privacy Policy launches an external browser and requires connectivity there.

Read the public [Privacy Policy](https://ahmedhassan-ai-dev.github.io/pass-the-phone-eg/privacy/).

## Current release status

**v0.8.0+8 is the prepared first-release candidate. Google Play publication is pending developer-account verification.** There is no Play Store download link yet. Store setup, declarations and review requirements still apply; local validation does not establish Play approval.

See [final release readiness](docs/release/FINAL_RELEASE_READINESS.md) and the [release checklist](docs/release/RELEASE_CHECKLIST.md) for the approved scope and remaining gates.

## Future improvements

- Expand the question bank after editorial review, with distinct prompts for each category.
- Extend hardware coverage, including ARM64 16 KB devices.
- Broaden backup/restore and interrupted-write verification.

These are future goals, not features included in v0.8.0+8.
