

import 'dart:convert';
import 'dart:developer';
import 'package:delivery_mvp_app/data/Model/getDistanceBodyModel.dart';
import 'package:delivery_mvp_app/data/controller/getDistanceController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/DeleteAddressModel.dart';
import '../data/Model/GetAddressResponseModel.dart';
import '../data/controller/getAllAddress.dart';
import 'AddAddressPage.dart';
import 'SelectProductScreen.dart';

class InstantDeliveryScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  const InstantDeliveryScreen(this.socket, {super.key});
  @override
  ConsumerState<InstantDeliveryScreen> createState() => _InstantDeliveryScreenState();
}


class _InstantDeliveryScreenState extends ConsumerState<InstantDeliveryScreen> {

  TextEditingController pickupController = TextEditingController();
  List<TextEditingController> dropControllers = [TextEditingController()];
  TextEditingController nameContr = TextEditingController();
  TextEditingController phonContro = TextEditingController();
  GoogleMapController? _mapController;
  LatLng? _currentLatLng;
  String? _currentAddress;
  bool isLoading = false;
  final int maxDrops = 3;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }
  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Location permission denied")),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Location permission permanently denied. Please enable it from settings."),
          ),
        );
        return;
      }

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      await Future.delayed(const Duration(seconds: 2));
      Position freshPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
      );

      final lat = freshPosition.latitude;
      final lon = freshPosition.longitude;

      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lon);
      Placemark place = placemarks.first;

      String address = [
        place.name,
        place.street,
        place.subLocality,
        place.locality,
        place.administrativeArea,
        place.postalCode,
        place.country,
      ].where((e) => e?.isNotEmpty ?? false).join(', ');

      final parts = address.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final uniqueParts = <String>{};
      final cleanParts = parts.where((e) => uniqueParts.add(e)).toList();
      address = cleanParts.join(', ');

      setState(() {
        _currentLatLng = LatLng(lat, lon);
        _currentAddress = address;
        pickupController.text = address;
      });

      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _currentLatLng!, zoom: 17.5),
        ),
      );
    } catch (e) {
      log("Location error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching current location: $e")),
      );
    }
  }
  void _addDropLocation() {
    if (dropControllers.length < maxDrops) {
      setState(() {
        dropControllers.add(TextEditingController());
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Maximum 3 drop locations allowed")),
      );
    }
  }
  void _removeDropLocation(int index) {
    if (dropControllers.length > 1) {
      setState(() {
        dropControllers.removeAt(index);
      });
    }
  }
  @override
  void dispose() {
    pickupController.dispose();
    for (var controller in dropControllers) {
      controller.dispose();
    }
    nameContr.dispose();
    phonContro.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(getDistanceProvider);
    var box = Hive.box("folder");
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(
        mini: true,
        backgroundColor: const Color(0xFFFFFFFF),
        shape: const CircleBorder(),
        onPressed: () => Navigator.pop(context),
        child: Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
        ),
      ),
      body:

      _currentLatLng == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(

        children: [


          GoogleMap(
            padding: EdgeInsets.only(top: 40.h, right: 16.w),
            initialCameraPosition: CameraPosition(target: _currentLatLng!, zoom: 15),
            onMapCreated: (controller) => _mapController = controller,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),

          DraggableScrollableSheet(
            initialChildSize: 0.45,
            minChildSize: 0.25,
            maxChildSize: 0.65,
            builder: (context, scrollController) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 5),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: 8.h),
                    Center(
                      child: Container(
                        width: 50.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      "Instant Delivery",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF111111),
                        letterSpacing: -1,
                      ),
                    ),


                    RideCardMyCode(
                      pickupController: pickupController,
                      dropControllers: dropControllers,
                      onAddDrop: _addDropLocation,
                      onRemoveDrop: _removeDropLocation,
                    ),


                    SizedBox(height: 15.h),


                    Container(
                      margin: EdgeInsets.only(left: 15.w, right: 15.w),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size(double.infinity, 50.h),
                          backgroundColor: const Color(0xFF006970),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                        ),



                        onPressed: () async {
                          if (pickupController.text.isEmpty ||
                              dropControllers.any((c) => c.text.isEmpty)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please fill pickup and all drop locations")),
                            );
                            return;
                          }

                          setState(() => isLoading = true);
                          try {
                            // 1. Pickup
                            final pickupLocs = await locationFromAddress(pickupController.text);
                            final pickupLat = pickupLocs.first.latitude;
                            final pickupLon = pickupLocs.first.longitude;

                            // 2. Drops
                            final List<double> dropLats = [];
                            final List<double> dropLons = [];
                            final List<String> dropNames = [];

                            for (var controller in dropControllers) {
                              final locs = await locationFromAddress(controller.text);
                              dropLats.add(locs.first.latitude);
                              dropLons.add(locs.first.longitude);
                              dropNames.add(controller.text);
                            }

                            final pickAddress = pickupController.text;

                            // 3. Total Distance (1, 2 या 3 drops → सब काम करेगा)
                            final totalDistKm = await getTotalDistance(
                              pickupLat: pickupLat,
                              pickupLon: pickupLon,
                              dropLats: dropLats,
                              dropLons: dropLons,
                              apiKey: 'AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g',
                            );
                            print('Total Distance: ${totalDistKm.toStringAsFixed(1)} km');

                            // 4. Body with multi-dropoff
                            final body = GetDistanceBodyModel(
                              name: nameContr.text.isNotEmpty ? nameContr.text : box.get("firstName") ?? "User",
                              mobNo: phonContro.text.isNotEmpty ? phonContro.text : box.get("phone") ?? "N/A",
                              origName: pickupController.text,
                              picUpType: "Instant",
                              origLat: pickupLat,
                              origLon: pickupLon,
                              dropoff: dropLats.asMap().entries.map((e) {
                                final i = e.key;
                                return Dropoff(
                                  name: dropNames[i],
                                  lat: dropLats[i],
                                  long: dropLons[i],
                                );
                              }).toList(),
                              totalDistance: totalDistKm.round(),
                            );

                            // 5. API Call
                            final response = await ref.read(getDistanceProvider.notifier).fetchDistance(body);

                            // 6. Navigate
                            if (mounted) {
                              await Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => ProductTypeSelectScreen(
                                    widget.socket,
                                    pickupLat,
                                    pickupLon,
                                    dropLats,
                                    dropLons,
                                    dropNames,
                                      pickAddress

                                    // totalDistance: totalDistKm.round(),
                                  ),
                                ),
                              );
                            }

                            setState(() => isLoading = false);
                          } catch (e) {
                            setState(() => isLoading = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        },
                        child: isLoading
                            ? const Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          ),
                        )
                            : Text(
                          "Next",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                    ),


                    SizedBox(height: 40.h),
                  ],
                ),
              );
            },
          ),


        ],
      ),
    );
  }

}

