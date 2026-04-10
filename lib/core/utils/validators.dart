class Validators {
  static String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'Amount is required';
    }

    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid amount';
    }

    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateGoalName(String? value) {
    return validateRequired(value, 'Goal name');
  }

  static String? validateCategory(String? value) {
    return validateRequired(value, 'Category');
  }

  static bool isValidAmount(String value) {
    final amount = double.tryParse(value);
    return amount != null && amount > 0;
  }
}
