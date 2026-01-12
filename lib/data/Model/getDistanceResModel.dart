
import 'dart:convert';

GetDistanceResModel getDistanceResModelFromJson(String str) => GetDistanceResModel.fromJson(json.decode(str));

String getDistanceResModelToJson(GetDistanceResModel data) => json.encode(data.toJson());

class GetDistanceResModel {
    String? message;
    int? code;
    bool? error;
    List<VehicleOption>? data;

    GetDistanceResModel({
        this.message,
        this.code,
        this.error,
        this.data,
    });

    factory GetDistanceResModel.fromJson(Map<String, dynamic> json) => GetDistanceResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null ? [] : List<VehicleOption>.from(json["data"]!.map((x) => VehicleOption.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "message": message,
        "code": code,
        "error": error,
        "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
    };
}

class VehicleOption {
    String? vehicleTypeId;
    String? vehicleType;
    String? image;
    bool? isDisable;
    String? price;
    String? gst;
    int? capacity;
    int? distance;
    bool? isCapability;
    String? name;
    String? mobNo;
    String? origName;
    double? origLat;
    double? origLon;
    List<DistanceDropoff>? dropoff;
    String? picUpType;

    VehicleOption({
        this.vehicleTypeId,
        this.vehicleType,
        this.image,
        this.isDisable,
        this.price,
        this.gst,
        this.capacity,
        this.distance,
        this.isCapability,
        this.name,
        this.mobNo,
        this.origName,
        this.origLat,
        this.origLon,
        this.dropoff,
        this.picUpType,
    });

    factory VehicleOption.fromJson(Map<String, dynamic> json) => VehicleOption(
        vehicleTypeId: json["vehicleTypeId"],
        vehicleType: json["vehicleType"],
        image: json["image"],
        isDisable: json["isDisable"],
        price: json["price"],
        gst: json["gst"],
        capacity: json["capacity"],
        distance: json["distance"],
        isCapability: json["isCapability"],
        name: json["name"],
        mobNo: json["mobNo"],
        origName: json["origName"],
        origLat: json["origLat"]?.toDouble(),
        origLon: json["origLon"]?.toDouble(),
        dropoff: json["dropoff"] == null ? [] : List<DistanceDropoff>.from(json["dropoff"]!.map((x) => DistanceDropoff.fromJson(x))),
        picUpType: json["picUpType"],
    );

    Map<String, dynamic> toJson() => {
        "vehicleTypeId": vehicleTypeId,
        "vehicleType": vehicleType,
        "image": image,
        "isDisable": isDisable,
        "price": price,
        "gst": gst,
        "capacity": capacity,
        "distance": distance,
        "isCapability": isCapability,
        "name": name,
        "mobNo": mobNo,
        "origName": origName,
        "origLat": origLat,
        "origLon": origLon,
        "dropoff": dropoff == null ? [] : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
        "picUpType": picUpType,
    };
}

// lib/data/Model/getDistanceResModel.dart

class DistanceDropoff {  // ← नया नाम
    final String? name;
    final double? lat;
    final double? long;

    DistanceDropoff({this.name, this.lat, this.long});

    factory DistanceDropoff.fromJson(Map<String, dynamic> json) => DistanceDropoff(
        name: json["name"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "lat": lat,
        "long": long,
    };

    // String get nameString => nameValues.reverse[name] ?? "Unknown";
}
//
// enum Name {
//     DHLI_INDIA,
//     KANTA_CHAURAHA_SINDHI_COLONY_JHOTWARA_JAIPUR_RAJASTHAN,
//     MANSAROVAR_JAIPUR_RAJASTHAN_INDIA
// }
//
// final nameValues = EnumValues({
//     "Déhli، India": Name.DHLI_INDIA,
//     "Kanta Chauraha, Sindhi Colony, Jhotwara, Jaipur, Rajasthan": Name.KANTA_CHAURAHA_SINDHI_COLONY_JHOTWARA_JAIPUR_RAJASTHAN,
//     "Mansarovar, Jaipur, Rajasthan, India": Name.MANSAROVAR_JAIPUR_RAJASTHAN_INDIA
// });

// class EnumValues<T> {
//     Map<String, T> map;
//     late Map<T, String> reverseMap;
//
//     EnumValues(this.map);
//
//     Map<T, String> get reverse {
//         reverseMap = map.map((k, v) => MapEntry(v, k));
//         return reverseMap;
//     }
// }
