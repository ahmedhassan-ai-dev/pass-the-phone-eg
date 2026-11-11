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
    'The Crew',
    'صحاب، تريقة، ومواقف ما تتنسيش',
    Icons.bolt_rounded,
    Color(0xFF8368CC),
  ),
  GameCategory(
    'love',
    'Crush Club',
    'كراشات وحكايات ملهاش آخر',
    Icons.favorite_rounded,
    Color(0xFFE47D91),
  ),
  GameCategory(
    'family',
    'Family Time',
    'قعدة العيلة بطعم مختلف',
    Icons.weekend_rounded,
    Color(0xFF58A18E),
  ),
];
