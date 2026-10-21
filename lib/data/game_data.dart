import 'models.dart';

const List<GameModel> allGames = [
  GameModel(id: 'arrowbox', title: 'ArrowBox', category: 'Puzzle', description: 'Move arrows toward the board edges and clear the puzzle one move at a time.', difficulty: 'Medium', emoji: '🎯'),
  GameModel(id: 'tictactoe', title: 'Tic-Tac-Toe', category: 'Board', description: 'Classic X and O strategy game for two players.', difficulty: 'Easy', emoji: '⭕'),
  GameModel(id: 'sudoku', title: 'Sudoku', category: 'Puzzle', description: 'Fill the 9×9 grid so every row, column, and box has all digits 1–9.', difficulty: 'Hard', emoji: '🔢'),
  GameModel(id: '2048', title: '2048', category: 'Puzzle', description: 'Slide and merge tiles to reach the 2048 tile.', difficulty: 'Medium', emoji: '🧩'),
  GameModel(id: 'minesweeper', title: 'Minesweeper', category: 'Puzzle', description: 'Uncover cells without hitting mines using number clues.', difficulty: 'Hard', emoji: '💣'),
  GameModel(id: 'memorymatch', title: 'Memory Match', category: 'Brain', description: 'Flip cards and find matching pairs as fast as you can.', difficulty: 'Easy', emoji: '🃏'),
  GameModel(id: 'snake', title: 'Snake', category: 'Arcade', description: 'Guide the snake to eat food and grow without hitting walls.', difficulty: 'Medium', emoji: '🐍'),
  GameModel(id: 'chess', title: 'Chess', category: 'Board', description: 'The timeless game of strategy, tactics, and foresight.', difficulty: 'Hard', emoji: '♟️'),
  GameModel(id: 'checkers', title: 'Checkers', category: 'Board', description: 'Jump over and capture your opponent\'s pieces.', difficulty: 'Medium', emoji: '🔴'),
  GameModel(id: 'solitaire', title: 'Solitaire', category: 'Classic', description: 'Classic Klondike card game to play solo.', difficulty: 'Medium', emoji: '🂡'),
  GameModel(id: 'wordsearch', title: 'Word Search', category: 'Brain', description: 'Find hidden words in a grid of letters.', difficulty: 'Easy', emoji: '🔍'),
  GameModel(id: 'slidingpuzzle', title: 'Sliding Puzzle', category: 'Puzzle', description: 'Rearrange tiles to complete the picture.', difficulty: 'Medium', emoji: '🔲'),
  GameModel(id: 'rps', title: 'Rock Paper Scissors', category: 'Quick', description: 'Beat the computer at this classic hand game.', difficulty: 'Easy', emoji: '✊'),
  GameModel(id: 'connectfour', title: 'Connect Four', category: 'Board', description: 'Drop discs to connect four of your color in a row.', difficulty: 'Medium', emoji: '🟡'),
  GameModel(id: 'hangman', title: 'Hangman', category: 'Brain', description: 'Guess the word one letter at a time before it\'s too late.', difficulty: 'Easy', emoji: '📝'),
  GameModel(id: 'dotsboxes', title: 'Dots & Boxes', category: 'Board', description: 'Connect dots to form boxes and outscore your opponent.', difficulty: 'Easy', emoji: '📦'),
];

const List<CategoryModel> allCategories = [
  CategoryModel(id: 'puzzle', name: 'Puzzle Games', description: 'Challenge your problem-solving skills', emoji: '🧩', gameCount: 5),
  CategoryModel(id: 'board', name: 'Board Games', description: 'Classic strategy and tabletop fun', emoji: '♟️', gameCount: 5),
  CategoryModel(id: 'arcade', name: 'Arcade Games', description: 'Fast-paced action and reflexes', emoji: '🕹️', gameCount: 1),
  CategoryModel(id: 'brain', name: 'Brain Games', description: 'Train your memory and cognition', emoji: '🧠', gameCount: 3),
  CategoryModel(id: 'classic', name: 'Classic Games', description: 'Timeless games you\'ll always love', emoji: '♠️', gameCount: 1),
  CategoryModel(id: 'quick', name: 'Quick Games', description: 'Fun in under a minute', emoji: '⚡', gameCount: 1),
];

List<GameModel> getGamesByCategory(String categoryId) {
  final catName = allCategories.firstWhere((c) => c.id == categoryId, orElse: () => allCategories.first).name.split(' ').first;
  return allGames.where((g) => g.category == catName).toList();
}
