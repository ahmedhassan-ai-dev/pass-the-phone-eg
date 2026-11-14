import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/app/app.dart';
import 'package:pass_the_phone/features/game/game_screen.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

void main() {
  testWidgets('finite game without handoff returns home after ten rounds', (
    tester,
  ) async {
    final store = AppStore(
      preferences: MemoryPreferences({
        'ptp_handoff_enabled_v5': false,
        'ptp_haptics_enabled_v5': false,
      }),
    );
    await tester.runAsync(store.load);
    await tester.pumpWidget(PassThePhoneApp(store: store));
    await tester.scrollUntilVisible(find.text('10'), 300);
    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('يلا نلعب'));
    await tester.tap(find.text('يلا نلعب'));
    await tester.pumpAndSettle();
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.text('السؤال التالي'));
      await tester.pumpAndSettle();
    }
    expect(find.text('خلصت الجولة'), findsOneWidget);
    await tester.tap(find.text('الرئيسية'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });

  testWidgets('Quick Play, handoff and confirmed back navigation', (
    tester,
  ) async {
    final store = AppStore(preferences: MemoryPreferences({}));
    await tester.runAsync(store.load);
    await tester.pumpWidget(PassThePhoneApp(store: store));
    await tester.tap(find.text('ابدأ بسرعة  ·  The Crew'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    expect(
      tester.widget<GameScreen>(find.byType(GameScreen)).session.isUnlimited,
      isTrue,
    );
    await tester.tap(find.text('سلّمت الموبايل'));
    await tester.pumpAndSettle();
    expect(find.text('الموبايل وصل؟'), findsOneWidget);
    await tester.tap(find.text('اكشف السؤال'));
    await tester.pumpAndSettle();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('نخرج من اللعبة؟'), findsOneWidget);
    await tester.tap(find.text('نكمل'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    await tester.tap(find.byTooltip('إنهاء اللعبة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خروج'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });
}
