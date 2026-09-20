import 'package:com.tara.passenger/core/utils/app_ext.dart';

/// An ISO timestamp formatted for display, or an em dash when there is nothing
/// usable to show.
///
/// The backend hands these over as nullable strings that are not always
/// well-formed, and the screens that render them used to call
/// `DateTime.parse("${value}")` bare — which throws on null, on an empty
/// string and on anything malformed, taking the whole list or detail screen
/// down with it. Parsing is attempted here and degrades instead
/// (`.agent/RULES.md` §Payload policy: display degrades, money fails loudly).
///
/// Shared so the history card (S1) and the announcement card (S3) cannot drift
/// apart on what a missing date looks like.
String displayIsoDate(Object? value) {
  final raw = value?.toString().trim();
  if (raw == null || raw.isEmpty || raw == 'null') return '—';
  final parsed = DateTime.tryParse(raw);
  if (parsed == null) return '—';
  return parsed.formatDateTime();
}
