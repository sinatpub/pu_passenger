import 'package:com.tara.passenger/data/models/history_booking_model.dart';
import 'package:get/get.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

class HistoryState {
  RxInt filterStatus = 0.obs; //
 
  var propertyPagingController =
      PagingController<int, Datum>(firstPageKey: 1).obs;
}
