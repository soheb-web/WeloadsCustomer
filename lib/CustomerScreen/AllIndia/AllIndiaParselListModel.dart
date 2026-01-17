// To parse this JSON data, do
//
//     final allIndiaResponseListModel = allIndiaResponseListModelFromJson(jsonString);

import 'dart:convert';

AllIndiaResponseListModel allIndiaResponseListModelFromJson(String str) =>
    AllIndiaResponseListModel.fromJson(json.decode(str));

String allIndiaResponseListModelToJson(AllIndiaResponseListModel data) =>
    json.encode(data.toJson());

class AllIndiaResponseListModel {
  String? message;
  int? code;
  bool? error;
  List<DatumAllIndia>? data;

  AllIndiaResponseListModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory AllIndiaResponseListModel.fromJson(Map<String, dynamic> json) =>
      AllIndiaResponseListModel(
        message: json["message"],
        code: json["code"],
        error: json["error"],
        data: json["data"] == null
            ? []
            : List<DatumAllIndia>.from(
            json["data"]!.map((x) => DatumAllIndia.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class DatumAllIndia {
  Dropoff? pickup;
  Dropoff? dropoff;
  String? id;
  List<Product>? product;
  Status? status;
  String? txId;
  int? createdAt;

  DatumAllIndia({
    this.pickup,
    this.dropoff,
    this.id,
    this.product,
    this.status,
    this.txId,
    this.createdAt,
  });

  factory DatumAllIndia.fromJson(Map<String, dynamic> json) => DatumAllIndia(
    pickup: json["pickup"] == null ? null : Dropoff.fromJson(json["pickup"]),
    dropoff: json["dropoff"] == null ? null : Dropoff.fromJson(json["dropoff"]),
    id: json["_id"],
    product: json["product"] == null
        ? []
        : List<Product>.from(json["product"]!.map((x) => Product.fromJson(x))),
    status: statusValues.map[json["status"]],
    txId: json["txId"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "dropoff": dropoff?.toJson(),
    "_id": id,
    "product": product == null ? [] : List<dynamic>.from(product!.map((x) => x.toJson())),
    "status": status != null ? statusValues.reverse[status] : null,
    "txId": txId,
    "createdAt": createdAt,
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
    location: json["location"] as String?,
    lat: (json["lat"] as num?)?.toDouble(),
    long: (json["long"] as num?)?.toDouble(),
    serviceListAvailable: json["serviceListAvailable"] as bool?,
    florNo: json["florNo"] as int?,
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
  String? item; // ← Changed to String? (no enum anymore)
  int? quantity;
  String? id;

  Product({
    this.item,
    this.quantity,
    this.id,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    item: json["item"] as String?,
    quantity: json["quantity"] as int?,
    id: json["_id"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "item": item,
    "quantity": quantity,
    "_id": id,
  };
}

enum Status {
  pending,
}

final statusValues = EnumValues({
  "pending": Status.pending,
});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap ??= map.map((k, v) => MapEntry(v, k));
    return reverseMap!;
  }
}