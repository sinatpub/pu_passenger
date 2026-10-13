import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/screens/invite/invite_presentation.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Scans an invite QR at sign-up (D40). Pops with the code, or with nothing
/// when the person goes back. A QR that holds no invite code keeps the camera
/// open and says so.
class InviteScanPage extends StatefulWidget {
  const InviteScanPage({super.key});

  @override
  State<InviteScanPage> createState() => _InviteScanPageState();
}

class _InviteScanPageState extends State<InviteScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    formats: const <BarcodeFormat>[BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  bool _done = false;
  bool _notAnInvite = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final Barcode barcode in capture.barcodes) {
      final String? code = parseInviteCode(barcode.rawValue);
      if (code != null) {
        _done = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
    if (!_notAnInvite && mounted) setState(() => _notAnInvite = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
            errorBuilder: (context, error) => _CameraError(
              denied:
                  error.errorCode == MobileScannerErrorCode.permissionDenied,
            ),
            overlayBuilder: (context, constraints) => ScanOverlay(
              hint: _notAnInvite
                  ? AppLocale.scanNotInvite.tr
                  : AppLocale.scanInviteHint.tr,
              isWarning: _notAnInvite,
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    color: TaColors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: TaIconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    semanticLabel: AppLocale.back.tr,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The frame and the line of help over the camera picture.
class ScanOverlay extends StatelessWidget {
  const ScanOverlay({super.key, required this.hint, this.isWarning = false});

  final String hint;

  /// The last QR seen was not an invite.
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double side =
            (constraints.biggest.shortestSide * 0.68).clamp(160.0, 300.0);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: side,
              height: side,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: TaColors.toastBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isWarning) ...[
                      const Icon(Icons.error_outline,
                          size: 16, color: Colors.white),
                      const SizedBox(width: 8),
                    ],
                    Flexible(
                      child: Text(
                        hint,
                        textAlign: TextAlign.center,
                        style: TaTextStyles.bodyMedium
                            .copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CameraError extends StatelessWidget {
  const _CameraError({required this.denied});

  final bool denied;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: TaColors.background,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.no_photography_outlined,
                  size: 40, color: TaColors.textMuted),
              const SizedBox(height: 12),
              Text(
                denied
                    ? AppLocale.cameraDenied.tr
                    : AppLocale.somethingWentWrong.tr,
                textAlign: TextAlign.center,
                style: TaTextStyles.titleLarge,
              ),
              if (denied) ...[
                const SizedBox(height: 6),
                Text(
                  AppLocale.cameraDeniedHint.tr,
                  textAlign: TextAlign.center,
                  style: TaTextStyles.bodyMedium
                      .copyWith(color: TaColors.textSecondary),
                ),
                const SizedBox(height: 16),
                TaButton(
                  label: AppLocale.openSettings.tr,
                  variant: TaButtonVariant.ghost,
                  size: TaButtonSize.small,
                  width: 180,
                  onTap: openAppSettings,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
