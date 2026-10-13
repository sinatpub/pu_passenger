import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/repository/referral_repository.dart';
import 'package:com.tara.passenger/presentation/screens/invite/logic.dart';
import 'package:flutter_test/flutter_test.dart';

class _Repository extends ReferralRepository {
  _Repository() : super(ReferralDatasource());

  Result<ReferralModel>? answer;
  int calls = 0;

  @override
  Future<Result<ReferralModel>> referral() async {
    calls++;
    return answer!;
  }
}

/// D40 — the one answer the QR sheet, the Profile card, the rewards screen
/// and the booking sheet all read.
void main() {
  late _Repository repository;
  late bool enabled;
  late InviteLogic logic;

  final offline = Result<ReferralModel>.err(
    const ApiException(type: ApiErrorType.connection, message: 'offline'),
  );

  setUp(() {
    repository = _Repository();
    enabled = true;
    logic = InviteLogic(repository, enabled: () => enabled);
  });

  test('nothing is asked while the feature is off', () async {
    enabled = false;
    await logic.fetch();

    expect(repository.calls, 0);
    expect(logic.creditBalance, 0);
  });

  test('the balance is the server\'s number', () async {
    repository.answer =
        Result.ok(const ReferralModel(code: 'PS4N7Q', rewardBalance: 2.07));
    await logic.fetch();

    expect(logic.creditBalance, 2.07);
    expect(logic.state.failed.value, isFalse);
    expect(logic.state.isLoading.value, isFalse);
  });

  test('a first fetch that fails says so', () async {
    repository.answer = offline;
    await logic.fetch();

    expect(logic.state.referral.value, isNull);
    expect(logic.state.failed.value, isTrue);
  });

  test('a refresh that fails keeps what was on screen', () async {
    repository.answer = Result.ok(const ReferralModel(rewardBalance: 2.07));
    await logic.fetch();
    repository.answer = offline;
    await logic.fetch();

    expect(logic.creditBalance, 2.07);
    expect(logic.state.failed.value, isFalse);
  });

  test('a sign-out forgets the last passenger\'s credit', () async {
    repository.answer = Result.ok(const ReferralModel(rewardBalance: 2.07));
    await logic.fetch();
    logic.clear();

    expect(logic.state.referral.value, isNull);
    expect(logic.creditBalance, 0);
  });
}
