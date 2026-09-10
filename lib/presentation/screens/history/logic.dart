import 'package:com.tara.passenger/core/utils/x_paging_data_handler.dart';
import 'package:com.tara.passenger/data/datasources/history_booking_info_source.dart';
import 'package:com.tara.passenger/presentation/screens/history/state.dart';
import 'package:com.tara.passenger/presentation/screens/home/logic.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';

class HistoryLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  /// Collaborators arrive by constructor and resolve lazily — see the same
  /// pass across the other passenger controllers (`.agent/TODO.md`
  /// Discovered Tasks, `docs/10` §3.2).
  HistoryLogic({HomeLogic? homeLogic}) : _injectedHomeLogic = homeLogic;

  final HomeLogic? _injectedHomeLogic;

  late final HomeLogic homeLogic = _injectedHomeLogic ?? Get.find<HomeLogic>();

  final HistoryState state = HistoryState();
  final HistroyBookingApi _repo = HistroyBookingApi();

  late TabController tabController;
  @override
  void onInit() {
    super.onInit();
    initTabController();
    state.filterStatus.value = 4; // set completed as default
    state.propertyPagingController.value.addPageRequestListener((pageNo) {
      Logger().d(pageNo);
      getAllHistoryBookingPaging(pageNo: pageNo);
    });
  }

  @override
  onClose() {
    tabController.dispose();
  }

  initTabController() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      if (tabController.indexIsChanging == false) {
        switchTabBarController(tabIndex: tabController.index);
      }
    });
  }

  Future<void> getAllHistoryBookingPaging(
      {required int pageNo,
      bool isRefresh = false,
      String? search,
      int? pptTypeId}) async {
    if (isRefresh) {
      state.propertyPagingController.value.refresh();
    }

    await xPagingDataHandler(
      pagingController: state.propertyPagingController.value,
      // P-12 — was called with no pageNo, so every "page" the paging
      // controller requested silently re-fetched page 1 forever (same bug
      // as P-13's announcements).
      function: _repo.getAllHistoryPaging(
          filterStatus: state.filterStatus.value, pageNo: pageNo),
      isRefresh: isRefresh,
      pageNo: pageNo,
    );
  }

  void switchTabBarController({required int tabIndex}) {
    if (tabIndex == 0) {
      // status = 6 => completed
      state.filterStatus.value = 4;
    } else if (tabIndex == 1) {
      // status = 5 => cancel
      state.filterStatus.value = 5;
    }
    state.propertyPagingController.value.refresh();
  }

  int getVehiclePrice({required int vehicleTypeId}) {
    final data = homeLogic.state.vehicleAllType?.data;
    if (data == null || data.isEmpty) return 0;

    final vehicle = data.firstWhereOrNull(
      (e) => e.id == vehicleTypeId,
    );

    return vehicle?.price ?? 0;
  }
}
