// To parse this JSON data, do
//
//     final requestBookingModel = requestBookingModelFromJson(jsonString);

import 'dart:convert';

import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/json_list.dart';

RequestBookingModel requestBookingModelFromJson(String str) =>
    RequestBookingModel.fromJson(json.decode(str));

String requestBookingModelToJson(RequestBookingModel data) =>
    json.encode(data.toJson());

class RequestBookingModel {
  Data? data;
  bool? status;
  String? message;

  RequestBookingModel({
    this.data,
    this.status,
    this.message,
  });

  factory RequestBookingModel.fromJson(Map<String, dynamic> json) =>
      RequestBookingModel(
        data: json["data"] is Map<String, dynamic>
            ? Data.fromJson(json["data"])
            : null,
        status: json["status"] is bool ? json["status"] : null,
        message: stringOrNull(json["message"]),
      );

  Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "status": status,
        "message": message,
      };
}

class Data {
  int? id;
  dynamic bookingCode;
  dynamic typeVehicleId;
  TypeVehicle? typeVehicle;
  String? startLatitude;
  String? startLongitude;
  dynamic endLatitude;
  dynamic endLongitude;
  dynamic startTime;
  dynamic endTime;
  String? startAddress;
  dynamic endAddress;
  dynamic fare;
  int? status;
  String? statusName;
  Passenger? passenger;
  Driver? driver;
  Payment? payment;
  int? timeoutCountDown;
  int? timeoutParam;
  DateTime? createdAt;
  DateTime? updatedAt;

