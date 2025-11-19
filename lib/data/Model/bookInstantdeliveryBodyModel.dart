
import 'dart:convert';

BookInstantDeliveryBodyModel bookInstantDeliveryBodyModelFromJson(String str) =>
    BookInstantDeliveryBodyModel.fromJson(json.decode(str));

String bookInstantDeliveryBodyModelToJson(BookInstantDeliveryBodyModel data) =>
    json.encode(data.toJson());

class BookInstantDeliveryBodyModel {
    final String vehicleTypeId;
    final String origName;
    final double origLat;
    final double origLon;
    final int coinAmount;
    final String? copanId;
    final List<BookDropoff> dropoff;
    final double distance;
    final int userPayAmount;
    final double taxAmount;
    final String mobNo;
    final String name;

    BookInstantDeliveryBodyModel({
        required this.vehicleTypeId,
        required this.origName,
        required this.origLat,
        required this.origLon,
        required this.coinAmount,
        this.copanId,
        required this.dropoff,
        required this.distance,
        required this.userPayAmount,
        required this.taxAmount,
        required this.mobNo,
        required this.name,
    });

    factory BookInstantDeliveryBodyModel.fromJson(Map<String, dynamic> json) =>
        BookInstantDeliveryBodyModel(
            vehicleTypeId: json["vehicleTypeId"],
            origName: json["origName"],
            origLat: json["origLat"]?.toDouble(),
            origLon: json["origLon"]?.toDouble(),
            coinAmount: json["coinAmount"],
            copanId: json["copanId"],
            dropoff: List<BookDropoff>.from(json["dropoff"].map((x) => BookDropoff.fromJson(x))),
            distance: json["distance"]?.toDouble(),
            userPayAmount: json["userPayAmount"],
            taxAmount: json["taxAmount"]?.toDouble(),
            mobNo: json["mobNo"],
            name: json["name"],
        );

    Map<String, dynamic> toJson() => {
        "vehicleTypeId": vehicleTypeId,
        "origName": origName,
        "origLat": origLat,
        "origLon": origLon,
        "coinAmount": coinAmount,
        "copanId": copanId,
        "dropoff": List<dynamic>.from(dropoff.map((x) => x.toJson())),

        "distance": distance,
        "userPayAmount": userPayAmount,
        "taxAmount": taxAmount,
        "mobNo": mobNo,
        "name": name,
    };
}

class BookDropoff {
    final String name;
    final double lat;
    final double long;

    BookDropoff({
        required this.name,
        required this.lat,
        required this.long,
    });

    factory BookDropoff.fromJson(Map<String, dynamic> json) => BookDropoff(
        name: json["name"]?.toString() ?? "",
        lat: json["lat"]?.toDouble() ?? 0.0,
        long: json["long"]?.toDouble() ?? 0.0,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "lat": lat,
        "long": long,
    };
}

class PackageDetails {
    final String description;
    final int weight;
    final bool fragile;

    PackageDetails({
        required this.description,
        required this.weight,
        required this.fragile,
    });

    factory PackageDetails.fromJson(Map<String, dynamic> json) => PackageDetails(
        description: json["description"],
        weight: json["weight"],
        fragile: json["fragile"],
    );

    Map<String, dynamic> toJson() => {
        "description": description,
        "weight": weight,
        "fragile": fragile,
    };
}