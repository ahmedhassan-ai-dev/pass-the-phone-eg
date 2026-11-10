import 'dart:math';
import '../models/party_question.dart';

enum GamePhase { question, handoff, finished }

class GameSession {
  final List<PartyQuestion> _source;
  final int? limit;
  final Random _random;
  late List<PartyQuestion> _deck;
  int _cursor = 0;
  int round = 1;
  GamePhase phase = GamePhase.question;
  String? _lastId;

  GameSession(List<PartyQuestion> questions, {this.limit, Random? random})
    : _source = List.of(questions),
      _random = random ?? Random() {
    if (_source.isEmpty) throw ArgumentError('No questions available');
    if (limit != null && limit! <= 0) throw ArgumentError('Invalid limit');
    _reshuffle();
  }

  PartyQuestion get current => _deck[_cursor];
  bool get isUnlimited => limit == null;

  void handOff() {
    if (phase == GamePhase.question) phase = GamePhase.handoff;
  }

  void revealNext() {
    if (phase != GamePhase.handoff) return;
    if (limit != null && round >= limit!) {
      phase = GamePhase.finished;
      return;
    }
    _lastId = current.id;
    _cursor++;
    if (_cursor >= _deck.length) _reshuffle();
    round++;
    phase = GamePhase.question;
  }

  void _reshuffle() {
    _deck = List.of(_source)..shuffle(_random);
    // Avoid showing the previous question immediately after a new shuffle.
    if (_deck.length > 1 && _deck.first.id == _lastId) {
      final first = _deck.removeAt(0);
      _deck.add(first);
    }
    _cursor = 0;
  }
}
