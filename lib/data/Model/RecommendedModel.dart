// To parse this JSON data, do
//
//     final recommendedModel = recommendedModelFromJson(jsonString);

import 'dart:convert';

RecommendedModel recommendedModelFromJson(String str) => RecommendedModel.fromJson(json.decode(str));

String recommendedModelToJson(RecommendedModel data) => json.encode(data.toJson());

class RecommendedModel {
  String? message;
  int? code;
  bool? error;
  List<Datum>? data;

  RecommendedModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory RecommendedModel.fromJson(Map<String, dynamic> json) => RecommendedModel(
    message: json["message"],
    code: json["code"],
    error: json["error"],
    data: json["data"] == null ? [] : List<Datum>.from(json["data"]!.map((x) => Datum.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Datum {
  String? name;
  String? key;
  String? value;

  Datum({
    this.name,
    this.key,
    this.value,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
    name: json["name"],
    key: json["key"],
    value: json["value"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "key": key,
    "value": value,
  };
}
