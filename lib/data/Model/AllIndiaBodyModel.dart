// To parse this JSON data, do
//
//     final allIndiaBodyModel = allIndiaBodyModelFromJson(jsonString);

import 'dart:convert';

AllIndiaBodyModel allIndiaBodyModelFromJson(String str) => AllIndiaBodyModel.fromJson(json.decode(str));

String allIndiaBodyModelToJson(AllIndiaBodyModel data) => json.encode(data.toJson());

class AllIndiaBodyModel {
  String? parcelSize;
  Weight? weight;
  String? goodsType;
  List<String>? specialHandling;
  bool? insuranceRequired;
  PickupSchedule? pickupSchedule;
  Dropoff? pickup;
  Dropoff? dropoff;

  AllIndiaBodyModel({
    this.parcelSize,
    this.weight,
    this.goodsType,
    this.specialHandling,
    this.insuranceRequired,
    this.pickupSchedule,
    this.pickup,
    this.dropoff,
  });

  factory AllIndiaBodyModel.fromJson(Map<String, dynamic> json) => AllIndiaBodyModel(
    parcelSize: json["parcelSize"],
    weight: json["weight"] == null ? null : Weight.fromJson(json["weight"]),
    goodsType: json["goodsType"],
    specialHandling: json["specialHandling"] == null ? [] : List<String>.from(json["specialHandling"]!.map((x) => x)),
    insuranceRequired: json["insuranceRequired"],
    pickupSchedule: json["pickupSchedule"] == null ? null : PickupSchedule.fromJson(json["pickupSchedule"]),
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
  );

  Map<String, dynamic> toJson() => {
    "parcelSize": parcelSize,
    "weight": weight?.toJson(),
    "goodsType": goodsType,
    "specialHandling": specialHandling == null ? [] : List<dynamic>.from(specialHandling!.map((x) => x)),
    "insuranceRequired": insuranceRequired,
    "pickupSchedule": pickupSchedule?.toJson(),
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
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
    "serviceDate": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "pickupTiming": pickupTiming,
    "dayLabel": dayLabel,
  };
}

class Weight {
  dynamic value;
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
