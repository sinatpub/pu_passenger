class ProfileModel {
    Data? data;
    bool? status;
    String? message;

    ProfileModel({
        this.data,
        this.status,
        this.message,
    });

    factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
        status: json["status"],
        message: json["message"],
    );

    Map<String, dynamic> toJson() => {
        "data": data?.toJson(),
        "status": status,
        "message": message,
    };
}

class Data {
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

    Data({
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

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"],
        name: json["name"],
        lastName: json["last_name"],
        firstName: json["first_name"],
        email: json["email"],
        gender: json["gender"],
        dob: json["dob"],
        countryCode: json["country_code"],
        phone: json["phone"],
        cardType: json["card_type"],
        cardNumber: json["card_number"],
        cardImage: json["card_image"],
        status: json["status"],
        statusDate: json["status_date"],
        roleId: json["role_id"],
        profileImage: json["profile_image"],
        lastLocation: json["last_location"] == null ? null : LastLocation.fromJson(json["last_location"]),
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

    LastLocation({
        this.latitude,
        this.longitude,
    });

    factory LastLocation.fromJson(Map<String, dynamic> json) => LastLocation(
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "latitude": latitude,
        "longitude": longitude,
    };
}
