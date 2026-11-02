import 'dart:convert';
import 'dart:io';

import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/arrow_board_rules.dart';
import 'package:locate/features/arrowbox/levels/hard_levels.dart';
import 'package:locate/features/arrowbox/levels/level_catalog.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';
import 'package:locate/features/arrowbox/levels/ultra_hard_levels.dart';

void main(List<String> args) async {
  final command = args.isEmpty ? 'audit' : args.first;
  final outDir = Directory('tool/audit_output');
  if (!outDir.existsSync()) outDir.createSync(recursive: true);

  if (command == 'audit') {
    await runAudit(outDir);
  } else if (command == 'generate') {
    await runGenerate(outDir);
  } else {
    print('Usage: dart run tool/audit_hard_ultra.dart [audit|generate]');
  }
}

Future<void> runAudit(Directory outDir) async {
  final report = <Map<String, dynamic>>[];
  for (var level = 201; level <= 500; level++) {
    final diff = LevelCatalog.difficultyFor(level);
    if (diff != ArrowBoxDifficulty.hard && diff != ArrowBoxDifficulty.ultraHard)
      continue;
    final lb = LevelCatalog.levelFor(level);
    final board = lb.arrows;
    final metrics = LevelSolver.analyze(board);
    final counts = List<int>.filled(4, 0);
    for (final a in board) {
      if (a != null) counts[a.index]++;
    }
    final initial = _escapeCount(board);
    final defective = _isDefective(diff, counts, metrics, initial);
    report.add({
      'level': level,
      'difficulty': diff.name,
      'counts': counts,
      'initialChoices': initial,
      'dependencyDepth': metrics?.dependencyDepth ?? 0,
      'forcedMoveRatio': metrics?.forcedMoveRatio ?? 0,
      'solvable': metrics?.solvable ?? false,
      'defective': defective,
    });
  }
  final file = File('${outDir.path}/audit_report.json');
  file.writeAsStringSync(jsonEncode(report));
  print('Audited ${report.length} levels. Report: ${file.path}');
  final defective = report.where((r) => r['defective'] == true).length;
  print('Defective: $defective');
}

Future<void> runGenerate(Directory outDir) async {
  final reportFile = File('${outDir.path}/audit_report.json');
  if (!reportFile.existsSync()) {
    print('Run audit first.');
    return;
  }
  final report = jsonDecode(reportFile.readAsStringSync()) as List;
  final candidates = <Map<String, dynamic>>[];
  for (final entry in report) {
    if (entry['defective'] != true) continue;
    final level = entry['level'] as int;
    final diff = entry['difficulty'] as String;
    List<ArrowDirection?>? board;
    try {
      if (diff == 'hard') {
        board = HardLevels.generate(level);
      } else {
        board = UltraHardLevels.generate(level);
      }
    } catch (e) {
      print('Failed level $level: $e');
      continue;
    }
    final metrics = LevelSolver.analyze(board);
    candidates.add({
      'level': level,
      'difficulty': diff,
      'board': board.map((a) => a?.index ?? -1).toList(),
      'metrics': {
        'dependencyDepth': metrics?.dependencyDepth,
        'forcedMoveRatio': metrics?.forcedMoveRatio,
        'solvable': metrics?.solvable,
      },
    });
  }
  final file = File('${outDir.path}/candidates.json');
  file.writeAsStringSync(jsonEncode(candidates));
  print('Generated ${candidates.length} candidates. File: ${file.path}');
}

bool _isDefective(
  ArrowBoxDifficulty diff,
  List<int> counts,
  LevelSolutionMetrics? m,
  int initial,
) {
  final distinct = counts.where((c) => c > 0).length;
  if (distinct < 3) return true;
  final maxProp =
      counts.reduce((a, b) => a > b ? a : b) / counts.reduce((a, b) => a + b);
  if (maxProp > 0.6) return true;
  if (m == null || !m.solvable) return true;
  if (diff == ArrowBoxDifficulty.hard && (m.dependencyDepth < 3)) return true;
  if (diff == ArrowBoxDifficulty.ultraHard && (m.dependencyDepth < 3))
    return true;
  if (m.forcedMoveRatio < 0.05) return true;
  return false;
}

int _escapeCount(List<ArrowDirection?> board) {
  var n = 0;
  for (var i = 0; i < board.length; i++) {
    if (arrowCanEscape(board, i)) n++;
  }
  return n;
}