Future<double> getTotalDistance({
  required double pickupLat,
  required double pickupLon,
  required List<double> dropLats,
  required List<double> dropLons,
  required String apiKey,
}) async {
  if (dropLats.isEmpty) throw Exception("No drop locations");

  final String origin = '$pickupLat,$pickupLon';
  final String destination = '${dropLats.last},${dropLons.last}';
  final List<String> waypoints = [];
  for (int i = 0; i < dropLats.length - 1; i++) {
    waypoints.add('${dropLats[i]},${dropLons[i]}');
  }
  final String waypointsParam = waypoints.isNotEmpty
      ? '&waypoints=${waypoints.join('|')}'
      : '';
  final url = Uri.parse(
    'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=$origin'
        '&destination=$destination'
        '$waypointsParam'
        '&key=$apiKey'
        '&mode=driving'
        '&optimizeWaypoints=true',
  );

  final response = await http.get(url);
  if (response.statusCode != 200) {
    throw Exception('HTTP ${response.statusCode}: Failed to fetch route');
  }

  final data = json.decode(response.body);
  if (data['status'] != 'OK') {
    throw Exception('Directions API Error: ${data['status']}');
  }

  double totalMeters = 0;
  final legs = data['routes'][0]['legs'] as List;
  for (var leg in legs) {
    totalMeters += (leg['distance']['value'] as num).toDouble();
  }

  return totalMeters / 1000; // km
}


class RideCardMyCode extends StatefulWidget {
  final TextEditingController pickupController;
  final List<TextEditingController> dropControllers;
  final VoidCallback onAddDrop;
  final Function(int) onRemoveDrop;

  const RideCardMyCode({
    super.key,
    required this.pickupController,
    required this.dropControllers,
    required this.onAddDrop,
    required this.onRemoveDrop,
  });

