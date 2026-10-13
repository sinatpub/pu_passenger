import 'package:com.tara.passenger/core/network/api_client.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';

/// The invite routes (D40). None exists on the real backend yet; the QA mock
/// backend answers them. The shapes are the ones in the backend spec,
/// section 5.
class ReferralDatasource {
  ReferralDatasource({ApiClient? apiClient}) : _injectedClient = apiClient;

  final ApiClient? _injectedClient;

  /// Lazy, as in `RequestBookingApi`: a test subclass that overrides every
  /// method must not build a Dio-backed client.
  late final ApiClient _apiClient = _injectedClient ?? ApiClient();

  Future<Result<ReferralModel>> referral() => _apiClient.request<ReferralModel>(
        path: '/taxi-passenger/referral',
        method: 'GET',
        decode: (response) => ReferralModel.fromJson(response.data),
      );

  /// Public: the person typing a code has no account yet.
  Future<Result<InviteCodeCheck>> checkCode(String code) =>
      _apiClient.request<InviteCodeCheck>(
        path: '/taxi-passenger/referral/check-code',
        method: 'GET',
        requiresToken: false,
        query: <String, dynamic>{'code': code},
        decode: (response) => InviteCodeCheck.fromJson(response.data),
      );
}
