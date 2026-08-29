import 'dart:convert';
import 'dart:io';
import 'package:com.tara.passenger/features/auth/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/remove_storage.dart';
import 'package:com.tara.passenger/storages/save_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/colors.dart';
import '../../../core/theme/text_styles.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/error_dialog_widget.dart';
import '../../widgets/x_button.dart';
import '../../widgets/x_showmodal_bottom.dart';
import 'state.dart';

class RegisterLogic extends GetxController {
  final RegisterState state = RegisterState();
  final AuthRepository _repository = Get.find<AuthRepository>();
  final SaveStoragePref _savePref = SaveStoragePref();
  final RemoveStoragePref _removePref = RemoveStoragePref();
  final ImagePicker _picker = ImagePicker();

  TextEditingController controllerName = TextEditingController();
  final LoginLogic loginLogic = Get.find<LoginLogic>();

  void passengerRegister() async {
    EasyLoading.show();
    try {
      String passengerName = state.passengerName == ''
          ? "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}${DateTime.now().hour}${DateTime.now().minute}${DateTime.now().second}"
          : state.passengerName;

      final result = await _repository.register(
        fullName: passengerName,
        phoneNumber: loginLogic.state.phoneNumber.value,
        platform: Platform.isAndroid ? "android" : "ios",
        profileImage: state.profileImage,
      );
      result.when(
        ok: (data) {
          if (data.data?.token != null && data.data?.user != null) {
            _savePref.saveJsonToken(authModel: json.encode(data));
            Get.offAllNamed(AppRoutes.BOTTOMNAV);
          } else {
            _showRegisterError();
          }
        },
        err: (_) => _showRegisterError(),
      );
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _showRegisterError() {
    HapticFeedback.heavyImpact();
    showErrorCustomDialog(
      Get.context!,
      AppLocale.pleaseTryAgain.tr,
      AppLocale.pleaseLoginAgain.tr,
      () {
        Get.back();
      },
    );
  }

  removeProfileImage() {
    state.profileImage = null;
    update();
  }

  // image picker
  Future<void> getImageFromCamera() async {
    var imageFile = await _picker.pickImage(source: ImageSource.camera);
    if (imageFile != null) {
      state.profileImage = File(imageFile.path);
      Get.back();
      update();
    }
  }

  Future<void> getImageGallery() async {
    var imageFile = await _picker.pickImage(source: ImageSource.gallery);
    if (imageFile != null) {
      state.profileImage = File(imageFile.path);
      Get.back();
      update();
    }
  }

  void showModal() async {
    xShowModalBottomSheet(
      initialChildSize: 0.4,
      maxChildSize: 1.0,
      minChildSize: 0.1,
      context: Get.context!,
      body: (context, scrollController) {
        return SizedBox(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              XButton(
                onPress: () {
                  getImageGallery();
                },
                child: Container(
                  width: 180,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.light2,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Gallery\nរូបថត",
                        textAlign: TextAlign.center,
                        style: ThemeConstands.font16SemiBold,
                      ),
                    ],
                  ),
                ),
              ),
              XButton(
                onPress: () {
                  getImageFromCamera();
                },
                child: Container(
                  width: 180,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.light2,
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt),
                      SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Take a Photo\nថតរូប",
                        textAlign: TextAlign.center,
                        style: ThemeConstands.font16SemiBold,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    super.onClose();
    _removePref.removePhonePref();
    _removePref.removeRegisterPref();
  }
}