  @override
  State<RideCardMyCode> createState() => _RideCardMyCodeState();
}
class _RideCardMyCodeState extends State<RideCardMyCode> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Pickup
        Container(
          margin: EdgeInsets.only(top: 15.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 18.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15.r),
            boxShadow: [
              BoxShadow(offset: const Offset(0, 2), blurRadius: 3, spreadRadius: 2, color: const Color.fromARGB(28, 0, 0, 0)),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.circle, size: 12.sp, color: Colors.green),
              SizedBox(width: 10.w),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => PickupPage(pickController: widget.pickupController)),
                    ).then((_) => setState(() {}));
                  },
                  child: Text(
                    widget.pickupController.text.isNotEmpty
                        ? widget.pickupController.text
                        : "Fetching location...",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(fontSize: 12.sp, color: Colors.grey[700]),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PickupPage(pickController: widget.pickupController)),
                  ).then((_) => setState(() {}));
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE5F0F1)),
                  child: Icon(Icons.arrow_forward_ios, size: 20.w),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 15.h),

        // Drop Locations
        // ...widget.dropControllers.asMap().entries.map((entry) {
        //   int index = entry.key;
        //   var controller = entry.value;
        //
        //   return Container(
        //     margin: EdgeInsets.only(bottom: 10.h),
        //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        //     decoration: BoxDecoration(
        //       color: Colors.white,
        //       borderRadius: BorderRadius.circular(12.r),
        //       border: Border.all(color: Colors.grey.shade300),
        //     ),
        //     child: Row(
        //       children: [
        //         Icon(Icons.location_on, size: 14.sp, color: Colors.red),
        //         SizedBox(width: 10.w),
        //         Expanded(
        //           child: TextField(
        //             controller: controller,
        //             readOnly: true,
        //             onTap: () {
        //               Navigator.push(
        //                 context,
        //                 MaterialPageRoute(builder: (_) => DropPage(dropController: controller)),
        //               ).then((_) => setState(() {}));
        //             },
        //             style: GoogleFonts.poppins(fontSize: 14.sp, fontWeight: FontWeight.w500),
        //             decoration: InputDecoration(
        //               isDense: true,
        //               hintText: "Drop ${index + 1} location",
        //               hintStyle: GoogleFonts.poppins(fontSize: 13.sp, color: Colors.grey),
        //               contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
        //               border: InputBorder.none,
        //             ),
        //           ),
        //         ),
        //
        //         if (widget.dropControllers.length > 1)
        //           IconButton(
        //             onPressed: () => widget.onRemoveDrop(index),
        //             icon: Icon(Icons.close, size: 18.sp, color: Colors.red),
        //           ),
        //
        //         if (widget.dropControllers.length < 3)
        //           Center(
        //             child: TextButton.icon(
        //               onPressed: widget.onAddDrop,
        //               icon: Icon(Icons.add, size: 16.sp, color: const Color(0xFF006970)),
        //               label: Text(
        //                 "",
        //                 style: GoogleFonts.poppins(fontSize: 13.sp, color: const Color(0xFF006970)),
        //               ),
        //             ),
        //           ),
        //       ],
        //     ),
        //   );
        // }).toList(),



        ...widget.dropControllers.asMap().entries.map((entry) {
          int index = entry.key;
          var controller = entry.value;
          final isLast = index == widget.dropControllers.length - 1;
          final showAddButton = widget.dropControllers.length < 3 && isLast;

          return Container(
            key: ValueKey(index), // Important for proper rebuilding
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, size: 14.sp, color: Colors.red),
                SizedBox(width: 10.w),
                Expanded(
                  child: TextField(
                    controller: controller,
                    readOnly: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DropPage(dropController: controller),
                        ),
                      ).then((_) => setState(() {}));
                    },
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: "Drop ${index + 1} location",
                      hintStyle: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        color: Colors.grey,
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 10.h,
                        horizontal: 8.w,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                // Remove button (except for the first one if you want minimum 1)
                if (widget.dropControllers.length > 1)


                    InkWell(
                      onTap: (){
                        widget.onRemoveDrop(index);
                      },
                      child: Container(
                          decoration: BoxDecoration(

                            borderRadius: BorderRadius.circular(30),
                            color: Colors.red
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(Icons.close, size: 20.sp, color: Colors.white),
                          )),
                    )
                  // )


                else
                  SizedBox(width: 8.w), // Space balance when no remove button


                // Add button - only on the last field
                if (showAddButton)

          Padding(
            padding:  EdgeInsets.only(left:10.w),
            child: InkWell(

            onTap:(){
            widget.onAddDrop();
            },
            child: Icon(Icons.add_circle, size: 34.sp, color: const Color(0xFF006970))),
          )



                  // TextButton.icon(
                  //   onPressed:
                  //   icon:
                  //   label: Text(
                  //     "",
                  //     style: GoogleFonts.poppins(
                  //       fontSize: 13.sp,
                  //       color: const Color(0xFF006970),
                  //       fontWeight: FontWeight.w500,
                  //     ),
                  //   ),
                  // )
                else if (widget.dropControllers.length < 3)
                  SizedBox(width: 10.w), // Optional: balance spacing
              ],
            ),
          );
        }).toList(),
        // Add More Drop


        SizedBox(height: 20.h),
      ],
    );
  }
}
class PickupPage extends ConsumerStatefulWidget {
  final TextEditingController pickController;
  final void Function(double lat, double lng)? onLocationPicked; // ← NEW
  const PickupPage({super.key, required this.pickController,
    this.onLocationPicked,
  });
  @override
  ConsumerState<PickupPage> createState() => _PickupPageState();
}
class _PickupPageState extends ConsumerState<PickupPage> {
  late final TextEditingController _pickupController;
  late final FocusNode _focusNode;
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";
  String _lat = '', _lon = '';
  bool _fetchingCurrent = false, _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pickupController = TextEditingController(text: widget.pickController.text);
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _showSnack("Permission denied");
      }
      if (permission == LocationPermission.deniedForever) return _showSnack("Permission permanently denied");

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return _showSnack("Enable location services");
      }

      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;
      final address = [place.name, place.street, place.subLocality, place.locality, place.administrativeArea, place.postalCode, place.country]
          .where((e) => e?.isNotEmpty ?? false)
          .join(', ');

      _pickupController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();
      _pickupController.selection = TextSelection.fromPosition(TextPosition(offset: _pickupController.text.length));
    } catch (e) {
      _showSnack("Failed: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }

  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final body = DeleteAddressModel(id: id);
      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);
      _showSnack("Deleted!");
      ref.invalidate(getAddressProvider);
    } catch (e) {
      _showSnack("Failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Pickup Details", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GooglePlaceAutoCompleteTextField(
              textEditingController: _pickupController,
              focusNode: _focusNode,
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                hintText: "Search pickup location",
                contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.blueAccent)),
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (p) => {if (p.lat != null && p.lng != null) {_lat = p.lat!, _lon = p.lng!}},
              itemClick: (p) {
                _pickupController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {_lat = p.lat!; _lon = p.lng!;}
                _pickupController.selection = TextSelection.fromPosition(TextPosition(offset: _pickupController.text.length));
              },
              itemBuilder: (_, __, p) => ListTile(leading: const Icon(Icons.location_on), title: Text(p.description ?? '')),
              seperatedBuilder: const Divider(height: 1),
              textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
              label: Text(_fetchingCurrent ? "Fetching…" : "Use Current Location"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), foregroundColor: Colors.white, minimumSize: Size(double.infinity, 44.h)),
            ),
            const SizedBox(height: 12),
          /*  ElevatedButton(
              onPressed: _pickupController.text.trim().isEmpty ? null : () {
                widget.pickController.text = _pickupController.text.trim();
                Navigator.pop(context);
              },
              child: Text("Confirm Pickup", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), minimumSize: Size(double.infinity, 48.h)),
            ),*/
            ElevatedButton(
              onPressed: _pickupController.text.trim().isEmpty
                  ? null
                  : () {
                widget.pickController.text = _pickupController.text.trim();

                // NEW: lat/long parent ko bhej do
                if (widget.onLocationPicked != null && _lat.isNotEmpty && _lon.isNotEmpty) {
                  widget.onLocationPicked!(double.parse(_lat), double.parse(_lon));
                }

                Navigator.pop(context);
              },
              child: Text("Confirm Pickup", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), minimumSize: Size(double.infinity, 48.h)),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (_) => Addaddresspage(Datum(), false))); ref.invalidate(getAddressProvider);}, icon: const Icon(Icons.add), label: const Text("Add Address")),
            const SizedBox(height: 30),
            Text("Saved Addresses", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            asyncResp.when(
              data: (model) {
                final addresses = List<Datum>.from(model.data ?? []);
                if (addresses.isEmpty) return const Text("No saved addresses", style: TextStyle(color: Colors.grey));
                return Expanded(
                  child: ListView.separated(
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final addr = addresses[i];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.green),
                        title: Text(addr.name ?? 'Unnamed'),
                        subtitle: Text(addr.type ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => Addaddresspage(addr, true)));
                              ref.invalidate(getAddressProvider);
                            } else if (v == 'delete') {
                              final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text("Delete?"), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red)))]));
                              if (confirm == true) {
                                final removed = addresses.removeAt(i);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Deleted"), action: SnackBarAction(label: "UNDO", onPressed: () {addresses.insert(i, removed); setState(() {});})));
                                try {await deleteAddress(removed.id);} catch (e) {addresses.insert(i, removed); setState(() {});}
                                ref.invalidate(getAddressProvider);
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Edit")])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                       /* onTap: () {
                          _pickupController.text = addr.name ?? '';
                          widget.pickController.text = _pickupController.text.trim();
                          Navigator.pop(context);
                        },*/
                        onTap: () {

                          _pickupController.text = addr.name ?? '';
                          widget.pickController.text = _pickupController.text.trim();

                          // NEW: Saved address se lat/long bhej do

                          if (widget.onLocationPicked != null && addr.lat != null && addr.lon != null) {
                            widget.onLocationPicked!(addr.lat!, addr.lon!);
                          }

                          Navigator.pop(context);

                          },
                      );
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Error: $e", style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}
class DropPage extends ConsumerStatefulWidget {
  final TextEditingController dropController;

