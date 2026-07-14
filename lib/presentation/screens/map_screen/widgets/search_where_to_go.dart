import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/app_ext.dart';
import '../../../../translations/app_locale.dart';

class SearchWhereToGo extends StatelessWidget {
  const SearchWhereToGo({super.key, this.onTap});
  final Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.all(8.d),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12.d),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              color: AppColors.dark1,
              size: 24..d,
            ),
            SizedBox(
              width: 8..d,
            ),
            Text(
              AppLocale.whereToGo.tr,
              style: ThemeConstands.font16SemiBold,
            ),
          ],
        ),
      ),
    );
  }
}
