/*



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/GetDeliveryByIdResModel2.dart'; // <-- Yeh import karo

class RequestDetailsPage extends StatefulWidget {
  final String deliveryId;
  final IO.Socket? socket; // Optional socket

  const RequestDetailsPage({
    super.key,
    required this.deliveryId,
    this.socket,
  });

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  GetDeliveryByIdResModel2? deliveryData;
  bool isLoadingData = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryData();
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

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (error != null || deliveryData?.data == null) {
      return Scaffold(
        body: Center(child: Text('Error: $error')),
      );
    }

    final data = deliveryData!.data!;
    final pickup = data.pickup;
    final dropoff = data.dropoff;
    final package = data.packageDetails;
    final vehicle = data.vehicleTypeId;
    final customer = data.customer; // Note: Customer object nahi hai abhi model mein, agar hai to use karo

    final phone = "N/A";
    final completedOrders = 0;
    final averageRating = 4.5;

    final packageType = package?.fragile == true ? 'Fragile Package' : 'Standard Package';
    final paymentMethod = data.paymentMethod ?? 'Cash';
    final amount = data.userPayAmount?.toStringAsFixed(0) ?? '0';
    final txId = data.txId ?? 'N/A';

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        leading: Padding(
          padding: EdgeInsets.only(left: 15.w),
          child: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF111111)),
          ),
        ),
        title: Text(
          "Delivery Details",
          style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111111)),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 10.h),


            Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.h,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFA8DADC),
                  ),
                  child: Center(
                    child: Text(
                      // Safe way to get first letter
                          () {
                        final name = data.deliveryBoy?.firstName?.trim();
                        if (name != null && name.isNotEmpty) {
                          return name[0].toUpperCase();
                        }
                        return 'D'; // Default letter
                      }(),
                      style: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF4F4F4F),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        // Full name with fallback
                            () {
                          final first = data.deliveryBoy?.firstName?.trim() ?? '';
                          final last = data.deliveryBoy?.lastName?.trim() ?? '';
                          final fullName = '$first $last'.trim();
                          return fullName.isEmpty ? 'Unknown Driver' : fullName;
                        }(),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      Text(
                        '${data.deliveryBoy?.completedOrderCount ?? 0} Deliveries',
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[600]),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (_) => const Icon(Icons.star, color: Colors.amber, size: 16)),
                          SizedBox(width: 6.w),
                          Text(
                            (data.deliveryBoy?.averageRating ?? 4.5).toStringAsFixed(1),
                            style: GoogleFonts.inter(fontSize: 13.sp),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: SvgPicture.asset(
                    vehicle?.image != null
                        ? "assets/vehicles/${vehicle!.name!.toLowerCase()}.svg"
                        : "assets/SvgImage/bikess.svg",
                    width: 28.w,
                    height: 28.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            // Pickup & Dropoff
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    const Icon(Icons.location_on_outlined, color: Color(0xFFDE4B65), size: 24),
                    SizedBox(height: 8.h),
                    ...List.generate(3, (_) => Padding(padding: EdgeInsets.symmetric(vertical: 4.h), child: const CircleAvatar(radius: 2, backgroundColor: Color(0xFF28B877)))),
                    SizedBox(height: 8.h),
                    const Icon(Icons.circle_outlined, color: Color(0xFF28B877), size: 18),
                  ],
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Pickup Location", style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
                      Text(pickup?.name ?? "Unknown Pickup", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                      SizedBox(height: 20.h),
                      Text("Delivery Location", style: GoogleFonts.inter(fontSize: 12.sp, color: Colors.grey[600])),
                      // Text(dropoff?.name ?? "Unknown Dropoff", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),


                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(
                          data.dropoff?.length ?? 0,
                              (i) => Padding(
                            padding: EdgeInsets.only(bottom: 8.h),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.location_on, size: 18, color: Color(0xFF28B877)),
                                SizedBox(width: 6.w),
                                Expanded(
                                  child: Text(
                                    data.dropoff![i].name ?? "Unknown Dropoff",
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Package & Recipient
            Row(
              children: [
                Expanded(child: buildInfoCard("What you are sending", packageType)),
                SizedBox(width: 20.w),
                Expanded(child: buildInfoCard("Vehicle", vehicle?.name ?? "Truck")),
              ],
            ),

            SizedBox(height: 16.h),
            buildInfoCard("Recipient Contact", phone),
            SizedBox(height: 16.h),

            Row(
              children: [
                Expanded(child: buildInfoCard("Payment Method", paymentMethod)),
                SizedBox(width: 20.w),
                Expanded(child: buildInfoCard("Delivery Fee", "₹$amount")),
              ],
            ),

            SizedBox(height: 16.h),
            buildInfoCard("Transaction ID", txId),

            const Spacer(),

            // Accept Button


            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 12.sp, color: const Color(0xFF77869E))),
        SizedBox(height: 4.h),
        Text(value, style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF111111))),
      ],
    );
  }
}*/


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/GetDeliveryByIdResModel2.dart';

class RequestDetailsPage extends StatefulWidget {
  final String deliveryId;
  final IO.Socket? socket;

  const RequestDetailsPage({
    super.key,
    required this.deliveryId,
    this.socket,
  });

  @override
  State<RequestDetailsPage> createState() => _RequestDetailsPageState();
}

