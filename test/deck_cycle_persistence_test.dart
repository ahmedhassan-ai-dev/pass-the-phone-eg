import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/core/services/app_store.dart';
import 'app_store_upgrade_test.dart' show MemoryPreferences;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'partially completed second cycle survives reload in exact order',
    () async {
      final prefs = MemoryPreferences({'ptp_handoff_enabled_v5': false});
      final store = AppStore(preferences: prefs);
      await store.load();
      final count = store.countFor('family');
      final game = store.startGame('family');
      for (var i = 0; i < count; i++) {
        game.handOff();
      }
      final secondCycleSeen = [game.current.id];
      for (var i = 0; i < 2; i++) {
        game.handOff();
        secondCycleSeen.add(game.current.id);
      }
      await store.flushPendingWrites();
      final remaining =
          (jsonDecode(prefs.values['ptp_remaining_decks_v4']! as String)
                  as Map)['family']
              as List;
      expect(remaining.length, count - 3);
      expect(remaining.toSet().intersection(secondCycleSeen.toSet()), isEmpty);
      final snapshot = Map<String, Object>.of(prefs.values);
      final expected = <String>[];
      for (var i = 0; i < remaining.length; i++) {
        game.handOff();
        expected.add(game.current.id);
      }
      final restored = AppStore(preferences: MemoryPreferences(snapshot));
      await restored.load();
      final resumed = restored.startGame('family');
      final actual = [resumed.current.id];
      for (var i = 1; i < remaining.length; i++) {
        resumed.handOff();
        actual.add(resumed.current.id);
      }
      expect(actual, expected);
      expect(actual.toSet().intersection(secondCycleSeen.toSet()), isEmpty);
      await store.flushPendingWrites();
      await restored.flushPendingWrites();
      store.dispose();
      restored.dispose();
    },
  );
}
