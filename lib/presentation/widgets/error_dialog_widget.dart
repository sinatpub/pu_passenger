import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showErrorCustomDialog(BuildContext context, String title,
    String description, VoidCallback onPressed,
    {bool isLoading = false, bool isDismiss = true}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: isDismiss,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(description),
            ],
          ),
        ),
        actions: <Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              // primary: Colors.red, // Customize your button color
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            onPressed: isLoading == false ? onPressed : () {},
            child: isLoading == false
                ? Text(AppLocale.pleaseTryAgain.tr)
                : const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
          ),
        ],
      );
    },
  );
}

Future<void> showGetXErrorCustomDialog({
  required String title,
  String? description,
  VoidCallback? onCancel,
  VoidCallback? onPressed,
  bool isLoading = false,
}) {
  return Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      insetPadding: const EdgeInsets.all(50.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            Text(description ?? ""),
            const SizedBox(height: 16.0),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                onCancel == null
                    ? const SizedBox()
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                        ),
                        onPressed: onCancel,
                        child: Text(AppLocale.cancel.tr),
                      ),
                const SizedBox(width: 16.0),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  onPressed: isLoading == false ? onPressed : () {},
                  child: isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : Text(AppLocale.pleaseTryAgain.tr),
                ),
              ],
            )
          ],
        ),
      ),
    ),
  );
}
