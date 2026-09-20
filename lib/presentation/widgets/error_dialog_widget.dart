import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Error dialog (roadmap F3 re-skin).
///
/// Signatures and dismissal/navigation semantics unchanged: a single retry
/// action that can show a loading state; barrier dismissed per [isDismiss].
Future<void> showErrorCustomDialog(BuildContext context, String title,
    String description, VoidCallback onPressed,
    {bool isLoading = false, bool isDismiss = true}) {
  return TaDialog.show(
    context,
    title: title,
    body: description,
    barrierDismissible: isDismiss,
    actions: [
      TaButton(
        label: AppLocale.pleaseTryAgain.tr,
        isLoading: isLoading,
        onTap: onPressed,
      ),
    ],
  );
}

/// GetX-hosted error dialog with optional cancel + retry (roadmap F3 re-skin).
///
/// Behavior preserved: `onCancel == null` hides the cancel action; the retry
/// action ignores taps while [isLoading].
Future<void> showGetXErrorCustomDialog({
  required String title,
  String? description,
  VoidCallback? onCancel,
  VoidCallback? onPressed,
  bool isLoading = false,
}) {
  return Get.dialog(
    TaDialogCard(
      title: title,
      body: description ?? '',
      actions: [
        if (onCancel != null)
          TaButton(
            label: AppLocale.cancel.tr,
            variant: TaButtonVariant.ghost,
            onTap: onCancel,
          ),
        TaButton(
          label: AppLocale.pleaseTryAgain.tr,
          variant: TaButtonVariant.primary,
          isLoading: isLoading,
          onTap: onPressed,
        ),
      ],
    ),
    barrierDismissible: true,
  );
}