import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../../auth/login_profile_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({required this.store, super.key});
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360;
        final controlSize = compact ? 44.0 : 52.0;

        return Row(
          children: [
            Expanded(
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    ArrowBoxLogoMark(size: 34),
                    SizedBox(width: 12),
                    ArrowBoxTitle(fontSize: 24),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ArrowBoxHeaderIconButton(
                  size: controlSize,
                  icon: isDark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  tooltip: 'Toggle Theme',
                  onPressed: () {
                    final current = store.themeMode;
                    if (current == ThemeMode.dark) {
                      store.setThemeMode(ThemeMode.light);
                    } else {
                      store.setThemeMode(ThemeMode.dark);
                    }
                  },
                ),
                SizedBox(width: compact ? 4 : 8),
                const LoginProfileButton(),
              ],
            ),
          ],
        );
      },
    );
  }
}
