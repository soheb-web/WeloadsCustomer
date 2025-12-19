

import 'dart:async';
import 'dart:developer';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:delivery_mvp_app/data/Model/CancelOrderModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
import 'home.screen.dart';

class PickupScreenNotification extends StatefulWidget {
  final IO.Socket? socket;
  final String deliveryId;
  const PickupScreenNotification({
    super.key,
    this.socket,
    required this.deliveryId,
  });
  @override
  State<PickupScreenNotification> createState() => _PickupScreenNotificationState();
}


class _PickupScreenNotificationState extends State<PickupScreenNotification> {
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  LatLng? _driverLatLng;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = <Polyline>{};
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> messages = [];
  Map<String, dynamic>? assignedDriver;
  bool isSocketConnected = false;
  GetDeliveryByIdResModel2? deliveryData;
  bool isLoadingData = true;
  String? error;
  late IO.Socket socket;
  String? driverToPickupETA = "Calculating...";
  late BitmapDescriptor _number1Icon;
  late BitmapDescriptor _number2Icon;
  late BitmapDescriptor driverIcon;


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

  int _maxFreeWaitingSeconds = 300; // डिफ़ॉल्ट 5 मिनट (fallback)

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    socket = widget.socket ??
        // IO.io('http://192.168.1.43:4567', <String, dynamic>{
        IO.io('https://backend.weloads.live', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    if (widget.socket == null) {
      socket.connect();
    }

    _setupSocketListeners();
    _fetchDeliveryData();
    _emitDriverArrivedAtPickup();
    _createNumberIcons();

    loadSimpleDriverIcon().then((_) {
      if (mounted) setState(() {});
    });

  }





  void _setupSocketListeners() {
    socket.onConnect((_) {
      log('Socket connected (PickupScreen)');
      if (mounted) setState(() => isSocketConnected = true);
      _joinDeliveryRoom();
    });

    socket.onDisconnect((_) {
      log('Socket disconnected');
      if (mounted) setState(() => isSocketConnected = false);
    });

    socket.on('receive_message', (data) {
      log('Received message: $data');
      if (mounted) {
        setState(() {
          messages.add({
            'text': data['message'] ?? 'Unknown message',
            'isMine': false,
          });
        });
      }
    });

    socket.on('driver_eta_update', (data) {
      if (data['deliveryId'] == widget.deliveryId && data['eta'] != null) {
        if (mounted) {
          setState(() {
            driverToPickupETA = "${data['eta']} min";
          });
        }
      }
    });

    socket.on('driver_location_update', (data) {
      if (data['deliveryId'] == widget.deliveryId && data['lat'] != null && data['lng'] != null) {
        final latLng = LatLng(data['lat'], data['lng']);
        setState(() {
          _markers.removeWhere((m) => m.markerId.value == 'driver');
          _markers.add(
            Marker(
              markerId: const MarkerId('driver'),
              position: latLng,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
              infoWindow: const InfoWindow(title: 'Driver Live Location'),
            ),
          );
        });
      }
    });
  }

  void _joinDeliveryRoom() {
    socket.emit('join_delivery', {'deliveryId': widget.deliveryId});
  }

