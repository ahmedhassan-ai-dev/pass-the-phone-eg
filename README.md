# Pass The Phone | ادّي الموبايل
An offline Egyptian Arabic party game built in Flutter.

## Setup (Windows / VS Code)
```powershell
flutter create --org com.passthephone pass_the_phone
cd pass_the_phone
```
Copy `lib/main.dart`, `assets/data/questions.json`, `pubspec.yaml`, and `test/game_deck_test.dart` from this starter package into the new Flutter project (replace existing files). Delete the generated `test/widget_test.dart`, since it tests the default counter app. Then:
```powershell
flutter pub get
flutter run
flutter test
```

## Gameplay
1. Start a game mode.
2. Player reads a prompt and hands the phone to someone matching it.
3. The receiving player taps `سلّمت الموبايل` or the previous player taps it before handing off.
4. New player taps `اكشف السؤال الجديد`, reads their prompt and passes again.
5. Questions are shuffled once and never repeated within one round.

## Structure
- `lib/main.dart`: MVP home screen, game screen, repository, question deck.
- `assets/data/questions.json`: Egyptian Arabic prompts organized by mode.

## Planned
- Add more curated prompts, custom questions, adjustable round length, animated transitions, testing, local session persistence.

## GitHub
Create an empty public GitHub repository called `pass-the-phone-eg` with **no README** (already included by this starter project). From the Flutter project directory:
```powershell
git add .
git commit -m "feat: initial offline Flutter party game MVP"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/pass-the-phone-eg.git
git push -u origin main
```
If git says this is not a repository, run `git init` before the add command.
