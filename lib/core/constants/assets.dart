/// Centralized asset paths
///
/// Usage:
/// ```dart
/// Image.asset(AppAssets.profileDefault)
/// Image.asset(AppAssets.appIcon)
/// ```
abstract class AppAssets {
  // ============================================
  // IMAGES
  // ============================================

  /// Default profile image
  static const String profileDefault = 'assets/profile.png';

  /// App icon
  static const String appIcon = 'assets/icon/icon.png';

  // ============================================
  // NOTE
  // ============================================

  // Fonts are loaded via google_fonts package, not bundled assets
  // This reduces APK size and ensures fonts are always up-to-date
}
