import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 8's search-results panel, driven by the `DestinationSearchStatus`
/// state machine in `search_state.dart` rather than by "is there a list".
///
/// Extracted from `MapDragPage` (C4) so the whole state table can be pumped
/// in widget tests without the GoogleMap platform view. Sizes to its content
/// (capped at half the screen) and returns to the caller via `logic` —
/// `selectPlace` (which pops `/map` with the pinned `LatLng`) and
/// `fetchPlaceSuggestions` (retry) stay in the logic, so the pin-commit
/// semantics P-05 pinned are untouched.
class SearchPanel extends StatelessWidget {
  const SearchPanel({super.key, required this.logic});

  final MapDragLogic logic;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: TaShadows.shadowLg,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: Get.height * 0.5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_body(context)],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final status = logic.searchStatus;
    final predictions = logic.state.suggestLocationData.predictions ?? const [];
    final hasPreviousResults = predictions.isNotEmpty;

    // ignore: avoid_print
    print('[QA] panel status=$status predictions=${predictions.length}');
    switch (status) {
      case DestinationSearchStatus.idle:
      case DestinationSearchStatus.belowThreshold:
        // The spec shows recents here; the app has no recents storage, so it
        // degrades to the "set on map" affordance. See PROGRESS.md.
        return _hintState(AppLocale.searchForPlace.tr);
      case DestinationSearchStatus.searching:
        if (hasPreviousResults) {
          // Spec: previous results stay visible, dimmed, rather than flashing
          // to an empty list between keystrokes.
          return Opacity(opacity: 0.4, child: _resultList(context));
        }
        return const _SkeletonResults();
      case DestinationSearchStatus.error:
        return _errorState(context);
      case DestinationSearchStatus.empty:
        return _emptyState();
      case DestinationSearchStatus.results:
        return _resultList(context);
    }
  }

  Widget _resultList(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 4),
            itemCount: logic.state.suggestLocationData.predictions?.length ?? 0,
            itemBuilder: (context, index) {
              final prediction =
                  logic.state.suggestLocationData.predictions![index];
              final split = splitPlaceDescription(prediction.description);
              return TaSearchResult(
                name: split.primary ?? AppLocale.noResultFound.tr,
                keyword: split.secondary ?? '',
                // Placeline responses carry no distance, so the badge is
                // omitted rather than faked (TaSearchResult hides it).
                onTap: () => _select(logic, prediction, context),
              );
            },
          ),
        ),
        const Divider(color: TaColors.border, height: 1),
        _setOnMapRow(),
      ],
    );
  }

  void _select(
      MapDragLogic logic, Prediction prediction, BuildContext context) {
    logic.searchController.text = prediction.description ?? '';
    logic.state.selectedPrediction = prediction;
    logic.selectPlace(logic.state.selectedPrediction);
    logic.update();
    FocusScope.of(context).unfocus();
  }

  /// Screen 8's empty state: `No places match "xyz"` + `Set on map` +
  /// `Check the spelling`.
  Widget _emptyState() {
    final query = logic.state.searchQuery.trim();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.d),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: TaColors.textMuted),
          SizedBox(height: 12.d),
          Text(
            '${AppLocale.noPlacesMatch.tr} "${query.isEmpty ? logic.searchController.text : query}"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocale.checkSpelling.tr,
            style: const TextStyle(fontSize: 14, color: TaColors.textMuted),
          ),
          SizedBox(height: 20.d),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 60.d),
            child: Column(
              children: [
                const Divider(color: TaColors.border, height: 1),
                _setOnMapRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Screen 8's failure state: `Couldn't search right now` + `Retry`, with
  /// the typed query kept so the retry re-runs the same search.
  Widget _errorState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24.d),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 48, color: TaColors.textMuted),
          SizedBox(height: 12.d),
          Text(
            AppLocale.couldntSearch.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: TaColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.d),
          SizedBox(
            width: 140.d,
            child: TaButton(
              label: AppLocale.retry.tr,
              size: TaButtonSize.small,
              onTap: () =>
                  logic.fetchPlaceSuggestions(logic.searchController.text),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14,
          color: TaColors.textSecondary,
        ),
      ),
    );
  }

  /// The pinned "Set location on the map" row at the foot of Screen 8's list.
  Widget _setOnMapRow() {
    return GestureDetector(
      onTap: () {
        logic.state.isShowMap = true;
        logic.update([MapDragUpdate.search, MapDragUpdate.confirm]);
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.d, vertical: 10.d),
        child: Row(
          children: [
            SizedBox(width: 14.d),
            const Icon(Icons.map_outlined, color: TaColors.primary, size: 20),
            SizedBox(width: 10.d),
            Text(
              AppLocale.setLocationMap.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: TaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Screen 8's "Searching" state for a fresh query: three skeleton rows, held
/// still so they do not scroll with the list they are about to become.
class _SkeletonResults extends StatelessWidget {
  const _SkeletonResults();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 8),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.d),
        child: Row(
          children: [
            Container(
              width: 40.d,
              height: 40.d,
              decoration: BoxDecoration(
                color: TaColors.disabledBg,
                borderRadius: BorderRadius.circular(20.d),
              ),
            ),
            SizedBox(width: 12.d),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14.d,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: TaColors.disabledBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  SizedBox(height: 8.d),
                  Container(
                    height: 12.d,
                    width: 140.d,
                    decoration: BoxDecoration(
                      color: TaColors.disabledBg,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ).toShimmer,
      ),
    );
  }
}