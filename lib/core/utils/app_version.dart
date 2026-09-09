import 'package:package_info_plus/package_info_plus.dart';

/// P-16 (docs/12) — the installed app version, read at runtime.
///
/// This replaces two hardcoded `"1.0.15"` literals in `AppLogic`. They had
/// drifted five releases behind `pubspec.yaml` (1.1.8), so the force-update
/// comparison was measuring the server's version against a string this app
/// had not been for a long time.
Future<String> installedAppVersion() async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
}

/// Whether to prompt the passenger to update.
///
/// Extracted as a pure function so the decision is testable without a
/// platform channel. The behaviour is deliberately preserved verbatim from
/// the original inline condition, including its quirk: a matching release
/// date suppresses the prompt even when the versions differ. That is a
/// business rule this refactor is not entitled to change (`.agent/RULES.md`
/// §Quirks that must survive any refactor).
bool shouldPromptUpdate({
  required String currentVersion,
  required String serverVersion,
  required String releaseDate,
  required String updateDate,
}) {
  if (currentVersion == serverVersion || releaseDate == updateDate) {
    return false;
  }
  return currentVersion != serverVersion && releaseDate != updateDate;
}
