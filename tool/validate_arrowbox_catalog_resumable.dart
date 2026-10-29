import 'dart:convert';
import 'dart:io';

import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/board_generator.dart';
import 'package:locate/features/arrowbox/levels/easy_levels.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';
import 'package:locate/features/arrowbox/levels/medium_levels.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

Future<void> main(List<String> args) async {
  final options = _Options.parse(args);
  final checkpoint = File(options.checkpoint);
  final state = await _load(checkpoint);
  final rows = <Map<String, Object?>>[...state.rows];
  final layouts = <String>{...state.layouts};
  final completed = rows.map((row) => row['level']).whereType<int>().toSet();
  final stopwatch = Stopwatch()..start();

  for (var level = options.start; level <= options.end; level++) {
    if (completed.contains(level)) continue;
    final difficulty = _difficultyFor(level);
    final stats = BoardGenerationStats();
    final watch = Stopwatch()..start();
    final row = <String, Object?>{
      'level': level,
      'difficulty': difficulty.name,
      'status': 'INCONCLUSIVE',
      'elapsedMs': 0,
    };
    try {
      final board = _generate(level, layouts, stats);
      final key = _key(board);
      row['arrows'] = board.whereType<ArrowDirection>().length;
      row['duplicate'] = !layouts.add(key);
      if (row['duplicate'] == true) {
        row['status'] = 'FAIL';
        row['reason'] = 'Duplicate layout';
      } else {
        LevelSolver.clearCache();
        final diagnostics = SolverDiagnostics();
        final metrics = LevelSolver.analyze(board, diagnostics: diagnostics);
        final replayed = metrics != null && _replay(board, metrics.solution);
        final profileError = metrics == null
            ? 'Solver returned no result'
            : replayed
                ? _profileError(level, board, metrics)
                : 'Solver solution did not replay';
        row['status'] = profileError == null ? 'PASS' : 'FAIL';
        if (profileError != null) row['reason'] = profileError;
        row['solvable'] = metrics?.solvable ?? false;
        row['replayed'] = replayed;
        row['initialChoices'] = metrics?.initialChoices;
        row['dependencyDepth'] = metrics?.dependencyDepth;
        row['forcedMoveRatio'] = metrics?.forcedMoveRatio;
        row['solverStates'] = diagnostics.statesVisited;
        row['solverCacheHits'] = diagnostics.cacheHits;
        row['solverCacheMisses'] = diagnostics.cacheMisses;
        row['solverMs'] = diagnostics.elapsedMicroseconds / 1000;
      }
      row['nodes'] = stats.nodesExpanded;
      row['backtracks'] = stats.backtracks;
      row['attempts'] = stats.attempts;
      row['generationMs'] = stats.elapsedMilliseconds;
    } catch (error) {
      row['status'] = 'INCONCLUSIVE';
      row['reason'] = error.toString();
      row['nodes'] = stats.nodesExpanded;
      row['backtracks'] = stats.backtracks;
      row['attempts'] = stats.attempts;
    }
    row['elapsedMs'] = watch.elapsedMilliseconds;
    rows.add(row);
    await _save(checkpoint, rows, layouts);
    stdout.writeln(jsonEncode(row));
  }

  stopwatch.stop();
  final summary = _summary(rows, options.start, options.end, stopwatch.elapsedMilliseconds);
  await File(options.report).writeAsString(_markdown(summary));
  await File(options.csv).writeAsString(_csv(rows));
  stdout.writeln(jsonEncode(summary));
  if (summary['inconclusive'] != 0 || summary['failed'] != 0) exitCode = 2;
}

String? _profileError(int level, List<ArrowDirection?> board, LevelSolutionMetrics metrics) {
  final arrows = board.whereType<ArrowDirection>().length;
  if (metrics.solution.length != arrows) return 'Solution length mismatch';
  if (level == 1 && arrows != 8) return 'Level 1 arrow count mismatch';
  if (level >= 101 && level <= 200 && (arrows < 16 || arrows > 23)) return 'Medium density mismatch';
  if (level >= 201 && level <= 350 && (arrows < 20 || arrows > 25)) return 'Hard density mismatch';
  if (level >= 351 && arrows != 25) return 'Ultra Hard density mismatch';
  if (level >= 201 && metrics.minimumDirectionCount < 3) return 'Directional variety mismatch';
  return null;
}

