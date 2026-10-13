import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/presentation/screens/invite/my_qr_sheet.dart';
import 'package:com.tara.passenger/presentation/widgets/widgets.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';

/// The floating QR button on Home (D40). Opens "My invite QR".
class InviteFab extends StatelessWidget {
  const InviteFab({super.key});

  static const double size = 56;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: AppLocale.myInviteQr.tr,
      child: TaPressable(
        onTap: () => MyQrSheet.show(context),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: TaColors.dark,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: TaColors.dark.withValues(alpha: 0.3),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const ExcludeSemantics(
            child: Icon(Icons.qr_code_2, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
