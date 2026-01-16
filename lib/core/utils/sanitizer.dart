/// Input sanitization utilities for security
///
/// Usage:
/// ```dart
/// final cleanText = Sanitizer.text(userInput);
/// final safeHtml = Sanitizer.htmlEncode(userInput);
/// ```
abstract class Sanitizer {
  /// Removes HTML tags and special characters from text
  static String text(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll(RegExp(r'''[<>"']'''), '') // Remove special chars
        .trim();
  }

  /// HTML encode special characters to prevent XSS
  static String htmlEncode(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  /// Removes script tags specifically
  static String removeScripts(String input) {
    return input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, multiLine: true),
            '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }

  /// Sanitizes a search query
  static String searchQuery(String input) {
    return input
        .replaceAll(
            RegExp(r'[^\w\s-]'), '') // Keep only alphanumeric, spaces, hyphens
        .trim();
  }

  /// Sanitizes a file name
  static String fileName(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\s.-]'),
            '') // Keep only alphanumeric, spaces, dots, hyphens
        .replaceAll(RegExp(r'\.+'), '.') // Replace multiple dots with single
        .trim();
  }

  /// Trims and normalizes whitespace
  static String normalizeWhitespace(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'\s+'), ' '); // Replace multiple spaces with single
  }

  /// Sanitizes a URL by encoding special characters
  static String urlEncode(String input) {
    return Uri.encodeComponent(input);
  }
}
