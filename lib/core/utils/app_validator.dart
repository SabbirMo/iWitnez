class AppValidator {
  const AppValidator._();

  /// Validates full name / user name
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your name";
    }
    return null;
  }

  /// Validates email address
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter your email";
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value.trim())) {
      return "Please enter a valid email address";
    }
    return null;
  }

  /// Validates password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    return null;
  }

  /// Validates confirm password against the original password
  static String? validateConfirmPassword(
    String? value,
    String? originalPassword,
  ) {
    if (value == null || value.isEmpty) {
      return "Please enter your password";
    }
    if (value.length < 8) {
      return "Password must be at least 8 characters long";
    }
    if (value != originalPassword) {
      return "Passwords do not match";
    }
    return null;
  }

  /// Generic required field validator
  static String? validateRequired(String? value, {String fieldName = "Field"}) {
    if (value == null || value.trim().isEmpty) {
      return "Please enter $fieldName";
    }
    return null;
  }
}
