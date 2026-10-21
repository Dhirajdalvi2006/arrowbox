import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ArrowBoxScreen extends StatefulWidget {
  const ArrowBoxScreen({super.key});

  @override
  State<ArrowBoxScreen> createState() => _ArrowBoxScreenState();
}

class _ArrowBoxScreenState extends State<ArrowBoxScreen> {
  final int _level = 1;
  final int _hearts = 3;

  static const _grid = [
    ['up', 'right', 'down', 'left', 'up'],
    ['left', 'up', 'right', 'down', 'right'],
    ['down', 'right', '', 'up', 'left'],
    ['right', 'down', 'left', 'right', 'up'],
    ['up', 'left', 'up', 'down', 'right'],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            const Spacer(),
            _buildBoard(),
            const SizedBox(height: 32),
            _buildControls(),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.pause_circle_outline_rounded, size: 28),
            color: AppColors.textSecondary,
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: Center(
              child: Text('Level $_level', style: AppTextStyles.screenTitle),
            ),
          ),
          Row(
            children: List.generate(3, (i) => Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(
                i < _hearts ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: i < _hearts ? AppColors.error : AppColors.border,
                size: 22,
              ),
            )),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, size: 22),
            color: AppColors.textSecondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildBoard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.boardDark,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 8))],
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
            ),
            itemCount: 25,
            itemBuilder: (ctx, i) {
              final row = i ~/ 5;
              final col = i % 5;
              final dir = _grid[row][col];
              return _ArrowCell(direction: dir);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlButton(icon: Icons.undo_rounded, label: 'Undo', onTap: () {}),
          _ControlButton(icon: Icons.lightbulb_outline_rounded, label: 'Hint', onTap: () {}),
          _ControlButton(icon: Icons.refresh_rounded, label: 'Restart', onTap: () {}),
        ],
      ),
    );
  }
}

class _ArrowCell extends StatelessWidget {
  final String direction;
  const _ArrowCell({required this.direction});

  IconData get _icon {
    switch (direction) {
      case 'up': return Icons.arrow_upward_rounded;
      case 'down': return Icons.arrow_downward_rounded;
      case 'left': return Icons.arrow_back_rounded;
      case 'right': return Icons.arrow_forward_rounded;
      default: return Icons.circle_outlined;
    }
  }

  Color get _color {
    switch (direction) {
      case 'up': return AppColors.arrowUp;
      case 'down': return AppColors.arrowDown;
      case 'left': return AppColors.arrowLeft;
      case 'right': return AppColors.arrowRight;
      default: return AppColors.boardCell;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.boardCell,
        borderRadius: BorderRadius.circular(8),
      ),
      child: direction.isEmpty
          ? null
          : Icon(_icon, color: _color, size: 20),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.cardWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(height: 6),
          Text(label, style: AppTextStyles.label.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
