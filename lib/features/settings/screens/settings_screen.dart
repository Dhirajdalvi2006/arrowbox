import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/app_store.dart';
import '../../../core/services/audio_manager.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../widgets/settings_widgets.dart';

/// Settings screen for ArrowBox.
///
/// Groups controls into Gameplay, Audio, Appearance, and Data & Storage
/// sections. Every control writes through [AppStore] and affects real
/// application behaviour immediately.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.store,
    this.embedded = false,
    this.onBackPressed,
    super.key,
  });

  final AppStore store;
  final bool embedded;
  final VoidCallback? onBackPressed;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isAuthLoading = false;
  String? _authError;

  @override
  void initState() {
    super.initState();
    widget.store.addListener(_onStoreChanged);
    // Sync AudioManager with persisted preferences.
    AudioManager.instance.initializeFromStore(
      soundEnabled: widget.store.soundEnabled,
      musicEnabled: widget.store.musicEnabled,
      musicVolume: widget.store.musicVolume,
    );
  }

  @override
  void didUpdateWidget(covariant SettingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.store != widget.store) {
      oldWidget.store.removeListener(_onStoreChanged);
      widget.store.addListener(_onStoreChanged);
    }
  }

  @override
  void dispose() {
    widget.store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) {
      setState(() {});
    }
  }

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

  Future<void> _confirmResetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text(
          'Reset settings?',
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Text(
          'All settings will return to defaults. Game progress is kept.',
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
    if (confirmed == true && mounted) {
      await widget.store.resetSettings();
      // Re-sync AudioManager with reset preferences.
      AudioManager.instance.initializeFromStore(
        soundEnabled: widget.store.soundEnabled,
        musicEnabled: widget.store.musicEnabled,
        musicVolume: widget.store.musicVolume,
      );
      // Re-apply theme after reset
      widget.store.setThemeMode(widget.store.themeMode);
    }
  }

  Future<void> _confirmResetProgress() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.getCard(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.getBorder(context)),
        ),
        title: Text(
          'Reset progress?',
          style: TextStyle(color: AppColors.getTextPrimary(context)),
        ),
        content: Text(
          'All completed levels and saved games will be permanently erased.',
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
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await widget.store.resetProgress();
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.store;
    final embedded = widget.embedded;
    final mediaQuery = MediaQuery.of(context);
    final padding = mediaQuery.padding;
    final bottomPadding = mediaQuery.viewInsets.bottom;

    // Calculate appropriate bottom padding accounting for:
    // - Bottom navigation bar (when embedded)
    // - Keyboard (viewInsets)
    // - Safe area
    double getBottomPadding() {
      double base = embedded ? 120 : 24;
      if (bottomPadding > 0) {
        base = base + bottomPadding;
      }
      return base;
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: Column(
        children: [
          // Top Bar with proper top padding
          Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: padding.top + 12,
              bottom: 12,
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryBright.withAlpha(153),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBright.withAlpha(64),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    iconSize: 24,
                    color: AppColors.primaryBright,
                    icon: const Icon(Icons.arrow_back_rounded),
                    tooltip: 'Back',
                    onPressed: () {
                      if (widget.onBackPressed != null) {
                        widget.onBackPressed!();
                      } else if (!embedded && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Navigator.popUntil(context, (route) => route.isFirst);
                      }
                    },
                  ),
                ),
                Expanded(
                  child: Text(
                    'Settings',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Scrollable settings content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(20, 4, 20, getBottomPadding()),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        onChanged: (v) async {
                          await store.setBool('soundEnabled', v);
                          await AudioManager.instance.setSfxMuted(!v);
                        },
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      SettingsSwitchRow(
                        icon: Icons.queue_music_rounded,
                        title: 'Background music',
                        value: store.musicEnabled,
                        onChanged: (v) async {
                          await store.setBool('musicEnabled', v);
                          await AudioManager.instance.setMusicEnabled(v);
                        },
                      ),
                      Divider(color: AppColors.getBorder(context), height: 1),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.volume_up_rounded,
                                  color: AppColors.primaryBright,
                                  size: 22,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    'Music volume',
                                    style: TextStyle(
                                      color: AppColors.getTextPrimary(context),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Text(
                                  '${(store.musicVolume * 100).round()}%',
                                  style: const TextStyle(
                                    color: AppColors.primaryBright,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
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
                                onChanged: (val) async {
                                  await store.setDouble('musicVolume', val);
                                  await AudioManager.instance.setMusicVolume(
                                    val,
                                  );
                                },
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

                  // DATA & STORAGE SECTION
                  const SettingsSectionHeader(title: 'DATA & STORAGE'),
                  Row(
                    children: [
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Settings',
                          icon: Icons.restore_rounded,
                          onPressed: _confirmResetSettings,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ArrowBoxSecondaryButton(
                          label: 'Reset Progress',
                          icon: Icons.delete_outline_rounded,
                          isDanger: true,
                          onPressed: _confirmResetProgress,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'ArrowBox 1.1.0',
                      style: TextStyle(
                        color: AppColors.getTextMuted(context),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
