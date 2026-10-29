import 'package:flutter/material.dart';
import 'package:locate/core/services/auth_service.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ArrowBoxSecondaryButton(
          label: 'Sign Out',
          icon: Icons.logout_rounded,
          onPressed: () async {
            await AuthService.instance.signOut();
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}
