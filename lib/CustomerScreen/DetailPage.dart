


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
}