class InputValidator {
  static String? empty(String value, String title, {int? minLen, int? maxLen}) {
    if (value.isEmpty) {
      return '$title must not be empty.';
    }
    if (minLen != null && maxLen != null && minLen == maxLen) {
      if (value.length != minLen) {
        return '$title must be exactly $minLen characters long.';
      }
    } else {
      if (minLen != null && value.length < minLen) {
        return '$title must be at least $minLen characters long.';
      }
      if (maxLen != null && value.length > maxLen) {
        return '$title must be at most $maxLen characters long.';
      }
    }

    return null;
  }

  static String? number(String number, String title, {int? minLen, int? maxLen}) {
    final numberRegex = RegExp(r'^\d+$');

    if (number.isEmpty) {
      return '$title must not be empty.';
    }
    if (!numberRegex.hasMatch(number)) {
      return '$title must contain only digits.';
    }
    if (minLen != null && maxLen != null && minLen == maxLen) {
      if (number.length != minLen) {
        return '$title must be exactly $minLen digits.';
      }
    } else {
      if (minLen != null && number.length < minLen) {
        return '$title must be at least $minLen digits.';
      }
      if (maxLen != null && number.length > maxLen) {
        return '$title must be at most $maxLen digits.';
      }
    }

    return null;
  }

  static String? email(String email) {
    final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");

    if (email.isEmpty) {
      return 'Email must not be empty.';
    }
    if (!emailRegex.hasMatch(email)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? password(String password) {
    if (password.isEmpty) {
      return 'Password must not be empty.';
    }

    if (password.length < 6) {
      return 'Password must be at least 6 characters.';
    }

    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumber = password.contains(RegExp(r'\d'));
    final hasSymbol = password.contains(RegExp(r'[!@#\$%^&*_()]'));

    if (!hasUppercase || !hasLowercase || !hasNumber || !hasSymbol) {
      return 'Password must include uppercase, lowercase, number, and symbol (!@#\$%^&*()).';
    }

    return null;
  }
}