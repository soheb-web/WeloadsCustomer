// To parse this JSON data, do
//
//     final deliveryResponseModel = deliveryResponseModelFromJson(jsonString);

import 'dart:convert';

DeliveryResponseModel deliveryResponseModelFromJson(String str) => DeliveryResponseModel.fromJson(json.decode(str));

String deliveryResponseModelToJson(DeliveryResponseModel data) => json.encode(data.toJson());

class DeliveryResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  DeliveryResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory DeliveryResponseModel.fromJson(Map<String, dynamic> json) => DeliveryResponseModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  String? deliveryId;
  String? status;
  String? otp;
  Pickup? pickup;
  List<Pickup>? dropoff;
  int? amount;
  VehicleType? vehicleType;
  VehicleDetails? vehicleDetails;
  Driver? driver;

  Data({
    this.deliveryId,
    this.status,
    this.otp,
    this.pickup,
    this.dropoff,
    this.amount,
    this.vehicleType,
    this.vehicleDetails,
    this.driver,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    deliveryId: json["deliveryId"],
    status: json["status"],
    otp: json["otp"],
    pickup: json["pickup"] == null ? null : Pickup.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? [] : List<Pickup>.from(json["dropoff"]!.map((x) => Pickup.fromJson(x))),
    amount: json["amount"],
    vehicleType: json["vehicleType"] == null ? null : VehicleType.fromJson(json["vehicleType"]),
    vehicleDetails: json["vehicleDetails"] == null ? null : VehicleDetails.fromJson(json["vehicleDetails"]),
    driver: json["driver"] == null ? null : Driver.fromJson(json["driver"]),
  );

  Map<String, dynamic> toJson() => {
    "deliveryId": deliveryId,
    "status": status,
    "otp": otp,
    "pickup": pickup?.toJson(),
    "dropoff": dropoff == null ? [] : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "amount": amount,
    "vehicleType": vehicleType?.toJson(),
    "vehicleDetails": vehicleDetails?.toJson(),
    "driver": driver?.toJson(),
  };
}

class Driver {
  String? id;
  String? firstName;
  String? lastName;
  String? phone;
  double? averageRating;

  Driver({
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.averageRating,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => Driver(
    id: json["id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    phone: json["phone"],
    averageRating: json["averageRating"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "firstName": firstName,
    "lastName": lastName,
    "phone": phone,
    "averageRating": averageRating,
  };
}

class Pickup {
  String? name;
  double? lat;
  double? long;
  String? id;

  Pickup({
    this.name,
    this.lat,
    this.long,
    this.id,
  });

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
    name: json["name"],
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
    "_id": id,
  };
}

class VehicleDetails {
  String? vehicle;
  String? numberPlate;
  String? model;
  int? capacityWeight;
  int? capacityVolume;
  bool? isActive;
  String? status;
  List<Document>? documents;
  String? verifiedBy;
  String? id;
  String? verificationRemarks;
  DateTime? verifiedAt;

  VehicleDetails({
    this.vehicle,
    this.numberPlate,
    this.model,
    this.capacityWeight,
    this.capacityVolume,
    this.isActive,
    this.status,
    this.documents,
    this.verifiedBy,
    this.id,
    this.verificationRemarks,
    this.verifiedAt,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) => VehicleDetails(
    vehicle: json["vehicle"],
    numberPlate: json["numberPlate"],
    model: json["model"],
    capacityWeight: json["capacityWeight"],
    capacityVolume: json["capacityVolume"],
    isActive: json["isActive"],
    status: json["status"],
    documents: json["documents"] == null ? [] : List<Document>.from(json["documents"]!.map((x) => Document.fromJson(x))),
    verifiedBy: json["verifiedBy"],
    id: json["_id"],
    verificationRemarks: json["verificationRemarks"],
    verifiedAt: json["verifiedAt"] == null ? null : DateTime.parse(json["verifiedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "vehicle": vehicle,
    "numberPlate": numberPlate,
    "model": model,
    "capacityWeight": capacityWeight,
    "capacityVolume": capacityVolume,
    "isActive": isActive,
    "status": status,
    "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
    "verifiedBy": verifiedBy,
    "_id": id,
    "verificationRemarks": verificationRemarks,
    "verifiedAt": verifiedAt?.toIso8601String(),
  };
}

class Document {
  String? type;
  String? fileUrl;
  String? verifiedBy;
  String? verificationStatus;
  String? id;
  String? remarks;
  DateTime? verifiedAt;

  Document({
    this.type,
    this.fileUrl,
    this.verifiedBy,
    this.verificationStatus,
    this.id,
    this.remarks,
    this.verifiedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    type: json["type"],
    fileUrl: json["fileUrl"],
    verifiedBy: json["verifiedBy"],
    verificationStatus: json["verificationStatus"],
    id: json["_id"],
    remarks: json["remarks"],
    verifiedAt: json["verifiedAt"] == null ? null : DateTime.parse(json["verifiedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "fileUrl": fileUrl,
    "verifiedBy": verifiedBy,
    "verificationStatus": verificationStatus,
    "_id": id,
    "remarks": remarks,
    "verifiedAt": verifiedAt?.toIso8601String(),
  };
}

class VehicleType {
  Dimensions? dimensions;
  String? id;
  String? name;
  int? capacity;
  int? baseFare;
  int? perKmRate;
  int? perMinuteRate;
  int? maxDeliveryDistance;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  VehicleType({
    this.dimensions,
    this.id,
    this.name,
    this.capacity,
    this.baseFare,
    this.perKmRate,
    this.perMinuteRate,
    this.maxDeliveryDistance,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleType.fromJson(Map<String, dynamic> json) => VehicleType(
    dimensions: json["dimensions"] == null ? null : Dimensions.fromJson(json["dimensions"]),
    id: json["_id"],
    name: json["name"],
    capacity: json["capacity"],
    baseFare: json["baseFare"],
    perKmRate: json["perKmRate"],
    perMinuteRate: json["perMinuteRate"],
    maxDeliveryDistance: json["maxDeliveryDistance"],
    image: json["image"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "dimensions": dimensions?.toJson(),
    "_id": id,
    "name": name,
    "capacity": capacity,
    "baseFare": baseFare,
    "perKmRate": perKmRate,
    "perMinuteRate": perMinuteRate,
    "maxDeliveryDistance": maxDeliveryDistance,
    "image": image,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class Dimensions {
  int? length;
  int? width;
  int? height;

  Dimensions({
    this.length,
    this.width,
    this.height,
  });

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    length: json["length"],
    width: json["width"],
    height: json["height"],
  );

  Map<String, dynamic> toJson() => {
    "length": length,
    "width": width,
    "height": height,
  };
}
