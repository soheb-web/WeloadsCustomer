/*
// To parse this JSON data, do
//
//     final transactionListResponseModel = transactionListResponseModelFromJson(jsonString);

import 'dart:convert';

TransactionListResponseModel transactionListResponseModelFromJson(String str) => TransactionListResponseModel.fromJson(json.decode(str));

String transactionListResponseModelToJson(TransactionListResponseModel data) => json.encode(data.toJson());

class TransactionListResponseModel {
  String? message;
  List<Code>? code;
  bool? error;
  List<Code>? data;

  TransactionListResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory TransactionListResponseModel.fromJson(Map<String, dynamic> json) => TransactionListResponseModel(
    message: json["message"],
    code: json["code"] == null ? [] : List<Code>.from(json["code"]!.map((x) => Code.fromJson(x))),
    error: json["error"],
    data: json["data"] == null ? [] : List<Code>.from(json["data"]!.map((x) => Code.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code == null ? [] : List<dynamic>.from(code!.map((x) => x.toJson())),
    "error": error,
    "data": data == null ? [] : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Code {
  String? id;
  Receiver? sender;
  Receiver? receiver;
  TxType? txType;
  Status? status;
  int? amount;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;
  User? user;
  String? razorpayOrderId;

  Code({
    this.id,
    this.sender,
    this.receiver,
    this.txType,
    this.status,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.razorpayOrderId,
  });

  factory Code.fromJson(Map<String, dynamic> json) => Code(
    id: json["_id"],
    sender: json["sender"] == null ? null : Receiver.fromJson(json["sender"]),
    receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
    txType: txTypeValues.map[json["txType"]]!,
    status: statusValues.map[json["status"]]!,
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    user: userValues.map[json["user"]]!,
    razorpayOrderId: json["razorpayOrderId"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender?.toJson(),
    "receiver": receiver?.toJson(),
    "txType": txTypeValues.reverse[txType],
    "status": statusValues.reverse[status],
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "user": userValues.reverse[user],
    "razorpayOrderId": razorpayOrderId,
  };
}

class Receiver {
  User? id;
  LastName? lastName;
  Email? email;

  Receiver({
    this.id,
    this.lastName,
    this.email,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    id: userValues.map[json["_id"]]!,
    lastName: lastNameValues.map[json["lastName"]]!,
    email: emailValues.map[json["email"]]!,
  );

  Map<String, dynamic> toJson() => {
    "_id": userValues.reverse[id],
    "lastName": lastNameValues.reverse[lastName],
    "email": emailValues.reverse[email],
  };
}

enum Email {
  SAJIV_GMAIL_COM,
  SKP_GMAIL_COM
}

final emailValues = EnumValues({
  "sajiv@gmail.com": Email.SAJIV_GMAIL_COM,
  "skp@gmail.com": Email.SKP_GMAIL_COM
});

enum User {
  THE_68_E5_F744_D1777_FDD770_CC78_D,
  THE_6918_AF8_E82_F491_A26_F3_A7_C57
}

final userValues = EnumValues({
  "68e5f744d1777fdd770cc78d": User.THE_68_E5_F744_D1777_FDD770_CC78_D,
  "6918af8e82f491a26f3a7c57": User.THE_6918_AF8_E82_F491_A26_F3_A7_C57
});

enum LastName {
  ANSARI,
  KHAN
}

final lastNameValues = EnumValues({
  "ansari": LastName.ANSARI,
  "khan": LastName.KHAN
});

enum Status {
  COMPLETED,
  FAILED,
  PENDING
}

final statusValues = EnumValues({
  "completed": Status.COMPLETED,
  "failed": Status.FAILED,
  "pending": Status.PENDING
});

enum TxType {
  DEPOSIT,
  WALLET_TRANSFER
}

final txTypeValues = EnumValues({
  "deposit": TxType.DEPOSIT,
  "wallet_transfer": TxType.WALLET_TRANSFER
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
*/




// To parse this JSON data, do
//     final transactionListResponseModel = transactionListResponseModelFromJson(jsonString);

import 'dart:convert';

TransactionListResponseModel transactionListResponseModelFromJson(String str) =>
    TransactionListResponseModel.fromJson(json.decode(str));

String transactionListResponseModelToJson(TransactionListResponseModel data) =>
    json.encode(data.toJson());

class TransactionListResponseModel {
  String? message;
  List<Code>? code;
  bool? error;
  List<Code>? data;

  TransactionListResponseModel({
    this.message,
    this.code,
    this.error,
    this.data,
  });

  factory TransactionListResponseModel.fromJson(Map<String, dynamic> json) =>
      TransactionListResponseModel(
        message: json["message"],
        code: json["code"] == null
            ? null
            : List<Code>.from(json["code"]!.map((x) => Code.fromJson(x))),
        error: json["error"],
        data: json["data"] == null
            ? null
            : List<Code>.from(json["data"]!.map((x) => Code.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code == null ? null : List<dynamic>.from(code!.map((x) => x.toJson())),
    "error": error,
    "data": data == null ? null : List<dynamic>.from(data!.map((x) => x.toJson())),
  };
}

class Code {
  String? id;
  Receiver? sender;
  Receiver? receiver;
  TxType? txType;
  Status? status;
  int? amount;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  int? v;
  User? user;
  String? razorpayOrderId;

  Code({
    this.id,
    this.sender,
    this.receiver,
    this.txType,
    this.status,
    this.amount,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.user,
    this.razorpayOrderId,
  });

  factory Code.fromJson(Map<String, dynamic> json) => Code(
    id: json["_id"],
    sender: json["sender"] == null ? null : Receiver.fromJson(json["sender"]),
    receiver: json["receiver"] == null ? null : Receiver.fromJson(json["receiver"]),
    txType: txTypeValues.map[json["txType"]],
    status: statusValues.map[json["status"]],
    amount: json["amount"],
    isDisable: json["isDisable"],
    isDeleted: json["isDeleted"],
    date: json["date"],
    month: json["month"],
    year: json["year"],
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    v: json["__v"],
    user: userValues.map[json["user"]],
    razorpayOrderId: json["razorpayOrderId"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "sender": sender?.toJson(),
    "receiver": receiver?.toJson(),
    "txType": txTypeValues.reverse[txType],
    "status": statusValues.reverse[status],
    "amount": amount,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "date": date,
    "month": month,
    "year": year,
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "__v": v,
    "user": userValues.reverse[user],
    "razorpayOrderId": razorpayOrderId,
  };
}

class Receiver {
  String? id;
  String? lastName;
  String? email;

  Receiver({
    this.id,
    this.lastName,
    this.email,
  });

  factory Receiver.fromJson(Map<String, dynamic> json) => Receiver(
    id: json["_id"],
    lastName: json["lastName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "lastName": lastName,
    "email": email,
  };
}

enum Status { completed, failed, pending }

final statusValues = EnumValues({
  "completed": Status.completed,
  "failed": Status.failed,
  "pending": Status.pending,
});

enum TxType { deposit, walletTransfer }

final txTypeValues = EnumValues({
  "deposit": TxType.deposit,
  "wallet_transfer": TxType.walletTransfer,
});

enum User {
  the68E5F744D1777Fdd770Cc78D,
  the6918Af8E82F491A26F3A7C57,
}

final userValues = EnumValues({
  "68e5f744d1777fdd770cc78d": User.the68E5F744D1777Fdd770Cc78D,
  "6918af8e82f491a26f3a7c57": User.the6918Af8E82F491A26F3A7C57,
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverse;

  EnumValues(this.map) {
    reverse = map.map((k, v) => MapEntry(v, k));
  }
}