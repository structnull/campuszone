import 'dart:async';
import 'package:flutter/foundation.dart';

/// Debouncer utility to prevent rapid repeated actions
///
/// Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
///
/// // In a text field or button
/// debouncer.run(() {
///   performSearch(query);
/// });
///
/// // Don't forget to dispose
/// @override
/// void dispose() {
///   debouncer.dispose();
///   super.dispose();
/// }
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  /// Run the action after the debounce period
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  /// Check if a timer is currently active
  bool get isActive => _timer?.isActive ?? false;
}

/// Throttler utility to limit action frequency
///
/// Usage:
/// ```dart
/// final throttler = Throttler(milliseconds: 1000);
///
/// // In a button or scroll handler
/// throttler.run(() {
///   fetchMoreData();
/// });
/// ```
class Throttler {
  final int milliseconds;
  DateTime? _lastRun;

  Throttler({this.milliseconds = 1000});

  /// Run the action if enough time has passed since the last run
  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null ||
        now.difference(_lastRun!).inMilliseconds >= milliseconds) {
      _lastRun = now;
      action();
    }
  }

  /// Reset the throttler
  void reset() {
    _lastRun = null;
  }
}

/// Cooldown utility for form submissions
///
/// Usage:
/// ```dart
/// final cooldown = Cooldown(duration: Duration(seconds: 3));
///
/// void onSubmit() async {
///   if (!cooldown.canRun) {
///     showSnackBar('Please wait before trying again');
///     return;
///   }
///   cooldown.trigger();
///   await submitForm();
/// }
/// ```
class Cooldown {
  final Duration duration;
  DateTime? _lastTriggered;

  Cooldown({this.duration = const Duration(seconds: 3)});

  /// Check if enough time has passed to run again
  bool get canRun {
    if (_lastTriggered == null) return true;
    return DateTime.now().difference(_lastTriggered!) >= duration;
  }

  /// Get remaining cooldown time
  Duration get remaining {
    if (_lastTriggered == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastTriggered!);
    if (elapsed >= duration) return Duration.zero;
    return duration - elapsed;
  }

  /// Trigger the cooldown
  void trigger() {
    _lastTriggered = DateTime.now();
  }

  /// Reset the cooldown
  void reset() {
    _lastTriggered = null;
  }
}
