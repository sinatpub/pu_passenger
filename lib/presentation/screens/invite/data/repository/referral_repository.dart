import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';

class ReferralRepository {
  ReferralRepository(this._datasource);

  final ReferralDatasource _datasource;

  Future<Result<ReferralModel>> referral() => _datasource.referral();

  Future<Result<InviteCodeCheck>> checkCode(String code) =>
      _datasource.checkCode(code);
}