  Future<void> _fetchDeliveryData() async {
    try {
      setState(() {
        isLoadingData = true;
        error = null;
      });
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.getDeliveryById2(widget.deliveryId);

      if (mounted) {
        setState(() {
          deliveryData = response;
          isLoadingData = false;
        });
        _addMarkers();
        _getDirections();
        _joinDeliveryRoom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e.toString();
          isLoadingData = false;
        });
      }
    }
  }

  void _emitDriverArrivedAtPickup() async{
   await _fetchDeliveryData();
    final payload = {"deliveryId": widget.deliveryId};
    final payloadLocation = {"driverId": deliveryData!.data!.deliveryBoy!.id ?? ""};
    if (socket.connected) {
      socket.emit("delivery:status_update", payload);
      // socket.emit("driver:get_location", payloadLocation);

      socket.emitWithAck(
        "driver:get_location",
        { "driverId": deliveryData!.data!.deliveryBoy!.id },
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

      log("Emitted → $payload");
      log("Emitted newww → $payloadLocation");

    /*  socket.on("delivery:status_update", (data) {
        log("Status updated response: $data");
        if (data['status'] == 'completed') {
          _navigateToGiveRatingScreen();
        } else if (data['status'] == 'cancelled_by_driver') {
          _navigateToHomeScreen();
        }
      });

      socket.on("driver:get_location", (data) {

      });*/

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
          // _navigateToGiveRatingScreen();



          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CompleteScreen(
                socket:socket,
                freeWaitingTime: data['freeWaitingTime'],
                previousAmount: data['previousAmount'],
                extraWaitingMinutes: data['extraWaitingMinutes'],
                extraWaitingCharge: data['extraWaitingCharge'],
                deliveryId: widget.deliveryId,
                driverId: deliveryData!.data!.deliveryBoy!.id ?? "",
                driverName: deliveryData!.data!.deliveryBoy!.firstName ?? "",
                driverLastName: deliveryData!.data!.deliveryBoy!.lastName ?? "",
                driverImage: deliveryData!.data!.deliveryBoy!.image ?? "",

              ),
            ),
          );


        } else if (status == 'cancelled_by_driver') {
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


        // Add more statuses if needed
      });


    } else {
      log("Socket not connected, retrying...");
      Future.delayed(const Duration(seconds: 2), _emitDriverArrivedAtPickup);
    }
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

      // // Agar map pe marker move karna hai to yahan call karo
      // _moveDriverMarker(_driverLatLng!);

      // UI update ke liye (if needed)
      setState(() {});
    } else {
      print("Driver location failed or not available");
      _driverLatLng = null;
    }
  }
  void _navigateToHomeScreen() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomeScreen(forceSocketRefresh: true)),
          (route) => false,
    );
  }

  void _navigateToGiveRatingScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiveRatingScreen(

            driverId: deliveryData!.data!.deliveryBoy!.id ?? "",
          driverName: deliveryData!.data!.deliveryBoy!.firstName ?? "",
          driverLastName: deliveryData!.data!.deliveryBoy!.lastName ?? "",
          driverImage: deliveryData!.data!.deliveryBoy!.image ?? "",

        ),
      ),
    );
  }

  @override
  void dispose() {
    if (widget.socket == null) {
      socket.dispose();
    }
    _controller.dispose();
    super.dispose();
  }

  Future<void> _getDirections() async {
    if (deliveryData?.data?.pickup == null || deliveryData?.data?.dropoff == null || deliveryData!.data!.dropoff!.isEmpty) return;

    final pickup = deliveryData!.data!.pickup!;
    final dropoffs = deliveryData!.data!.dropoff!;

    String origin = "${pickup.lat},${pickup.long}";
    String destination = "${dropoffs.last.lat},${dropoffs.last.long}";

    String waypoints = dropoffs
        .take(dropoffs.length - 1)
        .where((d) => d.lat != null && d.long != null)
        .map((d) => "${d.lat},${d.long}")
        .join("|");

    String apiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";
    String url =
        "https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$destination${waypoints.isNotEmpty ? "&waypoints=$waypoints" : ""}&key=$apiKey";

    try {
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map values = jsonDecode(response.body);
        if (values['status'] == 'OK' && values['routes'] != null && values['routes'].isNotEmpty) {
          String polylineString = values['routes'][0]['overview_polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(polylineString);
          if (mounted) {
            setState(() {
              _polylines.add(
                Polyline(
                  polylineId: const PolylineId('route'),
                  color: Colors.blue,
                  width: 5,
                  points: polylineCoordinates,
                ),
              );
            });
          }
        }
      }
    } catch (e) {
      log('Error fetching directions: $e');
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
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  Future<void> loadSimpleDriverIcon() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    const size = 100.0;


    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2 - 18,
      Paint()..color = const Color(0xFF00C853), // Bright Green
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

  void _addMarkers() {
    final markers = <Marker>{};
    // Current Location
    if (_driverLatLng != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('_driverLatLng'),
          position: _driverLatLng!,
          infoWindow: const InfoWindow(title: 'driver LatLng'),
          icon:driverIcon,
          // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Pickup
    if (deliveryData?.data?.pickup != null) {
      final pickup = deliveryData!.data!.pickup!;
      if (pickup.lat != null && pickup.long != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('pickup'),
            position: LatLng(pickup.lat!, pickup.long!),
            infoWindow: InfoWindow(title: 'Pickup', snippet: pickup.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          ),
        );
      }
    }

    // Multiple Dropoffs
    if (deliveryData?.data?.dropoff != null) {
      for (int i = 0; i < deliveryData!.data!.dropoff!.length; i++) {
        final drop = deliveryData!.data!.dropoff![i];
        if (drop.lat != null && drop.long != null) {

          BitmapDescriptor icon;
          if (i == 0)  icon = _number1Icon;
          // icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
          else if (i == 1)  icon = _number2Icon;
          // icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow);
          else icon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
          // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);


          markers.add(
            Marker(
              markerId: MarkerId('dropoff_$i'),
              position: LatLng(drop.lat!, drop.long!),
              infoWindow: InfoWindow(
                title: 'Drop ${i + 1}${i == deliveryData!.data!.dropoff!.length - 1 ? ' (Final)' : ''}',
                snippet: drop.name ?? 'Drop Location ${i + 1}',
              ),
              icon:icon,


              // BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            ),
          );
        }
      }
    }

    setState(() => _markers = markers);
  }

  void _sendMessage() {
    if (!isSocketConnected || _controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();
    socket.emit('send_message', {
      'message': message,
      'deliveryId': widget.deliveryId,
    });
    setState(() {
      messages.add({'text': message, 'isMine': true});
    });
    _controller.clear();
  }

  void _showCancelBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => CancelBottomSheetContent(
        txId: deliveryData?.data?.txId ?? '',
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location service disabled")));
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location permission denied forever")));
      return;
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    if (!mounted) return;

    setState(() {
      _currentLatLng = LatLng(position.latitude, position.longitude);
    });

    _mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(target: _currentLatLng!, zoom: 15)));
    _addMarkers();
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context);

    if (isLoadingData) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (error != null || deliveryData?.data == null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    final data = deliveryData!.data!;
    final driver = data.deliveryBoy;
    final pickup = data.pickup;
    final dropoffs = data.dropoff ?? [];

    final driverName = driver != null
        ? '${driver.firstName ?? ''} ${driver.lastName ?? ''}'.trim().isEmpty
        ? 'Unknown Driver'
        : '${driver.firstName ?? ''} ${driver.lastName ?? ''}'
        : 'Unknown Driver';

    final driverPhone = driver?.phone ?? 'N/A';
    final driverImage = driver?.image ?? "https://media.istockphoto.com/id/1394758946/vector/no-image-raster-symbol-missing-available-icon-no-gallery-for-this-moment-placeholder.jpg?s=170667a&w=0&k=20&c=HMFTtins81JmJWSrFbjs-xNL_W0KXonnGwCWJo5IPp0=";
    final vehicleTypeName = data.vehicleTypeId?.name ?? 'Vehicle';
    final amount = data.userPayAmount?.toString() ?? '0';
    final otp = data.otp ?? 'N/A';

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen()));
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
              },
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),

            DraggableScrollableSheet(
              initialChildSize: 0.45,
              minChildSize: 0.25,
              maxChildSize: 0.75,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5)],
                  ),
                  child: ListView(
                    controller: scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                    children: [
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 5.h,
                          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10.r)),
                        ),
                      ),
                      SizedBox(height: 10.h),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Your driver is arriving", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10.r)),
                            child: Text(driverToPickupETA!, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      const Divider(),

                      // Driver Info
                      Row(
                        children: [
                          CircleAvatar(radius: 25, backgroundImage: NetworkImage(driverImage)),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(driverName, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
                                Text(vehicleTypeName, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
                                Row(children: [const Icon(Icons.star, color: Colors.amber, size: 16), Text(driver?.averageRating?.toString() ?? "5", style: const TextStyle(fontSize: 13))]),
                              ],
                            ),
                          ),


                          actionButton("assets/SvgImage/calld.svg", () {
                            launchUrl(Uri.parse("tel:$driverPhone"));
                          }, ""),


                        ],
                      ),

                      SizedBox(height: 15.h),
                      const Divider(),

                      // Pickup & Multiple Dropoffs
                      Text("Pickup & Drop Locations", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 10.h),

                      // Pickup
                      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.my_location, color: Colors.green, size: 24),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text("Pickup Location", style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600)),
                            SizedBox(height: 4.h),
                            Text(pickup?.name ?? "Unknown Pickup", style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
                          ]),
                        ),
                      ]),
                      SizedBox(height: 12.h),

                      // Dropoffs
                      ...dropoffs.asMap().entries.map((entry) {
                        int idx = entry.key;
                        Pickup drop = entry.value;
                        bool isFinal = idx == dropoffs.length - 1;

                        return Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(Icons.location_on, color: Colors.red, size: 32),
                                  Positioned(
                                    top: 6,
                                    child: Text("${idx + 1}", style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Drop Location ${idx + 1}${isFinal ? " (Final)" : ""}",
                                      style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(drop.name ?? "Drop Location ${idx + 1}", style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),

                      if (otp != 'N/A') ...[
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.all(8.w),
                          decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8.r), border: Border.all(color: Colors.blue)),
                          child: Row(children: [
                            const Icon(Icons.lock, size: 16, color: Colors.blue),
                            SizedBox(width: 8.w),
                            Text('OTP: $otp', style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.blue[800])),
                          ]),
                        ),
                      ],

                      SizedBox(height: 20.h),

                      // Navigation Button
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: ElevatedButton.icon(
                          onPressed: _openCustomerLiveTracking,
                          icon: const Icon(Icons.navigation_rounded, color: Colors.white, size: 28),
                          label: Text("Start Navigation", style: GoogleFonts.inter(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00C853),
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                            elevation: 8,
                            minimumSize: const Size(double.infinity, 56),
                          ),
                        ),
                      ),




                      SizedBox(height: 20.h),
                      const Divider(),

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
                                _waitingSeconds >= _maxFreeWaitingSeconds ? Icons.warning_amber_rounded : Icons.access_time_filled,
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
                          Text("₹ $amount", style: const TextStyle(

                              fontWeight: FontWeight.w600)),
                        ],
                      ),

                      SizedBox(height: 15.h),
                      const Divider(),

                      // Chat
                      Text("Chat with Driver:", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w400)),
                      SizedBox(height: 8.h),

                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatingPage(
                                      name: driver?.firstName ?? "Driver",
                                      socket: socket,
                                      senderId: data.customer ?? "",
                                      receiverId: driver?.id ?? "",
                                      deliveryId: data.id ?? "",
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
                                    suffixIcon: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: _sendMessage),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),

                        ],
                      ),

                      SizedBox(height: 20.h),

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
                      SizedBox(height: 40,),
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

  Widget actionButton(String icon, VoidCallback onTap, String label) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 45.w,
            height: 45.h,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEEDEF)),
            child: Center(child: SvgPicture.asset(icon, width: 18.w, height: 18.h)),
          ),
          SizedBox(height: 6.h),
          Text(label, style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.black)),
        ],
      ),
    );
  }

  Future<void> _openCustomerLiveTracking() async {
    final pickup = deliveryData!.data!.pickup!;
    final dropoff = deliveryData!.data!.dropoff!.last;

    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
          '&origin=${_currentLatLng!.latitude},${_currentLatLng!.longitude}'
          '&destination=${dropoff.lat},${dropoff.long}'
          '&waypoints=${pickup.lat},${pickup.long}'
          '&travelmode=driving'
          '&dir_action=navigate',
    );

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      Fluttertoast.showToast(msg: "Google Maps not installed");
    }
  }
}


