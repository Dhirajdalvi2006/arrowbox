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
    BoardTheme(
      id: BoardThemeId.midnightNebula,
      name: 'Midnight Nebula',
      description: 'Deep space navy with stardust accents.',
      background: Color(0xFF0A0E27),
      cell: Color(0xFF121A3A),
      border: Color(0xFF3A4C80),
      dot: Color(0xFF6E8FB7),
      frame: Color(0xFF080B1A),
      frameBorder: Color(0x887B68EE),
    ),
    BoardTheme(
      id: BoardThemeId.deepOceanAbyss,
      name: 'Deep Ocean Abyss',
      description: 'Abyssal midnight with bioluminescent edges.',
      background: Color(0xFF020A14),
      cell: Color(0xFF041222),
      border: Color(0xFF1A3A5C),
      dot: Color(0xFF4E9BCA),
      frame: Color(0xFF01050B),
      frameBorder: Color(0x882DB3D4),
    ),
    BoardTheme(
      id: BoardThemeId.solarFlare,
      name: 'Solar Flare',
      description: 'Warm sunrise gradients.',
      background: Color(0xFF1A0B05),
      cell: Color(0xFF2E1A0B),
      border: Color(0xFF8B4A1A),
      dot: Color(0xFFFF8C42),
      frame: Color(0xFF140703),
      frameBorder: Color(0x88FF6B35),
    ),
    BoardTheme(
      id: BoardThemeId.neonVoid,
      name: 'Neon Void',
      description: 'Neon on a dark void.',
      background: Color(0xFF05050A),
      cell: Color(0xFF0A0A14),
      border: Color(0xFF4A4AFF),
      dot: Color(0xFF00FFFF),
      frame: Color(0xFF020205),
      frameBorder: Color(0x8800FFFF),
    ),
  ];

  static BoardTheme byId(BoardThemeId id) =>
      all.firstWhere((theme) => theme.id == id);
}