class _RequestDetailsPageState extends State<RequestDetailsPage> {
  GetDeliveryByIdResModel2? deliveryData;
  bool isLoadingData = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchDeliveryData();
  }

  Future<void> _fetchDeliveryData() async {
    try {
      setState(() => isLoadingData = true);
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.getDeliveryById2(widget.deliveryId);

      if (mounted) {
        setState(() {
          deliveryData = response;
          isLoadingData = false;
        });
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

  Widget _fareRow(String label, String value, {Color? valueColor, IconData? icon}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color:  Colors.black87 ?? valueColor),
            SizedBox(width: 10.w),
          ],
          Text(label, style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey.shade700)),
          const Spacer(),
          Text(value,
              style: GoogleFonts.inter(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (error != null || deliveryData?.data == null) {
      return Scaffold(body: Center(child: Text('Error: $error')));
    }

    final d = deliveryData!.data!;
    final driver = d.deliveryBoy;
    final pickup = d.pickup;
    final dropoffs = d.dropoff ?? [];
    final packageType = d.packageDetails?.fragile == true ? 'Fragile Package' : 'Standard\nPackage';

    // Waiting & Charge Details
    final int baseAmount =  d.userPayAmount ?? 0;
    final int extraMins = d.extraWaitingMinutes ?? 0;
    final int extraCharge = d.extraWaitingCharge ?? 0;
    final int freeMins = d.freeWaitingTime ?? 0;
    final int totalAmount = baseAmount + extraCharge;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Order Details", style: GoogleFonts.inter(fontSize: 19.sp, fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Info Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.grey.shade200,
                      child: Text(
                        (driver?.firstName?[0].toUpperCase() ?? 'D'),
                        style: GoogleFonts.inter(fontSize: 28.sp, fontWeight: FontWeight.bold, color: Color(0xFF006970)),
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${driver?.firstName ?? 'Driver'} ${driver?.lastName ?? ''}".trim(),
                            style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.w600),
                          ),
                          Text("${driver?.completedOrderCount ?? 0} deliveries completed",
                              style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade600)),
                          Row(
                            children: [
                              ...List.generate(5, (i) => Icon(
                                Icons.star,
                                size: 16.sp,
                                color: i < (driver?.averageRating ?? 4) ? Colors.amber : Colors.grey.shade300,
                              )),
                              SizedBox(width: 6.w),
                              Text((driver?.averageRating ?? 4.5).toStringAsFixed(1),
                                  style: GoogleFonts.inter(fontSize: 13.sp)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (d.vehicleTypeId?.image != null)
                      SvgPicture.asset("assets/vehicles/${d.vehicleTypeId!.name!.toLowerCase()}.svg", width: 40.w),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Pickup & Dropoff Locations
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(18.w),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Icon(Icons.radio_button_checked, color: Colors.red.shade400, size: 26.sp),
                        ...List.generate(dropoffs.length, (_) => Column(
                          children: [
                            Container(width: 2, height: 44.h, color: Color(0xFF006970)),
                            Icon(Icons.location_on, color: Color(0xFF006970), size: 22.sp),
                          ],
                        )),
                      ],
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _locationTile("Pickup", pickup?.name ?? "Not available"),
                          SizedBox(height: 16.h),
                          ...dropoffs.asMap().entries.map((e) => Padding(
                            padding: EdgeInsets.only(bottom: e.key == dropoffs.length - 1 ? 0 : 12.h),
                            child: _locationTile("Drop ${e.key + 1}", e.value.name ?? "Not available"),
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            // Package & Payment Info
            Row(
              children: [
                Expanded(child: _infoCard("Package Type", packageType, icon: Icons.card_giftcard_outlined)),
                SizedBox(width: 12.w),
                Expanded(child: _infoCard("Payment", d.paymentMethod?.toUpperCase() ?? "CASH", icon: Icons.payment)),
              ],
            ),

            SizedBox(height: 32.h),

            // MAIN FARE BREAKDOWN CARD
            Card(
              elevation: 8,
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Fare Breakdown", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20.h),

                    _fareRow("Base Fare", "₹$baseAmount"),
                    _fareRow("Free Waiting Time", "$freeMins min", icon: Icons.access_time, valueColor: Colors.green.shade600),

                    if (extraMins > 0) ...[
                      _fareRow("Extra Waiting Time", "$extraMins min", icon: Icons.timer, valueColor: Colors.orange),
                      _fareRow("Extra Waiting Charge", "+₹$extraCharge", icon: Icons.add_circle_outline, valueColor: Colors.red.shade600),
                    ] else
                      _fareRow("Extra Waiting", "No extra charge", valueColor: Colors.grey.shade600),

                    Divider(height: 40.h, thickness: 1.8, color: Color(0xFF006970)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Amount Paid", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                        Text("₹$totalAmount",
                            style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Color(0xFF006970))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),
          ],
        ),
      ),
    );
  }

  Widget _locationTile(String title, String address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade600)),
        SizedBox(height: 4.h),
        Text(address, style: GoogleFonts.inter(fontSize: 15.5.sp, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _infoCard(String title, String value, {IconData? icon}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 22.sp, color: Color(0xFF006970)),
          if (icon != null) SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey.shade600)),
              SizedBox(height: 4.h),
              Text(value, style: GoogleFonts.inter(fontSize: 13.sp, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}