  final void Function(double lat, double lng)? onLocationDrop; // ← NEW
  const DropPage({super.key, required this.dropController,
    this.onLocationDrop,
  });
  @override
  ConsumerState<DropPage> createState() => _DropPageState();
}
class _DropPageState extends ConsumerState<DropPage> {
  late final TextEditingController _dropController;
  late final FocusNode _focusNode;
  static const kGoogleApiKey = "AIzaSyC2UYnaHQEwhzvibI-86f8c23zxgDTEX3g";
  String _lat = '', _lon = '';
  bool _fetchingCurrent = false, _isLoading = false;

  @override
  void initState() {
    super.initState();
    _dropController = TextEditingController(text: widget.dropController.text);
    _focusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ref.invalidate(getAddressProvider);
  }

  @override
  void dispose() {
    _dropController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _fetchingCurrent = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return _showSnack("Permission denied");
      }
      if (permission == LocationPermission.deniedForever) return _showSnack("Permission permanently denied");
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return _showSnack("Enable location services");
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
      final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      final place = placemarks.first;
      final address = [place.name, place.street, place.subLocality, place.locality, place.administrativeArea, place.postalCode, place.country]
          .where((e) => e?.isNotEmpty ?? false)
          .join(', ');
      _dropController.text = address;
      _lat = position.latitude.toString();
      _lon = position.longitude.toString();
      _dropController.selection = TextSelection.fromPosition(TextPosition(offset: _dropController.text.length));
    } catch (e) {
      _showSnack("Failed: $e");
    } finally {
      setState(() => _fetchingCurrent = false);
    }
  }


  void _showSnack(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  Future<void> deleteAddress(String? id) async {
    if (id == null || id.isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final body = DeleteAddressModel(id: id);
      final service = APIStateNetwork(callPrettyDio());
      await service.deleteAddress(body);
      _showSnack("Deleted!");
      ref.invalidate(getAddressProvider);
    } catch (e) {
      _showSnack("Failed: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncResp = ref.watch(getAddressProvider);
    return Scaffold(
      appBar: AppBar(title: Text("Drop Details", style: GoogleFonts.poppins(fontSize: 18.sp, fontWeight: FontWeight.w600)), backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GooglePlaceAutoCompleteTextField(
              textEditingController: _dropController,
              focusNode: _focusNode,
              googleAPIKey: kGoogleApiKey,
              inputDecoration: InputDecoration(
                hintText: "Search drop location",
                contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 10.w),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r), borderSide: const BorderSide(color: Colors.blueAccent)),
              ),
              debounceTime: 400,
              isLatLngRequired: true,
              getPlaceDetailWithLatLng: (p) => {if (p.lat != null && p.lng != null) {_lat = p.lat!, _lon = p.lng!}},
              itemClick: (p) {
                _dropController.text = p.description ?? '';
                if (p.lat != null && p.lng != null) {_lat = p.lat!; _lon = p.lng!;}
                _dropController.selection = TextSelection.fromPosition(TextPosition(offset: _dropController.text.length));
              },
              itemBuilder: (_, __, p) => ListTile(leading: const Icon(Icons.location_on), title: Text(p.description ?? '')),
              seperatedBuilder: const Divider(height: 1),
              textStyle: GoogleFonts.poppins(fontSize: 15.sp, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _fetchingCurrent ? null : _useCurrentLocation,
              icon: _fetchingCurrent ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.my_location),
              label: Text(_fetchingCurrent ? "Fetching…" : "Use Current Location"),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), foregroundColor: Colors.white, minimumSize: Size(double.infinity, 44.h)),
            ),
            const SizedBox(height: 12),
           /* ElevatedButton(
              onPressed: () {
                widget.dropController.text = _dropController.text.trim();
                Navigator.pop(context);
              },
              child: Text("Confirm Drop", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), minimumSize: Size(double.infinity, 48.h)),
            ),*/
            ElevatedButton(
              onPressed: () {
                widget.dropController.text = _dropController.text.trim();

                // NEW: lat/long parent ko bhej do (DropPage ke liye)
                if (widget.onLocationDrop != null && _lat.isNotEmpty && _lon.isNotEmpty) {
                  widget.onLocationDrop!(double.parse(_lat), double.parse(_lon));
                }

                Navigator.pop(context);
              },
              child: Text("Confirm Drop", style: GoogleFonts.poppins(fontSize: 16.sp, color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006970), minimumSize: Size(double.infinity, 48.h)),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(onPressed: () async {await Navigator.push(context, MaterialPageRoute(builder: (_) => Addaddresspage(Datum(), false))); ref.invalidate(getAddressProvider);}, icon: const Icon(Icons.add), label: const Text("Add Address")),
            const SizedBox(height: 30),
            Text("Saved Addresses", style: GoogleFonts.poppins(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            asyncResp.when(
              data: (model) {
                final addresses = List<Datum>.from(model.data ?? []);
                if (addresses.isEmpty) return const Text("No saved addresses", style: TextStyle(color: Colors.grey));
                return Expanded(
                  child: ListView.separated(
                    itemCount: addresses.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final addr = addresses[i];
                      return ListTile(
                        leading: const Icon(Icons.location_on, color: Colors.red),
                        title: Text(addr.name ?? 'Unnamed'),
                        subtitle: Text(addr.type ?? ''),
                        trailing: PopupMenuButton<String>(
                          onSelected: (v) async {
                            if (v == 'edit') {
                              await Navigator.push(context, MaterialPageRoute(builder: (_) => Addaddresspage(addr, true)));
                              ref.invalidate(getAddressProvider);
                            } else if (v == 'delete') {
                              final confirm = await showDialog<bool>(context: context, builder: (_) => AlertDialog(title: const Text("Delete?"), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")), TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete", style: TextStyle(color: Colors.red)))]));
                              if (confirm == true) {
                                final removed = addresses.removeAt(i);
                                setState(() {});
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text("Deleted"), action: SnackBarAction(label: "UNDO", onPressed: () {addresses.insert(i, removed); setState(() {});})));
                                try {await deleteAddress(removed.id);} catch (e) {addresses.insert(i, removed); setState(() {});}
                                ref.invalidate(getAddressProvider);
                              }
                            }
                          },
                          itemBuilder: (_) => [
                            const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, color: Colors.blue), SizedBox(width: 8), Text("Edit")])),
                            const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                          ],
                        ),
                        onTap: () {

                          _dropController.text = addr.name ?? '';
                          widget.dropController.text = _dropController.text.trim();
                          if (widget.onLocationDrop != null && addr.lat != null && addr.lon != null) {
                            widget.onLocationDrop!(addr.lat!, addr.lon!);
                          }

                          Navigator.pop(context);

                          },
                      );
                    },
                  ),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (e, _) => Text("Error: $e", style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }
}