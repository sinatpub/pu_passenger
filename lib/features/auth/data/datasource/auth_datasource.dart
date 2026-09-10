import 'dart:io';

import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/data/models/login_phone_model.dart';
import 'package:com.tara.passenger/data/models/register_model.dart';
import 'package:com.tara.passenger/data/models/user_response_model.dart';
import 'package:dio/dio.dart';

/// P-02 (docs/12) — replaces PhoneNumerRemoteDataSource, OtpVerifyApi and
/// UserRegisterRemoteDataSource (all BaseApiService-based) with
/// core/network/ApiClient + Result<T> (F-02), mirroring pu_driver's
/// features/auth/data/datasource/auth_datasource.dart. loginPhone/verifyOtp
/// are pre-auth endpoints and don't need a token attempt; register keeps
/// requiresToken at its default (true) to match the driver app's own
/// mirrored choice there, even though a fresh registrant has none yet.
class AuthDatasource {
  AuthDatasource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Result<PhoneNumberModel>> loginPhone(String phone) {
    return _apiClient.request<PhoneNumberModel>(
      path: '/taxi-passenger/login-phone',
      method: 'POST',
      requiresToken: false,
      body: {'phone': phone},
      decode: (response) => PhoneNumberModel.fromJson(response.data),
    );
  }

  Future<Result<UserResponseModel>> verifyOtp({
    required String phone,
    required String otpCode,
  }) {
    return _apiClient.request<UserResponseModel>(
      path: '/taxi-passenger/verify-phone-otp',
      method: 'POST',
      requiresToken: false,
      body: {'phone': phone, 'otp_code': otpCode},
      decode: (response) => UserResponseModel.fromJson(response.data),
    );
  }

  Future<Result<RegisterModel>> register({
    required String fullName,
    required String phoneNumber,
    File? profileImage,
    required String platform,
  }) async {
    final formData = FormData.fromMap({
      'fullname': fullName,
      'phone': phoneNumber,
      'profile_image':
          profileImage != null ? await MultipartFile.fromFile(profileImage.path) : '',
      'platform': platform,
      // Hardcoded pre-migration, and pu_driver's own mirrored register()
      // keeps an equivalent hardcoded placeholder too — preserved as-is,
      // not something to invent a fix for during a network-stack port.
      'device_token': '1234',
      'gender': '1',
    });

    // Dio sets the multipart/form-data content-type (with boundary)
    // automatically for FormData bodies — pu_passenger's ApiClient has no
    // headers parameter to set it explicitly, unlike pu_driver's.
    return _apiClient.request<RegisterModel>(
      path: '/taxi-passenger/register',
      method: 'POST',
      body: formData,
      decode: (response) => RegisterModel.fromJson(response.data),
    );
  }
}
