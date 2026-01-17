/*
// To parse this JSON data, do
//
//     final allIndiaResponseModel = allIndiaResponseModelFromJson(jsonString);

import 'dart:convert';

AllIndiaResponseModel allIndiaResponseModelFromJson(String str) => AllIndiaResponseModel.fromJson(json.decode(str));

String allIndiaResponseModelToJson(AllIndiaResponseModel data) => json.encode(data.toJson());

class AllIndiaResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  AllIndiaResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory AllIndiaResponseModel.fromJson(Map<String, dynamic> json) => AllIndiaResponseModel(
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
  String? customer;
  String? parcelSize;
  Weight? weight;
  String? goodsType;
  List<dynamic>? specialHandling;
  bool? insuranceRequired;
  PickupSchedule? pickupSchedule;
  Dropoff? pickup;
  Dropoff? dropoff;
  String? status;
  dynamic adminNotes;
  String? id;
  String? txId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  Data({
    this.customer,
    this.parcelSize,
    this.weight,
    this.goodsType,
    this.specialHandling,
    this.insuranceRequired,
    this.pickupSchedule,
    this.pickup,
    this.dropoff,
    this.status,
    this.adminNotes,
    this.id,
    this.txId,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customer: json["customer"],
    parcelSize: json["parcelSize"],
    weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
    goodsType: json["goodsType"],
    specialHandling: json["specialHandling"] == null ? [] : List<dynamic>.from(json["specialHandling"]!.map((x) => x)),
    insuranceRequired: json["insuranceRequired"],
    pickupSchedule: json["pickupSchedule"] == null ? null : PickupSchedule.fromJson(json["pickupSchedule"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    status: json["status"],
    adminNotes: json["adminNotes"],
    id: json["_id"],
    txId: json["txId"],
    createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"].toString()),
    updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"].toString()),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "parcelSize": parcelSize,
    "weight": weight?.toJson(),
    "goodsType": goodsType,
    "specialHandling": specialHandling == null ? [] : List<dynamic>.from(specialHandling!.map((x) => x)),
    "insuranceRequired": insuranceRequired,
    "pickupSchedule": pickupSchedule?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "status": status,
    "adminNotes": adminNotes,
    "_id": id,
    "txId": txId,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
  };
}

class Dropoff {
  String? location;
  dynamic lat;
  dynamic long;

  Dropoff({
    this.location,
    this.lat,
    this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    location: json["location"],
    lat: json["lat"],
    long: json["long"],
  );

  Map<String, dynamic> toJson() => {
    "location": location,
    "lat": lat,
    "long": long,
  };
}

class PickupSchedule {
  DateTime? serviceDate;
  String? pickupTiming;
  String? dayLabel;

  PickupSchedule({
    this.serviceDate,
    this.pickupTiming,
    this.dayLabel,
  });

  factory PickupSchedule.fromJson(Map<String, dynamic> json) => PickupSchedule(
    serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
    pickupTiming: json["pickupTiming"],
    dayLabel: json["dayLabel"],
  );

  Map<String, dynamic> toJson() => {
    "serviceDate": serviceDate?.toIso8601String(),
    "pickupTiming": pickupTiming,
    "dayLabel": dayLabel,
  };
}

class Weight {
  int? value;
  String? unit;

  Weight({
    this.value,
    this.unit,
  });

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    value: json["value"],
    unit: json["unit"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "unit": unit,
  };
}
*/


// To parse this JSON data, do
//
//     final allIndiaResponseModel = allIndiaResponseModelFromJson(jsonString);

import 'dart:convert';

AllIndiaResponseModel allIndiaResponseModelFromJson(String str) =>
    AllIndiaResponseModel.fromJson(json.decode(str));

String allIndiaResponseModelToJson(AllIndiaResponseModel data) =>
    json.encode(data.toJson());

class AllIndiaResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  AllIndiaResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory AllIndiaResponseModel.fromJson(Map<String, dynamic> json) =>
      AllIndiaResponseModel(
        message: json["message"]?.toString(),
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
  String? customer;
  String? parcelSize;
  Weight? weight;
  String? goodsType;
  List<dynamic>? specialHandling;
  bool? insuranceRequired;
  PickupSchedule? pickupSchedule;
  Dropoff? pickup;
  Dropoff? dropoff;
  String? status;
  dynamic adminNotes;
  String? id;
  String? txId;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  num? amount; // response mein amount aa raha hai
  bool? isDisable;
  bool? isDeleted;
  num? date;
  num? month;
  num? year;

  Data({
    this.customer,
    this.parcelSize,
    this.weight,
    this.goodsType,
    this.specialHandling,
    this.insuranceRequired,
    this.pickupSchedule,
    this.pickup,
    this.dropoff,
    this.status,
    this.adminNotes,
    this.id,
    this.txId,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customer: json["customer"]?.toString(),
    parcelSize: json["parcelSize"]?.toString(),
    weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
    goodsType: json["goodsType"]?.toString(),
    specialHandling: json["specialHandling"] == null
        ? []
        : List<dynamic>.from(json["specialHandling"]!.map((x) => x)),
    insuranceRequired: json["insuranceRequired"],
    pickupSchedule: json["pickupSchedule"] == null
        ? null
        : PickupSchedule.fromJson(json["pickupSchedule"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    status: json["status"]?.toString(),
    adminNotes: json["adminNotes"],
    id: json["_id"]?.toString(), // ← safe conversion
    txId: json["txId"]?.toString(),
    createdAt: json["createdAt"] == null
        ? null
        : DateTime.tryParse(json["createdAt"].toString()),
    updatedAt: json["updatedAt"] == null
        ? null
        : DateTime.tryParse(json["updatedAt"].toString()),
    v: json["__v"],
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
  );

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "parcelSize": parcelSize,
    "weight": weight?.toJson(),
    "goodsType": goodsType,
    "specialHandling": specialHandling == null
        ? []
        : List<dynamic>.from(specialHandling!.map((x) => x)),
    "insuranceRequired": insuranceRequired,
    "pickupSchedule": pickupSchedule?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "status": status,
    "adminNotes": adminNotes,
    "_id": id,
    "txId": txId,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
  };
}

class Dropoff {
  String? location;
  double? lat;   // double? rakha (response mein decimal aa raha hai)
  double? long;

  Dropoff({
    this.location,
    this.lat,
    this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    location: json["location"]?.toString(),
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "location": location,
    "lat": lat,
    "long": long,
  };
}

class PickupSchedule {
  DateTime? serviceDate;
  String? pickupTiming;
  String? dayLabel;

  PickupSchedule({
    this.serviceDate,
    this.pickupTiming,
    this.dayLabel,
  });

  factory PickupSchedule.fromJson(Map<String, dynamic> json) => PickupSchedule(
    serviceDate: json["serviceDate"] == null
        ? null
        : DateTime.tryParse(json["serviceDate"].toString()),
    pickupTiming: json["pickupTiming"]?.toString(),
    dayLabel: json["dayLabel"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "serviceDate": serviceDate?.toIso8601String(),
    "pickupTiming": pickupTiming,
    "dayLabel": dayLabel,
  };
}

class Weight {
  num? value;   // num? rakha (int ya double dono handle karega)
  String? unit;

  Weight({
    this.value,
    this.unit,
  });

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    value: json["value"],
    unit: json["unit"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "unit": unit,
  };
}