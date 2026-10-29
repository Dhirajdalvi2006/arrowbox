import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/levels/board_generator.dart';

import '../tool/catalog_checkpoint.dart';

void main() {
  test('invalid configuration is distinct from budget exhaustion', () {
    final invalid = generateSolvableBoardOutcome(
      arrowCount: 0,
      seed: 1,
      minimumInitialChoices: 1,
      maximumInitialChoices: 1,
      minimumDependencyDepth: 0,
      maxAttempts: 1,
      maxNodesPerAttempt: 1,
    );
    expect(invalid.status, BoardGenerationStatus.invalidConfiguration);

    final exhausted = generateSolvableBoardOutcome(
      arrowCount: 8,
      seed: 7929,
      minimumInitialChoices: 2,
      maximumInitialChoices: 12,
      minimumDependencyDepth: 0,
      maxAttempts: 1,
      maxNodesPerAttempt: 1,
    );
    expect(exhausted.status, BoardGenerationStatus.budgetExhausted);
    expect(exhausted.status, isNot(BoardGenerationStatus.unsolvable));
  });

  test('checkpoint round trips and rejects incompatible data', () {
    final file = File('tool/test_outcome_checkpoint.json');
    addTearDown(() {
      for (final path in [file.path, '${file.path}.tmp', '${file.path}.bak']) {
        final candidate = File(path);
        if (candidate.existsSync()) candidate.deleteSync();
      }
    });
    final checkpoint = CatalogCheckpoint.empty(
      configuration: 'schema=1;start=1;end=2',
      start: 1,
      end: 2,
    );
    checkpoint.results[1] = {'status': 'BUDGET_EXHAUSTED'};
    checkpoint.save(file);

    final restored = CatalogCheckpoint.fromJson(
      jsonDecode(file.readAsStringSync()) as Map<String, dynamic>,
    );
    expect(restored.results[1]!['status'], 'BUDGET_EXHAUSTED');
    expect(
      () => CatalogCheckpoint.fromJson({
        'schemaVersion': 999,
        'configuration': 'wrong',
        'start': 1,
        'end': 2,
        'results': {},
      }),
      throwsFormatException,
    );
  });

  test('recovery restores a checkpoint after an interrupted replacement', () {
    final file = File('tool/test_recovery_checkpoint.json');
    final backup = File('${file.path}.bak');
    addTearDown(() {
      for (final path in [file.path, '${file.path}.tmp', backup.path]) {
        final candidate = File(path);
        if (candidate.existsSync()) candidate.deleteSync();
      }
    });
    final checkpoint = CatalogCheckpoint.empty(
      configuration: 'schema=1;start=1;end=1',
      start: 1,
      end: 1,
    );
    checkpoint.results[1] = {'status': 'SUCCESS'};
    backup.writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(checkpoint.toJson()),
    );

    CatalogCheckpoint.recover(file);

    expect(file.existsSync(), isTrue);
    expect(CatalogCheckpoint.read(file).results[1]!['status'], 'SUCCESS');
    expect(backup.existsSync(), isFalse);
  });

  test('recovery discards malformed temporary checkpoints', () {
    final file = File('tool/test_malformed_checkpoint.json');
    final temporary = File('${file.path}.tmp');
    addTearDown(() {
      for (final path in [file.path, temporary.path, '${file.path}.bak']) {
        final candidate = File(path);
        if (candidate.existsSync()) candidate.deleteSync();
      }
    });
    temporary.writeAsStringSync('{not-json');

    CatalogCheckpoint.recover(file);

    expect(file.existsSync(), isFalse);
    expect(temporary.existsSync(), isFalse);
  });
}
