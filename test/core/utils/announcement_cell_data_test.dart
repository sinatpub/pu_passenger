import 'package:flutter_test/flutter_test.dart';

import 'package:com.tara.passenger/core/utils/announcement_cell_data.dart';
import 'package:com.tara.passenger/core/utils/display_date.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

void main() {
  group('displayIsoDate (shared by S1 history and S3 announcements)', () {
    test('formats an ISO timestamp', () {
      expect(displayIsoDate('2026-09-11T09:41:00'), contains('2026'));
    });

    test('degrades rather than throwing', () {
      // The screens this replaced called `DateTime.parse("${value}")` bare,
      // which throws on every one of these.
      expect(displayIsoDate(null), '—');
      expect(displayIsoDate(''), '—');
      expect(displayIsoDate('null'), '—');
      expect(displayIsoDate('not a date'), '—');
    });
  });

  group('announcementTitle', () {
    test('passes a real title through, trimmed', () {
      expect(announcementTitle('  Fare update  '), 'Fare update');
    });

    test('an announcement with no title still gets a heading', () {
      expect(announcementTitle(null), AppLocale.untitledAnnouncement);
      expect(announcementTitle('   '), AppLocale.untitledAnnouncement);
      expect(announcementTitle('null'), AppLocale.untitledAnnouncement);
    });
  });

  group('announcementExcerpt', () {
    test('a short body is shown whole, with no ellipsis', () {
      expect(announcementExcerpt('Short notice.'), 'Short notice.');
    });

    test('collapses the newlines a web editor leaves behind', () {
      expect(
        announcementExcerpt('Line one.\n\n   Line two.'),
        'Line one. Line two.',
      );
    });

    test('cuts a long body and marks it with an ellipsis', () {
      final excerpt = announcementExcerpt('word ' * 100);

      expect(excerpt, isNotNull);
      expect(excerpt!.endsWith('…'), isTrue);
      expect(excerpt.length, lessThanOrEqualTo(kAnnouncementExcerptLength + 1));
    });

    test('cuts on a word boundary rather than mid-word', () {
      final excerpt = announcementExcerpt(
        'alpha bravo charlie delta echo foxtrot golf hotel india juliet '
        'kilo lima mike november oscar papa quebec romeo sierra tango',
        maxLength: 40,
      );

      expect(excerpt, isNotNull);
      // The char before the ellipsis should end a word, not split one.
      expect(excerpt!.endsWith('…'), isTrue);
      expect(excerpt.contains('  '), isFalse);
    });

    test('no body returns null so the caller drops the line', () {
      expect(announcementExcerpt(null), isNull);
      expect(announcementExcerpt('   '), isNull);
      expect(announcementExcerpt('null'), isNull);
    });
  });

  group('announcementBody', () {
    test('trims a real body', () {
      expect(announcementBody('  Full text.  '), 'Full text.');
    });

    test('no body returns null', () {
      expect(announcementBody(null), isNull);
      expect(announcementBody('null'), isNull);
    });
  });

  group('announcementImageUrls — one bad row must not break the screen', () {
    test('collects the file urls', () {
      expect(
        announcementImageUrls([
          {'file_url': 'https://a.example/1.png'},
          {'file_url': 'https://a.example/2.png'},
        ]),
        ['https://a.example/1.png', 'https://a.example/2.png'],
      );
    });

    test('skips non-map entries instead of throwing', () {
      // A bare `files[i]["file_url"]` throws on these.
      expect(
        announcementImageUrls([
          'not a map',
          42,
          null,
          {'file_url': 'https://a.example/ok.png'},
        ]),
        ['https://a.example/ok.png'],
      );
    });

    test('skips rows with a missing or empty url', () {
      expect(
        announcementImageUrls([
          {'other': 'x'},
          {'file_url': null},
          {'file_url': '  '},
          {'file_url': 'null'},
        ]),
        isEmpty,
      );
    });

    test('no files at all yields an empty list', () {
      expect(announcementImageUrls(null), isEmpty);
      expect(announcementImageUrls([]), isEmpty);
    });
  });
}
