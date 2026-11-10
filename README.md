# Pass The Phone — Flutter v0.2

Offline Egyptian Arabic party game with clean feature-first structure.

## Included
- 125 curated Arabic questions across friends/love/savage/family
- Custom questions (category specific or custom-only) saved locally
- Unlimited or 10/20/30/50 rounds, with fresh shuffle cycles
- Theme: system/light/dark, persisted locally
- Animated question reveal / handoff
- Pure Dart game session model + unit tests

## Install into existing Flutter repository

Copy `lib/`, `assets/`, `test/` and the dependency/assets entries from `pubspec.yaml` into your existing project. **Keep your existing `.git`, `android`, `web`, `ios`, and native project files.** The Dart package name in this archive is `pass_the_phone`; if your own pubspec `name:` differs, update test imports accordingly.

```sh
flutter pub get
flutter analyze
flutter test
flutter run
```

## Structure

`lib/core`: model, local storage, session state logic, themes.
`lib/features`: independent screen features.
`lib/app`: application bootstrap.

## Release checklist
- Set stable applicationId unique to you; configure signing and Play App Bundle
- Confirm Android targetSdk 36+, test release build on physical phones
- Privacy policy / Data Safety / content rating / store assets / testing requirements
- Keep advertising SDK and permissions out until monetization is introduced

## Storage
Questions and theme are stored with shared_preferences. This is convenient for local settings but **not a backup system**. A future version should add import/export for user-created questions.

## Caveat
Flutter SDK was not installed in the artifact environment. Run `flutter analyze` and `flutter test` locally before accepting this as release-ready.
