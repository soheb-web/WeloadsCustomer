

import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'dart:developer';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/data/Model/CancelOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/GetDeliveryByIdResModel2.dart';
import 'Chat/chating.page.dart';
import 'CompleteScreen.dart';
import 'Rating/ratingPage.dart';

class PickupScreen extends StatefulWidget {
  final IO.Socket socket;
  final String deliveryId;
  final Map<String, dynamic> driver;
  final String? otp;
  final Map<String, dynamic> pickup;
  final List<Map<String, dynamic>> dropoff; // ← Multiple Dropoffs
  final dynamic amount;
  final Map<String, dynamic>? vehicleType;
  final Map<String, dynamic>? vehicleDetail;
  final String? status;
  final String? txId;

  const PickupScreen({
    super.key,
    required this.socket,
    required this.deliveryId,
    required this.driver,
    this.otp,
    required this.pickup,
    required this.dropoff,
    this.amount,
    this.vehicleType,
    this.vehicleDetail,
    this.status,
    this.txId,
  });

  @override
  State<PickupScreen> createState() => _PickupScreenState();
}

class _PickupScreenState extends State<PickupScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = <Polyline>{};
  final TextEditingController _controller = TextEditingController();
  String receivedMessage = "";
  final List<Map<String, dynamic>> messages = [];
  Map<String, dynamic>? assignedDriver;
  bool isSocketConnected = false;
  List<LatLng> _routePoints = [];
  bool _routeFetched = false;
  String? toPickupDistance;
  String? toPickupDuration;
  List<String> dropDistances = [];
  List<String> dropDurations = [];
  String? totalDistance;
  String? totalDuration;
  late IO.Socket socket;
  bool isLoadingData = true;
  String? error;
  LatLng? _driverLatLng;
  bool status = false;
  String? driverToPickupETA;
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  GetDeliveryByIdResModel2? deliveryData2;
  late BitmapDescriptor driverIcon;
// ये वैरिएबल class में ऊपर declare कर लो
  bool _isArrived = false;
  int _waitingSeconds = 0;
  String _waitingTimeText = "00:00";
  Timer? _waitingTimer;
