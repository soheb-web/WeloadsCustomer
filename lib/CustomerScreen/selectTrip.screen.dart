
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'dart:ui' as ui;
import 'package:delivery_mvp_app/CustomerScreen/pickup.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import '../data/Model/GetNearByDriverResponseModel.dart';
import '../data/Model/NearByDriverModel.dart';
import '../data/Model/bookInstantdeliveryBodyModel.dart';
import '../data/Model/getDistanceResModel.dart';

class SelectTripScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final double pickupLat;
  final double pickupLon;
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
  final String productType; // 👈 NEW

  const SelectTripScreen(
      this.socket,
      this.pickupLat,
      this.pickupLon,
      this.dropLats,
      this.dropLons,
      this.dropNames,
      this.productType,
      {
        super.key,
      });

  @override
  ConsumerState<SelectTripScreen> createState() => _SelectTripScreenState();
}
class _SelectTripScreenState extends ConsumerState<SelectTripScreen> {
  final box = Hive.box("folder");
  GoogleMapController? _mapController;
  LatLng? _currentLatlng;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  String? userId;
  late double pickupLat, pickupLon;
  late List<double> dropLats, dropLons;
  late List<String> dropNames;
  String? toPickupDistance, toPickupDuration;
  List<String> dropDistances = [], dropDurations = [];
  String? totalDistance, totalDuration;
  int selectIndex = 0;
  bool isBooking = false;
  bool isLoadingDrivers = false;
  IO.Socket? socket;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  late GetNearByDriverResponse nearbyDrivers;
  late BitmapDescriptor driverCarIcon;
  late BitmapDescriptor driverBikeIcon;
  late BitmapDescriptor driverAutoIcon;
  late BitmapDescriptor driverTruckIcon;
  late BitmapDescriptor driverCycleIcon;
  bool _iconsLoaded = false;
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  @override
  void initState() {
    super.initState();
    socket = widget.socket;
    pickupLat = widget.pickupLat;
    pickupLon = widget.pickupLon;
    dropLats = widget.dropLats;
    dropLons = widget.dropLons;
    dropNames = widget.dropNames;
    userId = box.get("id")?.toString();
    log('User ID: $userId');
    _getCurrentLocation();
    startLocationStream();
    _setupDriverAssignedListener(); // ← यह add करो
    _setupEventListeners();
    _loadCustomIcons();
    _createNumberIcons();
  }

  void _setupDriverAssignedListener() {
    // Duplicate listener न लगे, इसलिए पहले off करो
    socket?.off('user:driver_assigned');
    socket?.on('user:driver_assigned', (payload) {
      print("🚀 Driver assigned received in SelectTripScreen: $payload");

      if (!mounted) return;

      _navigateToPickupScreen(payload);
    });
  }


