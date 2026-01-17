// To parse this JSON data, do
//
//     final parcelResponseModel = parcelResponseModelFromJson(jsonString);

import 'dart:convert';

ParcelResponseModel parcelResponseModelFromJson(String str) => ParcelResponseModel.fromJson(json.decode(str));

String parcelResponseModelToJson(ParcelResponseModel data) => json.encode(data.toJson());

class ParcelResponseModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  ParcelResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory ParcelResponseModel.fromJson(Map<String, dynamic> json) => ParcelResponseModel(
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
  List<ListElement>? list;
  Pagination? pagination;

  Data({
    this.list,
    this.pagination,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    list: json["list"] == null ? [] : List<ListElement>.from(json["list"]!.map((x) => ListElement.fromJson(x))),
    pagination: json["pagination"] == null ? null : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "list": list == null ? [] : List<dynamic>.from(list!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class ListElement {
  Weight? weight;
  PickupSchedule? pickupSchedule;
  Dropoff? pickup;
  Dropoff? dropoff;
  int? amount;
  bool? isDisable;
  bool? isDeleted;
  String? id;
  Customer? customer;
  ParcelSize? parcelSize;
  GoodsType? goodsType;
  List<String>? specialHandling;
  bool? insuranceRequired;
  Status? status;
  dynamic adminNotes;
  String? txId;
  int? createdAt;
  int? updatedAt;
  int? date;
  int? month;
  int? year;

  ListElement({
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

  factory ListElement.fromJson(Map<String, dynamic> json) => ListElement(
    weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
    pickupSchedule: json["pickupSchedule"] == null ? null : PickupSchedule.fromJson(json["pickupSchedule"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    id: json["_id"],
    customer: customerValues.map[json["customer"]]!,
    parcelSize: parcelSizeValues.map[json["parcelSize"]]!,
    goodsType: goodsTypeValues.map[json["goodsType"]]!,
    specialHandling: json["specialHandling"] == null ? [] : List<String>.from(json["specialHandling"]!.map((x) => x)),
    insuranceRequired: json["insuranceRequired"],
    status: statusValues.map[json["status"]]!,
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
    "customer": customerValues.reverse[customer],
    "parcelSize": parcelSizeValues.reverse[parcelSize],
    "goodsType": goodsTypeValues.reverse[goodsType],
    "specialHandling": specialHandling == null ? [] : List<dynamic>.from(specialHandling!.map((x) => x)),
    "insuranceRequired": insuranceRequired,
    "status": statusValues.reverse[status],
    "adminNotes": adminNotes,
    "txId": txId,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "date": date,
    "month": month,
    "year": year,
  };
}

enum Customer {
  THE_68_E5_F744_D1777_FDD770_CC78_D
}

final customerValues = EnumValues({
  "68e5f744d1777fdd770cc78d": Customer.THE_68_E5_F744_D1777_FDD770_CC78_D
});

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

enum GoodsType {
  ELECTRONICS,
  FURNITURE
}

final goodsTypeValues = EnumValues({
  "electronics": GoodsType.ELECTRONICS,
  "furniture": GoodsType.FURNITURE
});

enum ParcelSize {
  MEDIUM,
  SMALL
}

final parcelSizeValues = EnumValues({
  "medium": ParcelSize.MEDIUM,
  "small": ParcelSize.SMALL
});

class PickupSchedule {
  DateTime? serviceDate;
  String? pickupTiming;
  DayLabel? dayLabel;

  PickupSchedule({
    this.serviceDate,
    this.pickupTiming,
    this.dayLabel,
  });

  factory PickupSchedule.fromJson(Map<String, dynamic> json) => PickupSchedule(
    serviceDate: json["serviceDate"] == null ? null : DateTime.parse(json["serviceDate"]),
    pickupTiming: json["pickupTiming"],
    dayLabel: dayLabelValues.map[json["dayLabel"]]!,
  );

  Map<String, dynamic> toJson() => {
    "serviceDate": serviceDate?.toIso8601String(),
    "pickupTiming": pickupTiming,
    "dayLabel": dayLabelValues.reverse[dayLabel],
  };
}

enum DayLabel {
  MONDAY,
  SATURDAY
}

final dayLabelValues = EnumValues({
  "Monday": DayLabel.MONDAY,
  "Saturday": DayLabel.SATURDAY
});

enum Status {
  PENDING
}

final statusValues = EnumValues({
  "pending": Status.PENDING
});

class Weight {
  double? value;
  Unit? unit;

  Weight({
    this.value,
    this.unit,
  });

  factory Weight.fromJson(Map<String, dynamic> json) => Weight(
    value: json["value"]?.toDouble(),
    unit: unitValues.map[json["unit"]]!,
  );

  Map<String, dynamic> toJson() => {
    "value": value,
    "unit": unitValues.reverse[unit],
  };
}

enum Unit {
  KG
}

final unitValues = EnumValues({
  "kg": Unit.KG
});

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

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
