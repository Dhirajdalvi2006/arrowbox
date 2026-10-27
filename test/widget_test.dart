import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:locate/app.dart';
import 'package:locate/core/app_store.dart';
import 'package:locate/features/arrowbox/arrowbox_logic.dart';
import 'package:locate/features/arrowbox/arrowbox_screen.dart';
import 'package:locate/features/arrowbox/arrowbox_board_widgets.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'unlockedLevel': 3,
      'completedLevels': ['1', '2'],
      'gamesPlayed': 5,
      'totalMistakes': 8,
    });
  });

  testWidgets('Landing screen renders title, tagline and action buttons', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(ArrowBoxApp(store: store));
    await tester.pumpAndSettle();

    expect(find.byType(ArrowBoxTitle), findsWidgets);
    expect(find.text('Think. Aim. Escape.'), findsOneWidget);
    expect(find.text('Play Now'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
  });

  testWidgets('Level Selection screen displays the expanded catalog', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(
      home: LevelSelectionScreen(store: store),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Select Level'), findsOneWidget);
    expect(find.text('2 / ${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Levels Completed'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
  });

  testWidgets('Level difficulty filter can return to all levels', (tester) async {
    final store = await AppStore.load();
    await tester.pumpWidget(MaterialApp(
      home: LevelSelectionScreen(store: store),
    ));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Filter difficulty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ultra Hard'));
    await tester.pumpAndSettle();
    expect(find.text('201'), findsOneWidget);
    expect(find.text('Medium'), findsNothing);

    await tester.tap(find.byTooltip('Filter difficulty'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('All levels'));
    await tester.pumpAndSettle();
    expect(find.text('Medium'), findsWidgets);
  });

  test('Escape offset scales with board geometry and direction', () {
    expect(
      arrowEscapeOffset(ArrowDirection.right, 48),
      const Offset(48, 0),
    );
    expect(
      arrowEscapeOffset(ArrowDirection.up, 72),
      const Offset(0, -72),
    );
  });

  testWidgets('Gameplay screen renders Level 3 with hint and controls', (tester) async {
    final store = await AppStore.load();
    final game = ArrowBoxState.initial(level: 3);

    await tester.pumpWidget(MaterialApp(
      home: ArrowBoxScreen(store: store, initialState: game),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Level 3'), findsOneWidget);
    expect(find.text('MEDIUM'), findsOneWidget);
    expect(find.text('0 mistakes'), findsOneWidget);
    expect(find.text('Hint'), findsWidgets);
    expect(find.text('The blue arrow can escape upward.'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Restart'), findsOneWidget);
  });

  testWidgets('Settings screen renders categories and switches', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.reset());

    final store = await AppStore.load();

    await tester.pumpWidget(MaterialApp(
      home: SettingsScreen(store: store),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('GAMEPLAY'), findsOneWidget);
    expect(find.text('Haptic feedback'), findsOneWidget);
    expect(find.text('Show hints'), findsOneWidget);
    expect(find.text('AUDIO'), findsOneWidget);
    expect(find.text('APPEARANCE'), findsOneWidget);
    expect(find.text('Dark theme'), findsOneWidget);
  });

  testWidgets('Progress screen displays circular progress and 4 metric cards', (tester) async {
    final store = await AppStore.load();

    await tester.pumpWidget(MaterialApp(
      home: ProgressScreen(store: store),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('2 / ${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Total Levels'), findsOneWidget);
    expect(find.text('${AppStore.totalLevels}'), findsOneWidget);
    expect(find.text('Current Level'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Games Played'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('Total Mistakes'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
  });

  testWidgets('How to Play screen renders 4 step cards', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: HowToPlayScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('How to Play'), findsOneWidget);
    expect(find.text('Each block has a direction'), findsOneWidget);
    expect(find.text('Clear path to the edge'), findsOneWidget);
    expect(find.text('Remove the block'), findsOneWidget);
    expect(find.text('Complete the level'), findsOneWidget);
  });

  testWidgets('About screen renders version and legal rows', (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: AboutScreen(),
    ));
    await tester.pumpAndSettle();

    expect(find.text('About'), findsOneWidget);
    expect(find.text('ArrowBox'), findsOneWidget);
    expect(find.text('Think. Aim. Escape.'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);
    expect(find.text('Privacy Policy'), findsOneWidget);
    expect(find.text('Credits'), findsOneWidget);
  });
}