  void _navigateToPickupScreen(dynamic payload) async {
    try {
      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) return;

      final driver = Map<String, dynamic>.from(payload['driver'] ?? {});
      final otp = payload['otp']?.toString() ?? 'N/A';
      final pickup = Map<String, dynamic>.from(payload['pickup'] ?? {});
      final dropoffList = (payload['dropoff'] as List?)
          ?.map((e) => Map<String, dynamic>.from(e))
          .toList() ?? [];
      final amount = payload['amount'] ?? 0;
      final vehicleType = Map<String, dynamic>.from(payload['vehicleType'] ?? {});
      final status = payload['status']?.toString() ?? 'assigned';

      // txId Hive से लो (booking के बाद save किया था)
      final txId = box.get("current_booking_txId") ?? "";

      Fluttertoast.showToast(msg: "Driver Assigned!");

      Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
          builder: (context) => PickupScreen(
            socket: socket!,
            deliveryId: deliveryId,
            driver: driver,
            otp: otp,
            pickup: pickup,
            dropoff: dropoffList,
            amount: amount,
            vehicleType: vehicleType,
            vehicleDetail: payload['vehicleDetails'],
            status: status,
            txId: txId,
          ),
        ),
      );
    } catch (e, s) {
      log("Navigation error from SelectTripScreen: $e\n$s");
    }
  }
  Future<void> _createNumberIcons() async {
    _number1Icon = await _createNumberIcon("1", Colors.red);
    _number2Icon = await _createNumberIcon("2", Colors.orange);
  }
  Future<BitmapDescriptor> _createNumberIcon(String number, Color color) async {
    final size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = color,
    );
    canvas.drawCircle(
      Offset(size / 2, size / 2),
      size / 2 - 8,
      Paint()..color = Colors.white,
    );

    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: number,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 40,
        fontWeight: FontWeight.bold,
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  Future<void> _loadCustomIcons() async {
    try {
      driverCarIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/car.png',
      );
      driverBikeIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/b.png',
      );
      driverAutoIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/t.png',
      );
      driverTruckIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/truck.png',
      );
      driverCycleIcon = await BitmapDescriptor.fromAssetImage(
        const ImageConfiguration(size: Size(72, 72)),
        'assets/icons/cycle.png',
      );

      _iconsLoaded = true;
      if (mounted) safeSetState(() {});
      log("Custom driver icons loaded");
    } catch (e) {
      log("Icon load error: $e");
    }
  }
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Fluttertoast.showToast(msg: "Enable location service");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      Fluttertoast.showToast(msg: "Location denied permanently");
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    safeSetState(() {
      _currentPosition = position;
      _currentLatlng = LatLng(position.latitude, position.longitude);
    });

    if (mounted && _mapController != null) {
      _addMarkers();
      _fetchMultiStopRoute();
      _fitAllMarkersAndDrivers();
    }
  }
  void safeSetState(VoidCallback fn) {
    if (mounted) setState(fn);
  }
  void startLocationStream() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((position) {
          updateUserLocation(position.latitude, position.longitude);
          _currentPosition = position;
        });
  }
  void updateUserLocation(double lat, double lon) {
    if (socket?.connected == true && userId != null) {
      socket!.emitWithAck('user:location_update', {
        'userId': userId,
        'lat': lat,
        'lon': lon,
      });
    }
  }
  void _setupEventListeners() {
    socket?.on('receive_message', (data) => log('Message: $data'));
  }
  @override
  void dispose() {
    socket?.off('user:driver_assigned'); // important: memory leak avoid
    _locationSubscription?.cancel();
    _mapController?.dispose();
    socket?.clearListeners();
    socket?.disconnect();
    super.dispose();
  }
  void _addMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: LatLng(pickupLat, pickupLon),
        infoWindow: const InfoWindow(title: 'Pickup'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );
    for (int i = 0; i < dropLats.length; i++) {
      final lat = dropLats[i];
      final lon = dropLons[i];
      final name = dropNames[i];
      BitmapDescriptor icon;
      if (i == 0)
        icon = _number1Icon;
      else if (i == 1)
        icon = _number2Icon;
      else
        icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);

      _markers.add(
        Marker(
          markerId: MarkerId('drop_$i'),
          position: LatLng(lat, lon),
          infoWindow: InfoWindow(title: 'Drop ${i + 1}', snippet: name),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
        ),
      );
    }
    safeSetState(() {});
  }
  void _addNearbyDriverMarkers() {
    if (nearbyDrivers.data == null ||
        nearbyDrivers.data!.isEmpty ||
        !_iconsLoaded)
      return;
    _markers.removeWhere((m) => m.markerId.value.startsWith('driver_'));
    for (int i = 0; i < nearbyDrivers.data!.length; i++) {
      final driver = nearbyDrivers.data![i];
      final coords = driver.currentLocation?.coordinates;
      if (coords == null || coords.length < 2) continue;
      double baseLat = coords[1];
      double baseLon = coords[0];
      final String markerId = 'driver_${driver.id ?? i}_${i}';
      final double angle = (i * 137.508);
      final double radius = 0.00008;
      final double offsetLat = radius * cos(angle * pi / 180);
      final double offsetLon =
          radius * cos(angle * pi / 180) / cos(baseLat * pi / 180);
      final double finalLat = baseLat + offsetLat;
      final double finalLon = baseLon + offsetLon;
      final String model = (driver.vehicleDetails?.isNotEmpty == true)
          ? (driver.vehicleDetails![0].vehicleName ?? "").toLowerCase()
          : "bike";
      BitmapDescriptor icon = model.contains("truck")
          ? driverTruckIcon
          : model.contains("car")
          ? driverCarIcon
          : model.contains("bike")
          ? driverBikeIcon
          : model.contains("auto")
          ? driverAutoIcon
          : driverCycleIcon;
      _markers.add(
        Marker(
          markerId: MarkerId(markerId),
          position: LatLng(finalLat, finalLon),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          zIndex: i.toDouble(),
          infoWindow: InfoWindow(
            title: "${driver.firstName} ${driver.lastName}",
            snippet:
            "${driver.vehicleDetails?[0].model} • ${(driver.distance! / 1000).toStringAsFixed(1)} km",
          ),
        ),
      );
    }
    safeSetState(() {});
    _fitAllMarkersAndDrivers();
  }
  void _fitAllMarkersAndDrivers() {
    if (_markers.isEmpty || _mapController == null) return;
    final positions = _markers.map((m) => m.position).toList();
    if (positions.length == 1) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(positions[0], 14),
      );
      return;
    }
    final bounds = _calculateBounds(positions);
    _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }
  Future<void> _fetchMultiStopRoute() async {
    const apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> allPoints = [];

    dropDistances = List.filled(dropLats.length, '');
    dropDurations = List.filled(dropLats.length, '');

    for (int i = 0; i < dropLats.length; i++) {
      final origin = i == 0
          ? '$pickupLat,$pickupLon'
          : '${dropLats[i - 1]},${dropLons[i - 1]}';
      final dest = '${dropLats[i]},${dropLons[i]}';

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
        log("Drop route $i error: $e");
      }
    }

    safeSetState(() {
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

    if (_mapController != null && _routePoints.isNotEmpty) {
      _fitAllMarkersAndDrivers();
    }
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
  LatLngBounds _calculateBounds(List<LatLng> points) {
    double minLat = points[0].latitude, maxLat = points[0].latitude;
    double minLng = points[0].longitude, maxLng = points[0].longitude;
    for (var p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }
  @override
  Widget build(BuildContext context) {
    final distanceProviderState = ref.watch(getDistanceProvider);
    return Scaffold(
      backgroundColor: Colors.white,
      body:

      distanceProviderState.when(
        data: (response) {
          if (response.data == null || response.data!.isEmpty) {
            return Center(child: Text("No vehicles available"));
          }

          final vehicle = response.data![selectIndex]; // Selected vehicle

          return _currentLatlng == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              GoogleMap(
                padding: EdgeInsets.only(top: 40.h, right: 16.w),
                initialCameraPosition: CameraPosition(
                  target: _currentLatlng!,
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;
                  _addMarkers();
                  _fetchMultiStopRoute();
                },
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                markers: _markers,
                polylines: _polylines,
              ),

              Positioned(
                left: 10.w,
                top: 40.h,
                child: FloatingActionButton(
                  mini: true,
                  backgroundColor: Colors.white,
                  shape: const CircleBorder(),
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(
                    Icons.arrow_back_ios,
                    color: Color(0xFF1D3557),
                  ),
                ),
              ),

              // if (totalDistance != null)
              //   Positioned(
              //     bottom: 70.h,
              //     left: 16.w,
              //     right: 16.w,
              //     child: Container(
              //       padding: EdgeInsets.all(12.w),
              //       decoration: BoxDecoration(
              //         color: Colors.white,
              //         borderRadius: BorderRadius.circular(8.r),
              //         boxShadow: [
              //           BoxShadow(
              //             color: Colors.black12,
              //             blurRadius: 8,
              //           ),
              //         ],
              //       ),
              //       child: Column(
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           if (toPickupDistance != null)
              //             Text(
              //               'To Pickup: $toPickupDistance | $toPickupDuration',
              //               style: GoogleFonts.inter(fontSize: 14.sp),
              //             ),
              //           ...dropDistances.asMap().entries.map(
              //                 (e) => e.value.isNotEmpty
              //                 ? Text(
              //               'Drop ${e.key + 1}: ${e.value} | ${dropDurations[e.key]}',
              //               style: GoogleFonts.inter(
              //                 fontSize: 13.sp,
              //               ),
              //             )
              //                 : const SizedBox(),
              //           ),
              //           Text(
              //             'Total: $totalDistance | $totalDuration',
              //             style: GoogleFonts.inter(
              //               fontSize: 14.sp,
              //               fontWeight: FontWeight.bold,
              //             ),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ),

              if (totalDistance != null)
                Positioned(
                  bottom: 70.h,
                  left: 16.w,
                  right: 16.w,
                  child: Container(
                    // ... decoration same
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Remove this block completely:
                        // if (toPickupDistance != null)
                        //   Text('To Pickup: $toPickupDistance | $toPickupDuration', ...),

                        ...dropDistances.asMap().entries.map(
                              (e) => e.value.isNotEmpty
                              ? Text(
                            'Drop ${e.key + 1}: ${e.value} | ${dropDurations[e.key]}',
                            style: GoogleFonts.inter(fontSize: 13.sp),
                          )
                              : const SizedBox(),
                        ),
                        Text(
                          'Total: $totalDistance | $totalDuration',
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              DraggableScrollableSheet(
                initialChildSize: 0.50,
                minChildSize: 0.30,
                maxChildSize: 0.80,
                builder: (context, scrollController) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 16.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(30.r),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: ListView(
                      controller: scrollController,
                      padding: EdgeInsets.zero,
                      children: [
                        // ---- Top drag handle ----
                        Center(
                          child: Container(
                            margin: EdgeInsets.only(bottom: 10.h),
                            width: 60.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[300],
                            ),
                          ),
                        ),

                        // ---- LIST OF VEHICLES ----
                        ...List.generate(response.data!.length, (
                            dataIndex,
                            ) {
                          final isSelected = selectIndex == dataIndex;
                          return InkWell(
                            onTap: () async {
                              setState(() {
                                selectIndex = dataIndex;
                                isLoadingDrivers = true;
                                _markers.removeWhere(
                                      (m) => m.markerId.value.startsWith(
                                    'driver_',
                                  ),
                                );
                              });

                              try {
                                final selectedVehicle =
                                response.data![dataIndex];
                                final body = NearByDriverModel(
                                  lat: pickupLat,
                                  long: pickupLon,
                                  vehicleId: selectedVehicle
                                      .vehicleTypeId
                                      .toString(),
                                );

                                final drivers = await APIStateNetwork(
                                  callPrettyDio(),
                                ).getNearByDriverList(body);
                                setState(() {
                                  nearbyDrivers = drivers;
                                  isLoadingDrivers = false;
                                  if (drivers.data != null &&
                                      drivers.data!.isNotEmpty) {
                                    _addNearbyDriverMarkers();
                                  }
                                });
                              } catch (e) {
                                setState(
                                      () => isLoadingDrivers = false,
                                );
                              }
                            },
                            child: AnimatedContainer(
                              margin: EdgeInsets.only(bottom: 15.h),
                              duration: Duration(milliseconds: 250),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Color(0xFFE5F0F1)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(
                                  15.r,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.grey.shade300,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: isSelected
                                        ? Colors.black26
                                        : Colors.black12,
                                    blurRadius: isSelected ? 8 : 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 12.w,
                                  right: 12.w,
                                  top: isSelected ? 8 : 16.h,
                                  bottom: isSelected ? 10 : 16.h,
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    if (isSelected)
                                      Center(
                                        child: Image.network(
                                          response
                                              .data![dataIndex]
                                              .image
                                              .toString(),
                                          width: isSelected
                                              ? 100.w
                                              : 70.w,
                                          height: isSelected
                                              ? 60.h
                                              : 50.h,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        if (!isSelected)
                                          Image.network(
                                            response
                                                .data![dataIndex]
                                                .image
                                                .toString(),
                                            width: isSelected
                                                ? 100.w
                                                : 70.w,
                                            height: isSelected
                                                ? 70.h
                                                : 50.h,
                                            fit: BoxFit.contain,
                                          ),
                                        SizedBox(width: 8.w),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: [
                                            Text(
                                              response
                                                  .data![dataIndex]
                                                  .vehicleType ??
                                                  "",
                                              style:
                                              GoogleFonts.inter(
                                                fontSize:
                                                isSelected
                                                    ? 20.sp
                                                    : 16.sp,
                                                fontWeight:
                                                isSelected
                                                    ? FontWeight
                                                    .w600
                                                    : FontWeight
                                                    .w400,
                                              ),
                                            ),


                                            Text(
                                              _getEstimatedTime(
                                                vehicleType: response.data![dataIndex].vehicleType ?? "",
                                                distance: response.data![dataIndex].distance?.toDouble() ?? 7.0,
                                              ),
                                              style: GoogleFonts.inter(
                                                fontSize: isSelected ? 14.sp : 12.sp,
                                                color: Colors.grey[700],
                                              ),
                                            ),


                                            // Row(
                                            //   children: [
                                            //     Text(
                                            //       response
                                            //           .data![dataIndex]
                                            //           .name
                                            //           .toString(),
                                            //       style:
                                            //       GoogleFonts.inter(
                                            //         fontSize:
                                            //         isSelected
                                            //             ? 15.sp
                                            //             : 13.sp,
                                            //       ),
                                            //     ),
                                            //     SizedBox(width: 5.w),
                                            //     CircleAvatar(
                                            //       radius: 4.r,
                                            //       backgroundColor:
                                            //       Colors.grey,
                                            //     ),
                                            //     SizedBox(width: 5.w),
                                            //     Text(
                                            //       "${response.data![dataIndex].distance.toString()} away",
                                            //       style:
                                            //       GoogleFonts.inter(
                                            //         fontSize:
                                            //         isSelected
                                            //             ? 15.sp
                                            //             : 13.sp,
                                            //       ),
                                            //     ),
                                            //   ],
                                            // ),
                                          ],
                                        ),
                                        Spacer(),
                                        Text(
                                          "₹${response.data![dataIndex].price}",
                                          style: GoogleFonts.inter(
                                            fontSize: isSelected
                                                ? 18.sp
                                                : 15.sp,
                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        Container(
                          margin: EdgeInsets.only(top: 10.h),
                          width: double.infinity,
                          height: 50.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: Colors.grey,
                              width: 1.w,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/cash.png",
                                    height: 20.h,
                                    width: 20.w,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Cash",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/promo.png",
                                    height: 20.h,
                                    width: 20.w,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Promo Code",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Image.asset(
                                    "assets/note.png",
                                    height: 20.h,
                                    width: 20.w,
                                  ),
                                  SizedBox(width: 10.w),
                                  Text(
                                    "Add Note",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10.h),
                        _buildBookNowButton(
                          name: vehicle.name ?? "",
                          phon: vehicle.mobNo ?? "",
                          pickupAddress: vehicle.origName ?? "",
                          dropAddress: dropNames.join(" → "),
                          selectedVehicle: vehicle,
                        ),

                        // _buildBookNowButton(name, phon, pickupAddress, dropAddress),
                        SizedBox(height: 40.h),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
        error: (e, s) => Center(child: Text(e.toString())),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
  String _getEstimatedTime({required String vehicleType, required double distance}) {
    // distance is assumed in KM (your API returns 7 → 7 km)
    final double distanceKm = distance;

    double avgSpeed = 30.0; // default car

    if (vehicleType.toLowerCase().contains("bike")) {
      avgSpeed = 50.0;
    } else if (vehicleType.toLowerCase().contains("car")) {
      avgSpeed = 45.0;
    } else if (vehicleType.toLowerCase().contains("auto")) {
      avgSpeed = 40.0;
    } else if (vehicleType.toLowerCase().contains("truck")) {
      avgSpeed = 35.0;
    } else if (vehicleType.toLowerCase().contains("cycle")) {
      avgSpeed = 20.0;
    }

    final double timeInHours = distanceKm / avgSpeed;
    final int timeInMinutes = (timeInHours * 60).ceil();

    if (timeInMinutes < 5) return "~5 min";
    if (timeInMinutes > 60) return "${(timeInMinutes / 60).toStringAsFixed(1)} hr";

    return "~$timeInMinutes min";
  }
  Widget _buildBookNowButton({
    required String name,
    required String phon,
    required String pickupAddress,
    required String dropAddress,
    required VehicleOption selectedVehicle,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFF006970),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
        ),
      ),
      onPressed: isBooking
          ? null
          : () async {
        setState(() => isBooking = true);
        try {
          final body = BookInstantDeliveryBodyModel(
              vehicleTypeId: selectedVehicle.vehicleTypeId ?? "",
              origName: pickupAddress,
              origLat: pickupLat,
              origLon: pickupLon,
              coinAmount: 0,
              copanId: null,
              productType: widget.productType,
              dropoff:
              selectedVehicle.dropoff
                  ?.map(
                    (d) => BookDropoff(
                  name: d.name.toString(),
                  lat: d.lat ?? 0.0,
                  long: d.long ?? 0.0,
                ),
              )
                  .toList() ??
                  [],
              distance: (selectedVehicle.distance ?? 0).toDouble(),
              userPayAmount: double.parse(
                selectedVehicle.price ?? "0",
              ).toInt(),
              taxAmount: 18.0,
              mobNo: phon,
              name:name
          );
          final service = APIStateNetwork(callPrettyDio());
          final response = await service.bookInstantDelivery(body);
          if (response.code == 0) {
            final dataMap = response;
            final txId = dataMap.data.txId.toString();
            if (txId.isEmpty) {
              Fluttertoast.showToast(msg: "Booking failed: No txId");
              return;
            }
            box.put("current_booking_txId", txId);
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => WaitingForDriverScreen(

                  productType: widget.productType,
                  mobile :phon,
                  name:name,
                  userPayAmount:double.parse(
                    selectedVehicle.price ?? "0",
                  ).toInt(),
                  distance: (selectedVehicle.distance ?? 0).toDouble(),
                  id: selectedVehicle.vehicleTypeId ?? "",

                  socket: socket!,
                  pickupLat: pickupLat,
                  pickupLon: pickupLon,
                  dropLats: dropLats,
                  dropLons: dropLons,
                  dropNames: dropNames,
                  txId: txId,
                ),
              ),
            );
            Fluttertoast.showToast(msg: "Delivery booked!");
          } else {
            // response.data is List or null
            final errorMsg =
                response.message ?? "Invalid response from server";
            log(
              "Booking failed: $errorMsg | data type: ${response.data.runtimeType}",
            );
            Fluttertoast.showToast(msg: errorMsg);
          }
        } catch (e, s) {
          log("Booking error: $e\n$s");
          Fluttertoast.showToast(msg: "Booking error: ${e.toString()}");
        } finally {
          setState(() => isBooking = false);
        }
      },
      child: isBooking
          ? const CircularProgressIndicator(color: Colors.white)
          : Text(
        "Book Now",
        style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white),
      ),
    );
  }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class WaitingForDriverScreen extends StatefulWidget {
  String productType;
  String mobile;
  String name;
  int userPayAmount;
  double distance;
  String id;
  final IO.Socket socket;
  final double pickupLat;
  final double pickupLon;
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
  final String txId;
  WaitingForDriverScreen({
    super.key,
    required this.productType,
    required this.mobile,
    required this.name,
    required this.userPayAmount,
    required this.distance,
    required this.id,
    required this.socket,
    required this.pickupLat,
    required this.pickupLon,
    required this.dropLats,
    required this.dropLons,
    required this.dropNames,
    required this.txId,
  });

  @override
  State<WaitingForDriverScreen> createState() => _WaitingForDriverScreenState();
}
class _WaitingForDriverScreenState extends State<WaitingForDriverScreen>
    with TickerProviderStateMixin {
  final box = Hive.box("folder");
  late IO.Socket _socket;
  late Timer _dotTimer;
  Timer? _searchTimer;
  int _dotCount = 1;
  bool _isSearching = true;
  int _remainingSeconds = 300;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _routePoints = [];
  List<String> dropDistances = [];
  List<String> dropDurations = [];
  String? totalDistance, totalDuration;
  bool _routeFetched = false;
  bool _iconsLoaded = false;
  late double pickupLat, pickupLon;
  late List<double> dropLats, dropLons;
  late List<String> dropNames;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  Timer? _pulseUpdateTimer;
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  late BitmapDescriptor _dotIcon;



  @override
  void initState() {
    super.initState();
    _socket = widget.socket;
    pickupLat = widget.pickupLat;
    pickupLon = widget.pickupLon;
    dropLats = widget.dropLats;
    dropLons = widget.dropLons;
    dropNames = widget.dropNames;
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 40, end: 100).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
    // _setupEventListeners1();
    _socket.off('user:driver_assigned'); // duplicate avoid
    _socket.on('user:driver_assigned', _handleAssigned);
    _startSearching();
    _startPulseMarkerUpdater();
    _loadIconsAndInitMap();
  }


  // MARK: - Icon Loading
  Future<void> _loadIconsAndInitMap() async {
    await _createCustomIcons();
    setState(() => _iconsLoaded = true);
    _initMap();
  }
  Future<void> _createCustomIcons() async {
    _number1Icon = await _createNumberIcon("1", Colors.red);
    _number2Icon = await _createNumberIcon("2", Colors.orange);
    _dotIcon = await _createDotIcon();
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
  Future<BitmapDescriptor> _createDotIcon() async {
    final size = 40.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2, Paint()..color = Colors.blue);
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  void _startPulseMarkerUpdater() {
    _pulseUpdateTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted && _mapController != null && _iconsLoaded) {
        _updatePulsatingPickupMarker();
      }
    });
  }
  Future<void> _updatePulsatingPickupMarker() async {
    final icon = await _createPulsatingMarkerIcon();
    if (mounted) {
      setState(() {
        _markers.removeWhere((m) => m.markerId.value == 'pickup_pulse');
        _markers.add(Marker(
          markerId: const MarkerId('pickup_pulse'),
          position: LatLng(pickupLat, pickupLon),
          icon: icon,
          anchor: const Offset(0.5, 0.5),
          zIndex: 100,
        ));
      });
    }
  }
  Future<BitmapDescriptor> _createPulsatingMarkerIcon() async {
    final size = 180.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);
    final pulseRadius = _pulseAnimation.value / 2;

    canvas.drawCircle(center, pulseRadius, Paint()..color = Colors.blueAccent.withOpacity(0.3));
    canvas.drawCircle(center, pulseRadius, Paint()..color = Colors.blueAccent.withOpacity(0.6)..style = PaintingStyle.stroke..strokeWidth = 4);
    canvas.drawCircle(center, 24, Paint()..color = Colors.blueAccent);
    canvas.drawCircle(center, 24, Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4);

    final path = Path();
    path.moveTo(center.dx, center.dy - 18);
    path.lineTo(center.dx - 12, center.dy + 6);
    path.lineTo(center.dx + 12, center.dy + 6);
    path.close();
    canvas.drawPath(path, Paint()..color = Colors.white);

    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }
  // MARK: - Map Init
  void _initMap() {
    if (!_iconsLoaded) return;
    _addMarkers();
    _fetchMultiStopRoute();
  }
  void _addMarkers() {
    _markers.clear();
    _markers.add(Marker(
      markerId: const MarkerId('pickup_static'),
      position: LatLng(pickupLat, pickupLon),
      infoWindow: const InfoWindow(title: 'Pickup'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      zIndex: 99,
    ));

    for (int i = 0; i < dropLats.length; i++) {
      final lat = dropLats[i];
      final lon = dropLons[i];
      final name = dropNames[i];

      BitmapDescriptor icon;
      if (i == 0) icon = _number1Icon;
      else if (i == 1) icon = _number2Icon;
      else icon = _dotIcon;

      _markers.add(Marker(
        markerId: MarkerId('drop_$i'),
        position: LatLng(lat, lon),
        infoWindow: InfoWindow(title: 'Drop ${i + 1}', snippet: name),
        icon: icon,
        anchor: const Offset(0.5, 0.5),
      ));
    }
    _updatePulsatingPickupMarker();
  }


  // void _setupEventListeners1() {
  //   _socket.on('user:driver_assigned', _handleAssigned);
  // }


  Future<void> _handleAssigned(dynamic payload) async {
    if (!mounted) return;
    print("payload socket accept data $payload");
    try {
      if (payload is! Map<String, dynamic>) {
        log("Invalid payload: not a Map");
        return;
      }
      final deliveryId = payload['deliveryId'] as String?;
      if (deliveryId == null) {
        log("Missing deliveryId");
        return;
      }
      // Driver
      final driverData = payload['driver'];
      Map<String, dynamic> driver = {};
      if (driverData is Map<String, dynamic>) {
        driver = driverData;
      } else if (driverData is List && driverData.isNotEmpty) {
        driver = Map<String, dynamic>.from(driverData[0]);
      } else {
        log("No valid driver data");
        Fluttertoast.showToast(msg: "Driver info missing");
        return;
      }
      final driverName = '${driver['firstName'] ?? ''} ${driver['lastName'] ?? ''}'.trim();
      final otp = payload['otp']?.toString() ?? 'N/A';
      Fluttertoast.showToast(msg: "Driver Assigned: $driverName");
      // Pickup - Fix Type
      final pickupRaw = payload['pickup'];
      final Map<String, dynamic> pickup = (pickupRaw is Map)
          ? Map<String, dynamic>.from(pickupRaw)
          : {};
      // Dropoff: List of Maps
      final dropoffRaw = payload['dropoff'];
      final List<Map<String, dynamic>> dropoff = [];
      if (dropoffRaw is List) {
        for (var item in dropoffRaw) {
          if (item is Map) {
            dropoff.add(Map<String, dynamic>.from(item));
          }
        }
      }
      // Vehicle Type - Fix Type
      final vehicleTypeRaw = payload['vehicleType'];
      final vehicleDetailRaw = payload['vehicleDetails'];
      final Map<String, dynamic> vehicleType = (vehicleTypeRaw is Map)
          ? Map<String, dynamic>.from(vehicleTypeRaw)
          : {};
      // Other fields
      final amount = payload['amount'] ?? 0;
      final status = payload['status']?.toString() ?? 'pending';
      // Navigate - Now Safe
      if (mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(
            builder: (context) => PickupScreen(
              socket: widget.socket,
              deliveryId: deliveryId,
              driver: driver,
              otp: otp,
              pickup: pickup,           // Fixed
              dropoff: dropoff,         // Already List<Map<String, dynamic>>
              amount: amount,
              vehicleType: vehicleType, // Fixed
              vehicleDetail: vehicleDetailRaw, // Fixed
              status: status,
              txId: widget.txId,
            ),
          ),
        );
      }
    } catch (e, s) {
      log("Driver assign error: $e\n$s");
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _fetchMultiStopRoute() async {
    const String apiKey = 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g';
    double totalDistKm = 0.0;
    int totalTimeMin = 0;
    List<LatLng> allPoints = [];

    dropDistances = List.filled(dropLats.length, '');
    dropDurations = List.filled(dropLats.length, '');

    for (int i = 0; i < dropLats.length; i++) {
      final origin = i == 0 ? '$pickupLat,$pickupLon' : '${dropLats[i-1]},${dropLons[i-1]}';
      final dest = '${dropLats[i]},${dropLons[i]}';

      final url = Uri.https('maps.googleapis.com', '/maps/api/directions/json', {
        'origin': origin,
        'destination': dest,
        'key': apiKey,
      });

      try {
        final response = await http.get(url);
        if (response.statusCode == 200) {

          final data = json.decode(response.body);
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
        log("Route error $i: $e");
      }
    }

    if (mounted) {
      setState(() {
        _polylines.clear();
        if (allPoints.isNotEmpty) {
          _polylines.add(Polyline(
            polylineId: const PolylineId('full_route'),
            points: allPoints,
            color: Colors.blue,
            width: 5,
          ));
        }
        totalDistance = '${totalDistKm.toStringAsFixed(1)} km';
        totalDuration = '$totalTimeMin min';
        _routePoints = allPoints;
        _routeFetched = true;
      });

      if (_mapController != null && _routePoints.isNotEmpty) {
        final bounds = _calculateBounds(_routePoints);
        _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
      }
    }

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
  // MARK: - Timer & Search

  void _startDotTimer() {
    _dotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) setState(() => _dotCount = (_dotCount % 3) + 1);
    });
  }

  void _startSearchTimer() {
    _searchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (_remainingSeconds > 0) {
          setState(() => _remainingSeconds--);
        } else {
          _stopSearching();
        }
      }
    });
  }

  void _startSearching() {
    setState(() {
      _isSearching = true;
      _remainingSeconds = 300;
      _dotCount = 1;
    });
    _pulseController.repeat(reverse: true);
    _startDotTimer();
    _startSearchTimer();
  }

  void _stopSearching() {
    _dotTimer.cancel();
    _searchTimer?.cancel();
    _pulseController.stop();
    setState(() => _isSearching = false);
  }

  String _formatTime(int seconds) {
    int min = seconds ~/ 60;
    int sec = seconds % 60;
    return '$min:${sec.toString().padLeft(2, '0')}';
  }

  void _retrySearch() async {
    _stopSearching();
    setState(() => _isSearching = true);
    try {
      final body = BookInstantDeliveryBodyModel(

          vehicleTypeId: widget.id,
          origName: dropNames.first,
          origLat: pickupLat,
          origLon: pickupLon,
          coinAmount: 0,
          copanId: null,
          productType: widget.productType,
          dropoff: dropLats.asMap().entries.map((e) => BookDropoff(
            name: dropNames[e.key],
            lat: e.value,
            long: dropLons[e.key],
          )).toList(),
          distance:widget.distance,
          userPayAmount:widget.userPayAmount,
          // 270112,
          taxAmount: 18.0,
          mobNo:widget.mobile,
          name:widget.name
      );
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.bookInstantDelivery(body);
      if (response.code == 0) {
        box.put("current_booking_txId", response.data!.txId);
        setState(() {
          _remainingSeconds = 300;
          _dotCount = 1;
        });
        _pulseController.repeat(reverse: true);
        _startDotTimer();
        _startSearchTimer();
        Fluttertoast.showToast(msg: "Re-booking successful...");
      } else {
        setState(() => _isSearching = false);
        Fluttertoast.showToast(msg: response.message ?? "Retry failed");
      }
    }
    catch (e) {
      setState(() => _isSearching = false);
      Fluttertoast.showToast(msg: "Retry failed: $e");
    }
  }

  @override
  void dispose() {
    _socket.off('user:driver_assigned');
    _dotTimer.cancel();
    _searchTimer?.cancel();
    _pulseController.dispose();
    _pulseUpdateTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

// MARK: - Cancel Booking Function
  Future<void> _cancelCurrentBooking() async {
    // try {
    // final service = APIStateNetwork(callPrettyDio());
    // final response = await service.cancelDeliveryBooking(widget.txId);
    //
    // if (response.code == 0 || response.message?.toLowerCase().contains('cancelled') == true) {
    Fluttertoast.showToast(msg: "Booking cancelled successfully");
    _stopSearching(); // Stop all timers & animations
    setState(() {
      _isSearching = false; // Show "Try Again" button
    });
    //   } else {
    //     Fluttertoast.showToast(msg: response.message ?? "Failed to cancel");
    //   }
    // } catch (e) {
    //   Fluttertoast.showToast(msg: "Cancel failed: $e");
    // }
  }
  @override
  Widget build(BuildContext context) {
    final dots = '.' * _dotCount;

    return Scaffold(
      backgroundColor: Colors.white,
      body: _routeFetched && _iconsLoaded
          ? Stack(
        children: [

          GoogleMap(
            padding: EdgeInsets.only(top: 40.h, right: 16.w),
            initialCameraPosition: CameraPosition(target: LatLng(pickupLat, pickupLon), zoom: 15),
            onMapCreated: (controller) {
              _mapController = controller;
              _centerCameraOnPickup();
            },
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
            mapType: MapType.normal,
          ),


          Positioned(
            left: 10.w, top: 40.h,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              shape: const CircleBorder(),
              onPressed: () => Navigator.pop(context),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
              ),
            ),
          ),

          // Route Info

          Positioned(
            bottom: 210.h, left: 16.w, right: 16.w,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ...dropDistances.asMap().entries.map((e) => e.value.isNotEmpty
                  //     ? Text('Drop ${e.key + 1}: ${e.value} | ${dropDurations[e.key]}', style: GoogleFonts.inter(fontSize: 13.sp))
                  //     : const SizedBox()),
                  // if (totalDistance != null)
                  //   Text('Total: $totalDistance | $totalDuration', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold)),

                  ...dropDistances.asMap().entries.map((e) => e.value.isNotEmpty
                      ? Text('Drop ${e.key + 1}: ${e.value} | ${dropDurations[e.key]}', style: GoogleFonts.inter(fontSize: 13.sp))
                      : const SizedBox()),
                  if (totalDistance != null)
                    Text('Total: $totalDistance | $totalDuration', style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.bold)),

                ],
              ),
            ),
          ),

          Positioned(
            bottom: 50.h, left: 16.w, right: 16.w,
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isSearching
                        ? "Searching for nearby drivers$dots"
                        : "No driver found in 5 minutes",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  _isSearching
                      ? Column(
                    children: [
                      Text(
                        "Please wait... (${_formatTime(_remainingSeconds)})",
                        style: const TextStyle(fontSize: 15, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Cancel Button (Anytime during search)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            onPressed: () async {
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text("Cancel Booking?"),
                                  content: const Text("Are you sure you want to cancel this ride request?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, false),
                                      child: const Text("No"),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx, true),
                                      child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                await _cancelCurrentBooking();
                              }
                            },
                            child: const Text("Cancel", style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),

                          // Optional: You can also keep a small "Wait" hint or just loader
                          const CircularProgressIndicator(strokeWidth: 3, color: Colors.blueAccent),
                        ],
                      ),
                    ],
                  )
                      : Column(
                    children: [
                      const Text(
                        "No drivers available right now.",
                        style: TextStyle(fontSize: 15, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _retrySearch,
                        child: const Text("Try Again", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  void _centerCameraOnPickup() {
    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: LatLng(pickupLat, pickupLon), zoom: 15.5)));
  }
}