  Data({
    this.id,
    this.bookingCode,
    this.typeVehicleId,
    this.typeVehicle,
    this.startLatitude,
    this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.startTime,
    this.endTime,
    this.startAddress,
    this.endAddress,
    this.fare,
    this.status,
    this.statusName,
    this.passenger,
    this.driver,
    this.payment,
    this.timeoutCountDown,
    this.timeoutParam,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: intOrNull(json["id"]),
        bookingCode: json["booking_code"],
        typeVehicleId: intOrNull(json["type_vehicle_id"]),
        typeVehicle: json["type_vehicle"] is Map<String, dynamic>
            ? TypeVehicle.fromJson(json["type_vehicle"])
            : null,
        startLatitude: stringOrNull(json["start_latitude"]),
        startLongitude: stringOrNull(json["start_longitude"]),
        endLatitude: json["end_latitude"],
        endLongitude: json["end_longitude"],
        startTime: json["start_time"],
        endTime: json["end_time"],
        startAddress: stringOrNull(json["start_address"]),
        endAddress: json["end_address"],
        fare: json["fare"],
        status: intOrNull(json["status"]),
        statusName: stringOrNull(json["status_name"]),
        passenger: json["passenger"] is Map<String, dynamic>
            ? Passenger.fromJson(json["passenger"])
            : null,
        driver: json["driver"] is Map<String, dynamic>
            ? Driver.fromJson(json["driver"])
            : null,
        payment: json["payment"] is Map<String, dynamic>
            ? Payment.fromJson(json["payment"])
            : null,
        timeoutCountDown: intOrNull(json["timeout_count_down"]),
        timeoutParam: intOrNull(json["timeout_param"]),
        // Display-only: an unreadable timestamp must not fail the booking.
        createdAt: dateOrNull(json["created_at"]),
        updatedAt: dateOrNull(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_code": bookingCode,
        "type_vehicle_id": typeVehicleId,
        "type_vehicle": typeVehicle?.toJson(),
        "start_latitude": startLatitude,
        "start_longitude": startLongitude,
        "end_latitude": endLatitude,
        "end_longitude": endLongitude,
        "start_time": startTime,
        "end_time": endTime,
        "start_address": startAddress,
        "end_address": endAddress,
        "fare": fare,
        "status": status,
        "status_name": statusName,
        "passenger": passenger?.toJson(),
        "driver": driver?.toJson(),
        "payment": payment,
        "timeout_count_down": timeoutCountDown,
        "timeout_param": timeoutParam,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Passenger {
  int? id;
  String? name;
  String? lastName;
  String? firstName;
  String? email;
  int? gender;
  String? dob;
  String? countryCode;
  String? phone;
  dynamic cardType;
  dynamic cardNumber;
  dynamic cardImage;
  int? status;
  String? statusDate;
  int? roleId;
  String? profileImage;
  LastLocation? lastLocation;

  Passenger({
    this.id,
    this.name,
    this.lastName,
    this.firstName,
    this.email,
    this.gender,
    this.dob,
    this.countryCode,
    this.phone,
    this.cardType,
    this.cardNumber,
    this.cardImage,
    this.status,
    this.statusDate,
    this.roleId,
    this.profileImage,
    this.lastLocation,
  });

  factory Passenger.fromJson(Map<String, dynamic> json) => Passenger(
        id: intOrNull(json["id"]),
        name: stringOrNull(json["name"]),
        lastName: stringOrNull(json["last_name"]),
        firstName: stringOrNull(json["first_name"]),
        email: stringOrNull(json["email"]),
        gender: intOrNull(json["gender"]),
        dob: stringOrNull(json["dob"]),
        countryCode: stringOrNull(json["country_code"]),
        phone: stringOrNull(json["phone"]),
        cardType: intOrNull(json["card_type"]),
        cardNumber: json["card_number"],
        cardImage: json["card_image"],
        status: intOrNull(json["status"]),
        statusDate: stringOrNull(json["status_date"]),
        roleId: intOrNull(json["role_id"]),
        profileImage: stringOrNull(json["profile_image"]),
        lastLocation: json["last_location"] is Map<String, dynamic>
            ? LastLocation.fromJson(json["last_location"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "last_name": lastName,
        "first_name": firstName,
        "email": email,
        "gender": gender,
        "dob": dob,
        "country_code": countryCode,
        "phone": phone,
        "card_type": cardType,
        "card_number": cardNumber,
        "card_image": cardImage,
        "status": status,
        "status_date": statusDate,
        "role_id": roleId,
        "profile_image": profileImage,
        "last_location": lastLocation?.toJson(),
      };
}

class LastLocation {
  String? latitude;
  String? longitude;
  double? heading;

  LastLocation({
    this.latitude,
    this.longitude,
    this.heading,
  });

  /// Tolerant of numbers and text alike. `heading` arrives as text from
  /// this backend, and `"…".toDouble()` threw: every booking with a driver
  /// attached then failed to parse, so the passenger could neither be moved
  /// to the ride screen nor shown it.
  factory LastLocation.fromJson(Map<String, dynamic> json) => LastLocation(
        latitude: stringOrNull(json["latitude"]),
        longitude: stringOrNull(json["longitude"]),
        heading: doubleOrNull(json["heading"]),
      );

  Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
        "heading": heading,
      };
}

class TypeVehicle {
  int? id;
  String? name;

  /// The per-km rate, a dollar decimal the backend sends as text ("0.80").
  num? price;
  dynamic image;
  DateTime? createdAt;
  DateTime? updatedAt;

  TypeVehicle({
    this.id,
    this.name,
    this.price,
    this.image,
    this.createdAt,
    this.updatedAt,
  });

  factory TypeVehicle.fromJson(Map<String, dynamic> json) => TypeVehicle(
        id: intOrNull(json["id"]),
        name: stringOrNull(json["name"]),
        // Display-only here (the fare comes from the payment record), so an
        // unreadable rate degrades to null instead of failing the booking.
        price: json["price"] is num
            ? json["price"]
            : num.tryParse('${json["price"] ?? ''}'.trim()),
        image: json["image"],
        createdAt: dateOrNull(json["created_at"]),
        updatedAt: dateOrNull(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}

class Driver {
  int? id;
  String? name;
  String? lastName;
  String? firstName;
  String? email;
  int? gender;
  String? dob;
  String? countryCode;
  String? phone;
  int? cardType;
  String? cardNumber;
  String? cardImage;
  String? driverLicenseNumber;
  String? driverLicenseExpired;
  String? driverLicenseImage;
  int? status;

  String? statusDate;
  String? profileImage;
  Vehicle? vehicle;
  LastLocation? lastLocation;

  Driver({
    this.id,
    this.name,
    this.lastName,
    this.firstName,
    this.email,
    this.gender,
    this.dob,
    this.countryCode,
    this.phone,
    this.cardType,
    this.cardNumber,
    this.cardImage,
    this.driverLicenseNumber,
    this.driverLicenseExpired,
    this.driverLicenseImage,
    this.status,
    this.statusDate,
    this.profileImage,
    this.vehicle,
    this.lastLocation,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
        id: intOrNull(json["id"]),
        name: stringOrNull(json["name"]),
        lastName: stringOrNull(json["last_name"]),
        firstName: stringOrNull(json["first_name"]),
        email: stringOrNull(json["email"]),
        gender: intOrNull(json["gender"]),
        dob: stringOrNull(json["dob"]),
        countryCode: stringOrNull(json["country_code"]),
        phone: stringOrNull(json["phone"]),
        cardType: intOrNull(json["card_type"]),
        cardNumber: stringOrNull(json["card_number"]),
        cardImage: stringOrNull(json["card_image"]),
        driverLicenseNumber: stringOrNull(json["driver_license_number"]),
        driverLicenseExpired: stringOrNull(json["driver_license_expired"]),
        driverLicenseImage: stringOrNull(json["driver_license_image"]),
        status: intOrNull(json["status"]),
        statusDate: stringOrNull(json["status_date"]),
        profileImage: stringOrNull(json["profile_image"]),
        vehicle: json["vehicle"] is Map<String, dynamic>
            ? Vehicle.fromJson(json["vehicle"])
            : null,
        lastLocation: json["last_location"] is Map<String, dynamic>
            ? LastLocation.fromJson(json["last_location"])
            : null,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "last_name": lastName,
        "first_name": firstName,
        "email": email,
        "gender": gender,
        "dob": dob,
        "country_code": countryCode,
        "phone": phone,
        "card_type": cardType,
        "card_number": cardNumber,
        "card_image": cardImage,
        "driver_license_number": driverLicenseNumber,
        "driver_license_expired": driverLicenseExpired,
        "driver_license_image": driverLicenseImage,
        "status": status,
        "status_date": statusDate,
        "profile_image": profileImage,
        "vehicle": vehicle?.toJson(),
        "last_location": lastLocation?.toJson(),
      };
}

class Vehicle {
  int? id;
  int? typeVehicleId;
  num? pricrVehicle;
  String? model;
  String? manufacturer;
  int? yearOfManufacture;
  String? color;
  String? plateNumber;
  String? enginePower;
  int? maxPassenger;
  int? status;
  List<VehicleImage>? vehicleImage;

  Vehicle({
    this.id,
    this.typeVehicleId,
    this.pricrVehicle,
    this.model,
    this.manufacturer,
    this.yearOfManufacture,
    this.color,
    this.plateNumber,
    this.enginePower,
    this.maxPassenger,
    this.status,
    this.vehicleImage,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: intOrNull(json["id"]),
        typeVehicleId: intOrNull(json["type_vehicle_id"]),
        // A dollar decimal, sent as a number or as text; unused on screen,
        // so an unreadable one must not fail the booking.
        pricrVehicle: json["vehicle_price"] is num
            ? json["vehicle_price"]
            : num.tryParse('${json["vehicle_price"] ?? ''}'.trim()),
        model: stringOrNull(json["model"]),
        manufacturer: stringOrNull(json["manufacturer"]),
        yearOfManufacture: intOrNull(json["year_of_manufacture"]),
        color: stringOrNull(json["color"]),
        plateNumber: stringOrNull(json["plate_number"]),
        enginePower: stringOrNull(json["engine_power"]),
        maxPassenger: intOrNull(json["max_passenger"]),
        status: intOrNull(json["status"]),
        vehicleImage: parseJsonList<VehicleImage>(
            json["vehicle_image"], (x) => VehicleImage.fromJson(x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type_vehicle_id": typeVehicleId,
        "vehicle_price": pricrVehicle ?? pricrVehicle,
        "model": model,
        "manufacturer": manufacturer,
        "year_of_manufacture": yearOfManufacture,
        "color": color,
        "plate_number": plateNumber,
        "engine_power": enginePower,
        "max_passenger": maxPassenger,
        "status": status,
        "vehicle_image": vehicleImage == null
            ? []
            : List<dynamic>.from(vehicleImage!.map((x) => x.toJson())),
      };
}

class VehicleImage {
  int? id;
  String? fileOriginalName;
  String? fileSize;
  String? fileType;
  String? fileUrl;
  int? objectId;
  String? objectType;
  dynamic createdBy;

  VehicleImage({
    this.id,
    this.fileOriginalName,
    this.fileSize,
    this.fileType,
    this.fileUrl,
    this.objectId,
    this.objectType,
    this.createdBy,
  });

  factory VehicleImage.fromJson(Map<String, dynamic> json) => VehicleImage(
        id: intOrNull(json["id"]),
        fileOriginalName: stringOrNull(json["file_original_name"]),
        fileSize: stringOrNull(json["file_size"]),
        fileType: stringOrNull(json["file_type"]),
        fileUrl: stringOrNull(json["file_url"]),
        objectId: intOrNull(json["object_id"]),
        objectType: stringOrNull(json["object_type"]),
        createdBy: json["created_by"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "file_original_name": fileOriginalName,
        "file_size": fileSize,
        "file_type": fileType,
        "file_url": fileUrl,
        "object_id": objectId,
        "object_type": objectType,
        "created_by": createdBy,
      };
}

class Payment {
  int? id;
  int? invoiceId;
  int? rideId;
  String? distance;
  String? duration;
  String? amount;
  String? paymentMethod;
  int? status;
  String? statusName;
  String? createdAt;
  String? updatedAt;

  Payment({
    this.id,
    this.invoiceId,
    this.rideId,
    this.distance,
    this.duration,
    this.amount,
    this.paymentMethod,
    this.status,
    this.statusName,
    this.createdAt,
    this.updatedAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: intOrNull(json["id"]),
        invoiceId: intOrNull(json["invoice_id"]),
        rideId: intOrNull(json["ride_id"]),
        distance: stringOrNull(json["distance"]),
        duration: stringOrNull(json["duration"]),
        amount: stringOrNull(json["amount"]),
        paymentMethod: stringOrNull(json["payment_method"]),
        status: intOrNull(json["status"]),
        statusName: stringOrNull(json["status_name"]),
        createdAt: stringOrNull(json["created_at"]),
        updatedAt: stringOrNull(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "invoice_id": invoiceId,
        "ride_id": rideId,
        "distance": distance,
        "duration": duration,
        "amount": amount,
        "payment_method": paymentMethod,
        "status": status,
        "status_name": statusName,
        "created_at": createdAt,
        "updated_at": updatedAt,
      };
}
