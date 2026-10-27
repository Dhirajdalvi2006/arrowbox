import 'dart:math';

enum ArrowDirection {
  up,
  right,
  down,
  left;

  (int, int) get vector => switch (this) {
        ArrowDirection.up => (-1, 0),
        ArrowDirection.right => (0, 1),
        ArrowDirection.down => (1, 0),
        ArrowDirection.left => (0, -1),
      };

  String get directionText => switch (this) {
        ArrowDirection.up => 'upward',
        ArrowDirection.right => 'to the right',
        ArrowDirection.down => 'downward',
        ArrowDirection.left => 'to the left',
      };

  String get colorName => switch (this) {
        ArrowDirection.up => 'blue',
        ArrowDirection.right => 'amber',
        ArrowDirection.down => 'pink',
        ArrowDirection.left => 'mint',
      };
}

enum ArrowBoxDifficulty {
  medium,
  hard,
  ultraHard;

  String get label => switch (this) {
        ArrowBoxDifficulty.medium => 'Medium',
        ArrowBoxDifficulty.hard => 'Hard',
        ArrowBoxDifficulty.ultraHard => 'Ultra Hard',
      };
}

class ArrowBoxLevel {
  const ArrowBoxLevel(
    this.arrows, {
    this.difficulty = ArrowBoxDifficulty.medium,
    this.difficultyScore = 0,
  });

  final List<ArrowDirection?> arrows;
  final ArrowBoxDifficulty difficulty;
  final double difficultyScore;

  int get occupiedCount => arrows.whereType<ArrowDirection>().length;

  int get dependencyDepth => _solveMetrics(arrows)?.$3 ?? 0;

  double get averageBranching => _solveMetrics(arrows)?.$4 ?? 0;

  static const catalogSize = 500;
  static final List<ArrowBoxLevel> _allLevels = _generateAllLevels();
  static int get count => _allLevels.length;

  static List<ArrowBoxLevel> _generateAllLevels() {
    final list = <ArrowBoxLevel>[];

    // Level 1: Gentle onboarding (8 arrows on edges / clear paths)
    final levelOne = [
      ArrowDirection.up, null, ArrowDirection.up, null, ArrowDirection.up,
      null, null, null, null, null,
      ArrowDirection.left, null, null, null, ArrowDirection.right,
      null, null, null, null, null,
      ArrowDirection.down, null, ArrowDirection.down, null, ArrowDirection.down,
    ];
    list.add(ArrowBoxLevel(
      List.unmodifiable(levelOne),
      difficultyScore: _difficultyScore(levelOne),
    ));

    // Level 2: 10 arrows with simple dependencies
    final levelTwo = _buildGuaranteedSolvableBoard(10, 1024);
    list.add(ArrowBoxLevel(
      List.unmodifiable(levelTwo),
      difficultyScore: _difficultyScore(levelTwo),
    ));

    // Level 3: The exact board layout from the reference design
    final levelThree = [
      ArrowDirection.up, null, ArrowDirection.right, ArrowDirection.down, null,
      null, ArrowDirection.left, null, null, null,
      ArrowDirection.left, null, ArrowDirection.up, ArrowDirection.right, null,
      ArrowDirection.left, null, null, null, ArrowDirection.down,
      ArrowDirection.down, null, ArrowDirection.left, null, ArrowDirection.right,
    ];
    list.add(ArrowBoxLevel(
      List.unmodifiable(levelThree),
      difficultyScore: _difficultyScore(levelThree),
    ));

    // Preserve the original generated levels 4 to 30 byte-for-byte.
    for (var l = 4; l <= 30; l++) {
      final targetArrows = (10 + ((l - 3) * 0.55).round()).clamp(10, 25);
      final board = _buildGuaranteedSolvableBoard(targetArrows, l * 7919 + 31);
      list.add(ArrowBoxLevel(
        List.unmodifiable(board),
        difficulty: _difficultyFor(l),
        difficultyScore: _difficultyScore(board),
      ));
    }

    final layouts = <String>{
      for (final level in list) _layoutKey(level.arrows),
    };
    for (var l = 31; l <= catalogSize; l++) {
      final difficulty = _difficultyFor(l);
      List<ArrowDirection?> board;
      var attempt = 0;
      do {
        final seed = l * 7919 + 31 + attempt++;
        board = switch (difficulty) {
          ArrowBoxDifficulty.medium => _buildProfileBoard(
              10 + ((l * 7) % 5),
              seed,
            ),
          ArrowBoxDifficulty.hard || ArrowBoxDifficulty.ultraHard =>
            _buildFullBoard(difficulty, seed),
        };
        if (attempt > 1000) {
          throw StateError('Unable to generate a unique level $l');
        }
      } while (!layouts.add(_layoutKey(board)));
      list.add(ArrowBoxLevel(
        List.unmodifiable(board),
        difficulty: difficulty,
        difficultyScore: _difficultyScore(board),
      ));
    }

    return List.unmodifiable(list);
  }

