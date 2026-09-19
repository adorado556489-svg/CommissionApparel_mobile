/// Reusable form validation functions matching Laravel validation rules.
///
/// Each validator returns `null` on success or an error message string on
/// failure. Designed for use with Flutter's `TextFormField.validator`.
class Validators {
  Validators._();

  /// Field must not be null or empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Must be a valid email address.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  /// Must be at least 8 characters.
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  /// Must match the [password] value.
  static String? confirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Optional field — only validates format if non-empty.
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final regex = RegExp(r'^[0-9+\-() ]{7,20}$');
    if (!regex.hasMatch(value.trim())) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  /// Optional — validates that the value is numeric if non-empty.
  static String? numeric(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) return null;
    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }
    return null;
  }

  /// Optional — value must be >= [min] if non-empty.
  static String? minValue(
    String? value,
    double min, [
    String fieldName = 'Value',
  ]) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return '$fieldName must be a number';
    }
    if (parsed < min) {
      return '$fieldName must be at least ${min.toStringAsFixed(2)}';
    }
    return null;
  }

  /// Value must not exceed [max] characters.
  static String? maxLength(
    String? value,
    int max, [
    String fieldName = 'This field',
  ]) {
    if (value == null) return null;
    if (value.length > max) {
      return '$fieldName must be at most $max characters';
    }
    return null;
  }

  /// Combines multiple validators. Runs them in order and returns the first
  /// error, or `null` if all pass.
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
