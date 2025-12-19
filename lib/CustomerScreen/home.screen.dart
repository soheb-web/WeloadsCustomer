import 'dart:async';
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/instantDelivery.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/orderList.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/payment.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/profile.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/intl.dart';
import '../data/Model/getDeliveryHistoryResModel..dart';
import '../data/controller/getDeliveryHistoryController.dart';
import 'Newscreen.dart';


class HomeScreen extends ConsumerStatefulWidget {

  final bool
  forceSocketRefresh; // New flag to force socket refresh on navigation
  const HomeScreen( {super.key, this.forceSocketRefresh = false});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();

}



var box = Hive.box("folder");
var id = box.get("id");



class _HomeScreenState extends ConsumerState<HomeScreen> {
  int selectIndex = 0;
  List<Map<String, dynamic>> myList = [
    {"image": "assets/bike1.png", "name": "Bike Delivery",
      // "title": "Quick Parcels"
    },
    //
    {
      "image": "assets/smalltruck1.png",
      "name": "Mini Truck",
      // "title": "Local & Medium",
    },
    {
      "image": "assets/truck1.png",
      "name": "Three Wheeler Tempo",
      // "title": "Full Load",
    },

    {
      "image": "assets/auto1.png",
      "name": "Pickup Van",
      // "title": "Choose from Our Fleet",
    },
    // {
    //   "image": "assets/SvgImage/packer.svg",
    //   "name": "Packer &  Mover",
    //   "title": "Home Shifting",
    // },
    // {
    //   "image": "assets/SvgImage/india.svg",
    //   "name": "All India Parcel",
    //   "title": "Choose from Our Fleet",
    // },
  ];
  final List<Color> cardColors = [
    Color(0xFF87BEB5),
    Color(0xFFDEC9A9),
    Color(0xFF8FBAD1),
    Color(0xFF87BEB5),
    Color(0xFFDEC9A9),
    Color(0xFF87BEB5),
  ];
  int activeStep = 2;
  String? currentAddress;
  bool isSocketConnected = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  StreamSubscription<Position>? _locationSubscription;
  Map<String, dynamic>? assignedDriver;
  String receivedMessage = "";
  final List<Map<String, dynamic>> messages = [];
  bool _isCheckingLocation = true;
  String? userId;
  late IO.Socket socket;



  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    userId = box.get("id")?.toString();
    _connectSocket();
    if (widget.forceSocketRefresh) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.invalidate(getDeliveryHistoryController);
          _refreshSocketConnection();
        }
      });
    }
  }
  void _refreshSocketConnection() {
    if (!mounted) return;
    _disconnectSocket();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _connectSocket();
    });
  }

  // Disconnect ko safe banao
  void _disconnectSocket() {
    if (socket.connected) {
      socket.disconnect();
    }
    socket.clearListeners();
    socket.dispose();
    log('Old socket disconnected & disposed');
  }

  // Socket connect ko safe banao (setState post-frame mein)


  void _connectSocket() {

    const socketUrl = 'https://backend.weloads.live';
    
    // const socketUrl = 'https://backend.weloads.live';
    // const socketUrl = 'http://192.168.1.43:4567';
    // const socketUrl = 'http://192.168.1.26:4567';
    // const socketUrl = 'https://backend.weloads.live';
    // const socketUrl = 'http://192.168.1.43:4567';

    socket = IO.io(socketUrl, <String, dynamic>{
      'transports': ['websocket', 'polling'],
      'autoConnect': false,
    });

    socket.onAny((event, data) => log("SOCKET EVENT: $event → $data"));

    socket.connect();

    socket.onConnect((_) { 
      log('Socket connected (force refresh: ${widget.forceSocketRefresh})');
      // Fluttertoast.showToast(msg: "Online");

      // Safe setState - build phase ke baad
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isSocketConnected = true);
        }
      });

      if (userId != null) {
        socket.emitWithAck('registerCustomer', {
          'userId': userId,
          'role': 'customer',
        }, ack: (ack) => log('Registration ACK: $ack'));
      }
    });

    socket.onDisconnect((_) {
      log('Socket disconnected');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isSocketConnected = false);
        }
      });
    });

    socket.onReconnect((_) {
      // log('Online');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => isSocketConnected = true);
        }
      });
    });


  }

  Future<void> _checkLocationPermission() async {
    setState(() {
      _isCheckingLocation = true;
    });

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showLocationDialog(
        'Location services are disabled. Please enable them.',
      );
      setState(() => _isCheckingLocation = false);
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showLocationDialog('Location permission denied.');
        setState(() => _isCheckingLocation = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showLocationDialog(
        'Location permission denied forever. Please enable in app settings.',
      );
      setState(() => _isCheckingLocation = false);
      return;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      await _updateAddress();
      setState(() {
        _locationEnabled = true;
        _isCheckingLocation = false;
      });

      // Start listening for location updates
      startLocationStream();
    } catch (e) {
      log('Error getting location: $e');
      _showLocationDialog('Failed to get location. Please try again.');
      setState(() => _isCheckingLocation = false);
    }
  }
  void _showLocationDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Location Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkLocationPermission();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  Future<void> _updateAddress() async {
    if (_currentPosition == null) return;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          currentAddress =
              "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        });
      } else {
        setState(() {currentAddress =
        "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";});
      }
    } catch (e) {
      log('Error updating address: $e');
      setState(() {
        currentAddress =
            "${_currentPosition!.latitude}, ${_currentPosition!.longitude}";
      });
    }
  }
  void startLocationStream() {
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        ).listen((Position position) {
          log(
            "📍 Updated position: ${position.latitude}, ${position.longitude}",
          );
          setState(() {
            _currentPosition = position;
          });
          _updateAddress();
        });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
  Color _getStatusColor(Status? status) {
    String statusStr = status?.toString().split('.').last ?? "not_assigned";
    switch (statusStr.toLowerCase()) {
      case "assigned":
        return const Color(0xFFE3F2FD);
      case "ongoing":
      case "picked":
        return const Color(0xFF7DCF4A); // green
      case "not_assigned":
      case "no_driver_found":
        return const Color(0xFFFFEBEE); // red
      case "completed":
        return const Color(0xFFE8F5E9); // green
      case "cancelled_by_user":
      case "cancelled_by_driver":
        return const Color(0xFFFFCDD2); // dark red
      default:
        return const Color(0xFFE0E0E0);
    }
  }
  Color _getStatusTextColor(Status? status) {
    String statusStr = status?.toString().split('.').last ?? "not_assigned";
    switch (statusStr.toLowerCase()) {
      case "assigned":
        return const Color(0xFF0D47A1); // dark blue
      case "not_assigned":
        return const Color(0xFFC62828); // dark red
      case "completed":
        return const Color(0xFF2E7D32); // dark green
      case "pending":
        return const Color(0xFF7E6604); // dark yellow-brown
      default:
        return const Color(0xFF424242); // dark gray
    }
  }

  @override
  Widget build(BuildContext context) {
    final historyProvier = ref.watch(getDeliveryHistoryController);
    // 🔄 Show loader while checking
    if (_isCheckingLocation) {
      return Scaffold(
        backgroundColor: const Color(0xFF006970),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white, strokeWidth: 4),
              SizedBox(height: 20.h),
              Text(
                'Checking location permission...',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    // Don't show homepage until location is enabled
    if (!_locationEnabled) {
      return Scaffold(
        backgroundColor: const Color(0xFF006970),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, size: 100.sp, color: Colors.white),
              SizedBox(height: 20.h),
              Text(
                'Enable Location',
                style: GoogleFonts.inter(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                'Please enable location services to continue',
                style: GoogleFonts.inter(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.h),
              ElevatedButton(
                onPressed: _checkLocationPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF006970),
                  padding: EdgeInsets.symmetric(
                    horizontal: 40.w,
                    vertical: 15.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.r),
                  ),
                ),
                child: Text(
                  'Enable Location',
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: selectIndex == 0
          ?


      SingleChildScrollView(
        child: Stack(
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(left: 20.w),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                      ),
                      color: Color(0xFF006970),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 50.h),
                        Text(
                          "Hi ${box.get("firstName")},what do you\nwant to send today?",
                          style: GoogleFonts.inter(
                            fontSize: 25.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          "Fast, affordable and trusted deliveries.",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 30.h),
                        // ElevatedButton(
                        //   style: ElevatedButton.styleFrom(
                        //     minimumSize: Size(180.w, 50.h),
                        //     backgroundColor: Colors.amber,
                        //   ),
                        //   onPressed: () {
                        //
                        //
                        //     Navigator.push(context, MaterialPageRoute(builder: (context)=>InstantDeliveryScreen(socket)));
                        //
                        //
                        //     // Navigator.push(
                        //     //   context,
                        //     //   MaterialPageRoute(
                        //     //     builder: (context) =>
                        //     //
                        //     //         InstantDeliveryScreen(),
                        //     //   ),
                        //     // );
                        //
                        //   },
                        //   child: Text(
                        //     "Book",
                        //     style: GoogleFonts.inter(
                        //       fontSize: 16.sp,
                        //       fontWeight: FontWeight.w400,
                        //       color: Colors.black,
                        //     ),
                        //   ),
                        // ),

                        Padding(
                          padding: EdgeInsets.only(left: 10.w, right: 10.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              delivery("Local"),
                              delivery("City"),
                              delivery("Nationwide"),
                              delivery("Home Shifting"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.h),

                  // Center(
                  //   child: Text(
                  //     textAlign: TextAlign.center,
                  //     "Choose the right vehicle for your delivery - fast,reliable & affordable!",
                  //     style: GoogleFonts.inter(
                  //       fontSize: 18.sp,
                  //       fontWeight: FontWeight.bold,
                  //       color: Color(0xFF006970),
                  //     ),
                  //   ),
                  // ),

Positioned(
  top:250,
  bottom: 0,
  left: 0,
  right: 0,
  child: Container(




    decoration: BoxDecoration(
color: Colors.white,
      borderRadius: BorderRadius.only(topLeft: Radius.circular(20.sp), topRight: Radius.circular(20.sp))
    ),
    child: SingleChildScrollView(
      child: Column(children: [
                        SizedBox(height: 15.h),
      
        ElevatedButton(

          style: ElevatedButton.styleFrom(
            elevation: 5,
            minimumSize: Size(180.w, 50.h),
            backgroundColor: Colors.amber,
          ),
          onPressed: () {
      
      
            Navigator.push(context, MaterialPageRoute(builder: (context)=>InstantDeliveryScreen(socket)));
      
      
            // Navigator.push(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) =>
            //
            //         InstantDeliveryScreen(),
            //   ),
            // );
      
          },
          child: Text(
            "Start a Delivery",
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),

                        SizedBox(height: 20.h),
      
                        historyProvier.when(
                          data: (history) {
                            // Agar koi delivery nahi hai to empty container dikhao
                            if (history.data!.deliveries!.isEmpty) {
                              return Center(
                                child: Text(
                                  "No ongoing deliveries",
                                  style: GoogleFonts.inter(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              );
                            }
      
                            // Sirf ONGOING deliveries filter karo
                            final ongoingDeliveries = history.data!.deliveries!
                                .where((d) => d.status.toString() == "ongoing")
                                .toList();
      
                            if (ongoingDeliveries.isEmpty) {
                              return const SizedBox.shrink(); // Nothing to show
                            }
      
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: ongoingDeliveries.length,
                              itemBuilder: (context, index) {
                                final delivery = ongoingDeliveries[index];
      
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PickupScreenNotification(
                                          deliveryId: delivery.id ?? "",
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 15.h, left: 25.w, right: 25.w),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Order ID + Recipient
                                        Text(
                                          delivery.id ?? "",
                                          style: GoogleFonts.inter(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF0C341F),
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              "Recipient: ${delivery.name ?? "Unknown"}",
                                              style: GoogleFonts.inter(
                                                fontSize: 13.sp,
                                                fontWeight: FontWeight.w400,
                                                color: const Color(0xFF545454),
                                              ),
                                            ),
                                            const Spacer(),
                                            Container(
                                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF7DCF4A).withOpacity(0.2),
                                                borderRadius: BorderRadius.circular(4.r),
                                              ),
                                              child: Text(
                                                "ONGOING",
                                                style: GoogleFonts.inter(
                                                  fontSize: 11.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: const Color(0xFF1B5E20),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 10.h),
      
                                        // Drop Locations with Numbered Circles
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 35.w,
                                              height: 35.h,
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(5.r),
                                                color: const Color(0xFFF7F7F7),
                                              ),
                                              child: Center(
                                                child:Image.asset("assets/bike1.png")
                                                // SvgPicture.asset("assets/SvgImage/bikess.svg"),
                                              ),
                                            ),
                                            SizedBox(width: 10.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(Icons.location_on, size: 16.sp, color: const Color(0xFF27794D)),
                                                      SizedBox(width: 5.w),
                                                      Text(
                                                        "Drop off",
                                                        style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF545454)),
                                                      ),
                                                    ],
                                                  ),
      
                                                  // Multiple Drop Locations (1-3)
                                                  if (delivery.dropoff != null && delivery.dropoff!.isNotEmpty)
                                                    ...delivery.dropoff!.asMap().entries.map((entry) {
                                                      int idx = entry.key;
                                                      final drop = entry.value;
                                                      bool isFinal = idx == delivery.dropoff!.length - 1;
      
                                                      return Padding(
                                                        padding: EdgeInsets.only(left: 3.w, top: 6.h),
                                                        child: Row(
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Container(
                                                              width: 18.w,
                                                              height: 18.h,
                                                              decoration: const BoxDecoration(
                                                                color: Colors.red,
                                                                shape: BoxShape.circle,
                                                              ),
                                                              child: Center(
                                                                child: Text(
                                                                  "${idx + 1}",
                                                                  style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(width: 8.w),
                                                            Expanded(
                                                              child: RichText(
                                                                text: TextSpan(
                                                                  style: GoogleFonts.inter(
                                                                    fontSize: 14.sp,
                                                                    color: const Color(0xFF0C341F),
                                                                  ),
                                                                  children: [
                                                                    TextSpan(text: drop.name ?? "Drop ${idx + 1}"),
                                                                    if (isFinal)
                                                                      TextSpan(
                                                                        text: " (Final)",
                                                                        style: GoogleFonts.inter(
                                                                          fontWeight: FontWeight.w600,
                                                                          color: Colors.red[700],
                                                                        ),
                                                                      ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }).toList(),
      
                                                  SizedBox(height: 6.h),
      
                                                  // Date
                                                  Text(
                                                    DateFormat("dd MMMM yyyy, h:mma")
                                                        .format(DateTime.fromMillisecondsSinceEpoch(delivery.createdAt!))
                                                        .toLowerCase(),
                                                    style: GoogleFonts.inter(
                                                      fontSize: 12.sp,
                                                      color: const Color(0xFF545454),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
      
                                        SizedBox(height: 12.h),
                                        const Divider(color: Color(0xFFDCE8E9)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          error: (error, stackTrace) {
                            log("History Error: $error");
                            return Center(child: Text("Error loading deliveries"));
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                        ),
      
                        // SizedBox(height: 200.h),
      
                          Padding(
                            padding: EdgeInsets.only(
                              left: 15.w,
                              right: 15.w,
                              bottom: 10.h,
                            ),
                            child: GridView.builder(
                              shrinkWrap: true,
                              itemCount: myList.length,
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 20.w,
                                mainAxisSpacing: 20.w,
                                childAspectRatio: 0.80,
                              ),
                              itemBuilder: (context, index) {
      
      
                                return InkWell(
                                  onTap: () {
                                    if (index == 4 || index == 5) {
                                      Fluttertoast.showToast(msg: "Comming Soon");
                                    } else {
      
                                      Navigator.push(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) => InstantDeliveryScreen(socket),
                                        ),
                                      );
      
                                    }
                                  },
                                  child: Container(
                                    width: 160.w,
                                    height: 175.h,
                                    decoration: BoxDecoration(
      
                                      borderRadius: BorderRadius.circular(10.r),
                                    ),
                                    child: Card(
                                      elevation: 5.sp,
                                      color: Colors.white,
                                      // color: cardColors[index % cardColors.length],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10.r),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
      
      
                                          SizedBox(height: 30.h),
                                          Center(
                                            child:
                                                // myList[index]['image']
                                                //     .toString()
                                                //     .endsWith(".svg")
                                                // ? SvgPicture.asset(
                                                //     myList[index]['image'],
                                                //     width: 80.w,
                                                //     height: 80.h,
                                                //   )
                                                // :
                                                Image.asset(
                                                    myList[index]['image'],
                                                    width: 120.w,
                                                    height: 120.h,
                                                  ),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                              // left: 9.w,
                                              top: 4.h,
                                            ),
                                            child: Text(
                                              // "Trucks",
                                              myList[index]['name'].toString(),
                                              style: GoogleFonts.inter(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF000000),
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ),
                                          // Padding(
                                          //   padding: EdgeInsets.only(left: 9.w),
                                          //   child: Text(
                                          //     //  "Choose from Our Fleet",
                                          //     myList[index]['title'].toString(),
                                          //     style: GoogleFonts.inter(
                                          //       fontSize: 14.sp,
                                          //       fontWeight: FontWeight.w400,
                                          //       color: Color(0xFF000000),
                                          //       letterSpacing: -1,
                                          //     ),
                                          //   ),
                                          // ),
      
      
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
      
                        // SizedBox(height: 20.h,),
                        //
                        // SizedBox(height: 40.h),
                        //
                        // SizedBox(height: 40.h,),

                      ],
                    ),
    ),
  ),
),
     ]) )



          : selectIndex == 1
          ? OrderListScreen()
          : selectIndex == 2
          ? PaymentScreen()
          : ProfileScreen(socket),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (value) {
          setState(() {
            selectIndex = value;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Color(0xFF006970),
        unselectedItemColor: Colors.grey,
        currentIndex: selectIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Order"),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment_rounded),
            label: "Payment",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_sharp),
            label: "Account",
          ),
        ],
      ),
    );
  }
  Widget cardbuild(String image, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(image),
        SizedBox(height: 8.h),
        Text(
          name,
          style: GoogleFonts.inter(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: Color(0xFF353535),
          ),
        ),
      ],
    );
  }
  Widget delivery(String name) {
    return Container(
      padding: EdgeInsets.only(left: 10.w, right: 10.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.r),
        color: Color(0xFFF3F7F5),
      ),
      child: Text(
        name,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.w400,
          color: Color(0xFF006970),
        ),
      ),
    );
  }


}



class Shipment extends StatefulWidget {
  const Shipment({super.key});
  @override
  State<Shipment> createState() => _ShipmentState();
}



class _ShipmentState extends State<Shipment> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(top: 14.h),
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 14.h,
            bottom: 14.h,
          ),
          decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Color.fromARGB(153, 237, 237, 237)),
            boxShadow: [
              BoxShadow(
                spreadRadius: 0,
                blurRadius: 17.39,
                offset: Offset(0, 0),
                color: Color.fromARGB(15, 118, 118, 118),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFFFFF),
                  border: Border.all(color: Color.fromARGB(102, 237, 237, 237)),
                ),
                child: SvgPicture.asset(
                  "assets/SvgImage/id.svg",
                  width: 20.w,
                  height: 20.h,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "#HWDSF776567DS",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF353535),
                    ),
                  ),
                  Text(
                    "#On the way . 24 June",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFFABABAB),
                    ),
                  ),
                ],
              ),
              Spacer(),
              IconButton(
                style: IconButton.styleFrom(
                  minimumSize: Size(15.w, 30.h),
                  padding: EdgeInsets.only(right: 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {},
                icon: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Color(0xFF353535),
                  size: 16.sp,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
