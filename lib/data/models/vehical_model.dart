import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/json_list.dart';

class VehicalTypeEntities {
  List<SingleVehical> data;
  String message;
  bool status;

  VehicalTypeEntities({
    required this.data,
    required this.message,
    required this.status,
  });

  factory VehicalTypeEntities.fromJson(Map<String, dynamic> json) =>
      VehicalTypeEntities(
        data: parseJsonList<SingleVehical>(
            json["data"], (x) => SingleVehical.fromJson(x)),
        message: stringOrEmpty(json["message"]),
        status: boolOrDefault(json["status"]),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "message": message,
        "status": status,
      };
}

class SingleVehical {
  int id;
  String name;
  /// The per-km rate, in the amount the backend sends. A [num], not an int:
  /// the backend prices in decimals (`"0.30"`), and an int would turn that
  /// rate into 0.
  num price;
  String? image;
  int? orderKey;

  /// The fare floor, with decimals kept like [price]. Null when not sent.
  num? miniMunFare;
  DateTime? createdAt;
  DateTime? updatedAt;

  SingleVehical({
    required this.id,
    required this.name,
    required this.price,
    required this.orderKey,
    required this.miniMunFare,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SingleVehical.fromJson(Map<String, dynamic> json) => SingleVehical(
        // Display fields degrade — a blank label beats a dead vehicle list.
        id: intOrDefault(json["id"]),
        name: stringOrEmpty(json["name"]),
        // Money fails loudly: `price` is the per-km rate feeding
        // estimateFare(), so a silent 0 is a wrong fare shown as if right.
        // The backend sends it as a decimal string ("0.30").
        price: requireMoney(json["price"],
            model: "SingleVehical", field: "price"),
        image: json["image"] is String ? json["image"] : null,
        orderKey: json["order_key"] == null
            ? null
            : intOrDefault(json["order_key"]),
        // Nullable already, and the fare-floor quirk in .agent/RULES.md means
        // a null is handled by the caller rather than defaulted here. A
        // decimal string like `price`.
        miniMunFare: optionalMoney(json["minimum_fare"],
            model: "SingleVehical", field: "minimum_fare"),
        createdAt: dateOrNull(json["created_at"]),
        updatedAt: dateOrNull(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "image": image,
        "order_key":orderKey,
        "minimum_fare":miniMunFare,
        "created_at": createdAt?.toIso8601String(),
        "updated_at": updatedAt?.toIso8601String(),
      };
}