// Cancel Bottom Sheet remains same (you already have it)


class CancelBottomSheetContent extends StatefulWidget {
  final String txId;
  final VoidCallback onCancel;
  const CancelBottomSheetContent({super.key, required this.txId, required this.onCancel});

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
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 5.h,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10.r)),
                ),
              ),
              SizedBox(height: 20.h),
              Text('Why do you want to cancel?', style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
              SizedBox(height: 20.h),
              ...reasons.asMap().entries.map((e) {
                return RadioListTile<int>(
                  title: Text(e.value, style: GoogleFonts.inter(fontSize: 14.sp)),
                  value: e.key,
                  groupValue: selectedIndex,
                  onChanged: _isLoading ? null : (v) => setState(() => selectedIndex = v ?? 0),
                  activeColor: Colors.redAccent,
                );
              }),
              if (selectedIndex == reasons.length - 1)
                Padding(
                  padding: EdgeInsets.only(top: 10.h),
                  child: TextField(
                    controller: _otherController,
                    enabled: !_isLoading,
                    maxLines: 3,
                    decoration: InputDecoration(hintText: 'Enter your reason...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r))),
                  ),
                ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: _isLoading ? null : widget.onCancel, child: Text('Cancel', style: GoogleFonts.inter(fontSize: 16.sp)))),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : () async {
                        String reason = selectedIndex == reasons.length - 1 ? _otherController.text.trim() : reasons[selectedIndex];
                        if (reason.isEmpty) {
                          Fluttertoast.showToast(msg: 'Please provide a reason');
                          return;
                        }
                        setState(() => _isLoading = true);
                        await cancelOrderApiStatic(widget.txId, reason);
                        setState(() => _isLoading = false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : Text('Submit', style: GoogleFonts.inter(color: Colors.white)),
                    ),
                  ),
                  SizedBox(height: 100.h,)
                ],
              ),
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
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString(), backgroundColor: Colors.red, textColor: Colors.white);
    }
  }
}