// ये फंक्शन timer update करता रहेगा
  void _updateWaitingTimeText() {
    int mins = _waitingSeconds ~/ 60;
    int secs = _waitingSeconds % 60;
    _waitingTimeText = "${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}";
  }



  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    socket = widget.socket;
    _fetchDeliveryData();
    _emitDriverArrivedAtPickup();
    _setupEventListeners();
    _createNumberIcons();
    loadSimpleDriverIcon().then((_) {
      if (mounted) setState(() {});
    });
  }

  int _maxFreeWaitingSeconds = 300; // डिफ़ॉल्ट 5 मिनट (fallback)
  DateTime? _localArrivedAt; // Jab driver ne button dabaya tab ka time
  Future<void> loadSimpleDriverIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const size = 100.0;


    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 18,
      Paint()..color = const Color(0xFFD57430), // Bright Green
    );

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      12,
      Paint()..color = Colors.white,
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

    driverIcon = BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  }
  Future<void> _fetchDeliveryData() async {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.getDeliveryById2(widget.deliveryId);
      print("Raw Response: $response");
      GetDeliveryByIdResModel2 parsed;
      if (response is GetDeliveryByIdResModel2) {
        parsed = response; // Already parsed by Retrofit
      if (mounted) {
        setState(() {
          deliveryData2 = parsed;
          isLoadingData = false;
        });
        print("Driver: ${parsed.data?.deliveryBoy?.firstName ?? 'No Driver'}");
      }
  }}

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.trim().isEmpty) {
      Fluttertoast.showToast(msg: "फ़ोन नंबर उपलब्ध नहीं है");
      return;
    }

    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);

    try {
      final bool canLaunch = await canLaunchUrl(launchUri);
      if (canLaunch) {
        await launchUrl(launchUri);
      } else {
        Fluttertoast.showToast(msg: "कॉल नहीं हो पाया!");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "कुछ गलत हुआ: $e");
    }
  }

  void _emitDriverArrivedAtPickup() async{
    await _fetchDeliveryData();
    final payload = {"deliveryId": widget.deliveryId};
    // final payloadLocation = {"driverId": deliveryData2!.data!.deliveryBoy!.id ?? ""};
    if (!socket.connected) {
      log("Socket not connected, retrying in 2s...");
      Future.delayed(const Duration(seconds: 2), _emitDriverArrivedAtPickup);
      return;
    }

    socket.emit("delivery:status_update", payload);
    log("Emitted → delivery:status_update → $payload");

    socket.emitWithAck(
      "driver:get_location",
      { "driverId": deliveryData2!.data!.deliveryBoy!.id },
      ack: (data) {
        print("Driver Location Response: $data");
        // data mostly Map ya List mein aata hai, safe check karo
        if (data is Map<String, dynamic>) {
          _handleDriverLocationResponse(data);
        } else if (data is List && data.isNotEmpty) {
          // Agar list mein aaya ho (kabhi kabhi aisa hota hai)
          _handleDriverLocationResponse(data[0]);
        }
      },
    );

    // ← YEH PURA SAFE LISTENER HAI (Null-Safe + Type-Safe)
    socket.clearListeners(); // Optional: Avoid duplicate listeners
    socket.on("delivery:status_update", (data) {
      log("Received delivery:status_update → $data");
      // ← SABSE BADA FIX: Null & Type Check
      if (data == null) {
        log("Warning: Received null data from delivery:status_update");
        return;
      }
      if (data is! Map<String, dynamic>) {
        log("Warning: Invalid data format: $data");
        return;
      }
      final status = data['status']?.toString().toLowerCase();
      final success = data['success'] == true;
      if (status == null) {
        log("Warning: Status field missing in response");
        return;
      }
      log("Delivery status changed to: $status");

      if (status == 'completed' && success) {
        // _navigateToGiveRatingScreen(
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompleteScreen(
              socket: widget.socket,
              freeWaitingTime: data['freeWaitingTime'],
              previousAmount: data['previousAmount'],
              extraWaitingMinutes: data['extraWaitingMinutes'],
              extraWaitingCharge: data['extraWaitingCharge'],
              deliveryId: widget.deliveryId,
              driverId: deliveryData2!.data!.deliveryBoy!.id ?? "",
              driverName: deliveryData2!.data!.deliveryBoy!.firstName ?? "",
              driverLastName: deliveryData2!.data!.deliveryBoy!.lastName ?? "",
              driverImage: deliveryData2!.data!.deliveryBoy!.image ?? "",

            ),
          ),
        );
      }

      else if (status == 'cancelled_by_driver') {
        _navigateToHomeScreen();
      }


    ////////////////////////////////////////////////////////////
      ///////////////////////Arrived Driver /////////////////////
      if (status == "arrived") {
        final waitingTime = data["waitingTime"]; // ← Ye minutes mein aata hai (2, 4, 7, 10 etc)
        final arrivedAt = data["arrivedAt"];
        int freeMinutes = 5; // fallback
        if (waitingTime != null) {
          freeMinutes = int.tryParse(waitingTime.toString()) ?? 5;
        }
        int elapsedSeconds = 0;

        if (arrivedAt != null) {
          final serverTimestamp = arrivedAt is num
              ? arrivedAt.toInt()
              : int.tryParse(arrivedAt.toString()) ?? 0;
          if (serverTimestamp > 0) {
            elapsedSeconds = ((DateTime.now().millisecondsSinceEpoch - serverTimestamp) / 1000).floor();
          }
        }
        // Step 3: Timer ko perfect sync kar do
        _startOrSyncWaitingTimer(
          fromSeconds: elapsedSeconds,
          freeMinutes: freeMinutes,
        );
        log("Perfect Sync → Free: $freeMinutes min | Elapsed: $elapsedSeconds sec");
      }else if(status == "ongoing"){
        _isArrived=false;
      }
    });
    // Optional: Error listener
    socket.on("delivery:status_error", (error) {
      log("Delivery status error: $error");
      // Show toast or retry
    });
  }


  void _startOrSyncWaitingTimer({required int fromSeconds, required int freeMinutes}) {
    _maxFreeWaitingSeconds = freeMinutes * 60;

    setState(() {
      _isArrived = true;
      _waitingSeconds = fromSeconds;
      _updateWaitingTimeText();
    });

    _waitingTimer?.cancel();
    _waitingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _waitingSeconds++;
        _updateWaitingTimeText();
      });
    });
  }
