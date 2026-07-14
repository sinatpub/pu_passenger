import 'package:get/get.dart';

class AuthState {
  Rx<bool> isAuthorized = false.obs;
  Rx<bool> isLoading = false.obs;
  Rx<String> phoneNumber = ''.obs;
}
