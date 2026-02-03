// To parse this JSON data, do
//
//     final DeliveryBodyModel = DeliveryBodyModelFromJson(jsonString);

import 'dart:convert';

DeliveryBodyModel DeliveryBodyModelFromJson(String str) => DeliveryBodyModel.fromJson(json.decode(str));

String DeliveryBodyModelToJson(DeliveryBodyModel data) => json.encode(data.toJson());

class DeliveryBodyModel {
  String? deliveryId;

  DeliveryBodyModel({
    this.deliveryId,
  });

  factory DeliveryBodyModel.fromJson(Map<String, dynamic> json) => DeliveryBodyModel(
    deliveryId: json["deliveryId"],
  );

  Map<String, dynamic> toJson() => {
    "deliveryId": deliveryId,
  };
}
