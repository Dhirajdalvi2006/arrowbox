import 'package:flutter/material.dart';

class BoardTheme {
  const BoardTheme({
    required this.id,
    required this.name,
    required this.description,
    required this.background,
    required this.cell,
    required this.border,
    required this.dot,
    required this.frame,
    required this.frameBorder,
  });

  final BoardThemeId id;
  final String name;
  final String description;
  final Color background;
  final Color cell;
  final Color border;
  final Color dot;
  final Color frame;
  final Color frameBorder;
}

enum BoardThemeId { midnight, deepOcean, aurora, graphite }
