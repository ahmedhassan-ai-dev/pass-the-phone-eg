import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

class WriteControl {
  Completer<void>? gate;
  bool failNext = false;
  String? failKey;
  int active = 0;
  int maxActive = 0;
  final calls = <Object>[];
  final keys = <String>[];
}

class ControlledPreferences extends MemoryPreferences {
  ControlledPreferences() : super({});
  final control = WriteControl();

  Future<void> write(
    String key,
    Object value,
    Future<void> Function() action,
  ) async {
    control.active++;
    if (control.active > control.maxActive) control.maxActive = control.active;
    control.calls.add(value);
    control.keys.add(key);
    try {
      final pending = control.gate;
      control.gate = null;
      if (pending != null) await pending.future;
      if (control.failNext || control.failKey == key) {
        control.failNext = false;
        control.failKey = null;
        throw StateError('Injected storage failure');
      }
      await action();
    } finally {
      control.active--;
    }
  }

  @override
  Future<void> setBool(String key, bool value) =>
      write(key, value, () => super.setBool(key, value));
  @override
  Future<void> setString(String key, String value) =>
      write(key, value, () => super.setString(key, value));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('overlapping settings writes finish in request order', () async {
    final prefs = ControlledPreferences();
    final store = AppStore(preferences: prefs);
    await store.load();
    final gate = Completer<void>();
    prefs.control.gate = gate;
    final first = store.setHapticsEnabled(false);
    final second = store.setHapticsEnabled(true);
    await Future<void>.delayed(Duration.zero);
    expect(prefs.control.calls, [false]);
    expect(store.hapticsEnabled, isTrue);
    gate.complete();
    await Future.wait([first, second]);
    expect(prefs.control.calls, [false, true]);
    expect(prefs.control.maxActive, 1);
    expect(prefs.values['ptp_haptics_enabled_v5'], true);
    store.dispose();
  });

  test('concurrent custom additions retain both questions', () async {
    final prefs = ControlledPreferences();
    final store = AppStore(preferences: prefs);
    await store.load();
    await Future.wait([
      store.addQuestion('First owner question', 'family'),
      store.addQuestion('Second owner question', 'family'),
    ]);
    expect(store.customQuestions.length, 2);
    expect(
      (jsonDecode(prefs.values['ptp_custom_questions_v2']! as String) as List)
          .length,
      2,
    );
    expect(prefs.control.maxActive, 1);
    store.dispose();
  });

  test(
    'failed settings toggle keeps saved value on immediate reload',
    () async {
      final prefs = ControlledPreferences();
      prefs.values['ptp_haptics_enabled_v5'] = true;
      final store = AppStore(preferences: prefs);
      await store.load();
      prefs.control.failKey = 'ptp_haptics_enabled_v5';
      await store.setHapticsEnabled(false);
      await store.flushPendingWrites();
      expect(
        store.hapticsEnabled,
        isFalse,
        reason: 'Live OFF gating is immediate',
      );
      expect(store.hasSaveError, isTrue);
      expect(prefs.values['ptp_haptics_enabled_v5'], isTrue);
      expect(prefs.control.keys, ['ptp_haptics_enabled_v5']);
      final restored = AppStore(
        preferences: MemoryPreferences(Map<String, Object>.of(prefs.values)),
      );
      await restored.load();
      expect(
        restored.hapticsEnabled,
        isTrue,
        reason: 'Unsaved OFF is not durable',
      );
      expect(restored.hasSaveError, isFalse);
      expect(prefs.control.keys, [
        'ptp_haptics_enabled_v5',
      ], reason: 'No retry');
      store.dispose();
      restored.dispose();
    },
  );

