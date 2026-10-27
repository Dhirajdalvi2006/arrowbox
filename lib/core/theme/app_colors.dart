import 'package:flutter/material.dart';

class AppColors {
  // Reference Dark Palette (Default)
  static const darkBackground = Color(0xFF020810);
  static const darkSecondaryBackground = Color(0xFF051020);
  static const darkCard = Color(0xFF0A1628);
  static const darkSurfaceElevated = Color(0xFF0E1E35);
  static const darkTextPrimary = Color(0xFFF4F7FF);
  static const darkTextSecondary = Color(0xFFA8B9D5);
  static const darkTextMuted = Color(0xFF5D7196);
  static const darkBorder = Color(0xFF122540);
  static const darkBorderSubtle = Color(0x22358BFF);

  // Reference Light Palette
  static const lightBackground = Color(0xFFF4F7FC);
  static const lightSecondaryBackground = Color(0xFFEAF0F8);
  static const lightCardWhite = Color(0xFFFFFFFF);
  static const lightSurfaceSecondary = Color(0xFFF0F4FA);
  static const lightTextPrimary = Color(0xFF152238);
  static const lightTextSecondary = Color(0xFF52647D);
  static const lightTextMuted = Color(0xFF718198);
  static const lightBorder = Color(0xFFD8E1EE);

  // Default aliases
  static const background = darkBackground;
  static const cardWhite = darkCard;
  static const textPrimary = darkTextPrimary;
  static const textSecondary = darkTextSecondary;
  static const border = darkBorder;

  // Accents
  static const primary = Color(0xFF247BFF);
  static const primaryBright = Color(0xFF358BFF);
  static const primaryLight = Color(0xFFE6F0FF);
  static const primaryDark = Color(0xFF105CD6);
  static const cyan = Color(0xFF21D4FD);

  // Status
  static const success = Color(0xFF21D98B);
  static const warning = Color(0xFFFFB547);
  static const error = Color(0xFFFF4D6D);
  static const starGold = Color(0xFFFFC107);

  // Board
  static const boardDark = Color(0xFF040C18);
  static const boardCell = Color(0xFF081426);
  static const boardCellBorder = Color(0xFF122540);
  static const boardDotDark = Color(0xFF1E355B);
  static const boardDotLight = Color(0xFFBACADB);

  // Arrow Direction Gradients
  static const arrowUpGradient = [
    Color(0xFF21D4FF),
    Color(0xFF0879FF),
    Color(0xFF064BE8),
  ];
  static const arrowRightGradient = [
    Color(0xFFFFD86B),
    Color(0xFFFF9E00),
    Color(0xFFF66A00),
  ];
  static const arrowDownGradient = [
    Color(0xFFFF779A),
    Color(0xFFFF3268),
    Color(0xFFE8004F),
  ];
  static const arrowLeftGradient = [
    Color(0xFF75F8CF),
    Color(0xFF12D9A4),
    Color(0xFF00B98E),
  ];

  // For compatibility
  static const arrowUp = Color(0xFF247BFF);
  static const arrowDown = Color(0xFFFF5277);
  static const arrowLeft = Color(0xFF21D98B);
  static const arrowRight = Color(0xFFFFB547);

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color getBackground(BuildContext context) =>
      isDark(context) ? darkBackground : lightBackground;

  static Color getSecondaryBackground(BuildContext context) =>
      isDark(context) ? darkSecondaryBackground : lightSecondaryBackground;

  static Color getCard(BuildContext context) =>
      isDark(context) ? darkCard : lightCardWhite;

  static Color getSurfaceElevated(BuildContext context) =>
      isDark(context) ? darkSurfaceElevated : lightCardWhite;

  static Color getTextPrimary(BuildContext context) =>
      isDark(context) ? darkTextPrimary : lightTextPrimary;

  static Color getTextSecondary(BuildContext context) =>
      isDark(context) ? darkTextSecondary : lightTextSecondary;

  static Color getTextMuted(BuildContext context) =>
      isDark(context) ? darkTextMuted : lightTextMuted;

  static Color getBorder(BuildContext context) =>
      isDark(context) ? darkBorder : lightBorder;

  static Color getBoardDot(BuildContext context) =>
      isDark(context) ? boardDotDark : boardDotLight;
}
