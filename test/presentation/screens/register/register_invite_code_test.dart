import 'dart:async';
import 'dart:io';

import 'package:com.tara.passenger/core/network/api_exception.dart';
import 'package:com.tara.passenger/core/network/result.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/datasource/referral_datasource.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/models/referral_model.dart';
import 'package:com.tara.passenger/presentation/screens/invite/data/repository/referral_repository.dart';
import 'package:com.tara.passenger/presentation/screens/invite/widgets/invite_code_field.dart';
import 'package:com.tara.passenger/presentation/screens/register/logic.dart';
import 'package:com.tara.passenger/presentation/screens/register/state.dart';
import 'package:com.tara.passenger/presentation/screens/register/view.dart';
import 'package:flutter_test/flutter_test.dart';

class _Referral extends ReferralRepository {
  _Referral() : super(ReferralDatasource());

  final List<String> asked = <String>[];

  /// Answers in the order the checks were made, when the test completes them.
  final List<Completer<Result<InviteCodeCheck>>> pending =
      <Completer<Result<InviteCodeCheck>>>[];

  @override
  Future<Result<InviteCodeCheck>> checkCode(String code) {
    asked.add(code);
    final c = Completer<Result<InviteCodeCheck>>();
    pending.add(c);
    return c.future;
  }
}

/// D40 — the optional invite code on the sign-up form.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _Referral referral;
  late RegisterLogic logic;

  Result<InviteCodeCheck> yes(String name) =>
      Result.ok(InviteCodeCheck(valid: true, inviterName: name));
  final Result<InviteCodeCheck> no =
      Result.ok(const InviteCodeCheck(valid: false));

  setUp(() {
    referral = _Referral();
    logic = RegisterLogic(
      referralRepository: referral,
      inviteCheckDelay: Duration.zero,
    );
  });

  Future<void> type(String text) async {
    logic.onInviteCodeChanged(text);
    await pumpEventQueue();
  }

  test('a typed code is checked, upper case and without spaces', () async {
    await type('pu 7k2m');

    expect(referral.asked, ['PU7K2M']);
    expect(logic.state.inviteStatus, InviteCodeStatus.checking);
  });

  test('a code the server knows shows whose it is', () async {
    await type('PU7K2M');
    referral.pending.single.complete(yes('Dara Sok'));
    await pumpEventQueue();

    expect(logic.state.inviteStatus, InviteCodeStatus.valid);
    expect(logic.state.inviterName, 'Dara Sok');
  });

  test('a code nobody has is refused', () async {
    await type('NOPE00');
    referral.pending.single.complete(no);
    await pumpEventQueue();

    expect(logic.state.inviteStatus, InviteCodeStatus.invalid);
    expect(logic.state.inviterName, isNull);
  });

  test('a check that cannot be made is not a "no"', () async {
    await type('PU7K2M');
    referral.pending.single.complete(Result.err(const ApiException(
        type: ApiErrorType.connection, message: 'offline')));
    await pumpEventQueue();

    expect(logic.state.inviteStatus, InviteCodeStatus.failed);
  });

  test('an answer for a code since changed is ignored', () async {
    await type('PU7K2M');
    await type('SOKHA88');
    referral.pending.first.complete(no);
    await pumpEventQueue();
    expect(logic.state.inviteStatus, InviteCodeStatus.checking);

    referral.pending.last.complete(yes('Sokha Vann'));
    await pumpEventQueue();
    expect(logic.state.inviteStatus, InviteCodeStatus.valid);
    expect(logic.state.inviterName, 'Sokha Vann');
  });

  test('clearing the field is no code at all', () async {
    await type('PU7K2M');
    await type('');

    expect(logic.state.inviteCode, '');
    expect(logic.state.inviteStatus, InviteCodeStatus.idle);
  });

  group('Create with an invite code', () {
    RegisterState stateWith(InviteCodeStatus status) => RegisterState()
      ..passengerName = 'Mey Lin'
      ..profileImage = File('photo.jpg')
      ..inviteStatus = status;

    test('no code, a known code, or a check that failed: allowed', () {
      for (final status in [
        InviteCodeStatus.idle,
        InviteCodeStatus.valid,
        InviteCodeStatus.failed,
      ]) {
        expect(canSubmitRegistration(stateWith(status)), isTrue,
            reason: status.name);
      }
    });

    test('a refused code, or one still being checked: blocked', () {
      for (final status in [
        InviteCodeStatus.invalid,
        InviteCodeStatus.checking,
      ]) {
        expect(canSubmitRegistration(stateWith(status)), isFalse,
            reason: status.name);
      }
    });
  });
}
