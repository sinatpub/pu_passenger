import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/features/profile/data/datasource/profile_datasource.dart';
import 'package:com.tara.passenger/features/profile/data/models/profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._datasource);

  final ProfileDatasource _datasource;

  Future<Result<ProfileModel>> getProfile() => _datasource.getProfile();
}
