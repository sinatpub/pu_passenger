import 'package:com.tara.passenger/data/models/request_booking_model.dart';

/// What to look for on the street — "Toyota Prius · White". Falls back to the
/// vehicle type when the booking carries no model, and to `---` when it
/// carries neither.
String bookingVehicleInfo(Data? data) {
  final vehicle = data?.driver?.vehicle;
  return vehicleDescription(
    manufacturer: vehicle?.manufacturer,
    model: vehicle?.model,
    color: vehicle?.color,
    typeName: data?.typeVehicle?.name,
  );
}

/// The one way the app describes a car: maker and model, then colour. The
/// vehicle type stands in for a missing model, and `---` for nothing at all.
///
/// Shared by the live booking and the history record, whose models are
/// separate classes with the same vehicle fields.
String vehicleDescription({
  String? manufacturer,
  String? model,
  String? color,
  String? typeName,
}) {
  final maker = manufacturer?.trim() ?? '';
  var name = model?.trim() ?? '';
  // Some records already spell the maker out in the model.
  if (maker.isNotEmpty && !name.toLowerCase().startsWith(maker.toLowerCase())) {
    name = '$maker $name'.trim();
  }
  final parts = [
    name.isNotEmpty ? name : typeName?.trim() ?? '',
    color?.trim() ?? '',
  ].where((part) => part.isNotEmpty);
  return parts.isEmpty ? '---' : parts.join(' · ');
}
