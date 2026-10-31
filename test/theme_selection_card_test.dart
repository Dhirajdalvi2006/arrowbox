import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/theme/app_colors.dart';
import 'package:locate/core/theme/app_theme.dart';
import 'package:locate/features/arrow_designs/models/board_theme.dart';
import 'package:locate/features/arrow_lab/arrow_lab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Theme card layout has checkmark positioned without overlapping text',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      SharedPreferences.setMockInitialValues({'boardThemeId': 'midnight'});
      final store = await AppStore.load();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: ArrowLabScreen(store: store)),
        ),
      );
      await tester.pumpAndSettle();

      final cardFinder = find.ancestor(
        of: find.text('Midnight'),
        matching: find.byType(AnimatedContainer),
      );
      final cardRect = tester.getRect(cardFinder.first);
      final textRect = tester.getRect(find.text('Midnight'));
      final iconFinder = find.descendant(
        of: cardFinder.first,
        matching: find.byIcon(Icons.check_rounded),
      );
      expect(iconFinder, findsOneWidget);
      final iconRect = tester.getRect(iconFinder);

      // Verify badge is inside top-right corner of card bounds with safe insets
      expect(iconRect.top, greaterThanOrEqualTo(cardRect.top));
      expect(iconRect.right, lessThanOrEqualTo(cardRect.right));
      expect(iconRect.left, greaterThan(textRect.right));

      // Verify no overlap between text and check icon
      final overlapsX =
          !(textRect.right <= iconRect.left || textRect.left >= iconRect.right);
      final overlapsY =
          !(textRect.bottom <= iconRect.top || textRect.top >= iconRect.bottom);
      expect(overlapsX && overlapsY, isFalse);

      // Check AnimatedScale of unselected theme (e.g. Deep Ocean)
      final deepOceanFinder = find.ancestor(
        of: find.text('Deep Ocean'),
        matching: find.byType(AnimatedContainer),
      );
      final deepOceanScaleFinder = find.descendant(
        of: deepOceanFinder.first,
        matching: find.byType(AnimatedScale),
      );
      final deepOceanScale = tester.widget<AnimatedScale>(deepOceanScaleFinder);
      expect(deepOceanScale.scale, 0.0);

      // Scroll Deep Ocean into view before tapping
      await tester.ensureVisible(find.text('Deep Ocean'));
      await tester.pumpAndSettle();

      // Tap Deep Ocean to select it
      await tester.tap(find.text('Deep Ocean'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 250));

      expect(store.boardThemeId, BoardThemeId.deepOcean);

      final updatedDeepOceanScale = tester.widget<AnimatedScale>(
        find.descendant(
          of: deepOceanFinder.first,
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(updatedDeepOceanScale.scale, 1.0);

      final updatedMidnightScale = tester.widget<AnimatedScale>(
        find.descendant(
          of: cardFinder.first,
          matching: find.byType(AnimatedScale),
        ),
      );
      expect(updatedMidnightScale.scale, 0.0);
    },
  );

  testWidgets('Theme card checkmark badge renders cleanly in light theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400 * 2, 800 * 2);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() => tester.view.reset());

    SharedPreferences.setMockInitialValues({'boardThemeId': 'aurora'});
    final store = await AppStore.load();

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: ArrowLabScreen(store: store)),
      ),
    );
    await tester.pumpAndSettle();

    final auroraFinder = find.ancestor(
      of: find.text('Aurora'),
      matching: find.byType(AnimatedContainer),
    );
    expect(auroraFinder, findsOneWidget);

    final badgeFinder = find.descendant(
      of: auroraFinder.first,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == AppColors.cyan,
      ),
    );
    expect(badgeFinder, findsOneWidget);

    final iconFinder = find.descendant(
      of: badgeFinder,
      matching: find.byIcon(Icons.check_rounded),
    );
    expect(iconFinder, findsOneWidget);
    final iconWidget = tester.widget<Icon>(iconFinder);
    expect(iconWidget.color, Colors.white);
    expect(iconWidget.size, 13);
  });
}
