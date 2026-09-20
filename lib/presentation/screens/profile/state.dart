import 'package:com.tara.passenger/presentation/screens/profile/data/models/profile_model.dart';
import 'package:get/get.dart';

class ProfileState {
  Rxn<ProfileModel> data = Rxn<ProfileModel>();
  RxBool isLoading = false.obs;
  RxnString errorMessage = RxnString();
}
