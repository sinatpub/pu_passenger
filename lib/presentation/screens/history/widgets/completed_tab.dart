import 'package:com.tara.passenger/core/utils/x_paged_child_builder_delegate.dart';
import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:com.tara.passenger/presentation/screens/history/logic.dart';
import 'package:com.tara.passenger/presentation/screens/history/widgets/history_card_widget.dart';
import 'package:com.tara.passenger/translations/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import '../../../../core/utils/app_ext.dart';

class CompletedTabWidget extends StatelessWidget {
  CompletedTabWidget({super.key});
  final HistoryLogic logic = Get.find<HistoryLogic>();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        color: Colors.grey.withOpacity(.1),
        padding: const EdgeInsets.symmetric(horizontal: 0.0),
        child: RefreshIndicator(
          onRefresh: () async {
            HapticFeedback.mediumImpact();
            logic.state.propertyPagingController.value.refresh();
          },
          child: PagedListView<int, Datum>.separated(
            padding: EdgeInsets.only(top: 18.0, left: 18.d, right: 18.d),
            pagingController: logic.state.propertyPagingController.value,
            builderDelegate: XPagedChildBuilderDelegate.list(
              // loading for next page
              newPageProgressIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                ),
              ),
              // No more items
              noMoreItemsIndicatorBuilder: (context) => Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    AppLocale.noMoreData.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              ),

              itemBuilder: (context, item, index) => GetBuilder<HistoryLogic>(
                id: '${item.id}',
                builder: (logic) => HistoryCardWidget(
                  data: logic
                      .state.propertyPagingController.value.itemList?[index],
                ),
              ),
            ),
            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 18.d,
              );
            },
          ),
        ),
      ),
    );
  }
}
