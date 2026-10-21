class GameModel {
  final String id;
  final String title;
  final String category;
  final String description;
  final String difficulty;
  final String emoji;

  const GameModel({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.difficulty,
    required this.emoji,
  });
}

class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int gameCount;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.gameCount,
  });
}
