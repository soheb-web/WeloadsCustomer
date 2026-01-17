// To parse this JSON data, do
//
//     final createPickersAndMoverBooking = createPickersAndMoverBookingFromJson(jsonString);

import 'dart:convert';

CreatePickersAndMoverBooking createPickersAndMoverBookingFromJson(String str) => CreatePickersAndMoverBooking.fromJson(json.decode(str));

String createPickersAndMoverBookingToJson(CreatePickersAndMoverBooking data) => json.encode(data.toJson());

class CreatePickersAndMoverBooking {
  String? delivery;
  Dropoff? pickup;
  Dropoff? dropoff;
  List<Product>? product;
  Schedule? schedule;
  AddOns? addOns;
  int? amount;
  String? paymentMethod;

  CreatePickersAndMoverBooking({
    this.delivery,
    this.pickup,
    this.dropoff,
    this.product,
    this.schedule,
    this.addOns,
    this.amount,
    this.paymentMethod,
  });

  factory CreatePickersAndMoverBooking.fromJson(Map<String, dynamic> json) => CreatePickersAndMoverBooking(
    delivery: json["delivery"],
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    product: json["product"] == null ? [] : List<Product>.from(json["product"]!.map((x) => Product.fromJson(x))),
    schedule: json["schedule"] == null ? null : Schedule.fromJson(json["schedule"]),
    addOns: json["addOns"] == null ? null : AddOns.fromJson(json["addOns"]),
    amount: json["Amount"],
    paymentMethod: json["paymentMethod"],
  );

  Map<String, dynamic> toJson() => {
    "delivery": delivery,
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "product": product == null ? [] : List<dynamic>.from(product!.map((x) => x.toJson())),
    "schedule": schedule?.toJson(),
    "addOns": addOns?.toJson(),
    "Amount": amount,
    "paymentMethod": paymentMethod,
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
  double? lat;
  double? long;
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
    lat: json["lat"]?.toDouble(),
    long: json["long"]?.toDouble(),
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

  Product({
    this.item,
    this.quantity,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    item: json["item"],
    quantity: json["quantity"],
  );

  Map<String, dynamic> toJson() => {
    "item": item,
    "quantity": quantity,
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
    "serviceDate": "${serviceDate!.year.toString().padLeft(4, '0')}-${serviceDate!.month.toString().padLeft(2, '0')}-${serviceDate!.day.toString().padLeft(2, '0')}",
    "pickupTiming": pickupTiming,
    "dayLabel": dayLabel,
  };
}