  static ArrowBoxDifficulty _difficultyFor(int level) {
    if (level <= 50) return ArrowBoxDifficulty.medium;
    if (level <= 200) {
      return level % 5 == 0
          ? ArrowBoxDifficulty.hard
          : ArrowBoxDifficulty.medium;
    }
    if (level <= 400) {
      return level % 3 == 0
          ? ArrowBoxDifficulty.ultraHard
          : ArrowBoxDifficulty.hard;
    }
    return level % 5 == 0
        ? ArrowBoxDifficulty.hard
        : ArrowBoxDifficulty.ultraHard;
  }

  static String _layoutKey(List<ArrowDirection?> board) =>
      board.map((arrow) => arrow?.name ?? '-').join(',');

  static double _difficultyScore(List<ArrowDirection?> board) {
    final metrics = _solveMetrics(board);
    if (metrics == null) return 1.0;
    final (firstChoices, forcedRatio, dependencyDepth, averageBranching) = metrics;
    final density = board.whereType<ArrowDirection>().length / 25;
    final branchingPressure = 1 - ((firstChoices - 1).clamp(0, 24) / 24);
    return (density * 0.30 + forcedRatio * 0.40 +
            branchingPressure * 0.15 + (dependencyDepth / 25) * 0.10 +
            (1 - (averageBranching / 25).clamp(0.0, 1.0)) * 0.05)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static bool _canEscape(List<ArrowDirection?> board, int index) {
    final row = index ~/ 5;
    final column = index % 5;
    final (rowStep, columnStep) = board[index]!.vector;
    var nextRow = row + rowStep;
    var nextColumn = column + columnStep;
    while (nextRow >= 0 && nextRow < 5 && nextColumn >= 0 && nextColumn < 5) {
      if (board[nextRow * 5 + nextColumn] != null) return false;
      nextRow += rowStep;
      nextColumn += columnStep;
    }
    return true;
  }

  static List<ArrowDirection?> _buildProfileBoard(int arrowCount, int seed) {
    for (var attempt = 0; attempt < 1000; attempt++) {
      final board = _buildGuaranteedSolvableBoard(arrowCount, seed + attempt);
      if (board.whereType<ArrowDirection>().length == arrowCount) return board;
    }
    throw StateError('Unable to generate a board with $arrowCount arrows');
  }

  static List<ArrowDirection?> _buildFullBoard(
    ArrowBoxDifficulty difficulty,
    int seed,
  ) {
    List<ArrowDirection?>? bestBoard;
    (int, double, int, double)? bestMetrics;
    for (var attempt = 0; attempt < 1000; attempt++) {
      final rng = Random(seed + attempt);
      final remaining = <int>{...List<int>.generate(25, (index) => index)};
      final board = List<ArrowDirection?>.filled(25, null);
      var complete = true;

      while (remaining.isNotEmpty) {
        final candidates = <(int, ArrowDirection)>[];
        for (final index in remaining) {
          final row = index ~/ 5;
          final column = index % 5;
          for (final direction in ArrowDirection.values) {
            final (rowStep, columnStep) = direction.vector;
            var nextRow = row + rowStep;
            var nextColumn = column + columnStep;
            var clear = true;
            while (nextRow >= 0 && nextRow < 5 && nextColumn >= 0 && nextColumn < 5) {
              if (remaining.contains(nextRow * 5 + nextColumn)) {
                clear = false;
                break;
              }
              nextRow += rowStep;
              nextColumn += columnStep;
            }
            if (clear) candidates.add((index, direction));
          }
        }
        if (candidates.isEmpty) {
          complete = false;
          break;
        }
        final choice = candidates[rng.nextInt(candidates.length)];
        board[choice.$1] = choice.$2;
        remaining.remove(choice.$1);
      }

      final metrics = complete ? _solveMetrics(board) : null;
      if (metrics == null) continue;
      if (bestMetrics == null ||
          _profileDistance(difficulty, metrics) <
              _profileDistance(difficulty, bestMetrics)) {
        bestBoard = board;
        bestMetrics = metrics;
      }
      if (_matchesDifficultyProfile(difficulty, metrics)) return board;
    }
    if (bestBoard != null) return bestBoard;
    throw StateError('Unable to generate $difficulty board from seed $seed');
  }

  static double _profileDistance(
    ArrowBoxDifficulty difficulty,
    (int, double, int, double) metrics,
  ) {
    final (firstChoices, forcedRatio, dependencyDepth, _) = metrics;
    final target = switch (difficulty) {
      ArrowBoxDifficulty.medium => (4, 0.35, 3),
      ArrowBoxDifficulty.hard => (4, 0.30, 3),
      ArrowBoxDifficulty.ultraHard => (2, 0.70, 3),
    };
    return (firstChoices - target.$1).abs().toDouble() +
        (forcedRatio - target.$2).abs() * 10 +
        (dependencyDepth - target.$3).abs().toDouble();
  }

  static bool _matchesDifficultyProfile(
    ArrowBoxDifficulty difficulty,
    (int, double, int, double) metrics,
  ) {
    final (firstChoices, forcedRatio, _, _) = metrics;
    return switch (difficulty) {
      ArrowBoxDifficulty.medium => true,
      ArrowBoxDifficulty.hard =>
        firstChoices >= 2 && firstChoices <= 8 &&
        forcedRatio >= 0.10 && forcedRatio <= 0.85,
      ArrowBoxDifficulty.ultraHard =>
        firstChoices >= 1 && firstChoices <= 8 && forcedRatio >= 0.10 &&
        metrics.$3 >= 3,
    };
  }

  static (int, double, int, double)? _solveMetrics(List<ArrowDirection?> board) {
    final working = List<ArrowDirection?>.of(board);
    var firstChoices = 0;
    var forcedSteps = 0;
    var steps = 0;
    var branchingTotal = 0;
    var dependencyDepth = 0;
    var forcedStreak = 0;
    while (working.any((arrow) => arrow != null)) {
      final available = <int>[];
      for (var index = 0; index < working.length; index++) {
        if (working[index] != null && _canEscape(working, index)) {
          available.add(index);
        }
      }
      if (available.isEmpty) return null;
      if (steps == 0) firstChoices = available.length;
      if (available.length == 1) {
        forcedSteps++;
        forcedStreak++;
        dependencyDepth = dependencyDepth < forcedStreak
            ? forcedStreak
            : dependencyDepth;
      } else {
        forcedStreak = 0;
      }
      branchingTotal += available.length;
      working[available.first] = null;
      steps++;
    }
    return (
      firstChoices,
      steps == 0 ? 0.0 : forcedSteps / steps,
      dependencyDepth,
      steps == 0 ? 0.0 : branchingTotal / steps,
    );
  }

  static List<ArrowDirection?> _buildGuaranteedSolvableBoard(int arrowCount, int seed) {
    final rng = Random(seed);
    final board = List<ArrowDirection?>.filled(25, null);

    for (var step = 0; step < arrowCount; step++) {
      final candidates = <(int, ArrowDirection)>[];
      for (var r = 0; r < 5; r++) {
        for (var c = 0; c < 5; c++) {
          final idx = r * 5 + c;
          if (board[idx] != null) continue;

          for (final dir in ArrowDirection.values) {
            final (dr, dc) = dir.vector;
            var nr = r + dr;
            var nc = c + dc;
            var clear = true;
            while (nr >= 0 && nr < 5 && nc >= 0 && nc < 5) {
              if (board[nr * 5 + nc] != null) {
                clear = false;
                break;
              }
              nr += dr;
              nc += dc;
            }
            if (clear) {
              candidates.add((idx, dir));
            }
          }
        }
      }

      if (candidates.isEmpty) break;
      final choice = candidates[rng.nextInt(candidates.length)];
      board[choice.$1] = choice.$2;
    }
    return board;
  }

  static ArrowBoxLevel forNumber(int level) {
    if (level < 1 || level > count) {
      throw RangeError.range(level, 1, count, 'level');
    }
    return _allLevels[level - 1];
  }
}

class ArrowBoxState {
  ArrowBoxState._({
    required List<ArrowDirection?> board,
    required this.level,
    required this.lives,
    required this.mistakes,
    required this.moves,
    required this.secondsElapsed,
    required this.hintsUsed,
    required List<List<ArrowDirection?>> history,
  })  : board = List.unmodifiable(board),
        history = List.unmodifiable(
          history.map((snapshot) => List<ArrowDirection?>.unmodifiable(snapshot)),
        );

