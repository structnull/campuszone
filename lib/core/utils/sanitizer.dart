abstract class Sanitizer {
  static String text(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'''[<>"']'''), '')
        .trim();
  }

  static String htmlEncode(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#x27;');
  }

  static String removeScripts(String input) {
    return input
        .replaceAll(
            RegExp(r'<script[^>]*>.*?</script>',
                caseSensitive: false, multiLine: true),
            '')
        .replaceAll(RegExp(r'javascript:', caseSensitive: false), '')
        .replaceAll(RegExp(r'on\w+\s*=', caseSensitive: false), '');
  }

  static String searchQuery(String input) {
    return input.replaceAll(RegExp(r'[^\w\s-]'), '').trim();
  }

  static String fileName(String input) {
    return input
        .replaceAll(RegExp(r'[^\w\s.-]'), '')
        .replaceAll(RegExp(r'\.+'), '.')
        .trim();
  }

  static String normalizeWhitespace(String input) {
    return input.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  static String urlEncode(String input) {
    return Uri.encodeComponent(input);
  }
}
