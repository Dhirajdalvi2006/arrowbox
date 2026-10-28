import 'dart:io';

import 'package:locate/features/arrowbox/levels/board_generator.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

void main() {
  final cases = <(String, List<dynamic> Function({BoardGenerationStats? stats}), int)>[
    ('medium-200', ({stats}) => MediumLevels.generate(200, stats: stats), 1583901),
    ('hard-350', ({stats}) => HardLevels.generate(350, stats: stats), 2771861),
    ('ultra-351', ({stats}) => UltraHardLevels.generate(351, stats: stats), 2779876),
  ];
  for (final item in cases) {
    final stats = BoardGenerationStats();
    final watch = Stopwatch()..start();
    try {
      item.$2(stats: stats);
      stdout.writeln('${item.$1} generated');
    } catch (error) {
      stdout.writeln('${item.$1} $error');
    }
    stdout.writeln('attempts=${stats.attempts} nodes=${stats.nodesExpanded} '
        'candidates=${stats.candidatesExamined} backtracks=${stats.backtracks} '
        'solver=${stats.solverInvocations} inconclusive=${stats.solverInconclusive} '
        'duplicates=${stats.duplicateRejections} constraints=${stats.constraintRejections} '
        'initial=${stats.initialChoiceRejections} dependency=${stats.dependencyRejections} '
        'forced=${stats.forcedRatioRejections} direction=${stats.directionRejections} '
        'replay=${stats.replayRejections} elapsed=${watch.elapsedMilliseconds}ms');
  }
}
