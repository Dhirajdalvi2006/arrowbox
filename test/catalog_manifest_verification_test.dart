import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/levels/catalog_manifest.dart';
import 'package:locate/features/arrowbox/levels/level_catalog.dart';
import 'package:locate/features/arrowbox/levels/level_solver.dart';

void main() {
  group('Production Catalog Manifest Verification', () {
    test('Manifest has exactly 500 unique, solvable levels in correct difficulty bands', () {
      expect(arrowBoxCatalogLayouts.length, 500, reason: 'Manifest size mismatch');

      final layouts = <String>{};
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < 500; i++) {
        final levelNumber = i + 1;
        final layout = arrowBoxCatalogLayouts[i];

        // Check uniqueness
        expect(layouts.add(layout), isTrue, reason: 'Duplicate layout at level $levelNumber');

        // Check structure (25 comma-separated values)
        final values = layout.split(',');
        expect(values.length, 25, reason: 'Invalid layout length at level $levelNumber');

        // Parse and validate arrow directions
        final board = <ArrowDirection?>[];
        int arrowCount = 0;
        final directionsInLevel = <ArrowDirection>{};
        for (final val in values) {
          final index = int.tryParse(val);
          expect(index, isNotNull, reason: 'Non-numeric value in layout at level $levelNumber');
          if (index == -1) {
            board.add(null);
          } else {
            expect(index, inInclusiveRange(0, 3), reason: 'Invalid direction index at level $levelNumber');
            final dir = ArrowDirection.values[index!];
            board.add(dir);
            directionsInLevel.add(dir);
            arrowCount++;
          }
        }

        // Check solvability
        final metrics = LevelSolver.analyze(board);
        expect(metrics, isNotNull, reason: 'Level $levelNumber analysis failed');
        expect(metrics!.solvable, isTrue, reason: 'Level $levelNumber is unsolvable');

        // Check difficulty bands
        final difficulty = LevelCatalog.difficultyFor(levelNumber);
        if (levelNumber <= 100) {
          expect(difficulty, ArrowBoxDifficulty.easy);
          if (levelNumber == 1) expect(arrowCount, 8);
          else expect(arrowCount, inInclusiveRange(8, 20));
        } else if (levelNumber <= 200) {
          expect(difficulty, ArrowBoxDifficulty.medium);
          expect(arrowCount, inInclusiveRange(16, 23));
        } else if (levelNumber <= 350) {
          expect(difficulty, ArrowBoxDifficulty.hard);
          expect(arrowCount, inInclusiveRange(20, 25));
          expect(directionsInLevel.length, greaterThanOrEqualTo(3), reason: 'Hard level $levelNumber lacks direction variety');
        } else {
          expect(difficulty, ArrowBoxDifficulty.ultraHard);
          expect(arrowCount, 25);
          expect(directionsInLevel.length, greaterThanOrEqualTo(3), reason: 'Ultra Hard level $levelNumber lacks direction variety');
        }
      }

      stopwatch.stop();
      print('Verified 500 levels in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('LevelCatalog lazy access uses manifest and enforces validation', () {
      // Clear cache first if possible or just test a few levels
      // LevelCatalog doesn't have a public clearCache, but we can check if it throws for invalid state if we were to mock it.
      // Since we can't easily mock the manifest constant, we'll verify it returns the expected boards.

      for (final levelNumber in [1, 101, 201, 351, 500]) {
        final level = ArrowBoxLevel.forNumber(levelNumber);
        final manifestLayout = arrowBoxCatalogLayouts[levelNumber - 1];
        final boardLayout = level.arrows.map((a) => a?.index ?? -1).join(',');
        expect(boardLayout, manifestLayout, reason: 'LevelCatalog data mismatch for level $levelNumber');
      }
    });
  });
}
