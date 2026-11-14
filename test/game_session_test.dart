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

  test('persistence observer does not change uninterrupted shuffled order', () {
    var remaining = <String>[];
    final observed = GameSession(
      questions,
      handoffEnabled: false,
      random: Random(42),
      onRemainingChanged: (ids) {
        remaining = ids;
      },
    );
    final original = GameSession(
      questions,
      handoffEnabled: false,
      random: Random(42),
    );
    for (var i = 0; i < 40; i++) {
      expect(observed.current.id, original.current.id);
      expect(remaining.length, questions.length - (i % questions.length) - 1);
      expect(() => remaining.add('bad'), throwsUnsupportedError);
      observed.handOff();
      original.handOff();
    }
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

  test('handoff disabled shows the next question immediately', () {
    final game = GameSession(
      questions,
      handoffEnabled: false,
      random: Random(12),
    );
    final before = game.current.id;
    game.handOff();
    expect(game.phase, GamePhase.question);
    expect(game.round, 2);
    expect(game.current.id, isNot(before));
  });

  test('handoff disabled still ends after configured rounds', () {
    final game = GameSession(
      questions,
      limit: 2,
      handoffEnabled: false,
      random: Random(14),
    );
    game.handOff();
    expect(game.phase, GamePhase.question);
    game.handOff();
    expect(game.phase, GamePhase.finished);
  });

  test('no repeats across a cycle even with handoff disabled', () {
    final game = GameSession(
      questions,
      random: Random(33),
      handoffEnabled: false,
    );
    final seen = <String>{};
    for (var i = 0; i < questions.length; i++) {
      seen.add(game.current.id);
      game.handOff();
    }
    expect(seen.length, questions.length);
  });

  test('revealNext outside handoff is ignored', () {
    final game = GameSession(questions, random: Random(5));
    game.revealNext();
    expect(game.round, 1);
    expect(game.phase, GamePhase.question);
  });

  test('invalid limit is rejected', () {
    expect(() => GameSession(questions, limit: 0), throwsArgumentError);
    expect(() => GameSession(questions, limit: -3), throwsArgumentError);
  });

  test('wrong initial order is rejected', () {
    expect(
      () => GameSession(questions, initialOrder: [questions.first]),
      throwsArgumentError,
    );
    expect(
      () => GameSession(
        questions,
        initialOrder: [
          questions.first,
          questions.first,
          questions[2],
          questions[3],
        ],
      ),
      throwsArgumentError,
    );
  });

  test('last question does not become first after reshuffle', () {
    final game = GameSession(
      questions,
      random: Random(9),
      initialOrder: questions,
    );
    final ids = <String>[];
    for (var i = 0; i < questions.length; i++) {
      ids.add(game.current.id);
      game.handOff();
      game.revealNext();
    }
    expect(ids.toSet().length, questions.length);
    expect(game.current.id, isNot(ids.last));
  });

  test('empty questions rejected', () {
    expect(() => GameSession([]), throwsArgumentError);
  });
}
