import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The "Where to go?" trigger on the map's bottom sheet (Screen 7 §Map).
/// Thin wrapper over the shared [TaSearchCard] so the map keeps its named
/// entry point while staying on the C2 component.
class SearchWhereToGo extends StatelessWidget {
  const SearchWhereToGo({super.key, this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TaSearchCard(
      label: AppLocale.whereTo.tr,
      onTap: onTap,
    );
  }
}