import 'package:com.tara.passenger/data/models/announcement_model.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class AnnouncementState {
  var announcementPagingController =
      PagingController<int, AnnouncementDetailModel>(firstPageKey: 1).obs;
}
