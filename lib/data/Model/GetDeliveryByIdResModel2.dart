
import 'dart:convert';

GetDeliveryByIdResModel2 getDeliveryByIdResModel2FromJson(String str) =>
    GetDeliveryByIdResModel2.fromJson(json.decode(str));

String getDeliveryByIdResModel2ToJson(GetDeliveryByIdResModel2 data) =>
    json.encode(data.toJson());

class GetDeliveryByIdResModel2 {
  String? message;
  int? code;
  bool? error;
  Data? data;

  GetDeliveryByIdResModel2({this.message, this.code, this.error, this.data});

  factory GetDeliveryByIdResModel2.fromJson(Map<String, dynamic> json) =>
      GetDeliveryByIdResModel2(
        message: json["message"]?.toString(),
        code: json["code"] is int ? json["code"] : int.tryParse(json["code"]?.toString() ?? "0"),
        error: json["error"] is bool ? json["error"] : json["error"]?.toString() == "true",
        data: json["data"] == null ? null : Data.fromJson(json["data"] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    "message": message,
    "code": code,
    "error": error,
    "data": data?.toJson(),
  };
}

class Data {
  Pickup? pickup;
  PackageDetails? packageDetails;
  String? id;
  String? customer;
  DeliveryBoy? deliveryBoy;
  VehicleTypeId? vehicleTypeId;
  int? userPayAmount;
  List<Pickup>? dropoff;
  String? status;
  String? paymentMethod;
  int? freeWaitingTime;
  int? totalWaitingTime;
  int? extraWaitingMinutes;
  int? extraWaitingCharge;
  String? otp;
  String? txId;
  int? createdAt;

  Data({
    this.pickup,
    this.packageDetails,
    this.id,
    this.customer,
    this.deliveryBoy,
    this.vehicleTypeId,
    this.userPayAmount,
    this.dropoff,
    this.status,
    this.paymentMethod,
    this.freeWaitingTime,
    this.totalWaitingTime,
    this.extraWaitingMinutes,
    this.extraWaitingCharge,
    this.otp,
    this.txId,
    this.createdAt,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    pickup: json["pickup"] == null ? null : Pickup.fromJson(json["pickup"]),
    packageDetails: json["packageDetails"] == null
        ? null
        : PackageDetails.fromJson(json["packageDetails"]),
    id: json["_id"]?.toString(),
    customer: json["customer"]?.toString(),
    deliveryBoy: json["deliveryBoy"] == null
        ? null
        : DeliveryBoy.fromJson(json["deliveryBoy"]),
    vehicleTypeId: json["vehicleTypeId"] == null
        ? null
        : VehicleTypeId.fromJson(json["vehicleTypeId"]),
    userPayAmount: json["userPayAmount"] is int
        ? json["userPayAmount"]
        : int.tryParse(json["userPayAmount"]?.toString() ?? "0"),
    dropoff: json["dropoff"] == null
        ? []
        : List<Pickup>.from(json["dropoff"]!.map((x) => Pickup.fromJson(x))),
    status: json["status"]?.toString(),
    paymentMethod: json["paymentMethod"]?.toString(),
    freeWaitingTime: json["freeWaitingTime"],
    totalWaitingTime: json["totalWaitingTime"],
    extraWaitingMinutes: json["extraWaitingMinutes"],
    extraWaitingCharge: json["extraWaitingCharge"],
    otp: json["otp"]?.toString(),
    txId: json["txId"]?.toString(),
    createdAt: json["createdAt"] is int
        ? json["createdAt"]
        : int.tryParse(json["createdAt"]?.toString() ?? "0"),
  );

  Map<String, dynamic> toJson() => {
    "pickup": pickup?.toJson(),
    "packageDetails": packageDetails?.toJson(),
    "_id": id,
    "customer": customer,
    "deliveryBoy": deliveryBoy?.toJson(),
    "vehicleTypeId": vehicleTypeId?.toJson(),
    "userPayAmount": userPayAmount,
    "dropoff": dropoff == null ? [] : List<dynamic>.from(dropoff!.map((x) => x.toJson())),
    "status": status,
    "paymentMethod": paymentMethod,
    "freeWaitingTime": freeWaitingTime,
    "totalWaitingTime": totalWaitingTime,
    "extraWaitingMinutes": extraWaitingMinutes,
    "extraWaitingCharge": extraWaitingCharge,
    "otp": otp,
    "txId": txId,
    "createdAt": createdAt,
  };
}

class DeliveryBoy {
  CurrentLocation? currentLocation;
  String? id;
  String? userType;
  String? firstName;
  String? lastName;
  String? email;
  String? phone;
  String? password;
  String? cityId;
  String? driverStatus;
  String? status;
  String? deviceId;
  int? completedOrderCount;
  int? averageRating;
  String? referralCode;
  String? refByCode;
  String? socketId;
  bool? isDisable;
  bool? isDeleted;
  List<VehicleDetail>? vehicleDetails;
  List<dynamic>? rating;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;
  DateTime? lastLocationUpdate;
  String? image;

