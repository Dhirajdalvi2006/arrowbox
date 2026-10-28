import 'dart:io';
import 'dart:math';

import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/easy_levels.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

void main() {
  final stopwatch = Stopwatch()..start();
  final rows = <String>[];
  final layouts = <String, int>{};
  final bands = <ArrowBoxDifficulty, _BandStats>{
    ArrowBoxDifficulty.easy: _BandStats(100),
    ArrowBoxDifficulty.medium: _BandStats(100),
    ArrowBoxDifficulty.hard: _BandStats(150),
    ArrowBoxDifficulty.ultraHard: _BandStats(150),
  };
  var invalid = 0;
  var duplicates = 0;
  var determinismFailures = 0;
  var determinismChecks = 0;
  var inconclusive = 0;

  for (var levelNumber = 1; levelNumber <= ArrowBoxLevel.count; levelNumber++) {
    final expectedDifficulty = _difficultyFor(levelNumber);
    _BandStats? stats = bands[expectedDifficulty];
    final errors = <String>[];
    var board = <ArrowDirection?>[];
    LevelSolutionMetrics? metrics;
    var replayed = false;

    try {
      board = _generate(expectedDifficulty, levelNumber);
      final generatedBoard = board;
      metrics = LevelSolver.analyze(generatedBoard);
      stats!.generated++;
      stats.arrows.add(generatedBoard.whereType<ArrowDirection>().length);
      if (generatedBoard.length != 25) {
        errors.add('board length ${generatedBoard.length}');
      }
      final key = _key(generatedBoard);
      if (layouts.containsKey(key)) {
        duplicates++;
        errors.add('duplicate of level ${layouts[key]}');
      } else {
        layouts[key] = levelNumber;
      }
      if (metrics == null) {
        inconclusive++;
        stats.inconclusive++;
        errors.add('solver returned no metrics');
      } else {
        if (!metrics.solvable) {
          stats.unsolvable++;
          errors.add('solver marked unsolvable');
        } else {
          stats.solvable++;
          replayed = _replay(board, metrics.solution);
          if (!replayed) errors.add('solution replay did not clear board');
        }
        stats.depths.add(metrics.dependencyDepth);
        stats.initialChoices.add(metrics.initialChoices);
        stats.forcedRatios.add(metrics.forcedMoveRatio);
        stats.directionMinimums.add(metrics.minimumDirectionCount);
        _checkProfile(levelNumber, expectedDifficulty, board, metrics, errors);
      }
      if (expectedDifficulty == ArrowBoxDifficulty.easy &&
          levelNumber == 1 &&
          board.whereType<ArrowDirection>().length != 8) {
        errors.add('level 1 must contain 8 arrows');
      }
      if (expectedDifficulty == ArrowBoxDifficulty.ultraHard &&
          board.whereType<ArrowDirection>().length != 25) {
        errors.add('Ultra Hard must contain 25 arrows');
      }
      if ((expectedDifficulty == ArrowBoxDifficulty.hard ||
              expectedDifficulty == ArrowBoxDifficulty.ultraHard) &&
          (metrics == null || metrics.minimumDirectionCount < 3)) {
        errors.add('direction minimum below 3');
      }
      if (metrics != null && _shouldCheckDeterminism(levelNumber)) {
        determinismChecks++;
        final second = _generate(expectedDifficulty, levelNumber);
        if (_key(second) != key) determinismFailures++;
      }
    } catch (error) {
      invalid++;
      stats!.invalid++;
      errors.add('exception: $error');
    }

    final arrowCount = board.whereType<ArrowDirection>().length;
    final counts = metrics?.directionCounts.join('/') ?? '';
    rows.add(
      [
        levelNumber,
        expectedDifficulty.name,
        arrowCount,
        counts,
        metrics?.initialChoices ?? '',
        metrics?.dependencyDepth ?? '',
        metrics?.forcedMoveRatio.toStringAsFixed(4) ?? '',
        metrics?.solvable == true
            ? 'solvable'
            : metrics == null
            ? 'inconclusive'
            : 'unsolvable',
        replayed,
        errors.join(' | '),
      ].map(_csv).join(','),
    );
  }

  stopwatch.stop();
  final report = _report(
    bands: bands,
    rows: rows,
    duplicates: duplicates,
    determinismChecks: determinismChecks,
    determinismFailures: determinismFailures,
    invalid: invalid,
    inconclusive: inconclusive,
    elapsed: stopwatch.elapsed,
    catalogSize: ArrowBoxLevel.count,
  );
  final reportFile = File('docs/arrowbox_level_validation_report.md');
  reportFile.writeAsStringSync(report);
  File('docs/arrowbox_level_validation.csv').writeAsStringSync(
    [
      'level,difficulty,arrows,up/right/down/left,initialChoices,dependencyDepth,forcedMoveRatio,solverStatus,replayCleared,errors',
      ...rows,
    ].join('\n'),
  );
  stdout.write(report);
  if (invalid > 0 ||
      duplicates > 0 ||
      determinismFailures > 0 ||
      inconclusive > 0) {
    exitCode = 2;
  }
}

List<ArrowDirection?> _generate(ArrowBoxDifficulty difficulty, int level) {
  return switch (difficulty) {
    ArrowBoxDifficulty.easy => EasyLevels.generate(level),
    ArrowBoxDifficulty.medium => MediumLevels.generate(level),
    ArrowBoxDifficulty.hard => HardLevels.generate(level),
    ArrowBoxDifficulty.ultraHard => UltraHardLevels.generate(level),
  };
}

ArrowBoxDifficulty _difficultyFor(int level) {
  if (level <= 100) return ArrowBoxDifficulty.easy;
  if (level <= 200) return ArrowBoxDifficulty.medium;
  if (level <= 350) return ArrowBoxDifficulty.hard;
  return ArrowBoxDifficulty.ultraHard;
}

