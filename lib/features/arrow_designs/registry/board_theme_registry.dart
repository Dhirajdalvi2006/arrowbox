import 'package:flutter/material.dart';

import '../models/board_theme.dart';

class BoardThemeRegistry {
  const BoardThemeRegistry._();

  static const all = <BoardTheme>[
    BoardTheme(
      id: BoardThemeId.midnight,
      name: 'Midnight',
      description: 'The original deep navy board.',
      background: Color(0xFF040C18),
      cell: Color(0xFF081426),
      border: Color(0xFF122540),
      dot: Color(0xFF1E355B),
      frame: Color(0xFF040C18),
      frameBorder: Color(0x7721D4FD),
    ),
    BoardTheme(
      id: BoardThemeId.deepOcean,
      name: 'Deep Ocean',
      description: 'Cool blue depth with crisp edges.',
      background: Color(0xFF041A2A),
      cell: Color(0xFF07304A),
      border: Color(0xFF14516B),
      dot: Color(0xFF2A7692),
      frame: Color(0xFF031421),
      frameBorder: Color(0x8855D9FF),
    ),
    BoardTheme(
      id: BoardThemeId.aurora,
      name: 'Aurora',
      description: 'A quiet teal board with luminous accents.',
      background: Color(0xFF071B21),
      cell: Color(0xFF0B2A2B),
      border: Color(0xFF1C5550),
      dot: Color(0xFF3D8B7C),
      frame: Color(0xFF061519),
      frameBorder: Color(0x884BE7C8),
    ),
    BoardTheme(
      id: BoardThemeId.graphite,
      name: 'Graphite',
      description: 'A neutral slate surface for focused play.',
      background: Color(0xFF151A22),
      cell: Color(0xFF232B36),
      border: Color(0xFF3B4655),
      dot: Color(0xFF687789),
      frame: Color(0xFF11161D),
      frameBorder: Color(0x8898A9BF),
    ),
  ];

  static BoardTheme byId(BoardThemeId id) =>
      all.firstWhere((theme) => theme.id == id);
}
