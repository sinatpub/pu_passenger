import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/core/helper/phone_validate_helper.dart';
import 'package:com.tara.passenger/presentation/screens/login/logic.dart';

/// Characterization tests for the auth validation quirks (roadmap S4 Risk:
/// "validation quirks are easy to 'fix' by accident"; Done When: "Validation
/// behaviour is identical to the baseline").
///
/// **Written before the S4 re-skin and passing against the pre-re-skin code**,
/// so they pin the baseline rather than describe the result. S4's Verification
/// line refers to "auth tests" that did not exist — these are them.
///
/// Several assertions below pin behaviour that is arguably wrong. That is the
/// point: this file records what the app *does*, so a re-skin cannot quietly
/// change it. Anything genuinely worth fixing is called out in
/// `IMPLEMENTATION_PROGRESS.md`, not corrected here.
void main() {
  group('PhoneRepo.isValid — the login phone rule (preserve exactly)', () {
    late PhoneRepo repo;

    setUp(() => repo = PhoneRepo());

    test('rejects an empty number', () {
      expect(repo.isValid(''), isFalse);
      expect(repo.getErrorMessage(), 'Phone Number cannot be empty');
    });

    test('rejects anything non-numeric', () {
      expect(repo.isValid('012abc789'), isFalse);
      expect(repo.getErrorMessage(), 'Phone number must contain only numbers.');
    });

    test('rejects a number with spaces, because spaces are not digits', () {
      // The caller strips whitespace before getting here
      // (`phoneLogin` passes `phone.removeAllWhitespace`), so this only bites
      // a caller that forgets to.
      expect(repo.isValid('012 345 678'), isFalse);
    });

    test('accepts 8 digits — the real lower bound', () {
      expect(repo.isValid('01234567'), isTrue);
    });

    test('rejects 7 digits', () {
      expect(repo.isValid('0123456'), isFalse);
    });

    test('accepts 15 digits and rejects 16', () {
      expect(repo.isValid('0' * 15), isTrue);
      expect(repo.isValid('0' * 16), isFalse);
    });

    test('the length error message disagrees with the length check', () {
      // Pinned, not fixed: the check is `length < 8` but the message says
      // "between 9 and 15 digits". Recorded as a copy bug for P2.
      repo.isValid('0123456');
      expect(
        repo.getErrorMessage(),
        'Phone number must be between 9 and 15 digits.',
      );
    });

    test('a fresh repo with no call yields the generic message', () {
      expect(PhoneRepo().getErrorMessage(), 'Invalid phone number.');
    });
  });

  group('LoginLogic.validatePhoneNumber — normalization (preserve exactly)',
      () {
    late LoginLogic logic;

    // The repository field resolves lazily and only `phoneLogin` touches it,
    // which these tests never call — so nothing needs to be registered.
    setUp(() => logic = LoginLogic());

    test('strips whitespace', () {
      expect(logic.validatePhoneNumber('012 345 678'), '012345678');
    });

    test('prepends a leading zero when missing', () {
      expect(logic.validatePhoneNumber('12345678'), '012345678');
    });

    test('leaves an existing leading zero alone', () {
      expect(logic.validatePhoneNumber('012345678'), '012345678');
    });

    test('strips whitespace before deciding about the zero', () {
      expect(logic.validatePhoneNumber(' 12 345 678 '), '012345678');
    });
  });

  group('LoginLogic.validatePhone — the form validator', () {
    late LoginLogic logic;

    // The repository field resolves lazily and only `phoneLogin` touches it,
    // which these tests never call — so nothing needs to be registered.
    setUp(() => logic = LoginLogic());

    test('requires a number', () {
      expect(logic.validatePhone(null), 'Phone number is required');
      expect(logic.validatePhone(''), 'Phone number is required');
    });

    test('requires at least 10 characters', () {
      // Pinned, not reconciled: this says 10 while `PhoneRepo.isValid` accepts
      // 8. The two rules genuinely disagree; `phoneLogin` gates on isValid.
      expect(
        logic.validatePhone('012345678'),
        'Phone number must be at least 10 digits',
      );
      expect(logic.validatePhone('0123456789'), isNull);
    });
  });
}
