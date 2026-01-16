import 'package:flutter/material.dart';

abstract class AppAnimations {
  // Durations
  static const Duration fastest = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration pageTransition = Duration(milliseconds: 350);
  static const Duration slide = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration animationController = Duration(milliseconds: 1200);
  static const Duration snackbarDuration = Duration(seconds: 2);
  static const Duration snackbarLong = Duration(seconds: 60);

  // Curves
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve easeOut = Curves.easeOut;
  static const Curve easeOutCubic = Curves.easeOutCubic;
  static const Curve bounce = Curves.bounceOut;
  static const Curve elastic = Curves.elasticOut;
  static const Curve linear = Curves.linear;

  // Offsets
  static const Offset slideUpOffset = Offset(0.0, 1.0);
  static const Offset zeroOffset = Offset.zero;
  static const double hoverLift = -5.0;
}
