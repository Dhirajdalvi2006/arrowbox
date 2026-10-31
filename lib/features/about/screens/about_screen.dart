import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/arrowbox_widgets.dart';
import '../widgets/about_action_row.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'About',
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
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                child: Column(
                  children: [
                    const ArrowBoxHeroArtwork(size: 160),
                    const SizedBox(height: 18),
                    Text(
                      'ArrowBox',
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Think. Aim. Escape.',
                      style: TextStyle(
                        color: AppColors.cyan,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'A minimalist puzzle game where you clear\nthe board by finding the right paths for each arrow.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Version Container
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.getCard(context),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.getBorder(context),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              color: AppColors.getTextPrimary(context),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '© 2026 ArrowBox',
                            style: TextStyle(
                              color: AppColors.getTextMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Privacy Policy Row
                    AboutActionRow(
                      icon: Icons.description_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _showTextDialog(
                        context,
                        'Privacy Policy',
                        'ArrowBox operates entirely offline. No personal data, tracking, or device identifiers are collected or transmitted.',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Credits Row
                    AboutActionRow(
                      icon: Icons.people_outline_rounded,
                      title: 'Credits',
                      onTap: () => _showTextDialog(
                        context,
                        'Credits',
                        'ArrowBox was crafted with love as a modern Flutter puzzle game experience.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextDialog(BuildContext context, String title, String content) {
    showDialog<void>(
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
          content,
          style: TextStyle(
            color: AppColors.getTextSecondary(context),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.primaryBright),
            ),
          ),
        ],
      ),
    );
  }
}