  factory ArrowBoxState.initial({int level = 1}) {
    return ArrowBoxState._(
      board: List.of(ArrowBoxLevel.forNumber(level).arrows),
      level: level,
      lives: 3,
      mistakes: 0,
      moves: 0,
      secondsElapsed: 0,
      hintsUsed: 0,
      history: const [],
    );
  }

  factory ArrowBoxState.fromJson(Map<String, dynamic> json) {
    final level = json['level'];
    final lives = json['lives'];
    final mistakes = json['mistakes'];
    final moves = json['moves'] ?? 0;
    final secondsElapsed = json['secondsElapsed'] ?? 0;
    final hintsUsed = json['hintsUsed'] ?? 0;
    final board = json['board'];
    final rawHistory = json['history'];
    if (level is! int || lives is! int || mistakes is! int ||
        moves is! int || secondsElapsed is! int || hintsUsed is! int ||
        board is! List || mistakes < 0 || moves < 0 || secondsElapsed < 0 ||
        hintsUsed < 0 || (rawHistory != null && rawHistory is! List)) {
      throw const FormatException('Invalid saved game');
    }
    List<ArrowDirection?> parseBoard(dynamic value) {
      if (value is! List) throw const FormatException('Invalid saved game');
      final arrows = <ArrowDirection?>[];
      for (final item in value) {
        if (item == null) {
          arrows.add(null);
          continue;
        }
        if (item is! String) throw const FormatException('Invalid saved game');
        final matches = ArrowDirection.values.where((direction) => direction.name == item);
        if (matches.isEmpty) throw const FormatException('Invalid saved game');
        arrows.add(matches.first);
      }
      if (arrows.length != 25) throw const FormatException('Invalid saved game');
      return arrows;
    }

    final arrows = parseBoard(board);
    final history = <List<ArrowDirection?>>[];
    if (rawHistory != null) {
      for (final snapshot in rawHistory) {
        history.add(List.unmodifiable(parseBoard(snapshot)));
      }
    }
    if (level < 1 || level > ArrowBoxLevel.count || lives < 0 || lives > 3) {
      throw const FormatException('Invalid saved game');
    }
    return ArrowBoxState._(
      board: arrows,
      level: level,
      lives: lives,
      mistakes: mistakes,
      moves: moves,
      secondsElapsed: secondsElapsed,
      hintsUsed: hintsUsed,
      history: history,
    );
  }

