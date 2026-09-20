import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Yes/No (or single "OK") confirmation dialog (roadmap F3 re-skin).
///
/// Behavior preserved: "No" pops the dialog; "Yes" pops then runs [onYes];
/// `showOnlyOkay` hides the "No" action and turns the primary into "OK".
Future<void> showYesNoCustomDialog(
  BuildContext context, {
  Function()? onYes,
  bool? showOnlyOkay,
  required String title,
  required String description,
}) {
  final onlyOkay = showOnlyOkay == true;
  return TaDialog.show(
    context,
    title: title,
    body: description,
    barrierDismissible: true,
    actions: [
      if (!onlyOkay)
        TaButton(
          label: AppLocale.no.tr,
          variant: TaButtonVariant.ghost,
          onTap: Get.back,
        ),
      TaButton(
        label: onlyOkay ? AppLocale.ok.tr : AppLocale.yes.tr,
        variant: onlyOkay ? TaButtonVariant.ghost : TaButtonVariant.primary,
        onTap: () {
          Get.back();
          onYes?.call();
        },
      ),
    ],
  );
}