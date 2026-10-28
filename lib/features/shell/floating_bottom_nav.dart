import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class FloatingBottomNav extends StatelessWidget {
  const FloatingBottomNav({
    required this.index,
    required this.onChanged,
    super.key,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static const _items = [
    (Icons.home_rounded, 'Home'),
    (Icons.grid_view_rounded, 'Levels'),
    (Icons.auto_awesome_rounded, 'Arrow Lab'),
    (Icons.insights_rounded, 'Progress'),
    (Icons.settings_rounded, 'Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppColors.getCard(context).withValues(alpha: .96),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.getBorder(context)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var i = 0; i < _items.length; i++)
              Expanded(
                child: Semantics(
                  button: true,
                  selected: i == index,
                  label: _items[i].$2,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeOut,
                      constraints: const BoxConstraints(minHeight: 52),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: i == index
                            ? AppColors.primary.withValues(alpha: .18)
                            : null,
                        borderRadius: BorderRadius.circular(18),
                        border: i == index
                            ? Border.all(
                                color: AppColors.primaryBright.withValues(
                                  alpha: .5,
                                ),
                              )
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _items[i].$1,
                            size: 21,
                            color: i == index
                                ? AppColors.primaryBright
                                : AppColors.getTextMuted(context),
                          ),
                          const SizedBox(height: 2),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: RichText(
                              text: TextSpan(
                                text: _items[i].$2.toLowerCase(),
                                style: TextStyle(
                                  color: i == index
                                      ? AppColors.getTextPrimary(context)
                                      : AppColors.getTextMuted(context),
                                  fontSize: 10,
                                  fontWeight: i == index
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
