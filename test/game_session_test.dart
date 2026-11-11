import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/core/models/party_question.dart';
import 'package:pass_the_phone/core/services/game_session.dart';

void main() {
  final questions = List.generate(
    4,
    (i) => PartyQuestion(id: '$i', category: 'friends', text: 'Question $i'),
  );

  test('finite game ends after chosen number of rounds', () {
    final game = GameSession(questions, limit: 10, random: Random(1));
    for (var n = 1; n <= 10; n++) {
      expect(game.round, n);
      game.handOff();
      game.revealNext();
    }
    expect(game.phase, GamePhase.finished);
  });

  test('no duplicate in each full deck cycle', () {
    final game = GameSession(questions, random: Random(42));
    final first = <String>{};
    for (var n = 0; n < 4; n++) {
      first.add(game.current.id);
      game.handOff();
      game.revealNext();
    }
    expect(first.length, 4);
  });

  test('handoff hides question until reveal', () {
    final game = GameSession(questions, random: Random(2));
    final previous = game.current;
    game.handOff();
    expect(game.phase, GamePhase.handoff);
    game.revealNext();
    expect(game.current.id, isNot(previous.id));
  });

  test('initial order and per-reveal hooks work', () {
    final seen = <String>[];
    final game = GameSession(
      questions,
      initialOrder: questions.reversed.toList(),
      onQuestionShown: seen.add,
    );
    expect(game.current.id, questions.last.id);
    game.handOff();
    game.revealNext();
    expect(seen, ['3', '2']);
  });

  test('empty questions rejected', () {
    expect(() => GameSession([]), throwsArgumentError);
  });
}