  test(
    'failed second deck write reloads saved unseen order without retry',
    () async {
      final prefs = ControlledPreferences();
      prefs.values['ptp_handoff_enabled_v5'] = false;
      final store = AppStore(preferences: prefs);
      await store.load();
      final game = store.startGame('family');
      final seen = <String>[game.current.id];
      for (var i = 0; i < 2; i++) {
        game.handOff();
        seen.add(game.current.id);
      }
      await store.flushPendingWrites();
      final originalKnown = prefs.values['ptp_known_decks_v4'];
      final before = prefs.control.keys.length;
      prefs.control.failKey = 'ptp_known_decks_v4';
      game.handOff();
      seen.add(game.current.id);
      await store.flushPendingWrites();
      expect(store.hasSaveError, isTrue);
      expect(prefs.control.keys.skip(before), [
        'ptp_remaining_decks_v4',
        'ptp_known_decks_v4',
      ]);
      expect(prefs.values['ptp_known_decks_v4'], originalKnown);
      final snapshot = Map<String, Object>.of(prefs.values);
      final remaining =
          (jsonDecode(snapshot['ptp_remaining_decks_v4']! as String)
                  as Map)['family']
              as List;
      expect(remaining.length, store.countFor('family') - seen.length);
      expect(remaining.toSet().intersection(seen.toSet()), isEmpty);

      // Reload the partial disk snapshot before any successful retry can mask it.
      final restored = AppStore(
        preferences: MemoryPreferences(Map<String, Object>.of(snapshot)),
      );
      await restored.load();
      final resumed = restored.startGame('family');
      final actual = <String>[resumed.current.id];
      for (var i = 1; i < remaining.length; i++) {
        resumed.handOff();
        actual.add(resumed.current.id);
      }
      expect(actual, remaining);
      expect(actual.toSet().intersection(seen.toSet()), isEmpty);
      expect(
        prefs.control.keys.length,
        before + 2,
        reason: 'No retry on original store',
      );
      expect(prefs.values, snapshot);
      await restored.flushPendingWrites();
      store.dispose();
      restored.dispose();
    },
  );

  test(
    'failed add/delete preserves owner content and later writes recover',
    () async {
      final prefs = ControlledPreferences();
      final store = AppStore(preferences: prefs);
      await store.load();
      await store.addQuestion('Retained owner question', 'family');
      final original = prefs.values['ptp_custom_questions_v2'];
      prefs.control.failNext = true;
      await expectLater(
        store.addQuestion('Unsaved owner question', 'family'),
        throwsStateError,
      );
      expect(store.customQuestions.length, 1);
      expect(prefs.values['ptp_custom_questions_v2'], original);
      expect(store.hasSaveError, isTrue);
      prefs.control.failNext = true;
      await expectLater(
        store.removeQuestion(store.customQuestions.single.id),
        throwsStateError,
      );
      expect(store.customQuestions.length, 1);
      expect(prefs.values['ptp_custom_questions_v2'], original);
      await store.addQuestion('Unsaved owner question', 'family');
      expect(store.customQuestions.length, 2);
      await store.setHandoffEnabled(false);
      expect(prefs.values['ptp_handoff_enabled_v5'], false);
      store.dispose();
    },
  );

  test(
    'failed background deck write does not poison later snapshots',
    () async {
      final prefs = ControlledPreferences();
      final store = AppStore(preferences: prefs);
      await store.load();
      await store.setHandoffEnabled(false);
      prefs.control.failNext = true;
      final game = store.startGame('family');
      game.handOff();
      game.handOff();
      await store.flushPendingWrites();
      expect(store.hasSaveError, isTrue);
      final remaining =
          (jsonDecode(prefs.values['ptp_remaining_decks_v4']! as String)
                  as Map)['family']
              as List;
      expect(remaining.length, store.countFor('family') - 3);
      store.dispose();
    },
  );

  test(
    'unreadable persisted data is retained instead of overwritten',
    () async {
      final prefs = MemoryPreferences({
        'ptp_custom_questions_v2': '[{"owner":"unreadable"}]',
        'ptp_remaining_decks_v4': 'owner raw deck needing recovery',
        'ptp_known_decks_v4': '{}',
      });
      final originals = Map<String, Object>.of(prefs.values);
      final store = AppStore(preferences: prefs);
      await store.load();
      await expectLater(
        store.addQuestion('New owner question', 'family'),
        throwsStateError,
      );
      store.startGame('family');
      await store.flushPendingWrites();
      expect(prefs.values, originals);
      expect(store.hasSaveError, isTrue);
      store.dispose();
    },
  );
}