  DeliveryBoy({
    this.currentLocation,
    this.id,
    this.userType,
    this.firstName,
    this.lastName,
    this.email,
    this.phone,
    this.password,
    this.cityId,
    this.driverStatus,
    this.status,
    this.deviceId,
    this.completedOrderCount,
    this.averageRating,
    this.referralCode,
    this.refByCode,
    this.socketId,
    this.isDisable,
    this.isDeleted,
    this.vehicleDetails,
    this.rating,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
    this.lastLocationUpdate,
    this.image,
  });

  factory DeliveryBoy.fromJson(Map<String, dynamic> json) => DeliveryBoy(
    currentLocation: json["currentLocation"] == null
        ? null
        : CurrentLocation.fromJson(json["currentLocation"]),
    id: json["_id"]?.toString(),
    userType: json["userType"]?.toString(),
    firstName: json["firstName"]?.toString(),
    lastName: json["lastName"]?.toString(),
    email: json["email"]?.toString(),
    phone: json["phone"]?.toString(),
    password: json["password"]?.toString(),
    cityId: json["cityId"]?.toString(),
    driverStatus: json["driverStatus"]?.toString(),
    status: json["status"]?.toString(), // No enum crash
    deviceId: json["deviceId"]?.toString(),
    completedOrderCount: json["completedOrderCount"] is int
        ? json["completedOrderCount"]
        : int.tryParse(json["completedOrderCount"]?.toString() ?? "0"),
    averageRating: json["averageRating"] is int
        ? json["averageRating"]
        : int.tryParse(json["averageRating"]?.toString() ?? "0"),
    referralCode: json["referralCode"]?.toString(),
    refByCode: json["refByCode"]?.toString(),
    socketId: json["socketId"]?.toString(),
    isDisable: json["isDisable"] as bool?,
    isDeleted: json["isDeleted"] as bool?,
    vehicleDetails: json["vehicleDetails"] == null
        ? []
        : List<VehicleDetail>.from(json["vehicleDetails"]!.map((x) => VehicleDetail.fromJson(x))),
    rating: json["rating"],
    date: json["date"] is int ? json["date"] : null,
    month: json["month"] is int ? json["month"] : null,
    year: json["year"] is int ? json["year"] : null,
    createdAt: json["createdAt"] is int ? json["createdAt"] : null,
    updatedAt: json["updatedAt"] is int ? json["updatedAt"] : null,
    lastLocationUpdate: json["lastLocationUpdate"] == null
        ? null
        : DateTime.tryParse(json["lastLocationUpdate"]),
    image: json["image"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "currentLocation": currentLocation?.toJson(),
    "_id": id,
    "userType": userType,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
    "phone": phone,
    "cityId": cityId,
    "driverStatus": driverStatus,
    "status": status,
    "deviceId": deviceId,
    "completedOrderCount": completedOrderCount,
    "averageRating": averageRating,
    "referralCode": referralCode,
    "refByCode": refByCode,
    "socketId": socketId,
    "isDisable": isDisable,
    "isDeleted": isDeleted,
    "vehicleDetails": vehicleDetails == null
        ? []
        : List<dynamic>.from(vehicleDetails!.map((x) => x.toJson())),
    "lastLocationUpdate": lastLocationUpdate?.toIso8601String(),
    "image": image,
  };
}

class CurrentLocation {
  String? type;
  List<double>? coordinates;

  CurrentLocation({this.type, this.coordinates});

  factory CurrentLocation.fromJson(Map<String, dynamic> json) => CurrentLocation(
    type: json["type"]?.toString(),
    coordinates: json["coordinates"] == null
        ? null
        : List<double>.from(json["coordinates"]!.map((x) => x is num ? x.toDouble() : 0.0)),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "coordinates": coordinates,
  };
}

class VehicleDetail {
  String? verifiedBy;
  String? vehicle;
  String? numberPlate;
  String? model;
  int? capacityWeight;
  int? capacityVolume;
  bool? isActive;
  String? status;
  String? id;
  List<Document>? documents;
  String? verificationRemarks;
  DateTime? verifiedAt;

  VehicleDetail({
    this.verifiedBy,
    this.vehicle,
    this.numberPlate,
    this.model,
    this.capacityWeight,
    this.capacityVolume,
    this.isActive,
    this.status,
    this.id,
    this.documents,
    this.verificationRemarks,
    this.verifiedAt,
  });

  factory VehicleDetail.fromJson(Map<String, dynamic> json) => VehicleDetail(
    verifiedBy: json["verifiedBy"]?.toString(),
    vehicle: json["vehicle"]?.toString(),
    numberPlate: json["numberPlate"]?.toString(),
    model: json["model"]?.toString(),
    capacityWeight: json["capacityWeight"] is int ? json["capacityWeight"] : null,
    capacityVolume: json["capacityVolume"] is int ? json["capacityVolume"] : null,
    isActive: json["isActive"] as bool?,
    status: json["status"]?.toString(),
    id: json["_id"]?.toString(),
    documents: json["documents"] == null
        ? []
        : List<Document>.from(json["documents"]!.map((x) => Document.fromJson(x))),
    verificationRemarks: json["verificationRemarks"]?.toString(),
    verifiedAt: json["verifiedAt"] == null ? null : DateTime.tryParse(json["verifiedAt"] ?? ""),
  );

