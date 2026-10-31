import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';
import 'package:locate/features/auth/login_profile_button.dart';
import 'package:locate/features/shell/app_shell.dart';
import 'package:locate/features/shell/floating_bottom_nav.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Home Screen Layout Architecture', () {
    testWidgets('Header is fixed outside SingleChildScrollView', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen(store: store)));
      await tester.pumpAndSettle();

      // Verify SafeArea has Column with Header and Expanded
      final safeAreaFinder = find.byType(SafeArea);
      expect(safeAreaFinder, findsOneWidget);

      final columnFinder = find.descendant(
        of: safeAreaFinder,
        matching: find.byType(Column),
      );
      expect(columnFinder, findsWidgets);

      // Verify Header widgets exist
      expect(find.byType(ArrowBoxLogoMark), findsWidgets);
      expect(find.byType(ArrowBoxTitle), findsWidgets);
      expect(find.byTooltip('Toggle Theme'), findsOneWidget);
      expect(find.byType(LoginProfileButton), findsOneWidget);

      // Verify the header is NOT inside the SingleChildScrollView
      final scrollFinder = find.byType(SingleChildScrollView);
      expect(scrollFinder, findsOneWidget);

      expect(
        find.descendant(
          of: scrollFinder,
          matching: find.byTooltip('Toggle Theme'),
        ),
        findsNothing,
        reason: 'Theme toggle must remain outside scroll view in fixed header',
      );
      expect(
        find.descendant(
          of: scrollFinder,
          matching: find.byType(LoginProfileButton),
        ),
        findsNothing,
        reason: 'LoginProfileButton must remain outside scroll view in fixed header',
      );

      // Verify content is inside SingleChildScrollView
      expect(
        find.descendant(
          of: scrollFinder,
          matching: find.byType(ArrowBoxHeroArtwork),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: scrollFinder,
          matching: find.text('Play Adventure'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: scrollFinder, matching: find.text('Arrow Lab')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: scrollFinder, matching: find.text('How to Play')),
        findsOneWidget,
      );
    });

    testWidgets('Header stays fixed when content scrolls down', (tester) async {
      tester.view.physicalSize = const Size(720, 1280); // Small device
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen(store: store)));
      await tester.pumpAndSettle();

      final initialHeaderTop = tester
          .getTopLeft(find.byTooltip('Toggle Theme'))
          .dy;

      // Scroll down by 300 pixels
      final scrollFinder = find.byType(SingleChildScrollView);
      await tester.drag(scrollFinder, const Offset(0, -300));
      await tester.pumpAndSettle();

      final afterScrollHeaderTop = tester
          .getTopLeft(find.byTooltip('Toggle Theme'))
          .dy;
      expect(
        afterScrollHeaderTop,
        equals(initialHeaderTop),
        reason: 'Header must remain at exactly the same vertical position after scroll',
      );
    });

    testWidgets('Header elements alignment (logo left, controls right)', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: WelcomeScreen(store: store)));
      await tester.pumpAndSettle();

      final logoRect = tester.getRect(find.byType(ArrowBoxLogoMark).first);
      final themeBtnRect = tester.getRect(find.byTooltip('Toggle Theme'));
      final loginBtnRect = tester.getRect(find.byType(LoginProfileButton));

      expect(logoRect.left, lessThan(themeBtnRect.left));
      expect(themeBtnRect.left, lessThan(loginBtnRect.left));
    });

    testWidgets('Renders properly on small phone (360x640) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(720, 1280); // 360x640 dp
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.reset());

      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: AppShell(store: store)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(FloatingBottomNav), findsOneWidget);

      // Scroll to bottom
      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -600),
      );
      await tester.pumpAndSettle();

      // Verify player progress card is visible at the bottom
      expect(find.text('Player Mastery Progress'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Renders properly on large phone (430x932) without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1290, 2796); // 430x932 dp
      tester.view.devicePixelRatio = 3.0;
      addTearDown(() => tester.view.reset());

      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: AppShell(store: store)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Play Adventure'), findsOneWidget);
    });

    testWidgets(
      'Bottom navigation remains visible while Home scrolls above it',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600); // 400x800 dp
        tester.view.devicePixelRatio = 2.0;
        addTearDown(() => tester.view.reset());

        final store = await AppStore.load();
        await tester.pumpWidget(MaterialApp(home: AppShell(store: store)));
        await tester.pumpAndSettle();

        final navFinder = find.byType(FloatingBottomNav);
        expect(navFinder, findsOneWidget);
        final navInitialTop = tester.getTopLeft(navFinder).dy;

        // Scroll content
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -200),
        );
        await tester.pumpAndSettle();

        // FloatingBottomNav position must be unchanged
        expect(tester.getTopLeft(navFinder).dy, equals(navInitialTop));
      },
    );

    testWidgets('Works correctly in both Light and Dark themes', (
      tester,
    ) async {
      final store = await AppStore.load();

      // Light theme
      await store.setThemeMode(ThemeMode.light);
      await tester.pumpWidget(ArrowBoxApp(store: store));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Toggle to dark theme via header button
      await tester.tap(find.byTooltip('Toggle Theme'));
      await tester.pumpAndSettle();
      expect(store.themeMode, ThemeMode.dark);
      expect(tester.takeException(), isNull);
    });
  });
}
