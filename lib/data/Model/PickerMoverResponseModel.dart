// To parse this JSON data, do
//
//     final pickerMoverBookingModel = pickerMoverBookingModelFromJson(jsonString);

import 'dart:convert';

PickerMoverBookingModel pickerMoverBookingModelFromJson(String str) => PickerMoverBookingModel.fromJson(json.decode(str));

String pickerMoverBookingModelToJson(PickerMoverBookingModel data) => json.encode(data.toJson());

class PickerMoverBookingModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  PickerMoverBookingModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory PickerMoverBookingModel.fromJson(Map<String, dynamic> json) => PickerMoverBookingModel(
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
  dynamic deliveryBoy;
  String? delivery;
  Dropoff? pickup;
  Dropoff? dropoff;
  List<Product>? product;
  Schedule? schedule;
  AddOns? addOns;
  int? amount;
  String? status;
  dynamic cancellationReason;
  String? paymentMethod;
  bool? isDisable;
  bool? isDeleted;
  String? id;
  String? txId;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  Data({
    this.customer,
    this.deliveryBoy,
    this.delivery,
    this.pickup,
    this.dropoff,
    this.product,
    this.schedule,
    this.addOns,
    this.amount,
    this.status,
    this.cancellationReason,
    this.paymentMethod,
    this.isDisable,
    this.isDeleted,
    this.id,
    this.txId,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customer: json["customer"],
    deliveryBoy: json["deliveryBoy"],
    delivery: json["delivery"],
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    product: json["product"] == null ? [] : List<Product>.from(json["product"]!.map((x) => Product.fromJson(x))),
    schedule: json["schedule"] == null ? null : Schedule.fromJson(json["schedule"]),
    addOns: json["addOns"] == null ? null : AddOns.fromJson(json["addOns"]),
    amount: json["amount"],
    status: json["status"],
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    id: json["_id"],
    txId: json["txId"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
  );

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "delivery": delivery,
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "product": product == null ? [] : List<dynamic>.from(product!.map((x) => x.toJson())),
    "schedule": schedule?.toJson(),
    "addOns": addOns?.toJson(),
    "amount": amount,
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "_id": id,
    "txId": txId,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
  };
}

class AddOns {
  String? name;
  String? description;
  int? price;
  bool? isSelected;

  AddOns({
    this.name,
    this.description,
    this.price,
    this.isSelected,
  });

  factory AddOns.fromJson(Map<String, dynamic> json) => AddOns(
    name: json["name"],
    description: json["description"],
    price: json["price"],
    isSelected: json["isSelected"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "description": description,
    "price": price,
    "isSelected": isSelected,
  };
}

class Dropoff {
  String? location;
  dynamic lat;
  dynamic long;
  bool? serviceListAvailable;
  int? florNo;

  Dropoff({
    this.location,
    this.lat,
    this.long,
    this.serviceListAvailable,
    this.florNo,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    location: json["location"],
    lat: json["lat"],
    long: json["long"],
    serviceListAvailable: json["serviceListAvailable"],
    florNo: json["florNo"],
  );

  Map<String, dynamic> toJson() => {
    "location": location,
    "lat": lat,
    "long": long,
    "serviceListAvailable": serviceListAvailable,
    "florNo": florNo,
  };
}

class Product {
  String? item;
  int? quantity;
  String? id;

  Product({
    this.item,
    this.quantity,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    item: json["item"],
    quantity: json["quantity"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "item": item,
    "quantity": quantity,
    "_id": id,
  };
}

class Schedule {
  DateTime? serviceDate;
  String? pickupTiming;
  String? dayLabel;

  Schedule({
    this.serviceDate,
    this.pickupTiming,
    this.dayLabel,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
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
