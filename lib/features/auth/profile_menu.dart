import 'package:flutter/material.dart';
import 'package:locate/core/services/auth_service.dart';
import 'package:locate/core/theme/app_colors.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.currentUser;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.getBorder(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (user != null) ...[
            CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.getBorder(context),
              backgroundImage: user.photoURL != null
                  ? NetworkImage(user.photoURL!)
                  : null,
              child: user.photoURL == null
                  ? const Icon(
                      Icons.person,
                      size: 36,
                      color: AppColors.primaryBright,
                    )
                  : null,
            ),
            const SizedBox(height: 12),
            if (user.displayName != null && user.displayName!.isNotEmpty)
              Text(
                user.displayName!,
                style: TextStyle(
                  color: AppColors.getTextPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            if (user.email != null && user.email!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                user.email!,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 24),
          ],
          ArrowBoxSecondaryButton(
            label: 'Sign Out',
            icon: Icons.logout_rounded,
            onPressed: () async {
              await AuthService.instance.signOut();
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
