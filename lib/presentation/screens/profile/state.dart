import 'package:com.tara.passenger/data/models/profile_model.dart';
import 'package:get/get.dart';

class ProfileState {
  Rxn<ProfileModel> data = Rxn<ProfileModel>();
  RxBool isLoading =false.obs;
}
