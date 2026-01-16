/// Centralized form validation utilities
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: Validators.required,
/// )
///
/// TextFormField(
///   validator: Validators.email,
/// )
///
/// TextFormField(
///   validator: Validators.password,
/// )
/// ```
abstract class Validators {
  // ============================================
  // BASIC VALIDATORS
  // ============================================

  /// Validates that a field is not empty
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  /// Creates a required validator with custom message
  static String? Function(String?) requiredWith(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  // ============================================
  // EMAIL VALIDATION
  // ============================================

  /// Email regex pattern
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  /// Validates email format
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  /// Validates email format (optional - only validates if not empty)
  static String? emailOptional(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // ============================================
  // PASSWORD VALIDATION
  // ============================================

  /// Strong password validation
  /// - Minimum 8 characters
  /// - At least one uppercase letter
  /// - At least one lowercase letter
  /// - At least one number
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Include at least one uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Include at least one lowercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Include at least one number';
    }
    return null;
  }

  /// Simple password validation (for login, just checks minimum length)
  static String? passwordSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Checks if two password fields match
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != originalPassword) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // ============================================
  // TEXT LENGTH VALIDATION
  // ============================================

  /// Validates minimum length
  static String? Function(String?) minLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null; // Use required validator for empty check
      }
      if (value.length < length) {
        final name = fieldName ?? 'This field';
        return '$name must be at least $length characters';
      }
      return null;
    };
  }

  /// Validates maximum length
  static String? Function(String?) maxLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return null;
      }
      if (value.length > length) {
        final name = fieldName ?? 'This field';
        return '$name must be at most $length characters';
      }
      return null;
    };
  }

  // ============================================
  // URL VALIDATION
  // ============================================

  /// URL regex pattern
  static final _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  /// Validates URL format (optional)
  static String? url(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!_urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  // ============================================
  // PHONE VALIDATION
  // ============================================

  /// Phone number regex (basic)
  static final _phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');

  /// Validates phone number format (optional)
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (!_phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // ============================================
  // COMBINED VALIDATORS
  // ============================================

  /// Combines multiple validators
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) {
          return result;
        }
      }
      return null;
    };
  }
}
