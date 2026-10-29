import 'package:flutter/material.dart';
import 'package:locate/core/services/auth_service.dart';
import 'package:locate/core/widgets/arrowbox_widgets.dart';
import 'package:locate/core/theme/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLoading = false;

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    try {
      await AuthService.instance.signInWithGoogle();
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 48),
              const ArrowBoxTitle(fontSize: 32),
              const SizedBox(height: 32),
              ArrowBoxPrimaryButton(
                label: _isLoading ? 'Signing In...' : 'Sign in with Google',
                icon: Icons.login_rounded,
                onPressed: _isLoading ? () {} : _handleGoogleSignIn,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
