import 'dart:io';

import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/login_phone_model.dart';
import 'package:com.tara.passenger/data/models/register_model.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:com.tara.passenger/features/auth/data/datasource/auth_datasource.dart';

class AuthRepository {
  AuthRepository(this._datasource);

  final AuthDatasource _datasource;

  Future<Result<PhoneNumberModel>> loginPhone(String phone) => _datasource.loginPhone(phone);

  Future<Result<UserResponseModel>> verifyOtp({required String phone, required String otpCode}) =>
      _datasource.verifyOtp(phone: phone, otpCode: otpCode);

  Future<Result<RegisterModel>> register({
    required String fullName,
    required String phoneNumber,
    File? profileImage,
    required String platform,
  }) =>
      _datasource.register(
        fullName: fullName,
        phoneNumber: phoneNumber,
        profileImage: profileImage,
        platform: platform,
      );
}
