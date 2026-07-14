import 'package:com.tara.passenger/core/utils/app_constant.dart';
import 'package:get/get_navigation/src/root/internacionalization.dart';

import 'english_key.dart';
import 'khmer_key.dart';

class AppTranslation extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        AppConstant.englishCode: englishKey,
        AppConstant.khmerCode: khmerKey,
      };
}
