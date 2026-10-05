import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/widgets/search_panel.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The search view that opens over the pick-a-point map: the field at the
/// top with the keyboard up, and the results directly under it.
///
/// Back returns to the map, not out of the page. The search itself — the
/// debounce, the three-character threshold, `selectPlace` popping with the
/// place's `LatLng` — is `MapDragLogic`'s and unchanged.
class MapDragSearchView extends StatelessWidget {
  const MapDragSearchView({super.key});

  /// `TaTextField`'s input box; the back button is centred on it.
  static const double _fieldHeight = 54;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TaColors.background,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.d, 12.d, 16.d, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: _fieldHeight,
                    child: TaIconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      semanticLabel: AppLocale.back.tr,
                      onTap: Get.find<MapDragLogic>().closeSearch,
                    ),
                  ),
                  SizedBox(width: 10.d),
                  Expanded(child: _field()),
                ],
              ),
            ),
            Expanded(
              child: GetBuilder<MapDragLogic>(
                id: MapDragUpdate.fetchLocation,
                builder: (logic) => SearchPanel(logic: logic),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rebuilds on `search`, the id the field's own listener sends on every
  /// edit, so the clear button comes and goes with the text.
  Widget _field() {
    return GetBuilder<MapDragLogic>(
      id: MapDragUpdate.search,
      builder: (logic) => TaTextField(
        prefix:
            const Icon(Icons.search, size: 20, color: TaColors.textMuted),
        suffix: logic.searchController.text.isEmpty
            ? null
            : Semantics(
                button: true,
                label: AppLocale.clearSearch.tr,
                excludeSemantics: true,
                child: TaPressable(
                  onTap: logic.clearSearch,
                  child: Padding(
                    padding: EdgeInsets.all(6.d),
                    child: const Icon(Icons.close,
                        size: 18, color: TaColors.textSecondary),
                  ),
                ),
              ),
        textInputAction: TextInputAction.search,
        controller: logic.searchController,
        onChanged: logic.fetchPlaceSuggestions,
        hint: AppLocale.searchForPlace.tr,
        autofocus: true,
      ),
    );
  }
}
