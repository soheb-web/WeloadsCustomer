// To parse this JSON data, do
//
//     final parcelResponseListModel = parcelResponseListModelFromJson(jsonString);

import 'dart:convert';

ParcelResponseListModel parcelResponseListModelFromJson(String str) => ParcelResponseListModel.fromJson(json.decode(str));

String parcelResponseListModelToJson(ParcelResponseListModel data) => json.encode(data.toJson());

class ParcelResponseListModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  ParcelResponseListModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory ParcelResponseListModel.fromJson(Map<String, dynamic> json) => ParcelResponseListModel(
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
  List<ListElementParcel>? list;
  Pagination? pagination;

  Data({
    this.list,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    list: json["list"] == null ? [] : List<ListElementParcel>.from(json["list"]!.map((x) => ListElementParcel.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class ListElementParcel {
  Weight? weight;
  PickupSchedule? pickupSchedule;
  Dropoff? pickup;
  Dropoff? dropoff;
  int? amount;
  bool? isDisable;
  bool? isDeleted;
  String? id;
  String? customer;
  String? parcelSize;
  String? goodsType;
  List<String>? specialHandling;
  bool? insuranceRequired;
  String? status;
  dynamic adminNotes;
  String? txId;
  int? createdAt;
  int? updatedAt;
  int? date;
  int? month;
  int? year;

  ListElementParcel({
    this.weight,
    this.pickupSchedule,
    this.pickup,
    this.dropoff,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.id,
    this.customer,
    this.parcelSize,
    this.goodsType,
    this.specialHandling,
    this.insuranceRequired,
    this.status,
    this.adminNotes,
    this.txId,
    this.createdAt,
    this.updatedAt,
    this.date,
    this.month,
    this.year,
  });

  factory ListElementParcel.fromJson(Map<String, dynamic> json) => ListElementParcel(
    weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
    pickupSchedule: json["pickupSchedule"] == null ? null : PickupSchedule.fromJson(json["pickupSchedule"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    id: json["_id"],
    customer: json["customer"],
    parcelSize: json["parcelSize"],
    goodsType: json["goodsType"],
    specialHandling: json["specialHandling"] == null ? [] : List<String>.from(json["specialHandling"]!.map((x) => x)),
    insuranceRequired: json["insuranceRequired"],
    status: json["status"],
    adminNotes: json["adminNotes"],
    txId: json["txId"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
  );

  Map<String, dynamic> toJson() => {
    "weight": weight?.toJson(),
    "pickupSchedule": pickupSchedule?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "_id": id,
    "customer": customer,
    "parcelSize": parcelSize,
    "goodsType": goodsType,
    "specialHandling": specialHandling == null ? [] : List<dynamic>.from(specialHandling!.map((x) => x)),
    "insuranceRequired": insuranceRequired,
    "status": status,
    "adminNotes": adminNotes,
    "txId": txId,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "date": date,
    "month": month,
    "year": year,
  };
}

class Dropoff {
  String? location;
  double? lat;
  double? long;

  Dropoff({
    this.location,
    this.lat,
    this.long,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    location: json["location"],
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
  double? value;
  String? unit;

  Weight({
    this.value,
    this.unit,
  });

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    value: json["value"]?.toDouble(),
    unit: json["unit"],
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "unit": unit,
  };
}

class Pagination {
  int? total;
  int? pageNo;
  int? size;
  int? totalPages;

  Pagination({
    this.total,
    this.pageNo,
    this.size,
    this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json["total"],
    pageNo: json["pageNo"],
    size: json["size"],
    totalPages: json["totalPages"],
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "pageNo": pageNo,
    "size": size,
    "totalPages": totalPages,
  };
}
