abstract class PhoneNumberValidation {
  bool isValid(String phoneNumber);
  String getErrorMessage();
}

class PhoneRepo implements PhoneNumberValidation {
  String? _errorMessage;
  @override
  bool isValid(String phoneNumber) {
    final numericRegex = RegExp(r'^\d+$');

    if (phoneNumber.isEmpty) {
      _errorMessage = "Phone Number cannot be empty";
      return false;
    } else if (!numericRegex.hasMatch(phoneNumber)) {
      _errorMessage = 'Phone number must contain only numbers.';
      return false;
    } else if (phoneNumber.length < 8 || phoneNumber.length > 15) {
      _errorMessage = 'Phone number must be between 9 and 15 digits.';
      return false;
    }

    _errorMessage = null;
    return true;
  }

  @override
  String getErrorMessage() {
    return _errorMessage ?? 'Invalid phone number.';
  }
}
