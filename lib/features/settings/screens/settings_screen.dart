import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../widgets/settings_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({required this.store, this.embedded = false, super.key});
  final AppStore store;
  final bool embedded;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAuthLoading = false;
  String? _authError;

  Future<void> _handleSignIn() async {
    if (_isAuthLoading) return;
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });
    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (result == null && mounted) {
        // User cancelled
        setState(() => _isAuthLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _authError = e.toString().replaceFirst(
            RegExp(r'^(Exception|Error|StateError|UnsupportedError):\s*'),
            '',
          );
          _isAuthLoading = false;
        });
      }
    }
  }

  Future<void> _handleSignOut() async {
    if (_isAuthLoading) return;
    setState(() {
      _isAuthLoading = true;
      _authError = null;
    });
    try {
      await AuthService.instance.signOut();
    } catch (e) {
      if (mounted) {
        setState(() {
          _authError = 'Sign-out failed.';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final embedded = widget.embedded;

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  ArrowBoxHeaderIconButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    onPressed: embedded ? () {} : () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                children: [
                  // ACCOUNT SECTION
                  if (AuthService.instance.isAvailable) ...[
                    const SettingsSectionHeader(title: 'ACCOUNT'),
                    StreamBuilder<User?>(
                      stream: AuthService.instance.authStateChanges,
                      builder: (context, snapshot) {
                        final user = snapshot.data;
                        final isSignedIn = user != null;

                        return SettingsContainer(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  if (isSignedIn) ...[
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: AppColors.getBorder(
                                            context,
                                          ),
                                          backgroundImage: user.photoURL != null
                                              ? NetworkImage(user.photoURL!)
                                              : null,
                                          child: user.photoURL == null
                                              ? const Icon(
                                                  Icons.person,
                                                  color:
                                                      AppColors.primaryBright,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                user.displayName ?? 'Signed In',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        context,
                                                      ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              if (user.email != null)
                                                Text(
                                                  user.email!,
                                                  style: TextStyle(
                                                    color:
                                                        AppColors.getTextSecondary(
                                                          context,
                                                        ),
                                                    fontSize: 13,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ArrowBoxSecondaryButton(
                                        label: _isAuthLoading
                                            ? 'Signing Out...'
                                            : 'Sign Out',
                                        icon: Icons.logout_rounded,
                                        onPressed: _isAuthLoading
                                            ? () {}
                                            : _handleSignOut,
                                      ),
                                    ),
                                  ] else ...[
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.account_circle_outlined,
                                          color: AppColors.primaryBright,
                                          size: 28,
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Your Account',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getTextPrimary(
                                                        context,
                                                      ),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                'Sign in to connect your Google account.',
                                                style: TextStyle(
                                                  color:
                                                      AppColors.getTextSecondary(
                                                        context,
                                                      ),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_authError != null) ...[
                                      Text(
                                        _authError!,
                                        style: const TextStyle(
                                          color: AppColors.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                    SizedBox(
                                      width: double.infinity,
                                      child: ArrowBoxPrimaryButton(
                                        label: _isAuthLoading
                                            ? 'Signing In...'
                                            : 'Continue with Google',
                                        icon: Icons.login_rounded,
                                        onPressed: _isAuthLoading
                                            ? () {}
                                            : _handleSignIn,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                  ],

                  // GAMEPLAY SECTION
                  const SettingsSectionHeader(title: 'GAMEPLAY'),
                  SettingsContainer(
                    children: [
                      SettingsSwitchRow(
                        icon: Icons.vibration_rounded,
                        title: 'Haptic feedback',
                        value: store.hapticsEnabled,
                        onChanged: (v) => store.setBool('hapticsEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsSwitchRow(
                        icon: Icons.lightbulb_outline_rounded,
                        title: 'Show hints',
                        value: store.hintsEnabled,
                        onChanged: (v) => store.setBool('hintsEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsSwitchRow(
                        icon: Icons.help_outline_rounded,
                        title: 'Confirm before restart',
                        value: store.confirmRestart,
                        onChanged: (v) => store.setBool('confirmRestart', v),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // AUDIO SECTION
                  const SettingsSectionHeader(title: 'AUDIO'),
                  SettingsContainer(
                    children: [
                      SettingsSwitchRow(
                        icon: Icons.music_note_rounded,
                        title: 'Sound effects',
                        value: store.soundEnabled,
                        onChanged: (v) => store.setBool('soundEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsSwitchRow(
                        icon: Icons.queue_music_rounded,
                        title: 'Background music',
                        value: store.musicEnabled,
                        onChanged: (v) => store.setBool('musicEnabled', v),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              color: AppColors.primaryBright,
                              size: 22,
                            ),
                            const SizedBox(width: 14),
                            Text(
                              'Music volume',
                              style: TextStyle(
                                color: AppColors.getTextPrimary(context),
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Expanded(
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.primaryBright,
                                  inactiveTrackColor: AppColors.getBorder(
                                    context,
                                  ),
                                  thumbColor: AppColors.getTextPrimary(context),
                                  overlayColor: const Color(0x33247BFF),
                                  trackHeight: 4,
                                ),
                                child: Slider(
                                  value: store.musicVolume,
                                  onChanged: (val) =>
                                      store.setDouble('musicVolume', val),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // APPEARANCE SECTION
                  const SettingsSectionHeader(title: 'APPEARANCE'),
                  SettingsContainer(
                    children: [
                      SettingsRadioRow(
                        title: 'System theme',
                        selected: store.themeMode == ThemeMode.system,
                        onTap: () => store.setThemeMode(ThemeMode.system),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsRadioRow(
                        title: 'Light theme',
                        selected: store.themeMode == ThemeMode.light,
                        onTap: () => store.setThemeMode(ThemeMode.light),
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsRadioRow(
                        title: 'Dark theme',
                        selected: store.themeMode == ThemeMode.dark,
                        onTap: () => store.setThemeMode(ThemeMode.dark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // DATA SECTION
                  const SettingsSectionHeader(title: 'DATA'),
                  Row(
                    children: [
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Settings',
                          icon: Icons.restore_rounded,
                          onPressed: () => _confirm(
                            context,
                            'Reset settings?',
                            'All settings will return to defaults. Progress is kept.',
                            store.resetSettings,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Progress',
                          icon: Icons.delete_outline_rounded,
                          isDanger: true,
                          onPressed: () => _confirm(
                            context,
                            'Reset progress?',
                            'All completed levels and saved games will be permanently erased.',
                            store.resetProgress,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'ArrowBox 1.0.0',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    String title,
    String message,
    Future<void> Function() action,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text(
          title,
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Text(
          message,
          style: TextStyle(color: AppColors.getTextSecondary(context)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.getTextSecondary(context)),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await action();
    }
  }
}
