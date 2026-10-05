import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pin marks the map centre with its tip. `current_marker.svg` is 39×52
/// with the tip at y≈46, so a centred box must shift up by
/// size × (46/52 − 0.5) for the tip to land on the centre.
void main() {
  const area = Key('area');
  Widget host(Widget pin) => MaterialApp(
        home: Center(key: area, child: pin),
      );

  testWidgets('tip sits on the centre, not the box centre', (tester) async {
    await tester.pumpWidget(host(const TaCenterPin(size: 60)));

    final box = tester.getRect(find.byType(SvgPicture));
    final tipY = box.top + 60 * (46 / 52);
    expect(tipY,
        moreOrLessEquals(tester.getCenter(find.byKey(area)).dy, epsilon: 0.01));
  });

  testWidgets('callout floats above the pin box by the gap', (tester) async {
    await tester.pumpWidget(host(const TaCenterPin(
      size: 60,
      calloutGap: 12,
      callout: SizedBox(key: Key('callout'), width: 80, height: 20),
    )));

    final pin = tester.getRect(find.byType(SvgPicture));
    final callout = tester.getRect(find.byKey(const Key('callout')));
    expect(callout.bottom, moreOrLessEquals(pin.top - 12, epsilon: 0.01));
    expect(callout.center.dx, moreOrLessEquals(pin.center.dx, epsilon: 0.01));
  });
}
