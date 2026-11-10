import 'package:flutter/material.dart';

class GameCategory {
  final String id, title, subtitle;
  final IconData icon;
  final Color color;
  const GameCategory(this.id, this.title, this.subtitle, this.icon, this.color);
}

const gameCategories = <GameCategory>[
  GameCategory(
    'friends',
    'الصحاب',
    'ضحك ورخامة لطيفة',
    Icons.groups_rounded,
    Color(0xFF7B6EEA),
  ),
  GameCategory(
    'love',
    'الحب',
    'كراشات ومواقف',
    Icons.favorite_rounded,
    Color(0xFFE17892),
  ),
  GameCategory(
    'savage',
    'الجريء',
    'للشلة المقربة',
    Icons.local_fire_department_rounded,
    Color(0xFFE39854),
  ),
  GameCategory(
    'family',
    'العيلة',
    'قعدة عائلية ممتعة',
    Icons.home_rounded,
    Color(0xFF3F9E83),
  ),
  GameCategory(
    'custom',
    'أسئلتي',
    'من تأليف الشلة',
    Icons.edit_note_rounded,
    Color(0xFF5D90CB),
  ),
];
