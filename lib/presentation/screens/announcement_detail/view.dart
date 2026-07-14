import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/core/utils/app_ext.dart';
import 'package:com.tara.passenger/presentation/widgets/x_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../translations/app_locale.dart';
import 'logic.dart';
import 'state.dart';

class AnnouncementDetailPage extends StatelessWidget {
  AnnouncementDetailPage({super.key});

  final AnnouncementDetailLogic logic = Get.find<AnnouncementDetailLogic>();
  final AnnouncementDetailState state =
      Get.find<AnnouncementDetailLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocale.announcementDetail.tr),
        centerTitle: true,
      ),
      body: GetBuilder<AnnouncementDetailLogic>(builder: (logic) {
        return Container(
          width: Get.width,
          color: Colors.grey.withAlpha(20),
          padding: EdgeInsets.symmetric(horizontal: 12.d, vertical: 24.d),
          child: Column(
            spacing: 14.d,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 8.d,
                children: [
                  Text(
                    logic.state.data?.title ?? AppLocale.unKnown.tr,
                    style: ThemeConstands.font16SemiBold,
                  ),
                  Row(
                    children: [
                      Text(
                        "${AppLocale.releaseDate.tr} : ",
                        style: ThemeConstands.font12Regular,
                      ),
                      Text(
                        "${logic.state.data?.createdAt != null ? logic.state.data?.createdAt!.formatDateTime() : AppLocale.unKnown.tr}",
                        style: ThemeConstands.font12Regular,
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                logic.state.data?.description ?? AppLocale.unKnown.tr,
                style: ThemeConstands.font14Regular,
              ),
              ...[
                if (logic.state.data?.files != null &&
                    (logic.state.data?.files ?? []).isNotEmpty)
                  SizedBox(
                    height: 120.d,
                    child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      itemCount: (logic.state.data?.files ?? []).length,
                      itemBuilder: (context, index) {
                        return XNetworkImage(
                          src: logic.state.data?.files?[index]["file_url"],
                          errorWidget: SizedBox(
                            width: 120.d,
                            height: 120.d,
                            child: const Icon(Icons.image),
                          ),
                          fit: BoxFit.cover,
                          height: 120.d,
                        );
                      },
                      separatorBuilder: (context, index) => SizedBox(
                        width: 12.d,
                      ),
                    ),
                  ),
              ]
            ],
          ),
        );
      }),
    );
  }
}
