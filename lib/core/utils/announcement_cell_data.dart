import 'package:com.tara.passenger/core/utils/display_date.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:get/get.dart';

/// Display rules for the announcement list and detail (S3), kept pure so the
/// degrade cases are testable — the same split as `history_cell_data.dart` (S1)
/// and `fee_presentation.dart` (C6).

/// How much of the body a list card shows before it is cut.
const int kAnnouncementExcerptLength = 120;

/// The card's title, or the untitled fallback. An announcement with no title
/// is still worth showing — it has a body and a date.
String announcementTitle(String? title) {
  final text = title?.trim();
  if (text == null || text.isEmpty || text == 'null') {
    return AppLocale.untitledAnnouncement.tr;
  }
  return text;
}

/// A one-glance excerpt of the body (roadmap S3 Done When: "cards show
/// title/excerpt/date from existing fields").
///
/// Returns null when there is no body, so the caller drops the line rather
/// than printing "Unknown" under every title. Whitespace is collapsed first:
/// announcements are authored in a web editor and arrive with newlines that
/// would otherwise blow the card's height out before the ellipsis is reached.
String? announcementExcerpt(
  String? description, {
  int maxLength = kAnnouncementExcerptLength,
}) {
  final text = description?.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (text == null || text.isEmpty || text == 'null') return null;
  if (text.length <= maxLength) return text;
  // Cut on a word boundary where there is one nearby, so the excerpt does not
  // end mid-word.
  final cut = text.substring(0, maxLength);
  final lastSpace = cut.lastIndexOf(' ');
  final body = lastSpace > maxLength - 20 ? cut.substring(0, lastSpace) : cut;
  return '${body.trimRight()}…';
}

/// The announcement's date, degrading to an em dash.
String announcementDate(Object? createdAt) => displayIsoDate(createdAt);

/// The body as shown on the detail screen, or null when there is none.
String? announcementBody(String? description) {
  final text = description?.trim();
  if (text == null || text.isEmpty || text == 'null') return null;
  return text;
}

/// The image URLs on an announcement.
///
/// `files` is `List<dynamic>` of raw maps, so each entry is probed rather than
/// cast — one malformed row must not take the detail screen down, which a bare
/// `files[i]["file_url"]` would do for a non-map entry.
List<String> announcementImageUrls(List<dynamic>? files) {
  if (files == null) return const [];
  final urls = <String>[];
  for (final entry in files) {
    if (entry is! Map) continue;
    final url = entry['file_url']?.toString().trim();
    if (url == null || url.isEmpty || url == 'null') continue;
    urls.add(url);
  }
  return urls;
}
