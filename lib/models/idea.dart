import 'package:flutter/material.dart';

class Idea {
  const Idea({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.skills,
    required this.filledSpots,
    required this.totalSpots,
    required this.gradient,
  });

  final String id;
  final String title;
  final String description;
  final String category;
  final List<String> skills;
  final int filledSpots;
  final int totalSpots;
  final List<Color> gradient;

  String get spotsLabel => '$filledSpots de $totalSpots cupos';
}
