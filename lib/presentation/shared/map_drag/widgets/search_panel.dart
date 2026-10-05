import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/data/models/location_model.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/logic.dart';
import 'package:com.tara.passenger/presentation/shared/map_drag/search_state.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Screen 8's search results, driven by the `DestinationSearchStatus` state
/// machine in `search_state.dart` rather than by "is there a list".
///
/// Sits directly under the search field and fills the height it is given:
/// "Set location on the map" is pinned first in every state, and whatever
/// the state shows scrolls beneath it, so it fits the little room left above
/// the keyboard. It returns to the caller via `logic` — `selectPlace` (which
/// pops `/map` with the pinned `LatLng`) and `fetchPlaceSuggestions` (retry)
/// stay in the logic, so the pin-commit semantics P-05 pinned are untouched.
class SearchPanel extends StatelessWidget {
  const SearchPanel({super.key, required this.logic});

  final MapDragLogic logic;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _setOnMapRow(),
        Expanded(child: _body(context)),
      ],
    );
  }

  Widget _body(BuildContext context) {
    final status = logic.searchStatus;
    final predictions = logic.state.suggestLocationData.predictions ?? const [];
    final hasPreviousResults = predictions.isNotEmpty;

    switch (status) {
      case DestinationSearchStatus.idle:
      case DestinationSearchStatus.belowThreshold:
        // The spec shows recents here; the app has no recents storage, so it
        // says what will start a search instead. See PROGRESS.md.
        return _hintState(AppLocale.searchMinChars.tr);
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
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.d, 0, 16.d, 16.d),
      itemCount: logic.state.suggestLocationData.predictions?.length ?? 0,
      itemBuilder: (context, index) {
        final prediction = logic.state.suggestLocationData.predictions![index];
        final split = splitPlaceDescription(prediction.description);
        return TaSearchResult(
          name: split.primary ?? AppLocale.noResultFound.tr,
          keyword: split.secondary ?? '',
          // Placeline responses carry no distance, so the badge is
          // omitted rather than faked (TaSearchResult hides it).
          onTap: () => _select(logic, prediction, context),
        );
      },
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

  /// Screen 8's empty state: `No places match "xyz"` + `Check the spelling`.
  /// "Set location on the map" is the row pinned above it.
  Widget _emptyState() {
    final query = logic.state.searchQuery.trim();
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 24.d),
      child: Column(
        children: [
          const Icon(Icons.search_off, size: 48, color: TaColors.textMuted),
          SizedBox(height: 12.d),
          Text(
            '${AppLocale.noPlacesMatch.tr} "${query.isEmpty ? logic.searchController.text : query}"',
            textAlign: TextAlign.center,
            style:
                TaTextStyles.titleLarge.copyWith(color: TaColors.textPrimary),
          ),
          SizedBox(height: 4.d),
          Text(
            AppLocale.checkSpelling.tr,
            textAlign: TextAlign.center,
            style: TaTextStyles.bodyMedium.copyWith(color: TaColors.textMuted),
          ),
        ],
      ),
    );
  }

  /// Screen 8's failure state: `Couldn't search right now` + `Retry`, with
  /// the typed query kept so the retry re-runs the same search.
  Widget _errorState(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 24.d),
      child: Column(
        children: [
          const Icon(Icons.wifi_off, size: 48, color: TaColors.textMuted),
          SizedBox(height: 12.d),
          Text(
            AppLocale.couldntSearch.tr,
            textAlign: TextAlign.center,
            style:
                TaTextStyles.titleLarge.copyWith(color: TaColors.textPrimary),
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
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 16.d),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          message,
          textAlign: TextAlign.center,
          style:
              TaTextStyles.bodyMedium.copyWith(color: TaColors.textSecondary),
        ),
      ),
    );
  }

  /// "Set location on the map": closes the search and returns to the pin.
  /// Drawn as the same card as a result so it reads as the first choice.
  Widget _setOnMapRow() {
    return Semantics(
      button: true,
      child: TaPressable(
        onTap: logic.closeSearch,
        child: Container(
          margin: EdgeInsets.fromLTRB(16.d, 0, 16.d, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          decoration: BoxDecoration(
            color: TaColors.surface,
            borderRadius: BorderRadius.circular(14),
            boxShadow: TaShadows.shadowSm,
          ),
          child: Row(
            children: [
              const Icon(Icons.map_outlined,
                  color: TaColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppLocale.setLocationMap.tr,
                  style: TaTextStyles.labelLarge
                      .copyWith(color: TaColors.textPrimary),
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: TaColors.textMuted, size: 20),
            ],
          ),
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
      padding: EdgeInsets.symmetric(horizontal: 16.d, vertical: 8.d),
      itemCount: 3,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.d),
        child: Row(
          children: [
            TaSkeleton(width: 40.d, height: 40.d, circle: true),
            SizedBox(width: 12.d),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TaSkeleton(height: 14.d, radius: 4),
                  SizedBox(height: 8.d),
                  TaSkeleton(width: 140.d, height: 12.d, radius: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}