import 'package:flutter/foundation.dart';

/// Debug-only logger that strips logs in release builds
///
/// Usage:
/// ```dart
/// AppLogger.log('User logged in');
/// AppLogger.error('Failed to fetch data', error);
/// AppLogger.warning('Cache expired');
/// ```
abstract class AppLogger {
  /// Log a general message (debug only)
  static void log(String message) {
    assert(() {
      debugPrint('[CampusZone] $message');
      return true;
    }());
  }

  /// Log an info message (debug only)
  static void info(String message) {
    assert(() {
      debugPrint('[CampusZone INFO] $message');
      return true;
    }());
  }

  /// Log a warning message (debug only)
  static void warning(String message) {
    assert(() {
      debugPrint('[CampusZone WARNING] $message');
      return true;
    }());
  }

  /// Log an error with optional error object (debug only)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    assert(() {
      debugPrint('[CampusZone ERROR] $message');
      if (error != null) {
        debugPrint('[CampusZone ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[CampusZone ERROR] StackTrace: $stackTrace');
      }
      return true;
    }());
  }

  /// Log network request (debug only)
  static void network(String method, String url,
      {int? statusCode, String? body}) {
    assert(() {
      final status = statusCode != null ? ' [$statusCode]' : '';
      debugPrint('[CampusZone NETWORK] $method $url$status');
      if (body != null && body.length < 500) {
        debugPrint('[CampusZone NETWORK] Body: $body');
      }
      return true;
    }());
  }

  /// Log navigation (debug only)
  static void navigation(String from, String to) {
    assert(() {
      debugPrint('[CampusZone NAV] $from -> $to');
      return true;
    }());
  }

  /// Log state change (debug only)
  static void state(String component, String state) {
    assert(() {
      debugPrint('[CampusZone STATE] $component: $state');
      return true;
    }());
  }
}