List<ArrowDirection?> _generate(int level, Set<String> layouts, BoardGenerationStats stats) {
  final difficulty = _difficultyFor(level);
  return switch (difficulty) {
    ArrowBoxDifficulty.easy => EasyLevels.generate(level, excludedLayouts: layouts, stats: stats),
    ArrowBoxDifficulty.medium => MediumLevels.generate(level, excludedLayouts: layouts, stats: stats),
    ArrowBoxDifficulty.hard => HardLevels.generate(level, excludedLayouts: layouts, stats: stats),
    ArrowBoxDifficulty.ultraHard => UltraHardLevels.generate(level, excludedLayouts: layouts, stats: stats),
  };
}

ArrowBoxDifficulty _difficultyFor(int level) => level <= 100
    ? ArrowBoxDifficulty.easy
    : level <= 200
        ? ArrowBoxDifficulty.medium
        : level <= 350
            ? ArrowBoxDifficulty.hard
            : ArrowBoxDifficulty.ultraHard;

bool _replay(List<ArrowDirection?> board, List<int> solution) {
  final current = List<ArrowDirection?>.of(board);
  for (final index in solution) {
    if (!arrowCanEscape(current, index)) return false;
    current[index] = null;
  }
  return current.every((arrow) => arrow == null);
}

String _key(List<ArrowDirection?> board) => board.map((arrow) => arrow?.index ?? -1).join(',');

Future<_State> _load(File file) async {
  if (!await file.exists()) return _State([], {});
  final data = jsonDecode(await file.readAsString()) as Map<String, dynamic>;
  return _State(
    [for (final row in (data['rows'] as List<dynamic>? ?? [])) Map<String, Object?>.from(row as Map)],
    {...(data['layouts'] as List<dynamic>? ?? []).cast<String>()},
  );
}

Future<void> _save(File file, List<Map<String, Object?>> rows, Set<String> layouts) async {
  final temporary = File('${file.path}.tmp');
  await temporary.writeAsString(jsonEncode({'rows': rows, 'layouts': layouts.toList()}));
  await temporary.rename(file.path);
}

Map<String, Object> _summary(List<Map<String, Object?>> rows, int start, int end, int elapsed) => {
  'requestedStart': start,
  'requestedEnd': end,
  'checked': rows.where((row) => (row['level'] as int) >= start && (row['level'] as int) <= end).length,
  'passed': rows.where((row) => row['status'] == 'PASS').length,
  'failed': rows.where((row) => row['status'] == 'FAIL').length,
  'inconclusive': rows.where((row) => row['status'] == 'INCONCLUSIVE').length,
  'elapsedMs': elapsed,
};

String _markdown(Map<String, Object> summary) => '# ArrowBox catalog validation\n\n${summary.entries.map((entry) => '- ${entry.key}: ${entry.value}').join('\n')}\n';

String _csv(List<Map<String, Object?>> rows) {
  const headers = ['level', 'difficulty', 'status', 'reason', 'arrows', 'duplicate', 'solvable', 'replayed', 'initialChoices', 'dependencyDepth', 'forcedMoveRatio', 'generationMs', 'solverMs', 'solverStates', 'solverCacheHits', 'solverCacheMisses', 'attempts', 'nodes', 'backtracks'];
  String cell(Object? value) => '"${(value ?? '').toString().replaceAll('"', '""')}"';
  return [headers.join(','), ...rows.map((row) => headers.map((header) => cell(row[header])).join(','))].join('\n');
}

class _State {
  const _State(this.rows, this.layouts);
  final List<Map<String, Object?>> rows;
  final Set<String> layouts;
}

class _Options {
  const _Options(this.start, this.end, this.checkpoint, this.report, this.csv);
  final int start;
  final int end;
  final String checkpoint;
  final String report;
  final String csv;

  static _Options parse(List<String> args) {
    int value(String name, int fallback) => int.tryParse(_flag(args, name) ?? '') ?? fallback;
    String text(String name, String fallback) => _flag(args, name) ?? fallback;
    final start = value('start', 1);
    return _Options(start, value('end', 500), text('checkpoint', 'build/arrowbox_catalog_checkpoint.json'), text('report', 'build/arrowbox_catalog_validation.md'), text('csv', 'build/arrowbox_catalog_validation.csv'));
  }
}

String? _flag(List<String> args, String name) {
  final prefix = '--$name=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) return arg.substring(prefix.length);
  }
  return null;
}
