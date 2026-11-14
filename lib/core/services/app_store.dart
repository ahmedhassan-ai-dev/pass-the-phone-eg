import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/party_question.dart';
import 'game_session.dart';
import 'haptic_service.dart';

class AppStore extends ChangeNotifier {
  static const _themeKey = 'ptp_theme_v2';
  static const _handoffKey = 'ptp_handoff_enabled_v5';
  static const _hapticsKey = 'ptp_haptics_enabled_v5';
  static const _surpriseKey = 'ptp_surprise_enabled_v6';
  static const _customKey = 'ptp_custom_questions_v2';
  static const _deckKey = 'ptp_remaining_decks_v4';
  static const _knownKey = 'ptp_known_decks_v4';
  final SharedPreferencesAsync _prefs;
  Future<void> _writeTail = Future<void>.value();
  bool _disposed = false;
  bool hasSaveError = false;
  bool _customReadable = true;
  bool _decksReadable = true;

  // All writes, including custom-question mutations, share one ordered queue.
  // A rejected operation cannot poison subsequent operations or become an
  // unhandled error for fire-and-forget deck updates.
  Future<void> _write(Future<void> Function() action) {
    final operation = _writeTail.then((_) => action());
    _writeTail = operation.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        if (error is! ArgumentError) {
          hasSaveError = true;
          if (!_disposed) notifyListeners();
        }
      },
    );
    return operation;
  }

  Future<void> flushPendingWrites() => _writeTail;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  final Duration Function()? _hapticElapsed;
  AppStore({
    SharedPreferencesAsync? preferences,
    Duration Function()? hapticElapsed,
  }) : _prefs = preferences ?? SharedPreferencesAsync(),
       _hapticElapsed = hapticElapsed;
  final Random _random = Random.secure();
  List<PartyQuestion> _builtIn = [];
  List<PartyQuestion> _custom = [];
  Map<String, List<String>> _remaining = {};
  Map<String, List<String>> _known = {};
  ThemeMode themeMode = ThemeMode.system;
  bool handoffEnabled = true;
  bool hapticsEnabled = true;
  late final HapticService haptics = HapticService(
    isEnabled: () => hapticsEnabled,
    elapsed: _hapticElapsed,
  );
  bool surpriseEnabled = false;

  List<PartyQuestion> get customQuestions => List.unmodifiable(_custom);
  int countFor(String category) => available(category).length;
  List<PartyQuestion> available(String category) {
    // Legacy 'savage' questions are merged with 'friends' without losing content.
    final built = _builtIn.where(
      (q) =>
          q.category == category ||
          (category == 'friends' &&
              (q.category == 'savage' ||
                  (surpriseEnabled && q.category == 'surprise'))),
    );
    final custom = _custom.where(
      (q) =>
          q.category == category ||
          (category == 'friends' && q.category == 'savage'),
    );
    return [...built, ...custom];
  }

  Future<void> load() async {
    final raw = await rootBundle.loadString('assets/data/questions.json');
    _builtIn = (jsonDecode(raw) as List)
        .map((e) => PartyQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final stored = await _prefs.getString(_customKey);
    if (stored != null) {
      try {
        _custom = (jsonDecode(stored) as List)
            .map(
              (e) =>
                  PartyQuestion.fromJson(Map<String, dynamic>.from(e as Map)),
            )
            .toList();
      } catch (_) {
        _custom = [];
        _customReadable = false;
        hasSaveError = true;
      }
    }
    final savedDecks = await _prefs.getString(_deckKey);
    if (savedDecks != null) {
      try {
        final decoded = jsonDecode(savedDecks) as Map<String, dynamic>;
        _remaining = decoded.map(
          (key, value) =>
              MapEntry(key, (value as List).map((e) => e.toString()).toList()),
        );
      } catch (_) {
        _remaining = {};
        _decksReadable = false;
        hasSaveError = true;
      }
    }
    final knownRaw = await _prefs.getString(_knownKey);
    if (knownRaw != null) {
      try {
        _known = (jsonDecode(knownRaw) as Map<String, dynamic>).map(
          (key, value) =>
              MapEntry(key, (value as List).map((e) => e.toString()).toList()),
        );
      } catch (_) {
        _known = {};
        _decksReadable = false;
        hasSaveError = true;
      }
    }
    // Migration: in v0.3, standalone custom-mode questions were not assigned
    // to a playable category. Move them into The Crew without losing content.
    final legacy = _custom.where((q) => q.category == 'custom').toList();
    if (legacy.isNotEmpty) {
      _custom = _custom
          .map(
            (q) => q.category == 'custom'
                ? PartyQuestion(
                    id: q.id,
                    category: 'friends',
                    text: q.text,
                    isCustom: true,
                  )
                : q,
          )
          .toList();
      await _saveCustom();
    }
    final theme = await _prefs.getString(_themeKey);
    themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    handoffEnabled = await _prefs.getBool(_handoffKey) ?? true;
    hapticsEnabled = await _prefs.getBool(_hapticsKey) ?? true;
    surpriseEnabled = await _prefs.getBool(_surpriseKey) ?? false;
    notifyListeners();
  }

  Future<void> setHandoffEnabled(bool enabled) async {
    handoffEnabled = enabled;
    notifyListeners();
    await _write(
      () => _prefs.setBool(_handoffKey, enabled),
    ).catchError((Object _) {});
  }

  Future<void> setHapticsEnabled(bool enabled) async {
    hapticsEnabled = enabled;
    notifyListeners();
    await _write(
      () => _prefs.setBool(_hapticsKey, enabled),
    ).catchError((Object _) {});
  }

  Future<void> setSurpriseEnabled(bool enabled) async {
    surpriseEnabled = enabled;
    notifyListeners();
    await _write(
      () => _prefs.setBool(_surpriseKey, enabled),
    ).catchError((Object _) {});
  }

  GameSession startGame(String category, {int? limit}) {
    final questions = available(category);
    if (questions.isEmpty) throw ArgumentError('No questions available');
    final byId = {for (final q in questions) q.id: q};
    // Remaining IDs are carried across sessions. New questions enter the queue.
    final saved = _remaining[category] ?? [];
    final queue = saved.where(byId.containsKey).toList();
    if (queue.isEmpty) {
      queue.addAll(byId.keys);
      queue.shuffle(_random);
    } else {
      final newIds =
          byId.keys
              .where(
                (id) =>
                    !queue.contains(id) &&
                    !(_known[category] ?? []).contains(id),
              )
              .toList()
            ..shuffle(_random);
      queue.addAll(newIds);
    }
    // Used IDs are put after the remaining deck, so they are not shown before
    // unused ones in this session. They become eligible again after exhaustion.
    final used = byId.keys.where((id) => !queue.contains(id)).toList()
      ..shuffle(_random);
    final ordered = [...queue, ...used].map((id) => byId[id]!).toList();
    _remaining[category] = queue;
    _known[category] = byId.keys.toList();
    _persistDecks();
    return GameSession(
      questions,
      limit: limit,
      initialOrder: ordered,
      handoffEnabled: handoffEnabled,
      onRemainingChanged: (ids) => _recordRemaining(category, ids),
    );
  }

  void _recordRemaining(String category, List<String> ids) {
    _remaining[category] = List.of(ids);
    // Persist each reveal so closing the app will not reset progress.
    _persistDecks();
  }

  Future<void> _persistDecks() {
    // Never replace unreadable owner data with an empty/new deck as recovery.
    if (!_decksReadable) return Future<void>.value();
    final remaining = jsonEncode(_remaining);
    final known = jsonEncode(_known);
    return _write(() async {
      await _prefs.setString(_deckKey, remaining);
      await _prefs.setString(_knownKey, known);
    }).catchError((Object _) {});
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _write(
      () => _prefs.setString(_themeKey, value.name),
    ).catchError((Object _) {});
  }

  Future<void> addQuestion(String text, String category) async {
    if (!_customReadable) {
      throw StateError('Stored custom questions need recovery');
    }
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length < 8 || cleaned.length > 180) {
      throw ArgumentError('السؤال لازم يكون بين 8 و180 حرف');
    }
    if (!['friends', 'love', 'family'].contains(category)) {
      throw ArgumentError('اختار فئة صحيحة');
    }
    await _write(() async {
      if (available(
        category,
      ).any((q) => q.text.toLowerCase() == cleaned.toLowerCase())) {
        throw ArgumentError('السؤال ده موجود بالفعل');
      }
      final updated = [
        ..._custom,
        PartyQuestion(
          id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
          category: category,
          text: cleaned,
          isCustom: true,
        ),
      ];
      await _prefs.setString(
        _customKey,
        jsonEncode(updated.map((q) => q.toJson()).toList()),
      );
      _custom = updated;
      if (!_disposed) notifyListeners();
    });
  }

  Future<void> removeQuestion(String id) async {
    if (!_customReadable) {
      throw StateError('Stored custom questions need recovery');
    }
    await _write(() async {
      final updated = _custom.where((q) => q.id != id).toList();
      await _prefs.setString(
        _customKey,
        jsonEncode(updated.map((q) => q.toJson()).toList()),
      );
      _custom = updated;
      for (final queue in _remaining.values) {
        queue.remove(id);
      }
      if (!_disposed) notifyListeners();
    });
    await _persistDecks();
  }

  Future<void> _saveCustom() => _write(
    () => _prefs.setString(
      _customKey,
      jsonEncode(_custom.map((q) => q.toJson()).toList()),
    ),
  );
}
