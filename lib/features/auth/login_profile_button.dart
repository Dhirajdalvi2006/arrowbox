import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/arrowbox_widgets.dart';
import 'profile_menu.dart';
import 'login_screen.dart';

class LoginProfileButton extends StatelessWidget {
  const LoginProfileButton({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthService.instance.authStateChanges,
      builder: (context, snapshot) {
        final user = snapshot.data;
        final isSignedIn = user != null;

        if (isSignedIn) {
          return ArrowBoxHeaderIconButton(
            icon: Icons.person,
            tooltip: 'Profile',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: AppColors.getBackground(context),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) => const ProfileMenu(),
              );
            },
          );
        } else {
          return ArrowBoxHeaderIconButton(
            icon: Icons.login_rounded,
            tooltip: 'Login',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          );
        }
      },
    );
  }
}