// Socket se jo response aaya usko yahan use karo
  void _handleDriverLocationResponse(Map<String, dynamic> response) {
    if (response["success"] == true) {
      double lat = double.parse(response["lat"].toString());
      double lon = double.parse(response["lon"].toString());

      _driverLatLng = LatLng(lat, lon);
      _addMarkers();
      print("Driver Location Updated: $_driverLatLng");

      setState(() {});
    } else {
      print("Driver location failed or not available");
      _driverLatLng = null;
    }
  }
  void _navigateToGiveRatingScreen() {

  }
  void _navigateToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen(forceSocketRefresh: true)),
          (route) => false,
    );
  }
  void _setupEventListeners() {
    socket.on("delivery:status_updated", (data) {
      log("Status confirmed: $data");
    });
    socket.onConnect((_) => setState(() => isSocketConnected = true));
    socket.onDisconnect((_) => setState(() => isSocketConnected = false));
  }
  // MARK: - Fetch Route for Multiple Drops
  // Future<void> _fetchRoute() async {
  //   if (_currentLatLng == null || widget.pickup.isEmpty) return;
  //
  //   const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
  //   double totalDistKm = 0.0;
  //   int totalTimeMin = 0;
  //   List<LatLng> allPoints = [];
  //
  //   // 1. Driver → Pickup
  //   final pickupLat = widget.pickup['lat'] as double;
  //   final pickupLng = widget.pickup['long'] as double;
  //   final url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
  //     'origin': '${_currentLatLng!.latitude},${_currentLatLng!.longitude}',
  //     'destination': '$pickupLat,$pickupLng',
  //     'key': apiKey,
  //   });
  //
  //   try {
  //     final res = await http.get(url1);
  //     if (res.statusCode == 200) {
  //       final data = json.decode(res.body);
  //       if (data['status'] == 'OK') {
  //         final poly = data['routes'][0]['overview_polyline']['points'];
  //         final points = _decodePolyline(poly);
  //         allPoints.addAll(points);
  //         final leg = data['routes'][0]['legs'][0];
  //         toPickupDistance = leg['distance']['text'];
  //         toPickupDuration = leg['duration']['text'];
  //         driverToPickupETA = leg['duration']['text'];
  //         totalDistKm += (leg['distance']['value'] as num) / 1000;
  //         totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
  //       }
  //     }
  //   } catch (e) {
  //     log("Route1 error: $e");
  //   }
  //
  //   // 2. Pickup → Drop1 → Drop2 → Drop3
  //   dropDistances = List.filled(widget.dropoff.length, '');
  //   dropDurations = List.filled(widget.dropoff.length, '');
  //
  //   for (int i = 0; i < widget.dropoff.length; i++) {
  //     final origin = i == 0 ? '$pickupLat,$pickupLng' : '${widget.dropoff[i - 1]['lat']},${widget.dropoff[i - 1]['long']}';
  //     final dest = '${widget.dropoff[i]['lat']},${widget.dropoff[i]['long']}';
  //
  //     final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
  //       'origin': origin,
  //       'destination': dest,
  //       'key': apiKey,
  //     });
  //
  //     try {
  //       final res = await http.get(url);
  //       if (res.statusCode == 200) {
  //         final data = json.decode(res.body);
  //         if (data['status'] == 'OK') {
  //           final poly = data['routes'][0]['overview_polyline']['points'];
  //           final points = _decodePolyline(poly);
  //           allPoints.addAll(points);
  //           final leg = data['routes'][0]['legs'][0];
  //           dropDistances[i] = leg['distance']['text'];
  //           dropDurations[i] = leg['duration']['text'];
  //           totalDistKm += (leg['distance']['value'] as num) / 1000;
  //           totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
  //         }
  //       }
  //     } catch (e) {
  //       log("Drop $i route error: $e");
  //     }
  //   }
  //
  //   if (mounted) {
  //     setState(() {
  //       _polylines.clear();
  //       if (allPoints.isNotEmpty) {
  //         _polylines.add(Polyline(
  //           polylineId: const PolylineId('full_route'),
  //           points: allPoints,
  //           color: Colors.blue,
  //           width: 5,
  //         ));
  //       }
  //       totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
  //       totalDuration = '$totalTimeMin min';
  //       _routePoints = allPoints;
  //       _routeFetched = true;
  //     });
  //
  //     if (_mapController != null && _routePoints.isNotEmpty) {
  //       final bounds = _calculateBounds(_routePoints);
  //       _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  //     }
  //   }
  // }


  // Future<void> _fetchRoute() async {
  //   // अगर driver location नहीं है तो सिर्फ pickup → drops का route दिखाओ
  //   // user current location कभी use मत करो
  //
  //   const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
  //   double totalDistKm = 0.0;
  //   int totalTimeMin = 0;
  //   List<LatLng> allPoints = [];
  //
  //   final pickupLat = widget.pickup['lat'] as double;
  //   final pickupLng = widget.pickup['long'] as double;
  //
  //   // ✅ Driver location है तो driver → pickup की line + ETA दिखाओ
  //   if (_driverLatLng != null) {
  //     final url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
  //       'origin': '${_driverLatLng!.latitude},${_driverLatLng!.longitude}',
  //       'destination': '$pickupLat,$pickupLng',
  //       'key': apiKey,
  //     });
  //
  //     try {
  //       final res = await http.get(url1);
  //       if (res.statusCode == 200) {
  //         final data = json.decode(res.body);
  //         if (data['status'] == 'OK') {
  //           final poly = data['routes'][0]['overview_polyline']['points'];
  //           final points = _decodePolyline(poly);
  //           allPoints.addAll(points);
  //           final leg = data['routes'][0]['legs'][0];
  //           toPickupDistance = leg['distance']['text'];
  //           toPickupDuration = leg['duration']['text'];
  //           driverToPickupETA = leg['duration']['text'];
  //           totalDistKm += (leg['distance']['value'] as num) / 1000;
  //           totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
  //         }
  //       }
  //     } catch (e) {
  //       log("Driver to Pickup route error: $e");
  //     }
  //   } else {
  //     // Driver location नहीं → ETA "On the way" दिखाओ
  //     driverToPickupETA = "On the way";
  //   }
  //
  //   // बाकी का code वैसा ही रहे (pickup → drops)
  //   // ... existing drop loop code ...
  //
  // }


  Future<void> _fetchRoute() async {
    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> allPoints = [];

    final pickupLat = widget.pickup['lat'] as double;
    final pickupLng = widget.pickup['long'] as double;

    // 1. Driver → Pickup (only if driver location available)
    if (_driverLatLng != null) {
      final url1 = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': '${_driverLatLng!.latitude},${_driverLatLng!.longitude}',
        'destination': '$pickupLat,$pickupLng',
        'key': apiKey,
      });

      try {
        final res = await http.get(url1);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['status'] == 'OK') {
            final poly = data['routes'][0]['overview_polyline']['points'];
            final points = _decodePolyline(poly);
            allPoints.addAll(points);

            final leg = data['routes'][0]['legs'][0];
            toPickupDistance = leg['distance']['text'];
            toPickupDuration = leg['duration']['text'];
            driverToPickupETA = leg['duration']['text'];

            totalDistKm += (leg['distance']['value'] as num) / 1000;
            totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
          }
        }
      } catch (e) {
        log("Driver to Pickup route error: $e");
      }
    } else {
      driverToPickupETA = "On the way";
    }

    // 2. Pickup → Drop1 → Drop2 → ...
    dropDistances = List.filled(widget.dropoff.length, '');
    dropDurations = List.filled(widget.dropoff.length, '');

    for (int i = 0; i < widget.dropoff.length; i++) {
      final origin = i == 0
          ? '$pickupLat,$pickupLng'
          : '${widget.dropoff[i - 1]['lat']},${widget.dropoff[i - 1]['long']}';
      final dest = '${widget.dropoff[i]['lat']},${widget.dropoff[i]['long']}';

      final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': origin,
        'destination': dest,
        'key': apiKey,
      });

      try {
        final res = await http.get(url);
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['status'] == 'OK') {
            final poly = data['routes'][0]['overview_polyline']['points'];
            final points = _decodePolyline(poly);
            allPoints.addAll(points);

            final leg = data['routes'][0]['legs'][0];
            dropDistances[i] = leg['distance']['text'];
            dropDurations[i] = leg['duration']['text'];

            totalDistKm += (leg['distance']['value'] as num) / 1000;
            totalTimeMin += (leg['duration']['value'] as int) ~/ 60;
          }
        }
      } catch (e) {
        log("Drop $i route error: $e");
      }
    }

    // Update polyline and UI
    if (mounted) {
      setState(() {
        _polylines.clear();
        if (allPoints.isNotEmpty) {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('full_route'),
              points: allPoints,
              color: Colors.blue,
              width: 5,
            ),
          );
        }
        totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
        totalDuration = '$totalTimeMin min';
        _routePoints = allPoints;
      });

      // Camera fit on full route
      if (_mapController != null && _routePoints.isNotEmpty) {
        final bounds = _calculateBounds(_routePoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
      }
    }
  }

  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;

    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }
  Future<void> _createNumberIcons() async {
    _number1Icon = await _createNumberIcon("1", Colors.red);
    _number2Icon = await _createNumberIcon("2", Colors.orange);

  }
  Future<BitmapDescriptor> _createNumberIcon(String number, Color color) async {
    final size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, Paint()..color = color);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 8, Paint()..color = Colors.white);

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number,
      style: const TextStyle(color: Colors.black, fontSize: 40, fontWeight: FontWeight.bold),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2));

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  void _addMarkers() {
    final markers = <Marker>{};

    // Current Location
    if (_driverLatLng != null) {
      markers.add(Marker(
        markerId: const MarkerId('current'),
        position: _driverLatLng!,
        infoWindow: const InfoWindow(title: 'driver Location'),
        icon:
        driverIcon,
        // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }

    // Pickup
    final pickupLat = widget.pickup['lat'] as double;
    final pickupLng = widget.pickup['long'] as double;
    markers.add(Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(pickupLat, pickupLng),
      infoWindow: InfoWindow(title: widget.pickup['name'] ?? 'Pickup'),
      icon:
      BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    // Dropoffs
    for (int i = 0; i < widget.dropoff.length; i++) {
      final drop = widget.dropoff[i];
      final lat = drop['lat'] as double;
      final lng = drop['long'] as double;
      final name = drop['name'] ?? 'Drop ${i + 1}';

      BitmapDescriptor icon;
      if (i == 0)  icon = _number1Icon;
        // icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      else if (i == 1)  icon = _number2Icon;
        // icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
      else icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
            // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);

      markers.add(Marker(
        markerId: MarkerId('drop_$i'),
        position: LatLng(lat, lng),
        infoWindow: InfoWindow(title: 'Drop ${i + 1}', snippet: name),
        icon: icon,
      ));
    }

    setState(() => _markers = markers);
  }







  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;

    setState(() => _currentLatLng = LatLng(position.latitude, position.longitude));

    if (_mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentLatLng!, zoom: 15),
      ));
    }

    _addMarkers();
    _fetchRoute();
  }
  @override
  Widget build(BuildContext context) {
    final driver = widget.driver;
    final vehicleType = widget.vehicleType ?? {};
    final vehicleDetail = widget.vehicleDetail ?? {};
    final driverImageUrl = deliveryData2?.data?.deliveryBoy?.image?.toString().isNotEmpty == true
        ? deliveryData2!.data!.deliveryBoy!.image!
        : "https://via.placeholder.com/150"; // fallback image'

    final driverName = "${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}".trim();
    final driverPhone = deliveryData2?.data?.deliveryBoy?.image?.toString().isNotEmpty == true?
    deliveryData2!.data!.deliveryBoy!.phone:"";
        // driver['phone']?.toString() ?? 'N/A';
    final averageRating = driver['averageRating']?.toString() ?? '0';
    final pickupAddress = widget.pickup['name']?.toString() ?? 'Unknown Pickup';
    final otp = widget.otp?.toString() ?? 'N/A';
    final amount = widget.amount?.toString() ?? '0';
    final vehicleTypeName = vehicleType['name']?.toString() ?? 'N/A';
    final vehicleTypeNumber = vehicleDetail['numberPlate']?.toString() ?? 'N/A';
    final vehicalImage = (vehicleType['image']?.toString().isNotEmpty == true)
        ? vehicleType['image']
        : "https://via.placeholder.com/150";

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => HomeScreen(forceSocketRefresh: true)));
        }
      },
      child: Scaffold(
        body: _currentLatLng == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
          children: [
            GoogleMap(
              padding: EdgeInsets.only(top: 40.h, right: 16.w),
              initialCameraPosition: CameraPosition(target: _currentLatLng!, zoom: 15),
              onMapCreated: (controller) {
                _mapController = controller;
                _addMarkers();
                _fetchRoute();
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
            ),

            // Route Info
            if (toPickupDistance != null || dropDistances.isNotEmpty)
              Positioned(
                bottom: 70.h,
                left: 16.w,
                right: 16.w,
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (toPickupDistance != null)
                        Text('To Pickup: $toPickupDistance | $toPickupDuration', style: GoogleFonts.inter(fontSize: 14.sp)),
                      ...dropDistances.asMap().entries.map((e) => e.value.isNotEmpty
                          ? Text('Drop ${e.key + 1}: ${e.value} | ${dropDurations[e.key]}', style: GoogleFonts.inter(fontSize: 13.sp))
                          : const SizedBox()),
                      Text('Total: $totalDistance | $totalDuration', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),

            // Bottom Sheet
            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    children: [
                      Center(child: Container(width: 40.w, height: 5.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                            color: Colors.grey[300],
                          ),

                        )),
                      SizedBox(height: 10.h),

                      // ETA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Your driver is arriving", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.r)),
                            child: Text(driverToPickupETA ?? "Calculating...", style: GoogleFonts.inter(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      const Divider(),

                      // Driver Info
                      Row(
                        children: [

                          CircleAvatar(
                            radius: 30.r,
                            backgroundColor: Colors.grey.shade200,
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: driverImageUrl,
                                fit: BoxFit.cover,
                                width: 60.r,
                                height: 60.r,
                                placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                                errorWidget: (context, url, error) => Icon(Icons.person, size: 30.r, color: Colors.grey),
                              ),
                            ),
                          ),
                          // CircleAvatar(radius: 25, backgroundImage: NetworkImage(vehicalImage)),
                          SizedBox(width: 12.w),

                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(driverName, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                              Text('${vehicleTypeName}:- ${vehicleTypeNumber}'  , style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
                              Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), Text(averageRating, style: TextStyle(fontSize: 13))]),
                            ],
                          ),


                          const Spacer(),

                          actionButton("assets/SvgImage/calld.svg",driverPhone!)


                        ],
                      ),


                      SizedBox(height: 15.h),
                      const Divider(),

                      // Pickup
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.my_location, color: Colors.green),
                          SizedBox(width: 10.w),
                          Expanded(child: Text(pickupAddress, style: GoogleFonts.inter(fontSize: 13.sp))),
                        ],
                      ),
                      SizedBox(height: 8.h),

                      // Dropoffs
                      ...widget.dropoff.asMap().entries.map((e) {
                        final i = e.key;
                        final drop = e.value;
                        final name = drop['name'] ?? 'Drop ${i + 1}';
                        return Padding(
                          padding: EdgeInsets.only(left: 4.w, top: 8.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("${i + 1}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              SizedBox(width: 10.w),
                              Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 13.sp))),
                            ],
                          ),
                        );
                      }).toList(),

                      if (otp != 'N/A') ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.blue)),
                          child: Row(
                            children: [
                              const Icon(Icons.lock, size: 16, color: Colors.blue),
                              SizedBox(width: 8.w),
                              Text('OTP: $otp', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.blue[800])),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 20.h),

                      // Navigation Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: ElevatedButton.icon(
                          onPressed: _openCustomerLiveTracking,
                          icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 28),
                          label: Text("Start Navigation on Google Maps", style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                            elevation: 8,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                      ),

