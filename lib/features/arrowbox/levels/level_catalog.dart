import '../arrowbox_logic.dart';
import 'catalog_manifest.dart';
import 'level_solver.dart';

class LevelCatalog {
  static const size = 500;
  static final Map<int, ArrowBoxLevel> _levelCache = {};
  static List<ArrowBoxLevel>? _levels;

  static List<ArrowBoxLevel> get levels => _levels ??= _build();

  static ArrowBoxLevel levelFor(int level) {
    if (level < 1 || level > size) {
      throw RangeError.range(level, 1, size, 'level');
    }
    _validateManifest();
    return _levelCache.putIfAbsent(level, () {
      final difficulty = difficultyFor(level);
      final board = _parseLayout(arrowBoxCatalogLayouts[level - 1]);
      final metrics = LevelSolver.analyze(board);
      if (metrics == null || !metrics.solvable) {
        throw StateError('Unsolvable layout in catalog for level $level');
      }
      return ArrowBoxLevel(
        board,
        difficulty: difficulty,
        difficultyScore: _score(board, metrics),
      );
    });
  }

  static ArrowBoxDifficulty difficultyFor(int level) {
    if (level <= 100) return ArrowBoxDifficulty.easy;
    if (level <= 200) return ArrowBoxDifficulty.medium;
    if (level <= 350) return ArrowBoxDifficulty.hard;
    return ArrowBoxDifficulty.ultraHard;
  }

  static List<ArrowBoxLevel> _build() => List.unmodifiable([
        for (var level = 1; level <= size; level++) levelFor(level),
      ]);

  static bool _manifestValidated = false;

  static void _validateManifest() {
    if (_manifestValidated) return;
    if (arrowBoxCatalogLayouts.length != size) {
      throw StateError('ArrowBox catalog manifest has the wrong size');
    }
    final layouts = <String>{};
    for (var index = 0; index < arrowBoxCatalogLayouts.length; index++) {
      final layout = arrowBoxCatalogLayouts[index];
      final board = _parseLayout(layout);
      if (!layouts.add(layout)) {
        throw StateError('Duplicate layout in catalog at level ${index + 1}');
      }
      final metrics = LevelSolver.analyze(board);
      if (metrics == null || !metrics.solvable) {
        throw StateError('Unsolvable layout in catalog at level ${index + 1}');
      }
    }
    _manifestValidated = true;
  }

  static List<ArrowDirection?> _parseLayout(String layout) {
    final values = layout.split(',');
    if (values.length != 25) {
      throw StateError('Invalid layout in catalog manifest');
    }
    final board = <ArrowDirection?>[];
    for (final value in values) {
      final index = int.tryParse(value);
      if (index == -1) {
        board.add(null);
      } else if (index != null && index >= 0 &&
          index < ArrowDirection.values.length) {
        board.add(ArrowDirection.values[index]);
      } else {
        throw StateError('Invalid direction in catalog manifest');
      }
    }
    return board;
  }

  static double _score(
    List<ArrowDirection?> board,
    LevelSolutionMetrics metrics,
  ) {
    final density = board.whereType<ArrowDirection>().length / 25;
    final constraint = 1 - (metrics.initialChoices / 25);
    return (density * 0.45 + constraint * 0.35 +
            (metrics.dependencyDepth / 25).clamp(0.0, 1.0) * 0.20)
        .clamp(0.0, 1.0)
        .toDouble();
  }
}
