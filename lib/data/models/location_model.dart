class LocationModel {
  List<Prediction>? predictions;

  LocationModel({
    this.predictions,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) => LocationModel(
        predictions: json["predictions"] == null
            ? []
            : List<Prediction>.from(
                json["predictions"]!.map((x) => Prediction.fromJson(x))),
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
        description: json["description"],
        placeId: json["place_id"],
        reference: json["reference"],
      );

  Map<String, dynamic> toJson() => {
        "description": description,
        "place_id": placeId,
        "reference": reference,
      };
}
