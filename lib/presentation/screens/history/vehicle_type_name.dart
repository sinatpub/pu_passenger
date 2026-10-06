import 'package:get/get.dart';

import 'package:com.tara.passenger/presentation/screens/home/logic.dart';

/// A vehicle type's name as Home shows it today, so a past trip and the
/// booking screen call the same vehicle the same thing.
///
/// Null when the types are not loaded or [typeId] is not among them; the
/// trip is then shown without a vehicle name.
String? currentVehicleTypeName(int? typeId) {
  if (typeId == null || !Get.isRegistered<HomeLogic>()) return null;
  return Get.find<HomeLogic>()
      .state
      .vehicleAllType
      ?.data
      .firstWhereOrNull((type) => type.id == typeId)
      ?.name;
}
