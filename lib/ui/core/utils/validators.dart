class Validators {
  Validators._();

  static String normalizePhoneNumber(String? phone) {
    if (phone == null) return '';
    return phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  static String? validateFirstName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'First name is required';
    }
    final trimmed = value.trim();
    if (trimmed.length < 2) {
      return 'First name must be at least 2 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s\-']+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'First name should only contain letters';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
    );
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(
    String? password,
    String? confirmPassword,
  ) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (password != confirmPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final trimmed = value.trim();

    if (!trimmed.startsWith('+')) {
      return 'Please include country code with + (e.g. +1 555 123 4567)';
    }

    final normalized = normalizePhoneNumber(trimmed);
    // After +, must only contain digits
    final onlyDigitsAfterPlus = RegExp(r'^\+[0-9]+$');
    if (!onlyDigitsAfterPlus.hasMatch(normalized)) {
      return 'Phone number can only contain digits, spaces, and dashes';
    }

    if (normalized.length < 9) {
      return 'Phone number is too short. Please enter a valid number';
    }

    if (normalized.length > 16) {
      return 'Phone number is too long. Please verify your number';
    }

    final phoneRegex = RegExp(r'^\+[1-9]\d{7,14}$');
    if (!phoneRegex.hasMatch(normalized)) {
      return 'Please enter a valid phone number (e.g. +1 555 123 4567)';
    }

    return null;
  }

  static String? validateSmsCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Verification code is required';
    }
    final trimmed = value.trim();
    if (trimmed.length != 6 || !RegExp(r'^\d{6}$').hasMatch(trimmed)) {
      return 'Please enter the full 6-digit code';
    }
    return null;
  }
}
