import 'package:flutter_test/flutter_test.dart';
import 'package:pass_the_phone/main.dart';

void main() {
  test('deck filters selected mode and does not repeat questions', () {
    const questions = [
      PartyQuestion(id: 'a', category: 'friends', text: 'one'),
      PartyQuestion(id: 'b', category: 'friends', text: 'two'),
      PartyQuestion(id: 'c', category: 'family', text: 'three'),
    ];
    final deck = GameDeck(questions, 'friends');
    expect(deck.count, 2);
    final first = deck.current.id;
    deck.next();
    expect(deck.current.id, isNot(first));
    deck.next();
    expect(deck.finished, isTrue);
    deck.next();
    expect(deck.finished, isTrue);
  });
}