SizedBox(height: 20.h,),

                      if (!_isArrived)
                      // अभी तक arrived नहीं हुआ → Orange बटन
                     SizedBox()
                      else
                      // Arrived हो चुका है → Timer दिखेगा + Color Change Logic
                        Container(
                          height: 56.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: _waitingSeconds >= _maxFreeWaitingSeconds
                                ? Colors.red.shade600
                                : Colors.blue.shade600,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: (_waitingSeconds >= _maxFreeWaitingSeconds ? Colors.red : Colors.blue).withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _waitingSeconds >= 300 ? Icons.warning_amber_rounded : Icons.access_time_filled,
                                color: Colors.white,
                                size: 28.sp,
                              ),
                              SizedBox(width: 12.w),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Waiting Time",
                                    style: TextStyle(color: Colors.white70, fontSize: 13.sp),
                                  ),
                                  Text(
                                    _waitingTimeText,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
          Text(_waitingSeconds >= _maxFreeWaitingSeconds ?"Waiting charges are applied now":""),
                      // SizedBox(height: 15.h),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Total Amount", style: TextStyle(fontSize: 14)),
                          Text("₹ $amount  ", style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                        ],
                      ),
                      // SizedBox(height: 15.h),
                      const Divider(),

                      // Chat
                      // SizedBox(height: 20.h),
                      Text("Chat with Driver:", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w400)),
                      // SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatingPage(
                                name: deliveryData2?.data?.deliveryBoy?.firstName ?? "",
                                socket: widget.socket,
                                senderId: deliveryData2?.data?.customer ?? "",
                                receiverId: deliveryData2?.data?.deliveryBoy?.id ?? "",
                                deliveryId: deliveryData2?.data?.id ?? "",
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.only(top: 15.h, bottom: 20.h),
                          decoration: BoxDecoration(color: const Color(0xFFEEEDEF), borderRadius: BorderRadius.circular(40.r)),
                          child: TextField(
                            enabled: false,
                            controller: _controller,
                            decoration: InputDecoration(
                              hintText: "Send a message to your driver...",
                              hintStyle: GoogleFonts.inter(fontSize: 12.sp),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                            ),
                          ),
                        ),
                      ),

                      // Bottom Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _showCancelBottomSheet,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                              child: Text("Cancel Ride", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r))),
                              child: Text("Help", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40.h,),
                    ],
                  ),
                );
              },
            ),


          ],
        ),
      ),
    );
  }
  Widget actionButton(String icon,String phone ) {
    return Column(
      children: [
        GestureDetector(
          onTap: (){
            _makePhoneCall(phone);
          },
          child: Container(
            width: 45.w,
            height: 45.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFEEEDEF),
            ),
            child: Center(
              child: SvgPicture.asset(icon, width: 18.w, height: 18.h),
            ),
          ),
        ),
        SizedBox(height: 6.h),
        // Text(
        //   label,
        //   style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black),
        // ),
      ],
    );
  }
  Future<void> _openCustomerLiveTracking() async {
    if (_currentLatLng == null || widget.pickup.isEmpty || widget.dropoff.isEmpty) {
      Fluttertoast.showToast(msg: "Location loading...");
      return;
    }

    final origin = '${_currentLatLng!.latitude},${_currentLatLng!.longitude}';
    final pickup = '${widget.pickup['lat']},${widget.pickup['long']}';
    final waypoints = widget.dropoff.map((d) => '${d['lat']},${d['long']}').join('|');
    final destination = '${widget.dropoff.last['lat']},${widget.dropoff.last['long']}';

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=$origin'
          '&destination=$destination'
          '&waypoints=$pickup|$waypoints'
          '&travelmode=driving'
          '&dir_action=navigate',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Google Maps not installed");
    }
  }
  void _showCancelBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CancelBottomSheetContent(deliveryId: widget.txId.toString(), onCancel: () => Navigator.pop(context)),
    );
  }
  @override
  void dispose() {
    socket.off('receive_message');
    socket.off('connect');
    socket.off('disconnect');
    _controller.dispose();
    super.dispose();
  }
}

