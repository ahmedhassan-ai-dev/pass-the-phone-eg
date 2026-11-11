import 'dart:math';
import '../models/party_question.dart';

enum GamePhase { question, handoff, finished }

/// Pure Dart gameplay. No Flutter widgets or persistence in this layer.
class GameSession {
  final List<PartyQuestion> _source;
  final int? limit;
  final bool handoffEnabled;
  final Random _random;
  final void Function(String)? onQuestionShown;
  late List<PartyQuestion> _deck;
  int _cursor = 0;
  int round = 1;
  GamePhase phase = GamePhase.question;
  String? _lastId;

  GameSession(
    List<PartyQuestion> questions, {
    this.limit,
    this.handoffEnabled = true,
    Random? random,
    List<PartyQuestion>? initialOrder,
    this.onQuestionShown,
  }) : _source = List.of(questions),
       _random = random ?? Random.secure() {
    if (_source.isEmpty) throw ArgumentError('No questions available');
    if (limit != null && limit! <= 0) throw ArgumentError('Invalid limit');
    _deck = initialOrder == null
        ? (List.of(_source)..shuffle(_random))
        : List.of(initialOrder);
    if (_deck.length != _source.length ||
        _deck.map((q) => q.id).toSet().length != _source.length ||
        !_deck.map((q) => q.id).toSet().containsAll(_source.map((q) => q.id))) {
      throw ArgumentError('Invalid initial order');
    }
    onQuestionShown?.call(current.id);
  }

  PartyQuestion get current => _deck[_cursor];
  bool get isUnlimited => limit == null;

  void handOff() {
    if (phase == GamePhase.question) {
      if (handoffEnabled) {
        phase = GamePhase.handoff;
      } else {
        _moveNext();
      }
    }
  }

  void revealNext() {
    if (phase != GamePhase.handoff) return;
    _moveNext();
  }

  void _moveNext() {
    if (limit != null && round >= limit!) {
      phase = GamePhase.finished;
      return;
    }
    _lastId = current.id;
    _cursor++;
    if (_cursor >= _deck.length) _reshuffle();
    round++;
    phase = GamePhase.question;
    onQuestionShown?.call(current.id);
  }

  void _reshuffle() {
    _deck = List.of(_source)..shuffle(_random);
    if (_deck.length > 1 && _deck.first.id == _lastId) {
      final first = _deck.removeAt(0);
      _deck.add(first);
    }
    _cursor = 0;
  }
}
