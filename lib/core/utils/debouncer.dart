import 'dart:async';
import 'package:flutter/foundation.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  void cancel() {
    _timer?.cancel();
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }

  bool get isActive => _timer?.isActive ?? false;
}

class Throttler {
  final int milliseconds;
  DateTime? _lastRun;

  Throttler({this.milliseconds = 1000});

  void run(VoidCallback action) {
    final now = DateTime.now();
    if (_lastRun == null ||
        now.difference(_lastRun!).inMilliseconds >= milliseconds) {
      _lastRun = now;
      action();
    }
  }

  void reset() {
    _lastRun = null;
  }
}

class Cooldown {
  final Duration duration;
  DateTime? _lastTriggered;

  Cooldown({this.duration = const Duration(seconds: 3)});

  bool get canRun {
    if (_lastTriggered == null) return true;
    return DateTime.now().difference(_lastTriggered!) >= duration;
  }

  Duration get remaining {
    if (_lastTriggered == null) return Duration.zero;
    final elapsed = DateTime.now().difference(_lastTriggered!);
    if (elapsed >= duration) return Duration.zero;
    return duration - elapsed;
  }

  void trigger() {
    _lastTriggered = DateTime.now();
  }

  void reset() {
    _lastTriggered = null;
  }
}
