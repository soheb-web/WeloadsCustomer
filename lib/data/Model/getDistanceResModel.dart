import 'dart:convert';

GetDistanceResModel getDistanceResModelFromJson(String str) =>
    GetDistanceResModel.fromJson(json.decode(str));

String getDistanceResModelToJson(GetDistanceResModel data) =>
    json.encode(data.toJson());

class GetDistanceResModel {
  String? message;
  int? code;
  bool? error;
  List<VehicleOption>? data;

  GetDistanceResModel({this.message, this.code, this.error, this.data});

  factory GetDistanceResModel.fromJson(Map<String, dynamic> json) =>
      GetDistanceResModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null
            ? []
            : List<VehicleOption>.from(
                json["data"]!.map((x) => VehicleOption.fromJson(x)),
              ),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null
        ? []
        : List<dynamic>.from(data!.map((x) => x.toJson())),
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
  VehicleDimensions? vehicleDimensions;

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
    this.vehicleDimensions,
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
    dropoff: json["dropoff"] == null
        ? []
        : List<DistanceDropoff>.from(
            json["dropoff"]!.map((x) => DistanceDropoff.fromJson(x)),
          ),
    picUpType: json["picUpType"],
    vehicleDimensions: json["vehicleDimensions"] == null
        ? null
        : VehicleDimensions.fromJson(json["vehicleDimensions"]),
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
    "dropoff": dropoff == null
        ? []
        : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "picUpType": picUpType,
    "vehicleDimensions": vehicleDimensions?.toJson(),
  };
}

class DistanceDropoff {
  // ← नया नाम
  final String? name;
  final double? lat;
  final double? long;

  DistanceDropoff({this.name, this.lat, this.long});

  factory DistanceDropoff.fromJson(Map<String, dynamic> json) =>
      DistanceDropoff(
        name: json["name"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {"name": name, "lat": lat, "long": long};

  // String get nameString => nameValues.reverse[name] ?? "Unknown";
}

// class VehicleDimensions {
//   final int? length;
//   final int? width;
//   final int? height;

//   VehicleDimensions({this.length, this.width, this.height});

//   factory VehicleDimensions.fromJson(Map<String, dynamic> json) {
//     return VehicleDimensions(
//       length: json["length"],
//       width: json["width"],
//       height: json["height"],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     "length": length,
//     "width": width,
//     "height": height,
//   };
// }

class VehicleDimensions {
  final int? length;
  final int? width;
  final int? height;

  VehicleDimensions({this.length, this.width, this.height});

  factory VehicleDimensions.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;

      if (value is int) return value; // 40
      if (value is double) return value.toInt(); // 40.0
      if (value is String) return int.tryParse(value); // "40"

      return null;
    }

    return VehicleDimensions(
      length: parseInt(json["length"]),
      width: parseInt(json["width"]),
      height: parseInt(json["height"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "length": length,
    "width": width,
    "height": height,
  };
}
