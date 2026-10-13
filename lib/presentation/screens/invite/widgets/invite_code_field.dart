import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// Where the check of a typed invite code stands.
enum InviteCodeStatus {
  /// Nothing typed.
  idle,
  checking,
  valid,

  /// The server does not know the code.
  invalid,

  /// The check itself failed: no answer, not a "no".
  failed,
}

/// The optional invite code on the sign-up form (D40): a field with a scan
/// button, and under it who the code belongs to, or why it was refused.
///
/// It owns nothing. The form's logic checks the code and passes the result.
class InviteCodeField extends StatelessWidget {
  const InviteCodeField({
    super.key,
    required this.controller,
    required this.status,
    required this.onChanged,
    required this.onScan,
    this.inviterName,
  });

  final TextEditingController controller;
  final InviteCodeStatus status;
  final ValueChanged<String> onChanged;
  final VoidCallback onScan;

  /// Shown when [status] is [InviteCodeStatus.valid].
  final String? inviterName;

  @override
  Widget build(BuildContext context) {
    final String? error = switch (status) {
      InviteCodeStatus.invalid => AppLocale.inviteCodeUnknown.tr,
      InviteCodeStatus.failed => AppLocale.inviteCodeCheckFailed.tr,
      _ => null,
    };
    final String? inviter = inviterName;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          AppLocale.inviteCodeOptional.tr,
          style: TaTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: TaColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TaTextField(
          controller: controller,
          hint: AppLocale.enterInviteCode.tr,
          keyboardType: TextInputType.visiblePassword,
          textInputAction: TextInputAction.done,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
            LengthLimitingTextInputFormatter(12),
            _UpperCase(),
          ],
          errorText: error,
          onChanged: onChanged,
          suffix: status == InviteCodeStatus.checking
              ? const SizedBox(
                  width: 42,
                  height: 42,
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TaIconButton(
                  icon: const Icon(Icons.qr_code_scanner, size: 20),
                  semanticLabel: AppLocale.scanInviteQr.tr,
                  onTap: onScan,
                ),
        ),
        if (error == null) ...[
          const SizedBox(height: 6),
          if (status == InviteCodeStatus.valid && inviter != null)
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 16, color: TaColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    AppLocale.invitedBy.trParams({'name': inviter}),
                    style: TaTextStyles.bodySmall
                        .copyWith(color: TaColors.success),
                  ),
                ),
              ],
            )
          else
            Text(
              AppLocale.inviteCodeNote.tr,
              style: TaTextStyles.bodySmall.copyWith(color: TaColors.textMuted),
            ),
        ],
      ],
    );
  }
}

class _UpperCase extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
