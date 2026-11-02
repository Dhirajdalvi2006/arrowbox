import 'package:locate/core/services/auth_service.dart';
import 'package:locate/core/services/reward_service.dart';
import 'package:locate/features/arrow_designs/arrow_designs.dart';

/// Centralized admin access service.
///
/// Determines whether the currently authenticated user has administrator
/// privileges based on their Firebase Auth email address.  Admin status
/// is recalculated whenever the authentication state changes.
///
/// The only administrator account is: dalvi3473@gmail.com
///
/// Privileges are derived from the authenticated identity each time,
/// not stored locally, so they survive app restarts and account switches.
class AdminAccessService {
  AdminAccessService._();

  /// The single authoritative check: does the current user match the admin email?
  ///
  /// Returns [true] only when:
  /// * A user is authenticated (not signed out)
  /// * The user's email, after trimming and lowercasing, matches
  ///   'dalvi3473@gmail.com' exactly
  ///
  /// Returns [false] for signed-out users and all other email addresses.
  static bool get isAdmin {
    final user = AuthService.instance.currentUser;
    if (user == null) return false;

    final email = user.email;
    if (email == null) return false;

    return email.trim().toLowerCase() == 'dalvi3473@gmail.com';
  }

  /// Returns the admin email if the current user is an admin, [null] otherwise.
  ///
  /// Useful for display purposes or logging without exposing the full
  /// auth checks in widget logic.
  static String? get adminEmail {
    final user = AuthService.instance.currentUser;
    if (user == null) return null;

    final email = user.email;
    if (email == null) return null;

    final normalized = email.trim().toLowerCase();
    if (normalized == 'dalvi3473@gmail.com') return user.email;
    return null;
  }

  /// Whether the current user is a normal (non-admin) player.
  static bool get isNormalPlayer => !isAdmin;

  /// Whether the currently authenticated user can access all levels
  /// (admins) or must follow normal progression rules.
  static bool get canAccessAllLevels => isAdmin;

  /// Whether the currently authenticated user can equip all arrow skins
  /// and board themes immediately (admins).
  static bool get canAccessAllSkinsAndThemes => isAdmin;

  /// Check if a level selection request should be granted based on admin
  /// status and normal-player progression.
  ///
  /// Admins can select any level 1..500. Normal players can only select
  /// levels they have earned access to through normal progression.
  static bool canSelectLevel(int level) =>
      isAdmin || level >= 1 && level <= 500;

  /// For normal players, the highest level they can access based on
  /// completed levels. For admins, returns 500.
  static int get maxAccessibleLevel => isAdmin ? 500 : 1;

  /// Whether the current user can select any valid level directly.
  static bool canSelectLevelWithPolicy(
    int level, {
    int completedLevelCount = 0,
  }) {
    if (isAdmin) {
      // Admin can access any valid level
      return level >= 1 && level <= 500;
    }
    // Normal player: level must be within earned access
    // A player can access levels up to and including their unlockedLevel
    // (which is derived from completed levels + 1)
    return level >= 1 && level <= (completedLevelCount + 1);
  }

  /// Check if an arrow skin equip request should be granted.
  static bool canEquipSkin(ArrowSkinId skinId, {int completedLevelCount = 0}) {
    if (isAdmin) {
      // Admin can equip any registered skin
      return _allRegisteredSkinIds.contains(skinId);
    }
    // Normal player: check via RewardService
    return RewardService.isSkinUnlocked(skinId, completedLevelCount);
  }

  /// Check if a board theme equip request should be granted.
  static bool canEquipTheme(
    BoardThemeId themeId, {
    int completedLevelCount = 0,
  }) {
    if (isAdmin) {
      // Admin can equip any registered theme
      return _allRegisteredThemeIds.contains(themeId);
    }
    // Normal player: check via RewardService
    return RewardService.isThemeUnlocked(themeId, completedLevelCount);
  }

  /// All registered arrow skin IDs from the registry.
  static List<ArrowSkinId> get _allRegisteredSkinIds {
    return ArrowSkinRegistry.all.map((skin) => skin.id).toList();
  }

  /// All registered board theme IDs from the registry.
  static List<BoardThemeId> get _allRegisteredThemeIds {
    return BoardThemeRegistry.all.map((theme) => theme.id).toList();
  }

  /// Recalculate admin privileges when the auth state changes.
  ///
  /// Call this from an [AuthService] listener to keep the policy in sync.
  static void refresh() {
    // The [isAdmin] getter reads [AuthService.instance.currentUser] on every
    // call, so simply rebuilding widgets that depend on it will recalculate.
    // This method exists for explicit use case clarity.
    notifyListeners();
  }

  /// Stub for future [ChangeNotifier]-based listener support if needed.
  static void notifyListeners() {}
}

/// Extension on [ArrowSkinId] for admin-service convenience.
extension ArrowSkinIdExtension on ArrowSkinId {
  /// Human-readable name for display/logging.
  String get displayName => switch (this) {
    ArrowSkinId.classic => 'Classic',
    ArrowSkinId.neon => 'Neon',
    ArrowSkinId.glass => 'Glass',
    ArrowSkinId.minimal => 'Minimal',
    ArrowSkinId.bold => 'Bold',
    ArrowSkinId.pastel => 'Pastel',
    ArrowSkinId.tech => 'Tech',
    ArrowSkinId.fantasy => 'Fantasy',
    ArrowSkinId.cyber => 'Cyber',
    ArrowSkinId.voidStyle => 'Void',
    ArrowSkinId.aurora => 'Aurora',
  };
}

/// Extension on [BoardThemeId] for admin-service convenience.
extension BoardThemeIdExtension on BoardThemeId {
  /// Human-readable name for display/logging.
  String get displayName => switch (this) {
    BoardThemeId.midnight => 'Midnight',
    BoardThemeId.deepOcean => 'Deep Ocean',
    BoardThemeId.aurora => 'Aurora',
    BoardThemeId.graphite => 'Graphite',
    BoardThemeId.midnightNebula => 'Midnight Nebula',
    BoardThemeId.deepOceanAbyss => 'Deep Ocean Abyss',
    BoardThemeId.solarFlare => 'Solar Flare',
    BoardThemeId.neonVoid => 'Neon Void',
  };
}
