/// P-09 remainder (docs/12, docs/10 §2.4) — "socket primary, bounded poll
/// fallback".
///
/// The trip screen is refreshed by two channels: socket events and a 10s
/// poll. The poll used to run unconditionally, so a healthy socket still cost
/// six redundant requests a minute per passenger in a trip.
///
/// The fallback is *bounded*, not switched off. Cancelling the poll outright
/// while the socket reports connected would trust the socket further than it
/// has earned: a connection can be up at the transport layer while the server
/// has stopped sending booking updates, and the passenger would then watch a
/// frozen trip screen with no way to notice. So a healthy socket reduces the
/// poll to a safety net rather than removing it.
///
/// Ticks between polls while the socket is healthy. With the screen's 10s
/// timer this is one request a minute instead of six.
const int kHealthySocketPollEveryTicks = 6;

/// Whether this timer tick should fetch.
///
/// [tick] counts from 1 and increments on every timer fire, whether or not it
/// polled — so the safety net stays on a wall-clock cadence rather than
/// drifting with connection state.
bool shouldPollOnTick({required bool socketConnected, required int tick}) {
  // Socket down: it is the only channel left, so poll every tick.
  if (!socketConnected) return true;
  // Socket healthy: keep a bounded safety net.
  return tick % kHealthySocketPollEveryTicks == 0;
}