  Map<String, dynamic> toJson() => {
    "verifiedBy": verifiedBy,
    "vehicle": vehicle,
    "numberPlate": numberPlate,
    "model": model,
    "capacityWeight": capacityWeight,
    "capacityVolume": capacityVolume,
    "isActive": isActive,
    "status": status,
    "_id": id,
    "documents": documents == null ? [] : List<dynamic>.from(documents!.map((x) => x.toJson())),
    "verificationRemarks": verificationRemarks,
    "verifiedAt": verifiedAt?.toIso8601String(),
  };
}

class Document {
  String? type;
  String? fileUrl;
  String? verifiedBy;
  String? verificationStatus;
  String? id;
  String? remarks;
  DateTime? verifiedAt;

  Document({
    this.type,
    this.fileUrl,
    this.verifiedBy,
    this.verificationStatus,
    this.id,
    this.remarks,
    this.verifiedAt,
  });

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    type: json["type"]?.toString(),
    fileUrl: json["fileUrl"]?.toString(),
    verifiedBy: json["verifiedBy"]?.toString(),
    verificationStatus: json["verificationStatus"]?.toString(),
    id: json["_id"]?.toString(),
    remarks: json["remarks"]?.toString(),
    verifiedAt: json["verifiedAt"] == null ? null : DateTime.tryParse(json["verifiedAt"] ?? ""),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "fileUrl": fileUrl,
    "verifiedBy": verifiedBy,
    "verificationStatus": verificationStatus,
    "_id": id,
    "remarks": remarks,
    "verifiedAt": verifiedAt?.toIso8601String(),
  };
}

class Pickup {
  String? name;
  double? lat;
  double? long;
  String? id;

  Pickup({this.name, this.lat, this.long, this.id});

  factory Pickup.fromJson(Map<String, dynamic> json) => Pickup(
    name: json["name"]?.toString(),
    lat: json["lat"] is num ? (json["lat"] as num).toDouble() : null,
    long: json["long"] is num ? (json["long"] as num).toDouble() : null,
    id: json["_id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "lat": lat,
    "long": long,
    "_id": id,
  };
}

class PackageDetails {
  bool? fragile;

  PackageDetails({this.fragile});

  factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
    fragile: json["fragile"] is bool ? json["fragile"] : null,
  );

  Map<String, dynamic> toJson() => {"fragile": fragile};
}

class VehicleTypeId {
  Dimensions? dimensions;
  String? id;
  String? name;
  int? capacity;
  int? baseFare;
  int? perKmRate;
  int? perMinuteRate;
  int? maxDeliveryDistance;
  String? image;
  bool? isDisable;
  bool? isDeleted;
  int? date;
  int? month;
  int? year;
  int? createdAt;
  int? updatedAt;

  VehicleTypeId({
    this.dimensions,
    this.id,
    this.name,
    this.capacity,
    this.baseFare,
    this.perKmRate,
    this.perMinuteRate,
    this.maxDeliveryDistance,
    this.image,
    this.isDisable,
    this.isDeleted,
    this.date,
    this.month,
    this.year,
    this.createdAt,
    this.updatedAt,
  });

  factory VehicleTypeId.fromJson(Map<String, dynamic> json) => VehicleTypeId(
    dimensions: json["dimensions"] == null ? null : Dimensions.fromJson(json["dimensions"]),
    id: json["_id"]?.toString(),
    name: json["name"]?.toString(),
    capacity: json["capacity"] is int ? json["capacity"] : null,
    baseFare: json["baseFare"] is int ? json["baseFare"] : null,
    perKmRate: json["perKmRate"] is int ? json["perKmRate"] : null,
    perMinuteRate: json["perMinuteRate"] is int ? json["perMinuteRate"] : null,
    maxDeliveryDistance: json["maxDeliveryDistance"] is int ? json["maxDeliveryDistance"] : null,
    image: json["image"]?.toString(),
    isDisable: json["isDisable"] as bool?,
    isDeleted: json["isDeleted"] as bool?,
    date: json["date"] is int ? json["date"] : null,
    month: json["month"] is int ? json["month"] : null,
    year: json["year"] is int ? json["year"] : null,
    createdAt: json["createdAt"] is int ? json["createdAt"] : null,
    updatedAt: json["updatedAt"] is int ? json["updatedAt"] : null,
  );

  Map<String, dynamic> toJson() => {
    "dimensions": dimensions?.toJson(),
    "_id": id,
    "name": name,
    "capacity": capacity,
    "baseFare": baseFare,
    "image": image,
  };
}

class Dimensions {
  int? length;
  int? width;
  int? height;

  Dimensions({this.length, this.width, this.height});

  factory Dimensions.fromJson(Map<String, dynamic> json) => Dimensions(
    length: json["length"] is int ? json["length"] : null,
    width: json["width"] is int ? json["width"] : null,
    height: json["height"] is int ? json["height"] : null,
  );

  Map<String, dynamic> toJson() => {
    "length": length,
    "width": width,
    "height": height,
  };
}