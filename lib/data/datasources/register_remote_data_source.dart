import 'dart:io';

import 'package:com.tara.passenger/data/models/register_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:com.tara.passenger/core/api_service/base_api_service.dart';
import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:com.tara.passenger/core/utils/pretty_logger.dart';

class UserRegisterRemoteDataSource {
  final BaseApiService baseApiService = BaseApiService();

  UserRegisterRemoteDataSource();

  Future<RegisterModel> passengerRegister({
    required String fullName,
    required String phoneNumber,
    File? profileImage,
    required String platform,
  }) async {
    FormData data = FormData.fromMap({
      "fullname": fullName.toString(),
      "phone": phoneNumber.toString(),
      "profile_image": profileImage != null
          ? await MultipartFile.fromFile(profileImage.path)
          : "",
      "platform": platform.toString(),
      "device_token": "1234",
      "gender": "1" // man
    });

    return baseApiService.onRequest<RegisterModel>(
      path: "/taxi-passenger/register",
      method: "POST",
      headers: {
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      },
      onSuccess: (result) {
        tlog("Message after success ${result.data}}");
        return RegisterModel.fromJson(result.data);
      },
      bodyParse: data,
    );
  }
}
