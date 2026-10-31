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
      final credential = await AuthService.instance.signInWithGoogle();
      if (credential != null && mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sign-in failed: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
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
              Align(
                alignment: Alignment.centerLeft,
                child: ArrowBoxHeaderIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Spacer(),
              const ArrowBoxTitle(fontSize: 32),
              const SizedBox(height: 12),
              Text(
                'Sign in to save your game progress and sync across devices.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.getTextSecondary(context),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
              ArrowBoxPrimaryButton(
                label: _isLoading ? 'Signing In...' : 'Sign in with Google',
                icon: Icons.login_rounded,
                onPressed: _isLoading ? () {} : _handleGoogleSignIn,
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
