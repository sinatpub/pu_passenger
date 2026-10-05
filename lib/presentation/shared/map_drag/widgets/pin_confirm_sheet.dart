import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_radius.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/args.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/pickup_label.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The sheet under the pick-a-point map: the address the pin is on, and
/// Confirm. The pickup flow adds Screen 3's note for the driver.
///
/// Its own widget so it can be pumped in widget tests without the GoogleMap
/// platform view. Confirm still pops with the pin's `LatLng`, which the
/// `result is! LatLng` guard on the booking sheet awaits (P-05).
class PinConfirmSheet extends StatelessWidget {
  const PinConfirmSheet({super.key, required this.purpose});

  final MapDragPurpose purpose;

  bool get _isPickup => purpose == MapDragPurpose.pickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TaRadius.radiusXxl),
        ),
        boxShadow: TaShadows.shadowLg,
      ),
      padding: EdgeInsets.fromLTRB(
        20.d,
        16.d,
        20.d,
        20.d + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            purpose.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: TaColors.textMuted,
            ),
          ),
          SizedBox(height: 4.d),
          _address(),
          if (_isPickup) ...[
            SizedBox(height: 12.d),
            _driverNoteField(),
          ],
          SizedBox(height: 14.d),
          _confirmButton(),
        ],
      ),
    );
  }

  /// The pin's address as a name and its context — "Street 271" over "Daun
  /// Penh, Phnom Penh" — or two skeleton bars while it resolves.
  Widget _address() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.pickupLabel,
      builder: (logic) {
        final text = logic.pickupLabelText;
        final split = splitPlaceDescription(text);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _line(
              text == null ? null : split.primary ?? text,
              TaTextStyles.titleLarge.copyWith(color: TaColors.textPrimary),
              skeletonWidth: 180.d,
            ),
            SizedBox(height: 2.d),
            _line(
              text == null ? null : split.secondary ?? '',
              TaTextStyles.bodySmall.copyWith(color: TaColors.textSecondary),
              skeletonWidth: 120.d,
            ),
          ],
        );
      },
    );
  }

  /// One line of the address; null [text] is the skeleton state. It is always
  /// exactly one text line tall — the skeleton sits over a blank line — so
  /// the sheet, and the map above it, keep their size as addresses come and
  /// go.
  Widget _line(String? text, TextStyle style, {required double skeletonWidth}) {
    return Stack(
      alignment: AlignmentDirectional.centerStart,
      children: [
        Text(
          text == null || text.isEmpty ? ' ' : text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
        if (text == null)
          TaSkeleton(width: skeletonWidth, height: 12.d, radius: 4),
      ],
    );
  }

  /// A destination only needs a pin. A pickup follows Screen 3's state
  /// machine in `pickup_label.dart`: disabled until its address resolves.
  Widget _confirmButton() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.confirm,
      builder: (logic) {
        final canConfirm =
            _isPickup ? canConfirmPickup(logic.pickupConfirm) : logic.hasPin;
        return TaButton(
          label: purpose.confirmLabel,
          width: double.infinity,
          isEnabled: canConfirm,
          onTap: () => Get.back(result: logic.state.latlng),
        );
      },
    );
  }

  /// Screen 3's "Add a note for driver" — optional, capped to the spec's 60
  /// characters by `normaliseDriverNote` on the way into state (the display
  /// cap is cosmetic; the payload is what is validated).
  Widget _driverNoteField() {
    final logic = Get.find<MapDragLogic>();
    return TaNoteField(
      controller: logic.noteController,
      onChanged: logic.updateDriverNote,
      hint: AppLocale.addNoteForDriver.tr,
    );
  }
}
