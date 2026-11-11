import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pass_the_phone/core/services/app_store.dart';

// Emulates the existing async backend; does not switch Android storage engines.
class MemoryPreferences implements SharedPreferencesAsync {
  final Map<String, Object> values;
  MemoryPreferences(this.values);
  @override
  Future<String?> getString(String key) async => values[key] as String?;
  @override
  Future<bool?> getBool(String key) async => values[key] as bool?;
  @override
  Future<void> setString(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> setBool(String key, bool value) async {
    values[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Keys and JSON shape checked against ad31aad (v0.5) and e0db3d6 (v0.6).
  for (final version in [5, 6]) {
    for (final theme in ThemeMode.values) {
      test(
        'v0.$version $theme settings, custom content and unseen order survive',
        () async {
          final prefs = MemoryPreferences({
            'ptp_theme_v2': theme.name,
            'ptp_handoff_enabled_v5': false,
            'ptp_haptics_enabled_v5': false,
            if (version == 6) 'ptp_surprise_enabled_v6': true,
            'ptp_custom_questions_v2': jsonEncode([
              {
                'id': 'owner_a',
                'category': 'friends',
                'text': 'Owner question number one',
                'isCustom': true,
              },
              {
                'id': 'owner_b',
                'category': 'savage',
                'text': 'Owner question number two',
                'isCustom': true,
              },
            ]),
            'ptp_remaining_decks_v4': jsonEncode({
              'friends': ['owner_b', 'owner_a'],
            }),
            'ptp_known_decks_v4': jsonEncode({
              'friends': ['owner_a', 'owner_b'],
            }),
          });
          final originalCustom = prefs.values['ptp_custom_questions_v2'];
          final store = AppStore(preferences: prefs);
          await store.load();
          expect(store.themeMode, theme);
          expect(store.handoffEnabled, isFalse);
          expect(store.hapticsEnabled, isFalse);
          expect(store.surpriseEnabled, version == 6);
          expect(store.customQuestions.map((q) => q.id), [
            'owner_a',
            'owner_b',
          ]);
          expect(prefs.values['ptp_custom_questions_v2'], originalCustom);
          final game = store.startGame('friends');
          expect(game.current.id, 'owner_b');
          // Drain the asynchronous preference writes before simulating restart.
          await Future<void>.delayed(Duration.zero);
          final restarted = AppStore(preferences: prefs);
          await restarted.load();
          expect(restarted.startGame('friends').current.id, 'owner_a');
          await Future<void>.delayed(Duration.zero);
          expect(restarted.customQuestions.length, 2);
          expect(prefs.values['ptp_custom_questions_v2'], originalCustom);
          store.dispose();
          restarted.dispose();
        },
      );
    }
  }
  test(
    'legacy custom category migrates idempotently without losing content',
    () async {
      final prefs = MemoryPreferences({
        'ptp_custom_questions_v2': jsonEncode([
          {
            'id': 'old',
            'category': 'custom',
            'text': 'Legacy owner question',
            'isCustom': true,
          },
        ]),
      });
      for (var i = 0; i < 2; i++) {
        final store = AppStore(preferences: prefs);
        await store.load();
        expect(store.customQuestions.single.toJson(), {
          'id': 'old',
          'category': 'friends',
          'text': 'Legacy owner question',
          'isCustom': true,
        });
        store.dispose();
      }
    },
  );
  test('new custom questions and every setting survive restart', () async {
    final prefs = MemoryPreferences({});
    final store = AppStore(preferences: prefs);
    await store.load();
    await store.addQuestion('A new owner question', 'family');
    await store.setTheme(ThemeMode.dark);
    await store.setHandoffEnabled(false);
    await store.setHapticsEnabled(false);
    await store.setSurpriseEnabled(true);
    final restarted = AppStore(preferences: prefs);
    await restarted.load();
    expect(restarted.customQuestions.single.text, 'A new owner question');
    expect(restarted.themeMode, ThemeMode.dark);
    expect(restarted.handoffEnabled, isFalse);
    expect(restarted.hapticsEnabled, isFalse);
    expect(restarted.surpriseEnabled, isTrue);
    store.dispose();
    restarted.dispose();
  });
}
