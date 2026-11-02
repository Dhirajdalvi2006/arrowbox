import 'package:flutter_test/flutter_test.dart';
import 'package:locate/core/services/reward_service.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';

void main() {
  group('RewardService.calculateArrowSkinsEarned', () {
    test('0 completed levels earns 0 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(0), 0);
    });

    test('49 completed levels earns 0 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(49), 0);
    });

    test('50 completed levels earns 1 skin', () {
      expect(RewardService.calculateArrowSkinsEarned(50), 1);
    });

    test('99 completed levels earns 1 skin', () {
      expect(RewardService.calculateArrowSkinsEarned(99), 1);
    });

    test('100 completed levels earns 2 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(100), 2);
    });

    test('150 completed levels earns 3 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(150), 3);
    });

    test('200 completed levels earns 4 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(200), 4);
    });

    test('250 completed levels earns 5 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(250), 5);
    });

    test('300 completed levels earns 6 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(300), 6);
    });

    test('400 completed levels earns 8 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(400), 8);
    });

    test('450 completed levels earns 9 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(450), 9);
    });

    test('500 completed levels earns 10 skins', () {
      expect(RewardService.calculateArrowSkinsEarned(500), 10);
    });

    test('Negative levels clamp to 0', () {
      expect(RewardService.calculateArrowSkinsEarned(-10), 0);
    });

    test('Levels above 500 clamp to max', () {
      expect(RewardService.calculateArrowSkinsEarned(1000), 10);
    });
  });

  group('RewardService.calculateBoardThemesEarned', () {
    test('0 completed levels earns 0 themes', () {
      expect(RewardService.calculateBoardThemesEarned(0), 0);
    });

    test('49 completed levels earns 0 themes', () {
      expect(RewardService.calculateBoardThemesEarned(49), 0);
    });

    test('50 completed levels earns 0 themes', () {
      expect(RewardService.calculateBoardThemesEarned(50), 0);
    });

    test('99 completed levels earns 0 themes', () {
      expect(RewardService.calculateBoardThemesEarned(99), 0);
    });

    test('100 completed levels earns 1 theme', () {
      expect(RewardService.calculateBoardThemesEarned(100), 1);
    });

    test('150 completed levels earns 1 theme', () {
      expect(RewardService.calculateBoardThemesEarned(150), 1);
    });

    test('200 completed levels earns 2 themes', () {
      expect(RewardService.calculateBoardThemesEarned(200), 2);
    });

    test('250 completed levels earns 2 themes', () {
      expect(RewardService.calculateBoardThemesEarned(250), 2);
    });

    test('300 completed levels earns 3 themes', () {
      expect(RewardService.calculateBoardThemesEarned(300), 3);
    });

    test('400 completed levels earns 4 themes', () {
      expect(RewardService.calculateBoardThemesEarned(400), 4);
    });

    test('450 completed levels earns 4 themes', () {
      expect(RewardService.calculateBoardThemesEarned(450), 4);
    });

    test('500 completed levels earns 5 themes', () {
      expect(RewardService.calculateBoardThemesEarned(500), 5);
    });

    test('Levels above 500 clamp to max', () {
      expect(RewardService.calculateBoardThemesEarned(1000), 5);
    });
  });

  group('RewardService.defaults', () {
    test('Classic skin is always unlocked', () {
      expect(RewardService.isSkinUnlocked(ArrowSkinId.classic, 0), true);
      expect(RewardService.isSkinUnlocked(ArrowSkinId.classic, 500), true);
    });

    test('Default board theme is always unlocked', () {
      expect(RewardService.isThemeUnlocked(BoardThemeId.midnight, 0), true);
      expect(RewardService.isThemeUnlocked(BoardThemeId.midnight, 500), true);
    });

    test('Neon skin unlocked at level 50', () {
      expect(RewardService.isSkinUnlocked(ArrowSkinId.neon, 49), false);
      expect(RewardService.isSkinUnlocked(ArrowSkinId.neon, 50), true);
    });

    test('Deep Ocean theme unlocked at level 100', () {
      expect(RewardService.isThemeUnlocked(BoardThemeId.deepOcean, 99), false);
      expect(RewardService.isThemeUnlocked(BoardThemeId.deepOcean, 100), true);
    });

    test('Aurora skin unlocked at level 500', () {
      expect(RewardService.isSkinUnlocked(ArrowSkinId.aurora, 499), false);
      expect(RewardService.isSkinUnlocked(ArrowSkinId.aurora, 500), true);
    });
  });

  group('RewardService.nextMilestone', () {
    test('0 completed levels returns level 50 skin milestone', () {
      final next = RewardService.nextMilestone(0);
      expect(next, isNotNull);
      expect(next!.requiredCompletedLevels, 50);
      expect(next.category, RewardCategory.arrowSkin);
    });

    test('50 completed levels returns level 100 skin milestone', () {
      final next = RewardService.nextMilestone(50);
      expect(next, isNotNull);
      expect(next!.requiredCompletedLevels, 100);
    });

    test('100 completed levels returns level 150 skin milestone', () {
      final next = RewardService.nextMilestone(100);
      expect(next, isNotNull);
      expect(next!.requiredCompletedLevels, 150);
    });

    test('499 completed levels returns level 500 skin milestone', () {
      final next = RewardService.nextMilestone(499);
      expect(next, isNotNull);
      expect(next!.requiredCompletedLevels, 500);
    });

    test('500 completed levels returns null (no more milestones)', () {
      expect(RewardService.nextMilestone(500), isNull);
    });
  });

  group('RewardService.progressToNextMilestone', () {
    test('0 completed levels has 0% progress toward level 50', () {
      expect(RewardService.progressToNextMilestone(0), 0.0);
    });

    test('25 completed levels has 50% progress toward level 50', () {
      expect(RewardService.progressToNextMilestone(25), 0.5);
    });

    test('50 completed levels has 0% progress toward level 100', () {
      expect(RewardService.progressToNextMilestone(50), 0.0);
    });

    test('75 completed levels has 50% progress toward level 100', () {
      expect(RewardService.progressToNextMilestone(75), 0.5);
    });

    test('500 completed levels has 100% progress (no more milestones)', () {
      expect(RewardService.progressToNextMilestone(500), 1.0);
    });
  });

  group('RewardService.remainingLevelsToNextMilestone', () {
    test('0 completed levels has 50 remaining', () {
      expect(RewardService.remainingLevelsToNextMilestone(0), 50);
    });

    test('37 completed levels has 13 remaining', () {
      expect(RewardService.remainingLevelsToNextMilestone(37), 13);
    });

    test('50 completed levels has 50 remaining (toward level 100)', () {
      expect(RewardService.remainingLevelsToNextMilestone(50), 50);
    });

    test('500 completed levels has 0 remaining', () {
      expect(RewardService.remainingLevelsToNextMilestone(500), 0);
    });
  });

  group('RewardService.getRewardsAtMilestone', () {
    test('Level 50 returns one arrow skin reward', () {
      final rewards = RewardService.getRewardsAtMilestone(50);
      expect(rewards.length, 1);
      expect(rewards.first.category, RewardCategory.arrowSkin);
    });

    test('Level 100 returns both skin and theme rewards', () {
      final rewards = RewardService.getRewardsAtMilestone(100);
      expect(rewards.length, 2);
      expect(rewards.any((r) => r.category == RewardCategory.arrowSkin), true);
      expect(rewards.any((r) => r.category == RewardCategory.boardTheme), true);
    });

    test('Level 75 returns no rewards', () {
      final rewards = RewardService.getRewardsAtMilestone(75);
      expect(rewards.length, 0);
    });
  });

  group('RewardService.idempotency', () {
    test('Repeated calculations return same results', () {
      for (var i = 0; i < 100; i++) {
        expect(RewardService.calculateArrowSkinsEarned(100), 2);
        expect(RewardService.calculateBoardThemesEarned(100), 1);
      }
    });
  });
}
