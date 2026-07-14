import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import '../network_config/paging.dart';

xPagingDataHandler<PageKeyType, ItemType>({
  required PagingController<PageKeyType, ItemType> pagingController,
  required Future<Paging<ItemType>?> function,
  required bool isRefresh,
  required int pageNo,
  int? needPage,
  Function()? functionHandleIsRefresh1,
}) async {
  try {
    // Handle refresh case
    if (isRefresh) {
      pagingController.refresh();
      functionHandleIsRefresh1?.call();
    }

    // Fetch new items with error handling
    final newItems = await function.onError(
      (error, stackTrace) {
        pagingController.error = error;
        return null;
      },
    );

    // Handle cases based on the page number and `needPage` limit (if provided)
    if (needPage == null || pageNo <= needPage) {
      if ((newItems?.totalPages ?? 0) == 1) {
        pagingController.itemList?.clear();
        pagingController.appendLastPage(newItems?.data ?? []);
      } else if ((newItems?.totalPages ?? 0) > pageNo) {
        if (newItems?.data != null) {
          pagingController.appendPage(
              newItems?.data ?? [], (pageNo + 1) as PageKeyType?);
        }
      } else {
        if (newItems?.data != null) {
          pagingController.appendLastPage(newItems?.data ?? []);
        }
      }
    } else {
      // If the current page exceeds `needPage`, stop pagination
      pagingController.appendLastPage([]);
    }
  } catch (error) {
    pagingController.error = error;
  }
}
