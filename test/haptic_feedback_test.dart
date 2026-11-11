import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/app/app.dart';
import 'package:pass_the_phone/core/models/game_category.dart';
import 'package:pass_the_phone/core/models/party_question.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'package:pass_the_phone/core/services/game_session.dart';
import 'package:pass_the_phone/core/services/haptic_service.dart';
import 'package:pass_the_phone/features/game/game_screen.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <MethodCall>[];
  const selection = {'enabled': true, 'durationMs': 20};
  const transition = {'enabled': true, 'durationMs': 30};
  const pass = {'enabled': true, 'durationMs': 50};
  List<Object?> pulses() => calls.map((call) => call.arguments).toList();

  setUp(() {
    calls.clear();
    for (final channel in [HapticService.channel, SystemChannels.platform]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'HapticFeedback.vibrate' ||
                call.method == 'pulse') {
              calls.add(call);
            }
            return call.method == 'pulse' ? true : null;
          });
    }
  });
  tearDown(() {
    for (final channel in [HapticService.channel, SystemChannels.platform]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });

  test(
    'service sends one correct pulse per action and reads the live toggle',
    () async {
      var enabled = false;
      var elapsed = Duration.zero;
      final haptics = HapticService(
        isEnabled: () => enabled,
        elapsed: () => elapsed,
      );
      await haptics.selection();
      await haptics.passPhone();
      await haptics.revealQuestion();
      expect(calls, isEmpty);
      enabled = true;
      await haptics.selection();
      elapsed += HapticService.cooldown;
      await haptics.gameStart();
      elapsed += HapticService.cooldown;
      await haptics.passPhone();
      elapsed += HapticService.cooldown;
      await haptics.revealQuestion();
      expect(pulses(), [selection, transition, pass, transition]);
      expect(calls.every((call) => call.method == 'pulse'), isTrue);
      enabled = false;
      await haptics.passPhone();
      expect(pulses(), [selection, transition, pass, transition]);
    },
  );

  test('unsupported optional feedback does not interrupt the action', () async {
    for (final error in [
      PlatformException(code: 'unsupported'),
      MissingPluginException(),
    ]) {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            HapticService.channel,
            (_) async => throw error,
          );
      await expectLater(
        HapticService(isEnabled: () => true).passPhone(),
        completes,
      );
    }
    expect(
      calls,
      isEmpty,
      reason: 'No Android Flutter fallback or duplicate retries',
    );
  });

  test(
    'cooldown drops rapid pulses and never queues a request after OFF',
    () async {
      var elapsed = Duration.zero;
      var enabled = true;
      final haptics = HapticService(
        isEnabled: () => enabled,
        elapsed: () => elapsed,
      );
      await haptics.selection();
      await haptics.gameStart();
      await haptics.passPhone();
      elapsed += const Duration(milliseconds: 119);
      await haptics.revealQuestion();
      expect(pulses(), [selection]);
      enabled = false;
      elapsed += const Duration(seconds: 1);
      await haptics.passPhone();
      expect(pulses(), [selection]);
      enabled = true;
      await haptics.passPhone();
      expect(pulses(), [selection, pass]);
    },
  );

  test(
    'missing hardware result is silent without a second feedback path',
    () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(HapticService.channel, (call) async {
            calls.add(call);
            return false;
          });
      await expectLater(
        HapticService(isEnabled: () => true).passPhone(),
        completes,
      );
      expect(calls.single.method, 'pulse');
      expect(calls.single.arguments, pass);
    },
  );

  testWidgets('back navigation and cancel/confirm dialogs add no pulses', (
    tester,
  ) async {
    final store = AppStore(preferences: MemoryPreferences({}));
    await tester.runAsync(store.load);
    await tester.pumpWidget(PassThePhoneApp(store: store));
    await tester.tap(find.text('ابدأ بسرعة  ·  The Crew'));
    await tester.pumpAndSettle();
    expect(pulses(), [transition]);
    calls.clear();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    await tester.tap(find.text('نكمل'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsOneWidget);
    await tester.tap(find.byTooltip('إنهاء اللعبة'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('خروج'));
    await tester.pumpAndSettle();
    expect(find.byType(GameScreen), findsNothing);
    expect(calls, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    store.dispose();
  });

  for (final enabled in [true, false]) {
    testWidgets('home and game actions respect persisted haptics=$enabled', (
      tester,
    ) async {
      final store = AppStore(
        preferences: MemoryPreferences({'ptp_haptics_enabled_v5': enabled}),
        hapticElapsed: () =>
            tester.binding.clock.now().difference(DateTime(2000)),
      );
      await tester.runAsync(store.load);
      await tester.pumpWidget(PassThePhoneApp(store: store));
      await tester.pumpAndSettle();
      expect(calls, isEmpty, reason: 'Loading/building must never vibrate');
      await tester.scrollUntilVisible(find.text('Crush Club'), 200);
      await tester.tap(find.text('Crush Club'));
      await tester.pumpAndSettle();
      expect(pulses(), enabled ? [selection] : isEmpty);
      await tester.tap(find.text('Crush Club'));
      await tester.pumpAndSettle();
      expect(
        pulses(),
        enabled ? [selection] : isEmpty,
        reason: 'Unchanged selection is silent',
      );
      await tester.scrollUntilVisible(find.text('10'), 200);
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('يلا نلعب'));
      await tester.pump(const Duration(milliseconds: 150));
      await tester.tap(find.text('يلا نلعب'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('سلّمت الموبايل'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('اكشف السؤال'));
      await tester.pumpAndSettle();
      expect(
        pulses(),
        enabled
            ? [selection, selection, transition, pass, transition]
            : isEmpty,
      );
      calls.clear();
      // The existing route must observe a changed setting, not a captured bool.
      await store.setHapticsEnabled(!enabled);
      await store.setTheme(ThemeMode.dark);
      await tester.pumpAndSettle();
      expect(calls, isEmpty, reason: 'Preference/theme rebuild is silent');
      await tester.tap(find.text('سلّمت الموبايل'));
      await tester.pumpAndSettle();
      expect(pulses(), enabled ? isEmpty : [pass]);
      await tester.pumpWidget(const SizedBox.shrink());
      store.dispose();
    });
  }

  testWidgets(
    'settings toggle persists OFF/ON and tooltip feedback cannot bypass OFF',
    (tester) async {
      final prefs = MemoryPreferences({'ptp_haptics_enabled_v5': false});
      final store = AppStore(
        preferences: prefs,
        hapticElapsed: () =>
            tester.binding.clock.now().difference(DateTime(2000)),
      );
      await tester.runAsync(store.load);
      await tester.pumpWidget(PassThePhoneApp(store: store));
      await tester.longPress(find.byTooltip('الإعدادات'));
      await tester.pumpAndSettle();
      expect(calls, isEmpty);
      await tester.tap(find.byTooltip('الإعدادات'));
      await tester.pumpAndSettle();
      final toggle = find.widgetWithText(SwitchListTile, 'اهتزازات خفيفة');
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(prefs.values['ptp_haptics_enabled_v5'], isTrue);
      expect(
        calls,
        isEmpty,
        reason: 'Changing settings does not add a vibration',
      );
      final enabledRestart = AppStore(preferences: prefs);
      await tester.runAsync(enabledRestart.load);
      expect(enabledRestart.hapticsEnabled, isTrue);
      await enabledRestart.haptics.passPhone();
      expect(pulses(), [pass]);
      enabledRestart.dispose();
      calls.clear();
      await store.haptics.selection();
      expect(pulses(), [selection]);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect(prefs.values['ptp_haptics_enabled_v5'], isFalse);
      final restarted = AppStore(preferences: prefs);
      await tester.runAsync(restarted.load);
      calls.clear();
      await restarted.haptics.selection();
      await restarted.haptics.passPhone();
      await restarted.haptics.revealQuestion();
      expect(restarted.hapticsEnabled, isFalse);
      expect(calls, isEmpty);
      await tester.pumpWidget(const SizedBox.shrink());
      restarted.dispose();
      store.dispose();
    },
  );

  for (final handoff in [true, false]) {
    testWidgets(
      'Quick Play has one start pulse and no automatic reveal pulse ($handoff)',
      (tester) async {
        final store = AppStore(
          preferences: MemoryPreferences({'ptp_handoff_enabled_v5': handoff}),
          hapticElapsed: () =>
              tester.binding.clock.now().difference(DateTime(2000)),
        );
        await tester.runAsync(store.load);
        await tester.pumpWidget(PassThePhoneApp(store: store));
        await tester.tap(find.text('ابدأ بسرعة  ·  The Crew'));
        await tester.pumpAndSettle();
        expect(pulses(), [transition]);
        calls.clear();
        await tester.tap(
          find.text(handoff ? 'سلّمت الموبايل' : 'السؤال التالي'),
        );
        await tester.pumpAndSettle();
        expect(pulses(), [handoff ? pass : transition]);
        await tester.pumpWidget(const SizedBox.shrink());
        store.dispose();
      },
    );

    testWidgets('finite ending is silent with handoff=$handoff', (
      tester,
    ) async {
      final session = GameSession(
        const [
          PartyQuestion(
            id: 'a',
            category: 'friends',
            text: 'Test question one',
          ),
          PartyQuestion(
            id: 'b',
            category: 'friends',
            text: 'Test question two',
          ),
        ],
        limit: 1,
        handoffEnabled: handoff,
      );
      await tester.pumpWidget(
        MaterialApp(
          home: GameScreen(
            session: session,
            category: gameCategories.first,
            haptics: HapticService(isEnabled: () => true),
          ),
        ),
      );
      expect(calls, isEmpty);
      await tester.tap(find.text(handoff ? 'سلّمت الموبايل' : 'السؤال التالي'));
      await tester.pumpAndSettle();
      if (handoff) {
        expect(pulses(), [pass]);
        calls.clear();
        await tester.tap(find.text('اكشف السؤال'));
        await tester.pumpAndSettle();
      }
      expect(session.phase, GamePhase.finished);
      expect(calls, isEmpty, reason: 'No question was revealed at the end');
    });
  }
}
