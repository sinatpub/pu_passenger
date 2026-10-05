import 'package:com.tara.passenger/core/resources/asset_resource.dart';

/// The service art for a vehicle type, or null for a type the app has no
/// drawing of — the row then keeps its neutral placeholder.
///
/// Keyed by the vehicle type's id, like the seat counts and map markers: the
/// backend's `image` field is not relied on.
String? vehicleArtAsset(int? vehicleId) => switch (vehicleId) {
      1 => ImageAssets.vehicleTukTuk,
      2 => ImageAssets.vehicleClassic,
      3 => ImageAssets.vehicleMiniVan,
      4 => ImageAssets.vehicleSuv,
      5 => ImageAssets.vehicleVip,
      _ => null,
    };
