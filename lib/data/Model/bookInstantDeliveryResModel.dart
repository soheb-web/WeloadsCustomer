// To parse this JSON data, do
//
//     final bookInstantDeliveryResModel = bookInstantDeliveryResModelFromJson(jsonString);
import 'dart:convert';

BookInstantDeliveryResModel bookInstantDeliveryResModelFromJson(String str) =>
    BookInstantDeliveryResModel.fromJson(json.decode(str));

String bookInstantDeliveryResModelToJson(BookInstantDeliveryResModel data) =>
    json.encode(data.toJson());

class BookInstantDeliveryResModel {
  final String message;
  final int code;
  final bool error;
  final Data data;

  BookInstantDeliveryResModel({
    required this.message,
    required this.code,
    required this.error,
    required this.data,
  });

  factory BookInstantDeliveryResModel.fromJson(Map<String, dynamic> json) =>
      BookInstantDeliveryResModel(
        message: json["message"] ?? "",
        code: json["code"] ?? 0,
        error: json["error"] ?? false,
        data: Data.fromJson(json["data"] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data.toJson(),
  };
}

class Data {
  final String customer;
  final dynamic deliveryBoy;
  final dynamic pendingDriver;
  final String vehicleTypeId;
  final List<dynamic> rejectedDeliveryBoy;
  final bool isCopanCode;
  final int copanAmount;
  final int coinAmount;
  final int taxAmount;
  final int userPayAmount;
  final double distance;
  final String mobNo;
  final String picUpType;
  final String name;
  final Dropoff pickup;
  final List<Dropoff> dropoff; // <-- NOW LIST
  final PackageDetails packageDetails;
  final String status;
  final dynamic cancellationReason;
  final String paymentMethod;
  final dynamic image;
  final dynamic otp;
  final bool isDisable;
  final bool isDeleted;
  final String id;
  final String txId;
  final int date;
  final int month;
  final int year;
  final int createdAt;
  final int updatedAt;

  Data({
    required this.customer,
    required this.deliveryBoy,
    required this.pendingDriver,
    required this.vehicleTypeId,
    required this.rejectedDeliveryBoy,
    required this.isCopanCode,
    required this.copanAmount,
    required this.coinAmount,
    required this.taxAmount,
    required this.userPayAmount,
    required this.distance,
    required this.mobNo,
    required this.picUpType,
    required this.name,
    required this.pickup,
    required this.dropoff,
    required this.packageDetails,
    required this.status,
    required this.cancellationReason,
    required this.paymentMethod,
    required this.image,
    required this.otp,
    required this.isDisable,
    required this.isDeleted,
    required this.id,
    required this.txId,
    required this.date,
    required this.month,
    required this.year,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    customer: json["customer"] ?? "",
    deliveryBoy: json["deliveryBoy"],
    pendingDriver: json["pendingDriver"],
    vehicleTypeId: json["vehicleTypeId"] ?? "",
    rejectedDeliveryBoy: json["rejectedDeliveryBoy"] == null
        ? []
        : List<dynamic>.from(json["rejectedDeliveryBoy"].map((x) => x)),
    isCopanCode: json["isCopanCode"] ?? false,
    copanAmount: json["copanAmount"] ?? 0,
    coinAmount: json["coinAmount"] ?? 0,
    taxAmount: json["taxAmount"] ?? 0,
    userPayAmount: json["userPayAmount"] ?? 0,
    distance: (json["distance"] ?? 0.0).toDouble(),
    mobNo: json["mobNo"] ?? "",
    picUpType: json["picUpType"] ?? "",
    name: json["name"] ?? "",
    pickup: Dropoff.fromJson(json["pickup"] ?? {}),
    dropoff: json["dropoff"] == null
        ? <Dropoff>[]
        : List<Dropoff>.from(
      json["dropoff"].map((x) => Dropoff.fromJson(x)),
    ),
    packageDetails: PackageDetails.fromJson(json["packageDetails"] ?? {}),
    status: json["status"] ?? "",
    cancellationReason: json["cancellationReason"],
    paymentMethod: json["paymentMethod"] ?? "",
    image: json["image"],
    otp: json["otp"],
    isDisable: json["isDisable"] ?? false,
    isDeleted: json["isDeleted"] ?? false,
    id: json["_id"] ?? "",
    txId: json["txId"] ?? "",
    date: json["date"] ?? 0,
    month: json["month"] ?? 0,
    year: json["year"] ?? 0,
    createdAt: json["createdAt"] ?? 0,
    updatedAt: json["updatedAt"] ?? 0,
  );

  Map<String, dynamic> toJson() => {
    "customer": customer,
    "deliveryBoy": deliveryBoy,
    "pendingDriver": pendingDriver,
    "vehicleTypeId": vehicleTypeId,
    "rejectedDeliveryBoy":
    List<dynamic>.from(rejectedDeliveryBoy.map((x) => x)),
    "isCopanCode": isCopanCode,
    "copanAmount": copanAmount,
    "coinAmount": coinAmount,
    "taxAmount": taxAmount,
    "userPayAmount": userPayAmount,
    "distance": distance,
    "mobNo": mobNo,
    "picUpType": picUpType,
    "name": name,
    "pickup": pickup.toJson(),
    "dropoff": List<dynamic>.from(dropoff.map((x) => x.toJson())),
    "packageDetails": packageDetails.toJson(),
    "status": status,
    "cancellationReason": cancellationReason,
    "paymentMethod": paymentMethod,
    "image": image,
    "otp": otp,
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

class Dropoff {
  final String name;
  final double lat;
  final double long;
  final String? id; // Optional _id from API

  Dropoff({
    required this.name,
    required this.lat,
    required this.long,
    this.id,
  });

  factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
    name: json["name"] ?? "",
    lat: (json["lat"] ?? 0.0).toDouble(),
    long: (json["long"] ?? 0.0).toDouble(),
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
    if (id != null) "_id": id,
  };
}

class PackageDetails {
  final bool fragile;

  PackageDetails({required this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) =>
      PackageDetails(fragile: json["fragile"] ?? false);

  Map<String, dynamic> toJson() => {"fragile": fragile};
}