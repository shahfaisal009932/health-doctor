class Validators {
  Validators._();

  /// Email Validation
  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email is required";
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return "Enter valid email";
    }
    return null;
  }

  /// Password Validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 6) {
      return "Password must contain minimum 6 characters";
    }
    return null;
  }

  /// Required Field Validation
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  /// Name Validation
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name is required";
    }
    if (value.trim().length < 3) {
      return "Name must contain minimum 3 characters";
    }
    return null;
  }

  /// Phone Number Validation
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Phone number is required";
    }

    final phoneRegex = RegExp(r'^[0-9]{10}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return "Enter valid 10 digit phone number";
    }
    return null;
  }

  /// Session Note Validation
  static String? validateNote(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Session note is required";
    }
    if (value.trim().length < 10) {
      return "Note should contain minimum 10 characters";
    }
    return null;
  }

  /// Patient Age Validation
  static String? validateAge(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Age is required";
    }
    final age = int.tryParse(value);
    if (age == null) {
      return "Enter valid age";
    }
    if (age <= 0 || age > 120) {
      return "Enter valid age between 1-120";
    }
    return null;
  }
}
