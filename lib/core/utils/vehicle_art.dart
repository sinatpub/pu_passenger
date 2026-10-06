import 'package:com.tara.passenger/core/resources/asset_resource.dart';
import 'package:com.tara.passenger/core/utils/vehicle_kind.dart';

/// The service art for a kind of vehicle, or null for a type the app does
/// not recognise — the row then keeps its neutral placeholder.
///
/// The backend's `image` field is not relied on: it is empty.
String? vehicleArtAsset(VehicleKind? kind) => switch (kind) {
      VehicleKind.moto => ImageAssets.vehicleMoto,
      VehicleKind.tukTuk => ImageAssets.vehicleTukTuk,
      VehicleKind.car => ImageAssets.vehicleClassic,
      VehicleKind.miniVan => ImageAssets.vehicleMiniVan,
      VehicleKind.suv => ImageAssets.vehicleSuv,
      VehicleKind.vip => ImageAssets.vehicleVip,
      null => null,
    };

/// The top-down marker a driver of this kind is drawn with on the map. A
/// type the app does not recognise is drawn as a car.
String driverMarkerAsset(VehicleKind? kind) => switch (kind) {
      VehicleKind.moto => ImageAssets.motoMarker,
      VehicleKind.tukTuk => ImageAssets.rickshawMarker,
      VehicleKind.miniVan => ImageAssets.minVanCarMarker,
      VehicleKind.suv => ImageAssets.suvCarMarker,
      VehicleKind.vip => ImageAssets.alphardVipCarMarker,
      VehicleKind.car || null => ImageAssets.classicCarMarker,
    };
