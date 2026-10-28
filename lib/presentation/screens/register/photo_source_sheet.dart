import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// What the person picked on [PhotoSourceSheet].
enum PhotoSourceChoice { camera, gallery, remove }

/// Where the profile photo comes from (D43): a short list under a title.
///
/// It only asks. Each row closes the sheet with the choice, and the caller
/// opens the camera or the gallery after that, so the picker is never opened
/// on top of a sheet that is still there when the person cancels it.
class PhotoSourceSheet extends StatelessWidget {
  const PhotoSourceSheet({super.key, required this.hasPhoto});

  /// Adds "Remove photo".
  final bool hasPhoto;

  static Future<PhotoSourceChoice?> show(
    BuildContext context, {
    required bool hasPhoto,
  }) =>
      TaBottomSheet.show<PhotoSourceChoice>(
        context,
        PhotoSourceSheet(hasPhoto: hasPhoto),
      );

  @override
  Widget build(BuildContext context) {
    void choose(PhotoSourceChoice choice) => Navigator.of(context).pop(choice);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(AppLocale.profilePhoto.tr, style: TaTextStyles.headlineMedium),
        const SizedBox(height: 8),
        _SourceRow(
          icon: Icons.photo_camera_outlined,
          label: AppLocale.takePhoto.tr,
          onTap: () => choose(PhotoSourceChoice.camera),
        ),
        _SourceRow(
          icon: Icons.photo_library_outlined,
          label: AppLocale.chooseFromGallery.tr,
          onTap: () => choose(PhotoSourceChoice.gallery),
        ),
        if (hasPhoto)
          _SourceRow(
            icon: Icons.delete_outline,
            label: AppLocale.removePhoto.tr,
            isDanger: true,
            onTap: () => choose(PhotoSourceChoice.remove),
          ),
      ],
    );
  }
}

class _SourceRow extends StatelessWidget {
  const _SourceRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// "Remove photo": red, and no chevron, because it goes nowhere.
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final Color tint = isDanger ? TaColors.error : TaColors.primary;

    return Semantics(
      button: true,
      child: TaPressable(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDanger ? TaColors.errorBg : TaColors.primaryBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: tint),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TaTextStyles.titleMedium.copyWith(
                    color: isDanger ? TaColors.error : TaColors.textPrimary,
                  ),
                ),
              ),
              if (!isDanger)
                const Icon(Icons.chevron_right,
                    size: 20, color: TaColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
