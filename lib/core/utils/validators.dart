abstract class Validators {
  // Required
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  static String? Function(String?) requiredWith(String message) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message;
      }
      return null;
    };
  }

  // Email
  static final _emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? emailOptional(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_emailRegex.hasMatch(value)) {
      return 'Enter a valid email';
    }
    return null;
  }

  // Password
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

  static String? passwordSimple(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

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

  // Length
  static String? Function(String?) minLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length < length) {
        final name = fieldName ?? 'This field';
        return '$name must be at least $length characters';
      }
      return null;
    };
  }

  static String? Function(String?) maxLength(int length, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;
      if (value.length > length) {
        final name = fieldName ?? 'This field';
        return '$name must be at most $length characters';
      }
      return null;
    };
  }

  // URL
  static final _urlRegex = RegExp(
    r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
  );

  static String? url(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_urlRegex.hasMatch(value)) {
      return 'Enter a valid URL';
    }
    return null;
  }

  // Phone
  static final _phoneRegex = RegExp(r'^\+?[\d\s-]{10,}$');

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return null;
    if (!_phoneRegex.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  // Combine
  static String? Function(String?) combine(
      List<String? Function(String?)> validators) {
    return (String? value) {
      for (final validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}
