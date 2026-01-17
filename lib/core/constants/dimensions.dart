import 'package:flutter/material.dart';

abstract class AppSpacing {
  // Spacing values
  static const double tiny = 3.0;
  static const double xs = 4.0;
  static const double xxs = 6.0;
  static const double sm = 8.0;
  static const double snackbar = 10.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 28.0;
  static const double full = 30.0;
  static const double huge = 32.0;
  static const double section = 48.0;
  static const double sectionLarge = 60.0;
  static const double hero = 80.0;
  static const double bottomNavHeight = 150.0;

  // Edge Insets
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: lg,
    vertical: md,
  );
  static const EdgeInsets screenHorizontal =
      EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets authPadding =
      EdgeInsets.symmetric(horizontal: 28, vertical: xl);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets listItemPadding =
      EdgeInsets.symmetric(horizontal: lg, vertical: md);
  static const EdgeInsets formFieldSpacing = EdgeInsets.only(bottom: lg);
  static const EdgeInsets sectionMargin = EdgeInsets.symmetric(vertical: xl);
  static const EdgeInsets bottomNavSafeArea =
      EdgeInsets.only(bottom: bottomNavHeight);
  static const EdgeInsets tabPadding = EdgeInsets.all(14.0);
  static const EdgeInsets navBarPadding =
      EdgeInsets.symmetric(horizontal: xl, vertical: full);
  static const EdgeInsets listWithNavPadding =
      EdgeInsets.fromLTRB(lg, lg, lg, 80);
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(vertical: snackbar);
  static const EdgeInsets inputPadding = EdgeInsets.symmetric(horizontal: 15);
  static const EdgeInsets tagPadding =
      EdgeInsets.symmetric(horizontal: snackbar, vertical: 5);
  static const EdgeInsets chipPadding =
      EdgeInsets.symmetric(horizontal: md, vertical: sm);
  static const EdgeInsets dialogPadding =
      EdgeInsets.symmetric(vertical: xxl, horizontal: xxl);
}

abstract class AppRadius {
  // Values
  static const double tiny = 4.0;
  static const double sm = 8.0;
  static const double snackbar = 10.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 30.0;
  static const double pill = 40.0;

  // Pre-built
  static BorderRadius get cardRadius => BorderRadius.circular(md);
  static BorderRadius get buttonRadius => BorderRadius.circular(xxl);
  static BorderRadius get inputRadius => BorderRadius.circular(lg);
  static BorderRadius get dialogRadius => BorderRadius.circular(lg);
  static BorderRadius get featureCardRadius => BorderRadius.circular(xl);
  static BorderRadius get fullRadius => BorderRadius.circular(full);
  static BorderRadius get pillRadius => BorderRadius.circular(pill);
}

abstract class AppIconSize {
  static const double xs = 16.0;
  static const double sm = 20.0;
  static const double md = 22.0;
  static const double df = 24.0;
  static const double lg = 28.0;
  static const double social = 32.0;
  static const double xl = 36.0;
  static const double avatar = 48.0;
  static const double avatarLarge = 50.0;
  static const double hero = 64.0;
  static const double heroLarge = 120.0;
}

abstract class AppElevation {
  static const double none = 0.0;
  static const double low = 2.0;
  static const double card = 4.0;
  static const double fab = 6.0;
  static const double dialog = 10.0;
  static const double feature = 24.0;
}

abstract class AppDimensions {
  static const double inputHeight = 50.0;
  static const double buttonHeight = 52.0;
  static const double appBarTitleSize = 24.0;
  static const double cardImageHeight = 250.0;
  static const double noticeboardHeight = 800.0;
  static const double chatCardHeightSmall = 150.0;
  static const double chatCardHeightLarge = 180.0;
  static const double gradientHeight = 150.0;
  static const double avatarRadiusSmall = 30.0;
  static const double avatarRadiusLarge = 40.0;
  static const double borderWidth = 1.5;
  static const double loaderStrokeWidth = 2.0;
  static const double progressHeight = 4.0;

  // Component-specific dimensions
  static const double carouselCardHeight = 400.0;
  static const double communityImageHeight = 180.0;
  static const double eventImageHeight = 120.0;
  static const double gradientOverlayHeight = 50.0;
  static const double profileAvatarRadius = 100.0;
  static const double bottomScrollSpacing = 200.0;
  static const double avatarBorderWidth = 4.0;
}