// CancelBottomSheetContent remains same
class CancelBottomSheetContent extends StatefulWidget {
  final String deliveryId;
  final VoidCallback onCancel;
  const CancelBottomSheetContent({super.key, required this.deliveryId, required this.onCancel});

  @override
  State<CancelBottomSheetContent> createState() => _CancelBottomSheetContentState();
}
class _CancelBottomSheetContentState extends State<CancelBottomSheetContent> {
  final List<String> reasons = ['Driver not arrived on time', 'Wrong pickup location', 'Change of plans', 'Better option available', 'Other'];
  int selectedIndex = 0;
  final TextEditingController _otherController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration:  BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40.w, height: 5.h, decoration: BoxDecoration(
                  color: Colors.grey[300], borderRadius: BorderRadius.circular(10.r)
              ),)),
              SizedBox(height: 20.h),
              Text('Why do you want to cancel?', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 20.h),
              ...reasons.asMap().entries.map((e) => RadioListTile<int>(
                title: Text(e.value, style: GoogleFonts.inter(fontSize: 14.sp)),
                value: e.key,
                groupValue: selectedIndex,
                onChanged: _isLoading ? null : (v) => setState(() => selectedIndex = v ?? 0),
              )),
              if (selectedIndex == reasons.length - 1) ...[
                SizedBox(height: 10.h),
                TextField(controller: _otherController, enabled: !_isLoading, maxLines: 3, decoration: InputDecoration(hintText: 'Enter reason...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)))),
                SizedBox(height: 10.h),
              ],
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: _isLoading ? null : widget.onCancel, child: Text('Cancel'))),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () async {
                        setState(() => _isLoading = true);
                        final reason = selectedIndex == reasons.length - 1 ? _otherController.text.trim() : reasons[selectedIndex];
                        if (reason.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please enter reason');
                          setState(() => _isLoading = false);
                          return;
                        }
                        await cancelOrderApiStatic(widget.deliveryId, reason);
                        setState(() => _isLoading = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Submit'),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.h,)
            ],
          ),
        ),
      ),
    );
  }

  Future<void> cancelOrderApiStatic(String txId, String reason) async {
    try {
      final body = CancelOrderModel(txId: txId, cancellationReason: reason);
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.deliveryCancelledByUser(body);
      Fluttertoast.showToast(msg: response.message, backgroundColor: response.code == 0 ? Colors.green : Colors.red, textColor: Colors.white);
      if (response.code == 0 && mounted) {
        // Navigator.popUntil(context, (route) => route.isFirst);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => HomeScreen(forceSocketRefresh: true),
          ),
              (route) => false,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }
}
