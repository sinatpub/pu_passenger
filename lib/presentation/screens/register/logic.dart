import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/repository/referral_repository.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/screens/invite/scan_view.dart';
import 'package:com.tara.passenger/presentation/screens/invite/widgets/invite_code_field.dart';
import 'package:com.tara.passenger/presentation/screens/login/data/repository/auth_repository.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';
import 'package:com.tara.passenger/routes/app_pages.dart';
import 'package:com.tara.passenger/storages/remove_storage.dart';
import 'package:com.tara.passenger/services/session_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../translations/app_locale.dart';
import '../../widgets/error_dialog_widget.dart';
import 'photo_source_sheet.dart';
import 'state.dart';

class RegisterLogic extends GetxController {
  /// Collaborators arrive by constructor and resolve lazily. A `Get.find`
  /// in a field initializer runs at construction, so building this
  /// controller demanded every collaborator already be registered — the
  /// gap logged in `.agent/TODO.md` Discovered Tasks against
  /// `docs/10` §3.2. Production behaviour is unchanged: bindings register
  /// everything before first access.
  RegisterLogic({
    AuthRepository? repository,
    LoginLogic? loginLogic,
    ReferralRepository? referralRepository,
    Duration inviteCheckDelay = const Duration(milliseconds: 450),
  })  : _injectedRepository = repository,
        _injectedLoginLogic = loginLogic,
        _injectedReferralRepository = referralRepository,
        _inviteCheckDelay = inviteCheckDelay;

  final AuthRepository? _injectedRepository;
  final LoginLogic? _injectedLoginLogic;
  final ReferralRepository? _injectedReferralRepository;
  final Duration _inviteCheckDelay;

  late final ReferralRepository _referralRepository =
      _injectedReferralRepository ?? ReferralRepository(ReferralDatasource());

  late final AuthRepository _repository =
      _injectedRepository ?? Get.find<AuthRepository>();
  late final LoginLogic loginLogic =
      _injectedLoginLogic ?? Get.find<LoginLogic>();
  final RegisterState state = RegisterState();
  final RemoveStoragePref _removePref = RemoveStoragePref();
  final ImagePicker _picker = ImagePicker();

  TextEditingController controllerName = TextEditingController();

  // ── Invite code (D40) ────────────────────────────────────────────────────

  final TextEditingController controllerInviteCode = TextEditingController();
  Timer? _inviteCheckTimer;

  /// The code is checked a moment after the person stops typing, so the form
  /// can say whose it is before they submit. The server checks it again at
  /// sign-up; this is the early answer, not the rule.
  void onInviteCodeChanged(String text) {
    final String code = text.replaceAll(' ', '').toUpperCase();
    _inviteCheckTimer?.cancel();
    state
      ..inviteCode = code
      ..inviterName = null
      ..inviteStatus =
          code.isEmpty ? InviteCodeStatus.idle : InviteCodeStatus.checking;
    update();
    if (code.isEmpty) return;
    _inviteCheckTimer = Timer(_inviteCheckDelay, () => _checkInviteCode(code));
  }

  Future<void> _checkInviteCode(String code) async {
    final result = await _referralRepository.checkCode(code);
    // An answer for a code the person has since changed says nothing.
    if (isClosed || state.inviteCode != code) return;
    result.when(
      ok: (check) {
        state
          ..inviteStatus =
              check.valid ? InviteCodeStatus.valid : InviteCodeStatus.invalid
          ..inviterName = check.valid ? check.inviterName : null;
      },
      err: (_) => state.inviteStatus = InviteCodeStatus.failed,
    );
    update();
  }

  /// Opens the scanner and puts the scanned code in the field.
  Future<void> scanInviteCode() async {
    final String? code =
        parseInviteCode(await Get.to<String>(() => const InviteScanPage()));
    if (code == null) return;
    controllerInviteCode.text = code;
    onInviteCodeChanged(code);
  }
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
        inviteCode: state.inviteCode,
      );
      await result.when<FutureOr<void>>(
        ok: (data) async {
          if (data.data?.token != null && data.data?.user != null) {
            await SessionService.instance.startSession(
              token: data.data?.token,
              signInRecord: json.encode(data),
            );
            Get.offAllNamed(AppRoutes.BOTTOMNAV);
          } else {
            _showRegisterError();
          }
        },
        err: (error) {
          // D40: the server is the last word on an invite code.
          if (error.statusCode == 422 && state.inviteCode.isNotEmpty) {
            state.inviteStatus = InviteCodeStatus.invalid;
            update();
            return;
          }
          _showRegisterError();
        },
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
  Future<void> getImageFromCamera() => _pickImage(ImageSource.camera);

  Future<void> getImageGallery() => _pickImage(ImageSource.gallery);

  Future<void> _pickImage(ImageSource source) async {
    final imageFile = await _picker.pickImage(source: source);
    if (imageFile == null) return;
    state.profileImage = File(imageFile.path);
    update();
  }

  /// Asks where the photo comes from, then goes there. The sheet is closed
  /// by the time the camera or the gallery opens.
  Future<void> showModal() async {
    final choice = await PhotoSourceSheet.show(
      Get.context!,
      hasPhoto: state.profileImage != null,
    );
    switch (choice) {
      case PhotoSourceChoice.camera:
        await getImageFromCamera();
      case PhotoSourceChoice.gallery:
        await getImageGallery();
      case PhotoSourceChoice.remove:
        removeProfileImage();
      case null:
        break;
    }
  }

  @override
  void onClose() {
    _inviteCheckTimer?.cancel();
    controllerInviteCode.dispose();
    super.onClose();
    _removePref.removePhonePref();
    _removePref.removeRegisterPref();
  }
}
