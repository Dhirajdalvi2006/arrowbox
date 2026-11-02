import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:locate/core/app_store.dart';
import 'package:locate/features/home/screens/home_screen.dart';
import 'package:locate/features/progress/screens/activity_history_screen.dart';
import 'package:locate/features/progress/screens/progress_screen.dart';
import 'package:locate/features/progress/widgets/achievements_section.dart';
import 'package:locate/features/progress/widgets/journey_card.dart';
import 'package:locate/features/progress/widgets/player_stats_grid.dart';
import 'package:locate/features/progress/widgets/progress_ring.dart';
import 'package:locate/features/progress/widgets/recent_activity_section.dart';
import 'package:locate/features/shell/app_shell.dart';
import 'package:locate/features/shell/floating_bottom_nav.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Progress screen: back navigation', () {
    testWidgets('back button inside AppShell switches to the Home tab', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: AppShell(store: store)));
      await tester.pumpAndSettle();

      final nav = find.byType(FloatingBottomNav);
      await tester.tap(
        find.descendant(of: nav, matching: find.byType(Icon)).at(3),
      );
      await tester.pumpAndSettle();
      expect(find.text('Progress'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Play Adventure'), findsOneWidget);
    });
  });

  group('Progress screen: journey card', () {
    testWidgets('Continue Learning button is removed and ring stays', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.byType(JourneyCard), findsOneWidget);
      expect(find.byType(ProgressRing), findsOneWidget);
      expect(find.text('YOUR JOURNEY'), findsOneWidget);
      expect(find.text('Continue Level'), findsNothing);
    });

    testWidgets('journey shows completed count and next level', (tester) async {
      final store = await AppStore.load();
      store.completedLevels = {1, 2, 3};
      store.notifyListeners();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('3 / ${AppStore.totalLevels}'), findsOneWidget);
      expect(find.text('Next Level'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('fully completed journey celebrates completion', (
      tester,
    ) async {
      final store = await AppStore.load();
      store.completedLevels = {
        for (var i = 1; i <= AppStore.totalLevels; i++) i,
      };
      store.notifyListeners();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('500 / ${AppStore.totalLevels}'), findsOneWidget);
      expect(
        find.text('Congratulations! You have mastered every level.'),
        findsOneWidget,
      );
    });

    testWidgets('progress indicator fits all required completion counts', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      final counts = <int>[0, 9, 54, 100, 499, 500];
      for (final count in counts) {
        store.completedLevels = {for (var i = 1; i <= count; i++) i};
        store.notifyListeners();
        await tester.pumpAndSettle();

        expect(
          find.text('$count / ${AppStore.totalLevels}'),
          findsOneWidget,
          reason: 'Journey label should render for $count completed levels',
        );
        expect(find.byType(ProgressRing), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Progress screen: statistics', () {
    testWidgets('levels completed and next playable level are derived', (
      tester,
    ) async {
      final store = await AppStore.load();
      store.completedLevels = {1, 2, 3, 4, 5};
      store.notifyListeners();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('5 / ${AppStore.totalLevels}'), findsOneWidget);
      expect(find.text('Next Level'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('games played and total mistakes display stored values', (
      tester,
    ) async {
      final store = await AppStore.load();
      store.gamesPlayed = 66;
      store.totalMistakes = 41;
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('Games Played'), findsOneWidget);
      expect(find.text('66'), findsOneWidget);
      expect(find.text('Total Mistakes'), findsOneWidget);
      expect(find.text('41'), findsOneWidget);
    });
  });

  group('Progress screen: recent activity', () {
    testWidgets('VIEW ALL opens the activity history screen', (tester) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('VIEW ALL'), findsOneWidget);
      await tester.ensureVisible(find.text('VIEW ALL'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('VIEW ALL'));
      await tester.pumpAndSettle();

      expect(find.byType(ActivityHistoryScreen), findsOneWidget);
    });

    testWidgets('empty activity history shows polished empty state', (
      tester,
    ) async {
      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(find.text('No recent activity'), findsOneWidget);
    });
  });

  group('Progress screen: layout', () {
    testWidgets('page scrolls to the final section without overflow', (
      tester,
    ) async {
      final store = await AppStore.load();
      store.completedLevels = {for (var i = 1; i <= 20; i++) i};
      store.notifyListeners();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      final scrollable = find.byType(SingleChildScrollView);
      expect(scrollable, findsOneWidget);
      await tester.drag(scrollable, const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('PERSONAL BESTS'), findsOneWidget);
    });

    testWidgets('fits a narrow phone viewport without overflow', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final store = await AppStore.load();
      await tester.pumpWidget(MaterialApp(home: ProgressScreen(store: store)));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(JourneyCard), findsOneWidget);
      expect(find.byType(PlayerStatsGrid), findsOneWidget);
      expect(find.byType(RecentActivitySection), findsOneWidget);
      expect(find.byType(AchievementsSection), findsOneWidget);
    });
  });
}
