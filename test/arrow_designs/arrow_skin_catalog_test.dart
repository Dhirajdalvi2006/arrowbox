import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';

void main() {
  test('registry contains eleven unique styles in reference order', () {
    expect(ArrowSkinRegistry.all, hasLength(11));
    expect(ArrowSkinRegistry.all.map((skin) => skin.id).toSet(), hasLength(11));
    expect(ArrowSkinRegistry.all.map((skin) => skin.id), ArrowSkinId.values);
  });

  testWidgets('every skin renders all directions at small and large sizes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Wrap(
          children: [
            for (final skin in ArrowSkinRegistry.all)
              for (final direction in ArrowDirection.values) ...[
                skin.buildArrow(direction: direction, size: 12),
                skin.buildArrow(
                  direction: direction,
                  size: 76,
                  highlighted: true,
                ),
              ],
          ],
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('all preview boards build with the same deterministic layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SingleChildScrollView(
          child: Column(
            children: [
              for (final skin in ArrowSkinRegistry.all)
                ArrowSkinPreviewBoard(skin: skin, size: 180),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.byType(ArrowSkinPreviewBoard), findsNWidgets(8));
    expect(tester.takeException(), isNull);
  });

  test('registry lookup returns each requested skin', () {
    for (final id in ArrowSkinId.values) {
      expect(ArrowSkinRegistry.byId(id).id, id);
    }
  });
}