bool _replay(List<ArrowDirection?> board, List<int> solution) {
  final current = List<ArrowDirection?>.of(board);
  for (final index in solution) {
    if (!arrowCanEscape(current, index)) return false;
    current[index] = null;
  }
  return current.every((arrow) => arrow == null);
}

void _checkProfile(
  int level,
  ArrowBoxDifficulty difficulty,
  List<ArrowDirection?> board,
  LevelSolutionMetrics metrics,
  List<String> errors,
) {
  final arrows = board.whereType<ArrowDirection>().length;
  switch (difficulty) {
    case ArrowBoxDifficulty.easy:
      if (level != 1 && (arrows < 8 || arrows > 20)) {
        errors.add('Easy arrow count $arrows outside 8..20');
      }
    case ArrowBoxDifficulty.medium:
      if (arrows < 16 || arrows > 23) {
        errors.add('Medium arrow count $arrows outside 16..23');
      }
    case ArrowBoxDifficulty.hard:
      if (arrows < 20 || arrows > 25) {
        errors.add('Hard arrow count $arrows outside 20..25');
      }
    case ArrowBoxDifficulty.ultraHard:
      if (arrows != 25) {
        errors.add('Ultra Hard arrow count $arrows, expected 25');
      }
  }
  if (metrics.solution.length != arrows) {
    errors.add('solution length ${metrics.solution.length} != arrows $arrows');
  }
}

String _report({
  required Map<ArrowBoxDifficulty, _BandStats> bands,
  required List<String> rows,
  required int duplicates,
  required int determinismChecks,
  required int determinismFailures,
  required int invalid,
  required int inconclusive,
  required Duration elapsed,
  required int catalogSize,
}) {
  final buffer = StringBuffer()
    ..writeln('# ArrowBox Level Validation Report')
    ..writeln()
    ..writeln('Generated: ${DateTime.now().toIso8601String()}')
    ..writeln()
    ..writeln('## Result')
    ..writeln()
    ..writeln('- Catalog levels requested: $catalogSize')
    ..writeln('- Layouts checked: ${rows.length}')
    ..writeln('- Duplicate layouts: $duplicates')
    ..writeln('- Invalid or generation failures: $invalid')
    ..writeln('- Inconclusive solver results: $inconclusive')
    ..writeln('- Determinism checks: $determinismChecks')
    ..writeln('- Determinism failures: $determinismFailures')
    ..writeln('- Validation runtime: ${elapsed.inMilliseconds} ms')
    ..writeln()
    ..writeln('## Band statistics')
    ..writeln()
    ..writeln(
      '| Band | Expected | Generated | Solvable | Unsolvable | Inconclusive | Invalid | Arrows min/avg/median/max | Dependency avg/max | Initial choices avg | Forced ratio avg | Direction minimum min |',
    )
    ..writeln('|---|---:|---:|---:|---:|---:|---:|---|---:|---:|---:|---:|');
  for (final difficulty in ArrowBoxDifficulty.values) {
    final stats = bands[difficulty]!;
    buffer.writeln(
      '| ${difficulty.label} | ${stats.expected} | ${stats.generated} | ${stats.solvable} | ${stats.unsolvable} | ${stats.inconclusive} | ${stats.invalid} | ${stats.arrowSummary} | ${stats.depthAverage.toStringAsFixed(2)}/${stats.depthMax} | ${stats.initialAverage.toStringAsFixed(2)} | ${stats.forcedAverage.toStringAsFixed(3)} | ${stats.directionMinimumMin} |',
    );
  }
  buffer
    ..writeln()
    ..writeln('## Method')
    ..writeln()
    ..writeln(
      'The validator imports the production catalog, escape rules, and LevelSolver. Each solver-provided solution is replayed against the production `arrowCanEscape` rule and must clear the board. Solver failures are reported as inconclusive rather than treated as unsolvable.',
    )
    ..writeln()
    ..writeln(
      'The CSV companion contains one row per level, including errors and measured metrics.',
    );
  return buffer.toString();
}

bool _shouldCheckDeterminism(int level) {
  return level == 1 ||
      level == 100 ||
      level == 101 ||
      level == 200 ||
      level == 201 ||
      level == 350 ||
      level == 351 ||
      level == 500;
}

String _key(List<ArrowDirection?> board) =>
    board.map((arrow) => arrow?.index ?? -1).join(',');
String _csv(Object value) => '"${value.toString().replaceAll('"', '""')}"';

class _BandStats {
  _BandStats(this.expected);

  final int expected;
  int generated = 0;
  int solvable = 0;
  int unsolvable = 0;
  int inconclusive = 0;
  int invalid = 0;
  final arrows = <int>[];
  final depths = <int>[];
  final initialChoices = <int>[];
  final forcedRatios = <double>[];
  final directionMinimums = <int>[];

  String get arrowSummary => arrows.isEmpty
      ? 'n/a'
      : '${arrows.reduce(min)}/${_average(arrows).toStringAsFixed(2)}/${_median(arrows)}/${arrows.reduce(max)}';
  double get depthAverage => _average(depths);
  int get depthMax => depths.isEmpty ? 0 : depths.reduce(max);
  double get initialAverage => _average(initialChoices);
  double get forcedAverage => _average(forcedRatios);
  int get directionMinimumMin =>
      directionMinimums.isEmpty ? 0 : directionMinimums.reduce(min);
}

double _average(List<num> values) =>
    values.isEmpty ? 0 : values.reduce((a, b) => a + b) / values.length;
num _median(List<int> values) {
  final sorted = [...values]..sort();
  return sorted[sorted.length ~/ 2];
}
