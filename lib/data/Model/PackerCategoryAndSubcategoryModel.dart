// To parse this JSON data, do
//
//     final packerCategoryAndSubCategoryModel = packerCategoryAndSubCategoryModelFromJson(jsonString);

import 'dart:convert';

PackerCategoryAndSubCategoryModel packerCategoryAndSubCategoryModelFromJson(String str) => PackerCategoryAndSubCategoryModel.fromJson(json.decode(str));

String packerCategoryAndSubCategoryModelToJson(PackerCategoryAndSubCategoryModel data) => json.encode(data.toJson());

class PackerCategoryAndSubCategoryModel {
  String? message;
  int? code;
  bool? error;
  Data? data;

  PackerCategoryAndSubCategoryModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory PackerCategoryAndSubCategoryModel.fromJson(Map<String, dynamic> json) => PackerCategoryAndSubCategoryModel(
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
  List<Category>? category;
  List<DataSubCategory>? subCategory;

  Data({
    this.category,
    this.subCategory,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    category: json["category"] == null ? [] : List<Category>.from(json["category"]!.map((x) => Category.fromJson(x))),
    subCategory: json["subCategory"] == null ? [] : List<DataSubCategory>.from(json["subCategory"]!.map((x) => DataSubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "category": category == null ? [] : List<dynamic>.from(category!.map((x) => x.toJson())),
    "subCategory": subCategory == null ? [] : List<dynamic>.from(subCategory!.map((x) => x.toJson())),
  };
}

class Category {
  String? name;

  Category({
    this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
  };
}

class DataSubCategory {
  String? id;
  String? name;
  List<SubCategorySubCategory>? subCategories;

  DataSubCategory({
    this.id,
    this.name,
    this.subCategories,
  });

  factory DataSubCategory.fromJson(Map<String, dynamic> json) => DataSubCategory(
    id: json["_id"],
    name: json["name"],
    subCategories: json["subCategories"] == null ? [] : List<SubCategorySubCategory>.from(json["subCategories"]!.map((x) => SubCategorySubCategory.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "subCategories": subCategories == null ? [] : List<dynamic>.from(subCategories!.map((x) => x.toJson())),
  };
}

class SubCategorySubCategory {
  String? id;
  String? name;
  List<String>? innerCategory;
  bool? isInnerCategory;

  SubCategorySubCategory({
    this.id,
    this.name,
    this.innerCategory,
    this.isInnerCategory,
  });

  factory SubCategorySubCategory.fromJson(Map<String, dynamic> json) => SubCategorySubCategory(
    id: json["_id"],
    name: json["name"],
    innerCategory: json["innerCategory"] == null ? [] : List<String>.from(json["innerCategory"]!.map((x) => x)),
    isInnerCategory: json["isInnerCategory"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "innerCategory": innerCategory == null ? [] : List<dynamic>.from(innerCategory!.map((x) => x)),
    "isInnerCategory": isInnerCategory,
  };
}
