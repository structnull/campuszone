import 'package:flutter/material.dart';

/// Centralized dimensions for consistent spacing, sizing, and layout
///
/// Usage:
/// ```dart
/// Padding(padding: AppSpacing.screenPadding)
/// Container(decoration: BoxDecoration(borderRadius: AppRadius.cardRadius))
/// Icon(Icons.home, size: AppIconSize.md)
/// ```
abstract class AppSpacing {
  // ============================================
  // SPACING VALUES
  // ============================================

  /// 4.0 - Minimal spacing (icons, inline elements)
  static const double xs = 4.0;

  /// 6.0 - Tiny spacing (between label and input)
  static const double xxs = 6.0;

  /// 8.0 - Tight spacing (between related items)
  static const double sm = 8.0;

  /// 12.0 - Default spacing (list items, form fields)
  static const double md = 12.0;

  /// 16.0 - Standard spacing (cards, sections)
  static const double lg = 16.0;

  /// 20.0 - Comfortable spacing (major sections)
  static const double xl = 20.0;

  /// 24.0 - Large spacing (page margins, headers)
  static const double xxl = 24.0;

  /// 28.0 - Extra-large spacing
  static const double xxxl = 28.0;

  /// 32.0 - Major section spacing
  static const double huge = 32.0;

  /// 48.0 - Section dividers
  static const double section = 48.0;

  /// 60.0 - Large section spacing
  static const double sectionLarge = 60.0;

  /// 80.0 - Hero section spacing
  static const double hero = 80.0;

  /// 150.0 - Bottom nav safe area
  static const double bottomNavHeight = 150.0;

  // ============================================
  // PRE-BUILT EDGE INSETS
  // ============================================

  /// Screen padding - horizontal: 16, vertical: 12
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Screen padding (horizontal only) - 16
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: lg,
  );

  /// Auth screen padding - horizontal: 28, vertical: 20
  static const EdgeInsets authPadding = EdgeInsets.symmetric(
    horizontal: 28,
    vertical: xl,
  );

  /// Card padding - 16 all around
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// List item padding - horizontal: 16, vertical: 12
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );

  /// Form field spacing - bottom: 16
  static const EdgeInsets formFieldSpacing = EdgeInsets.only(bottom: lg);

  /// Section margin - vertical: 20
  static const EdgeInsets sectionMargin = EdgeInsets.symmetric(vertical: xl);

  /// Bottom nav safe area - bottom: 150
  static const EdgeInsets bottomNavSafeArea =
      EdgeInsets.only(bottom: bottomNavHeight);

  /// Tab padding - 14 all around
  static const EdgeInsets tabPadding = EdgeInsets.all(14.0);

  /// Nav bar padding - horizontal: 20, vertical: 30
  static const EdgeInsets navBarPadding = EdgeInsets.symmetric(
    horizontal: xl,
    vertical: 30,
  );

  /// List padding with bottom space for nav
  static const EdgeInsets listWithNavPadding =
      EdgeInsets.fromLTRB(lg, lg, lg, 80);

  /// Card margin - vertical: 10
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: 10);

  /// Input field horizontal padding - 15
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 15);
}

/// Border radius constants
abstract class AppRadius {
  // ============================================
  // RADIUS VALUES
  // ============================================

  /// 8.0 - Small (buttons, inputs)
  static const double sm = 8.0;

  /// 10.0 - Snackbar, small elements
  static const double snackbar = 10.0;

  /// 12.0 - Medium (cards)
  static const double md = 12.0;

  /// 16.0 - Large (modals, containers)
  static const double lg = 16.0;

  /// 20.0 - Extra large (feature cards)
  static const double xl = 20.0;

  /// 24.0 - Rounded (pills, FABs)
  static const double xxl = 24.0;

  /// 30.0 - Full round (buttons)
  static const double full = 30.0;

  // ============================================
  // PRE-BUILT BORDER RADIUS
  // ============================================

  /// Card border radius - 12
  static BorderRadius get cardRadius => BorderRadius.circular(md);

  /// Button border radius - 24
  static BorderRadius get buttonRadius => BorderRadius.circular(xxl);

  /// Input field border radius - 16
  static BorderRadius get inputRadius => BorderRadius.circular(lg);

  /// Dialog/modal border radius - 16
  static BorderRadius get dialogRadius => BorderRadius.circular(lg);

  /// Feature card border radius - 20
  static BorderRadius get featureCardRadius => BorderRadius.circular(xl);

  /// Full rounded radius - 30
  static BorderRadius get fullRadius => BorderRadius.circular(full);
}

/// Icon size constants
abstract class AppIconSize {
  /// 16.0 - Inline icons
  static const double xs = 16.0;

  /// 20.0 - Small icons (form fields)
  static const double sm = 20.0;

  /// 22.0 - Default icons
  static const double md = 22.0;

  /// 24.0 - Standard icons
  static const double df = 24.0;

  /// 28.0 - Large icons
  static const double lg = 28.0;

  /// 36.0 - Navigation icons
  static const double xl = 36.0;

  /// 48.0 - Profile avatars
  static const double avatar = 48.0;

  /// 50.0 - Large avatar
  static const double avatarLarge = 50.0;

  /// 64.0 - Empty state icons
  static const double hero = 64.0;

  /// 120.0 - Large hero icons
  static const double heroLarge = 120.0;
}

/// Elevation constants
abstract class AppElevation {
  /// 0.0 - Flat
  static const double none = 0.0;

  /// 2.0 - Subtle elevation
  static const double low = 2.0;

  /// 4.0 - Cards
  static const double card = 4.0;

  /// 6.0 - FAB
  static const double fab = 6.0;

  /// 10.0 - Dialogs, dropdown
  static const double dialog = 10.0;

  /// 24.0 - Feature cards
  static const double feature = 24.0;
}

/// Common dimension values
abstract class AppDimensions {
  /// Input field height - 50
  static const double inputHeight = 50.0;

  /// Button height - 52
  static const double buttonHeight = 52.0;

  /// App bar title font size - 24
  static const double appBarTitleSize = 24.0;

  /// Card image height - 250
  static const double cardImageHeight = 250.0;

  /// Noticeboard card height - 800
  static const double noticeboardHeight = 800.0;

  /// Chat card height (small screen) - 150
  static const double chatCardHeightSmall = 150.0;

  /// Chat card height (large screen) - 180
  static const double chatCardHeightLarge = 180.0;

  /// Gradient bottom height - 150
  static const double gradientHeight = 150.0;

  /// Profile avatar radius (small screen) - 30
  static const double avatarRadiusSmall = 30.0;

  /// Profile avatar radius (large screen) - 40
  static const double avatarRadiusLarge = 40.0;

  /// Border width - 1.5
  static const double borderWidth = 1.5;

  /// Loader stroke width - 2
  static const double loaderStrokeWidth = 2.0;

  /// Linear progress min height - 4
  static const double progressHeight = 4.0;
}
