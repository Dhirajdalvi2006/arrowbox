import '../arrowbox_logic.dart';

bool arrowCanEscape(List<ArrowDirection?> board, int index) {
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
