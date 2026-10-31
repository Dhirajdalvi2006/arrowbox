import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TutorialStepCard extends StatelessWidget {
  const TutorialStepCard({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.visual,
    super.key,
  });

  final int step;
  final String title;
  final String subtitle;
  final Widget visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.getCard(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.getBorder(context), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.getSurfaceElevated(context),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$step',
                    style: const TextStyle(
                      color: AppColors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: AppColors.getTextPrimary(context),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.getTextSecondary(context),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(child: visual),
        ],
      ),
    );
  }
}

class Step1Visual extends StatelessWidget {
  const Step1Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.arrowUpGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.arrow_upward_rounded,
        color: Colors.white,
        size: 28,
      ),
    );
  }
}

class Step2Visual extends StatelessWidget {
  const Step2Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _miniTile(AppColors.arrowUpGradient, Icons.arrow_upward_rounded),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.cyan,
          size: 18,
        ),
        const SizedBox(width: 8),
        _miniTile(AppColors.arrowUpGradient, Icons.arrow_upward_rounded),
      ],
    );
  }

  Widget _miniTile(List<Color> colors, IconData icon) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      gradient: LinearGradient(colors: colors),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Icon(icon, color: Colors.white, size: 20),
  );

  Widget _miniEmpty(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.getSecondaryBackground(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.getBorder(context)),
    ),
  );
}

class Step3Visual extends StatelessWidget {
  const Step3Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: AppColors.arrowRightGradient,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.arrow_forward_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        _miniEmpty(context),
        const SizedBox(width: 8),
        const Icon(
          Icons.arrow_forward_rounded,
          color: AppColors.warning,
          size: 18,
        ),
      ],
    );
  }

  Widget _miniEmpty(BuildContext context) => Container(
    width: 36,
    height: 36,
    decoration: BoxDecoration(
      color: AppColors.getSecondaryBackground(context),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.getBorder(context)),
    ),
  );
}

class Step4Visual extends StatelessWidget {
  const Step4Visual({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x2221D98B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0x4421D98B)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20),
          SizedBox(width: 8),
          Text(
            'Board Cleared!',
            style: TextStyle(
              color: AppColors.success,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