  Map<String, dynamic> toJson() => {
        'level': level,
        'lives': lives,
        'mistakes': mistakes,
        'moves': moves,
        'secondsElapsed': secondsElapsed,
        'hintsUsed': hintsUsed,
        'history': history
            .map((snapshot) => snapshot.map((arrow) => arrow?.name).toList())
            .toList(),
        'board': board.map((arrow) => arrow?.name).toList(),
      };

  final List<ArrowDirection?> board;
  final int level;
  final int lives;
  final int mistakes;
  final int moves;
  final int secondsElapsed;
  final int hintsUsed;
  final List<List<ArrowDirection?>> history;

  bool get isCleared => board.every((arrow) => arrow == null);
  bool get isGameOver => lives <= 0;

  ArrowBoxState restart() => ArrowBoxState.initial(level: level);

  ArrowBoxState withSeconds(int seconds) => ArrowBoxState._(
        board: board,
        level: level,
        lives: lives,
        mistakes: mistakes,
        moves: moves,
        secondsElapsed: seconds,
        hintsUsed: hintsUsed,
        history: history,
      );

  ArrowBoxState undo() {
    if (history.isEmpty) return this;
    return ArrowBoxState._(
      board: history.last,
      level: level,
      lives: lives,
      mistakes: mistakes,
      moves: (moves - 1).clamp(0, 9999),
      secondsElapsed: secondsElapsed,
      hintsUsed: hintsUsed,
      history: history.sublist(0, history.length - 1),
    );
  }

