import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/features/profile/data/models/profile_model.dart';

/// P-14 (docs/12) — replaces the old ProfileApi (BaseApiService-based) with
/// core/network/ApiClient + Result<T> (F-02), mirroring pu_driver's own
/// features/profile/data/datasource/profile_datasource.dart.
class ProfileDatasource {
  ProfileDatasource({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<Result<ProfileModel>> getProfile() {
    return _apiClient.request<ProfileModel>(
      path: '/taxi-passenger/get-profile',
      method: 'GET',
      decode: (response) => ProfileModel.fromJson(response.data),
    );
  }
}
