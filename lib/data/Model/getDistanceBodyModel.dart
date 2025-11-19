// // To parse this JSON data, do
// //
// //     final getDistanceBodyModel = getDistanceBodyModelFromJson(jsonString);
//
// import 'dart:convert';
//
// GetDistanceBodyModel getDistanceBodyModelFromJson(String str) => GetDistanceBodyModel.fromJson(json.decode(str));
//
// String getDistanceBodyModelToJson(GetDistanceBodyModel data) => json.encode(data.toJson());
//
// class GetDistanceBodyModel {
//     String name;
//     String mobNo;
//     String origName;
//     String destName;
//     String picUpType;
//     double origLat;
//     double origLon;
//     double destLat;
//     double destLon;
//
//     GetDistanceBodyModel({
//         required this.name,
//         required this.mobNo,
//         required this.origName,
//         required this.destName,
//         required this.picUpType,
//         required this.origLat,
//         required this.origLon,
//         required this.destLat,
//         required this.destLon,
//     });
//
//     factory GetDistanceBodyModel.fromJson(Map<String, dynamic> json) => GetDistanceBodyModel(
//         name: json["name"],
//         mobNo: json["mobNo"],
//         origName: json["origName"],
//         destName: json["destName"],
//         picUpType: json["picUpType"],
//         origLat: json["origLat"]?.toDouble(),
//         origLon: json["origLon"]?.toDouble(),
//         destLat: json["destLat"]?.toDouble(),
//         destLon: json["destLon"]?.toDouble(),
//     );
//
//     Map<String, dynamic> toJson() => {
//         "name": name,
//         "mobNo": mobNo,
//         "origName": origName,
//         "destName": destName,
//         "picUpType": picUpType,
//         "origLat": origLat,
//         "origLon": origLon,
//         "destLat": destLat,
//         "destLon": destLon,
//     };
// }




// models/distance/get_distance_body_model.dart
import 'dart:convert';

/// JSON String → Model
GetDistanceBodyModel getDistanceBodyModelFromJson(String str) =>
    GetDistanceBodyModel.fromJson(json.decode(str));

/// Model → JSON String
String getDistanceBodyModelToJson(GetDistanceBodyModel data) =>
    json.encode(data.toJson());

/// Main Model – Updated for Multi Dropoff + totalDistance
class GetDistanceBodyModel {
    final String name;
    final String mobNo;
    final String origName;
    final String picUpType;
    final double origLat;
    final double origLon;
    final List<Dropoff> dropoff;
    final int? totalDistance; // Optional – API से आएगा

    GetDistanceBodyModel({
        required this.name,
        required this.mobNo,
        required this.origName,
        required this.picUpType,
        required this.origLat,
        required this.origLon,
        required this.dropoff,
        this.totalDistance,
    });

    factory GetDistanceBodyModel.fromJson(Map<String, dynamic> json) =>
        GetDistanceBodyModel(
            name: json["name"] ?? '',
            mobNo: json["mobNo"] ?? '',
            origName: json["origName"] ?? '',
            picUpType: json["picUpType"] ?? '',
            origLat: _toDouble(json["origLat"]),
            origLon: _toDouble(json["origLon"]),
            dropoff: (json["dropoff"] as List<dynamic>?)
                ?.map((x) => Dropoff.fromJson(x as Map<String, dynamic>))
                .toList() ??
                [],
            totalDistance: json["totalDistance"] as int?,
        );

    Map<String, dynamic> toJson() => {
        "name": name,
        "mobNo": mobNo,
        "origName": origName,
        "picUpType": picUpType,
        "origLat": origLat,
        "origLon": origLon,
        "dropoff": dropoff.map((e) => e.toJson()).toList(),
        if (totalDistance != null) "totalDistance": totalDistance,
    };

    @override
    String toString() {
        return 'GetDistanceBodyModel(name: $name, mobNo: $mobNo, origName: $origName, '
            'picUpType: $picUpType, origLat: $origLat, origLon: $origLon, '
            'dropoff: $dropoff, totalDistance: $totalDistance)';
    }
}

/// Helper: Safe double conversion
double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is int) return value.toDouble();
    if (value is double) return value;
    return 0.0;
}




// models/distance/dropoff.dart
class Dropoff {
    final String name;
    final double lat;
    final double long;

    Dropoff({
        required this.name,
        required this.lat,
        required this.long,
    });

    factory Dropoff.fromJson(Map<String, dynamic> json) => Dropoff(
        name: json["name"] ?? '',
        lat: _toDouble(json["lat"]),
        long: _toDouble(json["long"]),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "lat": lat,
        "long": long,
    };

    @override
    String toString() => 'Dropoff(name: $name, lat: $lat, long: $long)';
}

