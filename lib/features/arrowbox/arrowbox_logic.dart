import 'levels/arrow_board_rules.dart';
import 'levels/level_catalog.dart';
import 'levels/level_solver.dart';

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
  easy,
  medium,
  hard,
  ultraHard;

  String get label => switch (this) {
        ArrowBoxDifficulty.easy => 'Easy',
        ArrowBoxDifficulty.medium => 'Medium',
        ArrowBoxDifficulty.hard => 'Hard',
        ArrowBoxDifficulty.ultraHard => 'Ultra Hard',
      };
}

class ArrowBoxLevel {
  const ArrowBoxLevel(
    this.arrows, {
    required this.difficulty,
    required this.difficultyScore,
  });

  final List<ArrowDirection?> arrows;
  final ArrowBoxDifficulty difficulty;
  final double difficultyScore;

  int get occupiedCount => arrows.whereType<ArrowDirection>().length;
  int get dependencyDepth => LevelSolver.analyze(arrows)?.dependencyDepth ?? 0;

  static const catalogSize = LevelCatalog.size;
  static int get count => catalogSize;

  static ArrowBoxLevel forNumber(int level) {
    if (level < 1 || level > count) {
      throw RangeError.range(level, 1, count, 'level');
    }
    return LevelCatalog.levels[level - 1];
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
        } else if (item is String) {
          final matches = ArrowDirection.values.where((d) => d.name == item);
          if (matches.isEmpty) throw const FormatException('Invalid saved game');
          arrows.add(matches.first);
        } else {
          throw const FormatException('Invalid saved game');
        }
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

  bool canEscape(int index) => arrowCanEscape(board, index);

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
    if (idx == null) return 'No clear path right now. Free a blocking arrow first.';
    final arrow = board[idx]!;
    return 'The ${arrow.colorName} arrow can escape ${arrow.directionText}.';
  }

  ArrowMoveResult move(int index) {
    if (isCleared || isGameOver || index < 0 || index >= board.length) {
      return ArrowMoveResult(this, false, false);
    }
    final direction = board[index];
    if (direction == null) return ArrowMoveResult(this, false, false);
    if (!canEscape(index)) {
      final next = ArrowBoxState._(
        board: board,
        level: level,
        lives: (lives - 1).clamp(0, 3),
        mistakes: mistakes + 1,
        moves: moves + 1,
        secondsElapsed: secondsElapsed,
        hintsUsed: hintsUsed,
        history: history,
      );
      return ArrowMoveResult(next, false, next.isGameOver);
    }
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
