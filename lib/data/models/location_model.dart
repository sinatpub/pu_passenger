import 'package:com.tara.passenger/core/utils/json_field.dart';
import 'package:com.tara.passenger/core/utils/json_list.dart';

class LocationModel {
  List<Prediction>? predictions;

  LocationModel({
    this.predictions,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        predictions: parseJsonList<Prediction>(
            json["predictions"], (x) => Prediction.fromJson(x)),
      );

  Map<String, dynamic> toJson() => {
        "predictions": predictions == null
            ? []
            : List<dynamic>.from(predictions!.map((x) => x.toJson())),
      };
}

class Prediction {
  String? description;
  String? placeId;
  String? reference;

  Prediction({
    this.description,
    this.placeId,
    this.reference,
  });

  factory Prediction.fromJson(Map<String, dynamic> json) => Prediction(
        description: stringOrNull(json["description"]),
        placeId: stringOrNull(json["place_id"]),
        reference: stringOrNull(json["reference"]),
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "place_id": placeId,
        "reference": reference,
      };
}
