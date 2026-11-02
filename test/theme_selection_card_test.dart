import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/theme/app_colors.dart';
import 'package:locate/core/theme/app_theme.dart';
import 'package:locate/features/arrow_designs/models/board_theme.dart';
import 'package:locate/features/arrow_lab/arrow_lab_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Scrolls the appearance catalog until [text] is rendered and visible.
///
/// Sliver grids build their items lazily, so off-screen themes must be
/// scrolled into view before they can be located or tapped.
Future<void> scrollToText(WidgetTester tester, String text) async {
  final scrollable = find.byType(CustomScrollView).first;
  for (var i = 0; i < 40 && find.text(text).evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle();
}

/// Scrolls until a widget matching [matches] is built (i.e. scrolled into
/// the viewport of a lazy sliver grid).
Future<void> scrollUntilWidget(
  WidgetTester tester,
  bool Function(Widget) matches,
) async {
  final scrollable = find.byType(CustomScrollView).first;
  for (
    var i = 0;
    i < 40 && find.byWidgetPredicate(matches).evaluate().isEmpty;
    i++
  ) {
    await tester.drag(scrollable, const Offset(0, -500));
    await tester.pumpAndSettle();
  }
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'Theme card layout has checkmark positioned without overlapping text',
    (tester) async {
      tester.view.physicalSize = const Size(360 * 2, 800 * 2);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      SharedPreferences.setMockInitialValues({
        'boardThemeId': 'midnight',
        'completedLevels': List<String>.generate(101, (i) => i.toString()),
      });
      final store = await AppStore.load();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(body: ArrowLabScreen(store: store)),
        ),
      );
      await tester.pumpAndSettle();

      // The catalog scrolls; reveal the selected Midnight card.
      await scrollToText(tester, 'Midnight');
      await tester.pumpAndSettle();
      expect(find.text('Midnight'), findsOneWidget);

      final cardFinder = find.ancestor(
        of: find.text('Midnight'),
        matching: find.byType(AnimatedContainer),
      );
      final cardRect = tester.getRect(cardFinder.first);
      final textRect = tester.getRect(find.text('Midnight'));
      final iconFinder = find.descendant(
        of: cardFinder.first,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Icon &&
              widget.icon == Icons.check_rounded &&
              widget.size == 13.0,
        ),
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
      await scrollToText(tester, 'Deep Ocean');
      await tester.pumpAndSettle();
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

    // Scroll past the skins into the theme section. Skins and themes share
    // the 'Aurora' name, so resolve Aurora to the theme card by scrolling to
    // the themes section first (the skin 'Aurora' is then out of view).
    await scrollToText(tester, 'BOARD THEME');
    await tester.pumpAndSettle();

    // Build the selected Aurora theme card (3rd theme row).
    await scrollUntilWidget(tester, (widget) {
      if (widget is! AnimatedContainer) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      final border = decoration.border;
      if (border is! Border) return false;
      return border.top.color == AppColors.cyan;
    });

    // Skins and themes share the 'Aurora' name, so locate the selected theme
    // card via its cyan border (the skin 'Aurora' shares the name but is not
    // selected).
    final selectedCard = find.byWidgetPredicate((widget) {
      if (widget is! AnimatedContainer) return false;
      final decoration = widget.decoration;
      if (decoration is! BoxDecoration) return false;
      final border = decoration.border;
      if (border is! Border) return false;
      return border.top.color == AppColors.cyan;
    });
    expect(selectedCard, findsOneWidget);

    expect(
      find.descendant(of: selectedCard.first, matching: find.text('Aurora')),
      findsOneWidget,
    );

    final badgeFinder = find.descendant(
      of: selectedCard.first,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Container &&
            widget.decoration is BoxDecoration &&
            (widget.decoration as BoxDecoration).color == AppColors.cyan &&
            (widget.decoration as BoxDecoration).shape == BoxShape.circle,
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
