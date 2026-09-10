import 'package:com.tara.passenger/presentation/screens/booking_map_screen/poll_policy.dart';
import 'package:flutter_test/flutter_test.dart';

/// P-09 remainder / F-03 (docs/12, docs/10 §2.4). The 10s poll used to run
/// unconditionally alongside the socket — six redundant requests a minute per
/// passenger in a trip. These pin the bounded-fallback policy, including the
/// deliberate decision *not* to switch the poll off entirely.
void main() {
  group('shouldPollOnTick — socket down', () {
    test('polls on every tick, because it is the only channel left', () {
      for (var tick = 1; tick <= 12; tick++) {
        expect(
          shouldPollOnTick(socketConnected: false, tick: tick),
          isTrue,
          reason: 'tick $tick must poll while the socket is down',
        );
      }
    });
  });

  group('shouldPollOnTick — socket healthy', () {
    test('stays quiet for the first five ticks', () {
      for (var tick = 1; tick <= 5; tick++) {
        expect(
          shouldPollOnTick(socketConnected: true, tick: tick),
          isFalse,
          reason: 'tick $tick should defer to the socket',
        );
      }
    });

    test('still polls once every six ticks as a safety net', () {
      expect(shouldPollOnTick(socketConnected: true, tick: 6), isTrue);
      expect(shouldPollOnTick(socketConnected: true, tick: 12), isTrue);
      expect(shouldPollOnTick(socketConnected: true, tick: 18), isTrue);
    });

    test('the fallback is bounded, never disabled — a transport-level '
        'connection can be up while the server has gone quiet', () {
      final polls = <int>[];
      for (var tick = 1; tick <= 60; tick++) {
        if (shouldPollOnTick(socketConnected: true, tick: tick)) {
          polls.add(tick);
        }
      }
      // 60 ticks at 10s = 10 minutes. One request a minute, not zero and
      // not six.
      expect(polls, hasLength(10));
      expect(polls.first, kHealthySocketPollEveryTicks);
    });
  });

  group('shouldPollOnTick — transitions', () {
    test('a drop mid-cycle resumes full-rate polling immediately, without '
        'waiting for the next safety-net tick', () {
      // Tick 3 with a healthy socket would have stayed quiet...
      expect(shouldPollOnTick(socketConnected: true, tick: 3), isFalse);
      // ...but the same tick with the socket down must poll.
      expect(shouldPollOnTick(socketConnected: false, tick: 3), isTrue);
    });
  });
}
