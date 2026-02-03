// To parse this JSON data, do
//
//     final sendMoneyBodyModel = sendMoneyBodyModelFromJson(jsonString);

import 'dart:convert';

SendMoneyBodyModel sendMoneyBodyModelFromJson(String str) => SendMoneyBodyModel.fromJson(json.decode(str));

String sendMoneyBodyModelToJson(SendMoneyBodyModel data) => json.encode(data.toJson());

class SendMoneyBodyModel {
  String? userId;
  int? amount;

  SendMoneyBodyModel({
    this.userId,
    this.amount,
  });

  factory SendMoneyBodyModel.fromJson(Map<String, dynamic> json) => SendMoneyBodyModel(
    userId: json["userId"],
    amount: json["amount"],
  );

  Map<String, dynamic> toJson() => {
    "userId": userId,
    "amount": amount,
  };
}
