import 'package:get/get.dart';

import '../../../core/utils/x_paging_data_handler.dart';
import '../../../data/datasources/announcement_api.dart';
import 'state.dart';

class AnnouncementLogic extends GetxController {
  /// Collaborators arrive by constructor and resolve lazily. A `Get.find`
  /// in a field initializer runs at construction, so building this
  /// controller demanded every collaborator already be registered — the
  /// gap logged in `.agent/TODO.md` Discovered Tasks against
  /// `docs/10` §3.2. Production behaviour is unchanged: bindings register
  /// everything before first access.
  AnnouncementLogic({
    AnnouncementRepo? repo,
  })  : _injectedRepo = repo;

  final AnnouncementRepo? _injectedRepo;

  late final AnnouncementRepo _repo =
      _injectedRepo ?? Get.find<AnnouncementRepo>();
  final AnnouncementState state = AnnouncementState();
  @override
  onInit() {
    super.onInit();
    state.announcementPagingController.value.addPageRequestListener((pageNo) {
      getAllAnnouncementPaging(pageNo: pageNo);
    });
  }

  Future<void> getAllAnnouncementPaging(
      {required int pageNo,
      bool isRefresh = false,
      String? search,
      int? pptTypeId}) async {
    if (isRefresh) {
      state.announcementPagingController.value.refresh();
    }

    await xPagingDataHandler(
      pagingController: state.announcementPagingController.value,
      // P-13 — was called with no pageNo, so every "page" the paging
      // controller requested silently re-fetched page 1 forever.
      function: _repo.getAllAnnouncement(pageNo: pageNo),
      isRefresh: isRefresh,
      pageNo: pageNo,
    );
  }
}
