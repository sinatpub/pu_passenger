/// What sort of vehicle a vehicle type is, as far as the app draws and
/// describes it: its drawing, its seat count, its marker on the map.
enum VehicleKind { moto, tukTuk, car, miniVan, suv, vip }

/// The kind a vehicle type's [name] describes, or null when the name says
/// nothing the app recognises — the caller then shows a neutral placeholder
/// rather than the wrong vehicle.
///
/// By name, not by id: the ids are the backend's own and differ between
/// backends (`1` is "Moto" on one and was "Tuk Tuk" on another), while a
/// type called "Tuktuk" is a tuk tuk wherever it comes from.
VehicleKind? vehicleKindFromName(String? name) {
  final text = name?.toLowerCase() ?? '';
  if (text.trim().isEmpty) return null;
  for (final entry in _keywords.entries) {
    if (entry.value.any(text.contains)) return entry.key;
  }
  return null;
}

/// Checked in this order, so "Alphard VIP" is a VIP and "Mini Van" is a van
/// before either can match a looser word.
const Map<VehicleKind, List<String>> _keywords = {
  VehicleKind.moto: ['moto', 'bike', 'scooter', 'ម៉ូតូ'],
  VehicleKind.tukTuk: ['tuk', 'rickshaw', 'remork', 'តុកតុក', 'រ៉ឺម៉ក'],
  VehicleKind.vip: ['vip', 'alphard'],
  VehicleKind.miniVan: ['van'],
  VehicleKind.suv: ['suv'],
  VehicleKind.car: ['car', 'classic', 'sedan', 'taxi', 'ឡាន', 'រថយន្ត'],
};
