import 'package:flutter/material.dart';

/// Centralized animation durations and curves
///
/// Usage:
/// ```dart
/// AnimatedContainer(duration: AppAnimations.normal)
/// AnimatedOpacity(curve: AppAnimations.defaultCurve)
/// ```
abstract class AppAnimations {
  // ============================================
  // DURATIONS
  // ============================================

  /// 100ms - Very fast (micro-interactions)
  static const Duration fastest = Duration(milliseconds: 100);

  /// 150ms - Fast (button press, hover)
  static const Duration fast = Duration(milliseconds: 150);

  /// 200ms - Quick transitions
  static const Duration quick = Duration(milliseconds: 200);

  /// 300ms - Normal (most UI transitions)
  static const Duration normal = Duration(milliseconds: 300);

  /// 350ms - Page transitions
  static const Duration pageTransition = Duration(milliseconds: 350);

  /// 400ms - Slide transitions
  static const Duration slide = Duration(milliseconds: 400);

  /// 500ms - Slow (emphasis animations)
  static const Duration slow = Duration(milliseconds: 500);

  /// 1200ms - Animation controller default
  static const Duration animationController = Duration(milliseconds: 1200);

  /// 2s - Snackbar display duration
  static const Duration snackbarDuration = Duration(seconds: 2);

  /// 60s - Long operation snackbar
  static const Duration snackbarLong = Duration(seconds: 60);

  // ============================================
  // CURVES
  // ============================================

  /// Default curve for most animations
  static const Curve defaultCurve = Curves.easeInOut;

  /// Ease out for entries
  static const Curve easeOut = Curves.easeOut;

  /// Ease out cubic for smooth exits
  static const Curve easeOutCubic = Curves.easeOutCubic;

  /// Bounce for playful interactions
  static const Curve bounce = Curves.bounceOut;

  /// Elastic for emphasizing actions
  static const Curve elastic = Curves.elasticOut;

  /// Linear for consistent motion
  static const Curve linear = Curves.linear;

  // ============================================
  // OFFSET VALUES
  // ============================================

  /// Vertical slide offset
  static const Offset slideUpOffset = Offset(0.0, 1.0);

  /// Zero offset
  static const Offset zeroOffset = Offset.zero;

  /// Hover lift offset
  static const double hoverLift = -5.0;
}
