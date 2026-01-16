import 'package:flutter/foundation.dart';

abstract class AppLogger {
  static void log(String message) {
    assert(() {
      debugPrint('[CampusZone] $message');
      return true;
    }());
  }

  static void info(String message) {
    assert(() {
      debugPrint('[CampusZone INFO] $message');
      return true;
    }());
  }

  static void warning(String message) {
    assert(() {
      debugPrint('[CampusZone WARNING] $message');
      return true;
    }());
  }

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

  static void navigation(String from, String to) {
    assert(() {
      debugPrint('[CampusZone NAV] $from -> $to');
      return true;
    }());
  }

  static void state(String component, String state) {
    assert(() {
      debugPrint('[CampusZone STATE] $component: $state');
      return true;
    }());
  }
}
