import 'dart:ui' show SemanticsAction;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/app/app.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'package:pass_the_phone/core/services/haptic_service.dart';
import 'package:pass_the_phone/core/services/game_session.dart';
import 'package:pass_the_phone/core/models/game_category.dart';
import 'package:pass_the_phone/core/models/party_question.dart';
import 'package:pass_the_phone/core/theme/app_theme.dart';
import 'package:pass_the_phone/features/home/home_screen.dart';
import 'package:pass_the_phone/features/game/game_screen.dart';
import 'package:pass_the_phone/features/questions/custom_questions_screen.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

Widget harness(
  Widget child,
  Brightness brightness,
  Size size,
  double scale, {
  double keyboard = 0,
}) => MaterialApp(
  key: ValueKey(child.runtimeType),
  theme: AppTheme.build(brightness),
  locale: const Locale('ar'),
  supportedLocales: const [Locale('ar')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: MediaQuery(
    data: MediaQueryData(
      size: size,
      textScaler: TextScaler.linear(scale),
      padding: const EdgeInsets.only(top: 24, bottom: 24),
      viewInsets: EdgeInsets.only(bottom: keyboard),
    ),
    child: Directionality(textDirection: TextDirection.rtl, child: child),
  ),
);

void main() {
  testWidgets('selected category is exposed as an actionable selected button', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final store = AppStore(
      preferences: MemoryPreferences({'ptp_haptics_enabled_v5': false}),
    );
    await tester.runAsync(store.load);
    await tester.pumpWidget(PassThePhoneApp(store: store));
    final crew = find.byKey(const ValueKey('category-friends'));
    final love = find.byKey(const ValueKey('category-love'));
    await tester.scrollUntilVisible(crew, 200);
    expect(
      tester
          .getSemantics(crew)
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      true,
    );
    expect(
      tester
          .getSemantics(love)
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      false,
    );
    expect(
      tester.getSemantics(love).getSemanticsData().flagsCollection.isButton,
      true,
    );
    expect(
      tester
          .getSemantics(love)
          .getSemanticsData()
          .hasAction(SemanticsAction.tap),
      true,
    );
    await tester.tap(love);
    await tester.pumpAndSettle();
    expect(
      tester
          .getSemantics(love)
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      true,
    );
    expect(
      tester
          .getSemantics(crew)
          .getSemanticsData()
          .flagsCollection
          .isSelected
          .toBoolOrNull(),
      false,
    );
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
    semantics.dispose();
  });

  testWidgets('round semantics announces the round only once', (tester) async {
    final semantics = tester.ensureSemantics();
    final game = GameSession([
      PartyQuestion(id: 'one', category: 'family', text: 'سؤال للقعدة'),
    ]);
    await tester.pumpWidget(
      harness(
        GameScreen(
          session: game,
          category: gameCategories.last,
          haptics: HapticService(isEnabled: () => false),
        ),
        Brightness.light,
        const Size(800, 600),
        1,
      ),
    );
    expect(find.bySemanticsLabel('الجولة 1'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.bySemanticsLabel('الجولة 1'))
          .getSemanticsData()
          .label,
      'الجولة 1',
    );
    semantics.dispose();
  });
  testWidgets('app resolves Arabic framework strings and RTL', (tester) async {
    final store = AppStore(preferences: MemoryPreferences({}));
    await tester.runAsync(store.load);
    await tester.pumpWidget(PassThePhoneApp(store: store));
    final context = tester.element(find.byType(HomeScreen));
    expect(Localizations.localeOf(context).languageCode, 'ar');
    expect(Directionality.of(context), TextDirection.rtl);
    expect(MaterialLocalizations.of(context).backButtonTooltip, isNot('Back'));
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });

  for (final brightness in Brightness.values) {
    for (final size in [const Size(360, 800), const Size(800, 360)]) {
      testWidgets('$brightness $size layouts at 200% text scale', (
        tester,
      ) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final store = AppStore(preferences: MemoryPreferences({}));
        await tester.runAsync(store.load);
        await tester.pumpWidget(
          harness(HomeScreen(store: store), brightness, size, 2),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'Home');
        await tester.scrollUntilVisible(find.text('يلا نلعب'), 300);
        expect(tester.takeException(), isNull, reason: 'Home scroll');
        await tester.pumpWidget(
          harness(
            CustomQuestionsScreen(store: store),
            brightness,
            size,
            2,
            keyboard: size.height > 400 ? 240 : 100,
          ),
        );
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.byType(TextField),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.enterText(
          find.byType(TextField),
          'سؤال طويل للقعدة ' * 10,
        );
        await tester.scrollUntilVisible(
          find.byType(DropdownButtonFormField<String>),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Family Time').last);
        await tester.pumpAndSettle();
        expect(
          tester.takeException(),
          isNull,
          reason: 'Long selected category',
        );
        await tester.scrollUntilVisible(
          find.text('ضيف السؤال'),
          200,
          scrollable: find.byType(Scrollable).first,
        );
        expect(
          tester.takeException(),
          isNull,
          reason: 'Custom questions with keyboard',
        );
        final game = GameSession([
          PartyQuestion(
            id: 'long',
            category: 'family',
            text: 'سؤال طويل للقعدة ' * 10,
          ),
        ]);
        await tester.pumpWidget(
          harness(
            GameScreen(
              session: game,
              category: gameCategories.last,
              haptics: HapticService(isEnabled: () => false),
            ),
            brightness,
            size,
            2,
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('سلّمت الموبايل'));
        expect(
          tester.getRect(find.text('سلّمت الموبايل')).bottom,
          lessThanOrEqualTo(size.height - 24),
        );
        expect(tester.takeException(), isNull, reason: 'Long game question');
        await tester.pumpWidget(const SizedBox.shrink());
        await store.flushPendingWrites();
        store.dispose();
      });
    }
  }
}
