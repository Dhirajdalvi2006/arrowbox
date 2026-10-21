import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _sound = true;
  bool _music = false;
  bool _vibration = true;
  String _theme = 'Light';
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Preferences'),
          _SettingsCard(children: [
            _SwitchRow('Sound Effects', Icons.volume_up_rounded, _sound, (v) => setState(() => _sound = v)),
            const _Divider(),
            _SwitchRow('Background Music', Icons.music_note_rounded, _music, (v) => setState(() => _music = v)),
            const _Divider(),
            _SwitchRow('Vibration', Icons.vibration_rounded, _vibration, (v) => setState(() => _vibration = v)),
          ]),
          const SizedBox(height: 20),
          _SectionTitle('Appearance'),
          _SettingsCard(children: [
            _SelectRow('Theme', Icons.palette_rounded, _theme, ['Light', 'Dark', 'System'], (v) => setState(() => _theme = v)),
            const _Divider(),
            _SelectRow('Language', Icons.language_rounded, _language, ['English', 'Spanish', 'French'], (v) => setState(() => _language = v)),
          ]),
          const SizedBox(height: 20),
          _SectionTitle('App Settings'),
          _SettingsCard(children: [
            _ActionRow(
              'Reset Progress',
              Icons.restart_alt_rounded,
              AppColors.error,
              () => showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Reset Progress'),
                  content: const Text('This will erase all your game progress. Are you sure?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Reset', style: TextStyle(color: AppColors.error))),
                  ],
                ),
              ),
            ),
          ]),
          const SizedBox(height: 20),
          _SectionTitle('About'),
          _SettingsCard(children: [
            _InfoRow('About App', Icons.info_outline_rounded, () {}),
            const _Divider(),
            _InfoRow('Version 1.0.0', Icons.new_releases_outlined, null),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title, style: AppTextStyles.label.copyWith(fontWeight: FontWeight.w700, letterSpacing: 0.8, fontSize: 11)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(children: children),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SwitchRow(this.label, this.icon, this.value, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: Switch.adaptive(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
    );
  }
}

class _SelectRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> options;
  final ValueChanged<String> onChanged;
  const _SelectRow(this.label, this.icon, this.value, this.options, this.onChanged);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: GestureDetector(
        onTap: () => showModalBottomSheet(
          context: context,
          builder: (_) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              ...options.map((o) => ListTile(
                title: Text(o),
                trailing: o == value ? const Icon(Icons.check, color: AppColors.primary) : null,
                onTap: () { onChanged(o); Navigator.pop(context); },
              )),
              const SizedBox(height: 16),
            ],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: AppTextStyles.body.copyWith(color: AppColors.primary, fontWeight: FontWeight.w500)),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionRow(this.label, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: color, size: 22),
      title: Text(label, style: AppTextStyles.body.copyWith(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const _InfoRow(this.label, this.icon, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: AppTextStyles.body.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
      trailing: onTap != null ? const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary, size: 18) : null,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 56, color: AppColors.border);
  }
}
