import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_the_phone/app/app.dart';
import 'package:pass_the_phone/core/services/app_info.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'package:pass_the_phone/features/game/game_screen.dart';
import 'package:pass_the_phone/features/home/home_screen.dart';

// Run only on a designated emulator with no owner installation. Real platform
// channels and preferences are used; no preference clearing or mocks are used.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<AppStore> launch(WidgetTester tester) async {
    final store = AppStore();
    await store.load();
    await tester.pumpWidget(PassThePhoneApp(store: store));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
    return store;
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  }

  Future<void> finish(WidgetTester tester, AppStore store) async {
    await store.flushPendingWrites();
    expect(store.hasSaveError, isFalse);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  }

  testWidgets('native metadata, RTL, settings and themes persist on reload', (
    tester,
  ) async {
    final store = await launch(tester);
    expect(
      Directionality.of(tester.element(find.byType(HomeScreen))),
      TextDirection.rtl,
    );
    expect(await AppInfo.versionLabel(), '0.8.0 (8)');
    await tapVisible(tester, find.byTooltip('الإعدادات'));
    for (final label in [
      'شاشة تسليم الموبايل',
      'اهتزازات خفيفة',
      'كروت مفاجأة',
    ]) {
      final tile = find.widgetWithText(SwitchListTile, label);
      await tester.scrollUntilVisible(tile, 180);
      final before = tester.widget<SwitchListTile>(tile).value;
      await tapVisible(tester, tile);
      expect(tester.widget<SwitchListTile>(tile).value, !before);
    }
    await tester.scrollUntilVisible(find.text('داكن'), 180);
    await tapVisible(tester, find.text('داكن'));
    expect(
      Theme.of(tester.element(find.text('داكن'))).brightness,
      Brightness.dark,
    );
    await tapVisible(tester, find.text('فاتح'));
    expect(
      Theme.of(tester.element(find.text('فاتح'))).brightness,
      Brightness.light,
    );
    await tester.scrollUntilVisible(find.text('سياسة الخصوصية'), 150);
    expect(find.text('Pass The Phone · 0.8.0 (8)'), findsOneWidget);
    await store.flushPendingWrites();
    final restored = AppStore();
    await restored.load();
    expect(restored.handoffEnabled, store.handoffEnabled);
    expect(restored.hapticsEnabled, store.hapticsEnabled);
    expect(restored.surpriseEnabled, store.surpriseEnabled);
    expect(restored.themeMode, ThemeMode.light);
    restored.dispose();
    await finish(tester, store);
  });

  testWidgets(
    'custom question UI saves through the Android preferences backend',
    (tester) async {
      final store = await launch(tester);
      final text =
          'سؤال اختبار المحاكي ${DateTime.now().millisecondsSinceEpoch}';
      await tapVisible(tester, find.byTooltip('أسئلتي'));
      await tester.enterText(find.byType(TextField), text);
      await tapVisible(tester, find.text('ضيف السؤال'));
      // The platform save is asynchronous; wait until the success UI appears.
      for (
        var i = 0;
        i < 50 && !store.customQuestions.any((q) => q.text == text);
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect(store.customQuestions.where((q) => q.text == text), hasLength(1));
      await store.flushPendingWrites();
      final restored = AppStore();
      await restored.load();
      expect(
        restored.customQuestions.where((q) => q.text == text),
        hasLength(1),
      );
      restored.dispose();
      await finish(tester, store);
    },
  );

  testWidgets('Quick Play handoff, reveal, cancel and confirmed exit', (
    tester,
  ) async {
    final store = await launch(tester);
    await store.setHandoffEnabled(true);
    await store.setHapticsEnabled(true);
    await tapVisible(tester, find.text('ابدأ بسرعة  ·  The Crew'));
    final game = tester.widget<GameScreen>(find.byType(GameScreen)).session;
    expect(game.isUnlimited, isTrue);
    final first = game.current.id;
    await tapVisible(tester, find.text('سلّمت الموبايل'));
    expect(find.text('الموبايل وصل؟'), findsOneWidget);
    await tapVisible(tester, find.text('اكشف السؤال'));
    expect(game.current.id, isNot(first));
    await tapVisible(tester, find.byTooltip('إنهاء اللعبة'));
    await tapVisible(tester, find.text('نكمل'));
    expect(find.byType(GameScreen), findsOneWidget);
    await tapVisible(tester, find.byTooltip('إنهاء اللعبة'));
    await tapVisible(tester, find.text('خروج'));
    expect(find.byType(GameScreen), findsNothing);
    await finish(tester, store);
  });

  testWidgets(
    'second deck cycle retains exact unseen order on real storage reload',
    (tester) async {
      final store = await launch(tester);
      await store.setHandoffEnabled(false);
      await store.setHapticsEnabled(false);
      final family = find.byKey(const ValueKey('category-family'));
      await tester.scrollUntilVisible(family, 220);
      await tapVisible(tester, family);
      final play = find.text('يلا نلعب');
      await tester.scrollUntilVisible(play, 220);
      await tapVisible(tester, play);
      final game = tester.widget<GameScreen>(find.byType(GameScreen)).session;
      final count = store.countFor('family');
      final initial = <String>{game.current.id};
      for (var i = 1; i < count; i++) {
        await tapVisible(tester, find.text('السؤال التالي'));
        expect(initial.add(game.current.id), isTrue);
      }
      final secondSeen = <String>{};
      for (var i = 0; i < 3; i++) {
        await tapVisible(tester, find.text('السؤال التالي'));
        expect(secondSeen.add(game.current.id), isTrue);
      }
      await store.flushPendingWrites();
      final raw = await SharedPreferencesAsync().getString(
        'ptp_remaining_decks_v4',
      );
      final remaining = List<String>.from(
        (jsonDecode(raw!) as Map)['family'] as List,
      );
      expect(remaining.length, count - 3);
      expect(remaining.toSet().intersection(secondSeen), isEmpty);
      await finish(tester, store);
      final restored = await launch(tester);
      await tester.scrollUntilVisible(family, 220);
      await tapVisible(tester, family);
      await tester.scrollUntilVisible(play, 220);
      await tapVisible(tester, play);
      final resumed = tester
          .widget<GameScreen>(find.byType(GameScreen))
          .session;
      expect(resumed.current.id, remaining.first);
      for (var i = 1; i < remaining.length; i++) {
        await tapVisible(tester, find.text('السؤال التالي'));
        expect(resumed.current.id, remaining[i]);
      }
      await finish(tester, restored);
    },
  );

  testWidgets('finite ten-round game completes and returns home', (
    tester,
  ) async {
    final store = await launch(tester);
    await store.setHandoffEnabled(false);
    await tester.scrollUntilVisible(find.text('10'), 220);
    await tapVisible(tester, find.text('10'));
    await tester.scrollUntilVisible(find.text('يلا نلعب'), 220);
    await tapVisible(tester, find.text('يلا نلعب'));
    for (var i = 0; i < 10; i++) {
      await tapVisible(tester, find.text('السؤال التالي'));
    }
    expect(find.text('خلصت الجولة'), findsOneWidget);
    await tapVisible(tester, find.text('الرئيسية'));
    expect(find.byType(GameScreen), findsNothing);
    await finish(tester, store);
  });
}
