// To parse this JSON data, do
//
//     final historyBookingModel = historyBookingModelFromJson(jsonString);

import 'dart:convert';
import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/json_list.dart';

HistoryBookingModel historyBookingModelFromJson(String str) =>
    HistoryBookingModel.fromJson(json.decode(str));

String historyBookingModelToJson(HistoryBookingModel data) =>
    json.encode(data.toJson());

class HistoryBookingModel {
  List<Datum>? data;
  int? currentPage;
  int? perPage;
  int? total;
  bool? status;
  String? message;

  HistoryBookingModel({
    this.data,
    this.currentPage,
    this.perPage,
    this.total,
    this.status,
    this.message,
  });

  /// Display data throughout, so every field degrades instead of failing:
  /// one row with `booking_code` as a number (the model wanted text) used to
  /// throw and take the whole list with it.
  ///
  /// The rows and their counters are read wherever a Laravel backend puts
  /// them: at the top level, inside `data` (a paginator), or with the
  /// counters under `meta`.
  factory HistoryBookingModel.fromJson(Map<String, dynamic> json) {
    final inner = json["data"];
    final Map<String, dynamic> page =
        inner is Map<String, dynamic> ? inner : json;
    final meta = page["meta"];
    final Map<String, dynamic> counters =
        meta is Map<String, dynamic> ? meta : page;
    return HistoryBookingModel(
      data: parseJsonList<Datum>(page["data"], (x) => Datum.fromJson(x)),
      currentPage: intOrNull(counters["current_page"]),
      perPage: intOrNull(counters["per_page"]),
      total: intOrNull(counters["total"]),
      status: boolOrNull(json["status"]),
      message: stringOrNull(json["message"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "current_page": currentPage,
        "per_page": perPage,
        "total": total,
        "status": status,
        "message": message,
      };
}

class Datum {
  int? id;
  String? bookingCode;
  String? startLatitude;
  String? startLongitude;
  String? endLatitude;
  String? endLongitude;
  String? startTime;
  String? endTime;
  String? startAddress;
  String? endAddress;
  dynamic fare;
  int? status;
  String? statusName;
  Passenger? passenger;
  Driver? driver;
  Payment? payment;
  String? createdAt;
  String? updatedAt;

  Datum({
    this.id,
    this.bookingCode,
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
    this.createdAt,
    this.updatedAt,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: intOrNull(json["id"]),
        bookingCode: stringOrNull(json["booking_code"]),
        startLatitude: stringOrNull(json["start_latitude"]),
        startLongitude: stringOrNull(json["start_longitude"]),
        endLatitude: stringOrNull(json["end_latitude"]),
        endLongitude: stringOrNull(json["end_longitude"]),
        startTime: stringOrNull(json["start_time"]),
        endTime: stringOrNull(json["end_time"]),
        startAddress: stringOrNull(json["start_address"]),
        endAddress: stringOrNull(json["end_address"]),
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
        createdAt: stringOrNull(json["created_at"]),
        updatedAt: stringOrNull(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "booking_code": bookingCode,
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
        "payment": payment?.toJson(),
        "created_at": createdAt,
        "updated_at": updatedAt,
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
      };
}

class Vehicle {
  int? id;

  int? typeVehicleId;
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
        "model": model,
        "manufacturer": manufacturer,
        "year_of_manufacture": yearOfManufacture,
        "color": color,
        "plate_number": plateNumber,
        "engine_power": enginePower,
        "max_passenger": maxPassenger,
        "status": status,
        "vehicle_image":
            List<dynamic>.from(vehicleImage!.map((x) => x.toJson())),
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
        cardType: json["card_type"],
        cardNumber: json["card_number"],
        cardImage: json["card_image"],
        status: intOrNull(json["status"]),
        statusDate: stringOrNull(json["status_date"]),
        roleId: intOrNull(json["role_id"]),
        profileImage: stringOrNull(json["profile_image"]),
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
