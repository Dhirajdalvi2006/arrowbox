import 'dart:io';
import 'package:locate/features/arrowbox/levels/board_generator.dart';
import 'package:locate/features/arrowbox/levels/easy_levels.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

void main() {
  final probes = <(String, List<dynamic> Function(int, BoardGenerationStats), List<int>)>[
    ('easy', (level, stats) => EasyLevels.generate(level, stats: stats), [1, 50, 100]),
    ('medium', (level, stats) => MediumLevels.generate(level, stats: stats), [101, 150, 200]),
    ('hard', (level, stats) => HardLevels.generate(level, stats: stats), [201, 275, 350]),
    ('ultra', (level, stats) => UltraHardLevels.generate(level, stats: stats), [351, 425, 500]),
  ];
  for (final probe in probes) {
    for (final level in probe.$3) {
      final watch = Stopwatch()..start();
      final stats = BoardGenerationStats();
      try {
        final board = probe.$2(level, stats);
        stdout.writeln(
          '${probe.$1} $level arrows=${board.where((a) => a != null).length} '
          'ms=${watch.elapsedMilliseconds} attempts=${stats.attempts} '
          'nodes=${stats.nodesExpanded} backtracks=${stats.backtracks} '
          'initialRejects=${stats.initialChoiceRejections} '
          'candidates=${stats.candidatesExamined} solvers=${stats.solverInvocations} '
          'duplicates=${stats.duplicateRejections} constraints=${stats.constraintRejections} '
          'replay=${stats.replayRejections} inconclusive=${stats.solverInconclusive} '
          'dependency=${stats.dependencyRejections} forced=${stats.forcedRatioRejections} '
          'direction=${stats.directionRejections} depth=${stats.maxDepth}',
        );
      } catch (error) {
        stdout.writeln(
          '${probe.$1} $level ERROR $error ms=${watch.elapsedMilliseconds} '
          'attempts=${stats.attempts} nodes=${stats.nodesExpanded} '
          'backtracks=${stats.backtracks} candidates=${stats.candidatesExamined} '
          'solvers=${stats.solverInvocations} initialRejects=${stats.initialChoiceRejections} '
          'constraints=${stats.constraintRejections} inconclusive=${stats.solverInconclusive} '
          'replay=${stats.replayRejections} dependency=${stats.dependencyRejections} '
          'forced=${stats.forcedRatioRejections} direction=${stats.directionRejections}',
        );
      }
    }
  }
}
