import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('question bank is valid, unique, and playable', () async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    final rows = jsonDecode(raw) as List<dynamic>;
    expect(rows.length, greaterThanOrEqualTo(155));
    final ids = <String>{};
    final texts = <String>{};
    const allowed = {'friends', 'savage', 'love', 'family', 'surprise'};
    for (final row in rows) {
      final q = Map<String, dynamic>.from(row as Map);
      final id = q['id'];
      final category = q['category'];
      final text = q['text'];
      expect(id, isA<String>());
      expect(category, isA<String>());
      expect(text, isA<String>());
      expect((id as String).trim(), isNotEmpty);
      expect(
        allowed.contains(category),
        isTrue,
        reason: 'Unknown category in $id',
      );
      expect((text as String).trim().length, greaterThanOrEqualTo(8));
      expect(ids.add(id), isTrue, reason: 'Duplicate ID $id');
      expect(
        texts.add('$category:${text.trim().toLowerCase()}'),
        isTrue,
        reason: 'Duplicate question text in $category',
      );
    }
    expect(
      rows.where(
        (e) =>
            (e as Map)['category'] == 'friends' || (e)['category'] == 'savage',
      ),
      isNotEmpty,
    );
  });
}