  bool canEscape(int index) {
    if (index < 0 || index >= board.length || board[index] == null) return false;
    final row = index ~/ 5;
    final column = index % 5;
    final (rowStep, columnStep) = board[index]!.vector;
    var nextRow = row + rowStep;
    var nextColumn = column + columnStep;
    while (nextRow >= 0 && nextRow < 5 && nextColumn >= 0 && nextColumn < 5) {
      if (board[nextRow * 5 + nextColumn] != null) return false;
      nextRow += rowStep;
      nextColumn += columnStep;
    }
    return true;
  }

  int? get nextEscapeIndex {
    for (var index = 0; index < board.length; index++) {
      if (canEscape(index)) return index;
    }
    return null;
  }

  ArrowBoxState useHint() {
    if (nextEscapeIndex == null) return this;
    return ArrowBoxState._(
      board: board,
      level: level,
      lives: lives,
      mistakes: mistakes,
      moves: moves,
      secondsElapsed: secondsElapsed,
      hintsUsed: hintsUsed + 1,
      history: history,
    );
  }

  String get hintMessage {
    final idx = nextEscapeIndex;
    if (idx == null) {
      return 'No clear path right now. Free a blocking arrow first.';
    }
    final arrow = board[idx]!;
    return 'The ${arrow.colorName} arrow can escape ${arrow.directionText}.';
  }

  ArrowMoveResult move(int index) {
    if (isCleared || isGameOver || index < 0 || index >= board.length) {
      return ArrowMoveResult(this, false, false);
    }
    final direction = board[index];
    if (direction == null) return ArrowMoveResult(this, false, false);

    final row = index ~/ 5;
    final column = index % 5;
    final (rowStep, columnStep) = direction.vector;
    var nextRow = row + rowStep;
    var nextColumn = column + columnStep;

    while (nextRow >= 0 && nextRow < 5 && nextColumn >= 0 && nextColumn < 5) {
      if (board[nextRow * 5 + nextColumn] != null) {
        // Blocked move - deduct life, increment mistakes
        final nextLives = (lives - 1).clamp(0, 3);
        final next = ArrowBoxState._(
          board: board,
          level: level,
          lives: nextLives,
          mistakes: mistakes + 1,
          moves: moves + 1,
          secondsElapsed: secondsElapsed,
          hintsUsed: hintsUsed,
          history: history,
        );
        return ArrowMoveResult(next, false, next.isGameOver);
      }
      nextRow += rowStep;
      nextColumn += columnStep;
    }

    // Valid escape - remove arrow from board, add to history
    final nextBoard = List<ArrowDirection?>.of(board)..[index] = null;
    final next = ArrowBoxState._(
      board: nextBoard,
      level: level,
      lives: lives,
      mistakes: mistakes,
      moves: moves + 1,
      secondsElapsed: secondsElapsed,
      hintsUsed: hintsUsed,
      history: [...history, board],
    );
    return ArrowMoveResult(next, true, next.isCleared);
  }

  ArrowBoxState? nextLevel() {
    if (level >= ArrowBoxLevel.count) return null;
    final nextNum = level + 1;
    return ArrowBoxState._(
      board: List.of(ArrowBoxLevel.forNumber(nextNum).arrows),
      level: nextNum,
      lives: 3,
      mistakes: 0,
      moves: 0,
      secondsElapsed: 0,
      hintsUsed: 0,
      history: const [],
    );
  }
}

class ArrowMoveResult {
  const ArrowMoveResult(this.state, this.wasValid, this.reachedEndState);

  final ArrowBoxState state;
  final bool wasValid;
  final bool reachedEndState;
}
