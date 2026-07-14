// import 'package:get/get.dart';


// abstract class IPhoneNumber {
//   bool isValidPhoneNumber(String phoneNumber);

//   bool validatePhone({required String phoneNumberNoSpace});
// }

// class PhoneNumberRepo implements IPhoneNumber {
//   @override
//   bool isValidPhoneNumber(String phoneNumber) {
//     // Define the regex pattern for the phone number formats 012123123 or 0121231234
//     // This pattern ensures the number starts with 0 and is followed by either 8 or 9 digits
//     final RegExp phoneRegExp = RegExp(r'^0\d{8,9}$');

//     // Check if the phone number matches the regex pattern
//     return phoneRegExp.hasMatch(phoneNumber);
//   }

//   @override
//   bool validatePhone({required String phoneNumberNoSpace}) {
//     //region validate phone
//     if (phoneNumberNoSpace.isEmpty) {
//       showCustomSnackBack(
//           title: AppLocale.phoneNumber.tr,
//           message: AppLocale.valueCantBeEmpty.tr,
//           isError: true);
//       return false;
//     } else {
//       if ((isValidPhoneNumber(phoneNumberNoSpace) == false)) {
//         showCustomSnackBar(
//             title: AppLocale.phoneNumber.tr,
//             message: AppLocale.checkPhoneHint.tr,
//             isError: true);
//         return false;
//       }
//       return true;
//     }
//     //endregion
//   }
// }
