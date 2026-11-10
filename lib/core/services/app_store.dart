import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/party_question.dart';

class AppStore extends ChangeNotifier {
  static const _themeKey = 'ptp_theme_v2';
  static const _customKey = 'ptp_custom_questions_v2';
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  List<PartyQuestion> _builtIn = [];
  List<PartyQuestion> _custom = [];
  ThemeMode themeMode = ThemeMode.system;

  List<PartyQuestion> get customQuestions => List.unmodifiable(_custom);
  int countFor(String category) => available(category).length;
  List<PartyQuestion> available(String category) {
    if (category == 'custom') return List.of(_custom);
    return [
      ..._builtIn.where((q) => q.category == category),
      ..._custom.where((q) => q.category == category),
    ];
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
      }
    }
    final theme = await _prefs.getString(_themeKey);
    themeMode = switch (theme) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.system,
    };
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode value) async {
    themeMode = value;
    notifyListeners();
    await _prefs.setString(_themeKey, value.name);
  }

  Future<void> addQuestion(String text, String category) async {
    final cleaned = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (cleaned.length < 8 || cleaned.length > 180) {
      throw ArgumentError('السؤال لازم يكون بين 8 و180 حرف');
    }
    if (_custom.any((q) => q.category == category && q.text == cleaned)) {
      throw ArgumentError('السؤال ده موجود بالفعل');
    }
    _custom.add(
      PartyQuestion(
        id: 'custom_${DateTime.now().microsecondsSinceEpoch}',
        category: category,
        text: cleaned,
        isCustom: true,
      ),
    );
    notifyListeners();
    await _saveCustom();
  }

  Future<void> removeQuestion(String id) async {
    _custom.removeWhere((q) => q.id == id);
    notifyListeners();
    await _saveCustom();
  }

  Future<void> _saveCustom() => _prefs.setString(
    _customKey,
    jsonEncode(_custom.map((q) => q.toJson()).toList()),
  );
}
