import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'Rating/ratingPage.dart';
import 'home.screen.dart';

class CompleteScreen extends StatefulWidget {
  final IO.Socket socket;
  final int freeWaitingTime;
  final int previousAmount;
  final int extraWaitingMinutes;
  final int extraWaitingCharge;
  final String deliveryId;
  final String driverId;
  final String driverName;
  final String driverLastName;
  final String driverImage;

  const CompleteScreen({
    required this.socket,
    required this.freeWaitingTime,
    required this.previousAmount,
    required this.extraWaitingMinutes,
    required this.extraWaitingCharge,
    required this.deliveryId,
    required this.driverId,
    required this.driverName,
    required this.driverLastName,
    required this.driverImage,
    super.key,
  });

  @override
  State<CompleteScreen> createState() => _CompleteScreenState();
}

class _CompleteScreenState extends State<CompleteScreen> {
  // Helper Row
  Widget _fareRow({
    required String label,
    required String value,
    Color valueColor = Colors.black87,
    IconData? icon,
    Color? iconColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20.sp, color: iconColor),
            SizedBox(width: 8.w),
          ],
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.inter(
                fontSize: 17.sp,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int totalWaitingMinutes = widget.freeWaitingTime + widget.extraWaitingMinutes;
    final int totalAmount = widget.previousAmount + widget.extraWaitingCharge;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        // leading: IconButton(
        //   icon: Icon(Icons.close, color: Colors.grey.shade700),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: Text("Ride Completed", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 17.sp)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            SizedBox(height: 20.h),

            Text("Ride Completed!", style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Color(0xFF006970))),
            SizedBox(height: 8.h),
            Text("Thank you for riding with us", style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.grey.shade600)),

            SizedBox(height: 30.h),

            // Driver Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34.r,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.driverImage,
                          fit: BoxFit.cover,
                          width: 68.r,
                          height: 68.r,
                          placeholder: (_, __) => CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (_, __, ___) => Icon(Icons.person, size: 34.r),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Your Driver", style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
                          SizedBox(height: 4.h),
                          Text("${widget.driverName} ${widget.driverLastName}",
                              style: GoogleFonts.inter(fontSize: 19.sp, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    Icon(Icons.thumb_up_alt_rounded, color: Color(0xFF006970), size: 32.sp),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),

            // MAIN FARE CARD – With Total & Chargeable Waiting
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Trip Fare Details", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 20.h),

                    _fareRow(label: "Base Fare", value: "₹${widget.previousAmount}"),

                    _fareRow(
                      label: "Free Waiting Time",
                      value: "${widget.freeWaitingTime} min",
                      valueColor: Colors.green.shade600,
                      icon: Icons.access_time,
                      iconColor: Colors.green.shade600,
                    ),

                    _fareRow(
                      label: "Total Waiting Time",
                      value: "$totalWaitingMinutes min",
                      valueColor: Colors.blue.shade700,
                      icon: Icons.timer,
                      iconColor: Colors.blue.shade700,
                    ),

                    _fareRow(
                      label: "Chargeable Waiting Time",
                      value: "${widget.extraWaitingMinutes} min",
                      valueColor: widget.extraWaitingMinutes > 0 ? Colors.red.shade600 : Colors.grey.shade600,
                      icon: widget.extraWaitingMinutes > 0 ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                      iconColor: widget.extraWaitingMinutes > 0 ? Colors.red.shade600 : Colors.grey.shade500,
                    ),

                    if (widget.extraWaitingMinutes > 0)
                      _fareRow(
                        label: "Extra Waiting Charge",
                        value: "+₹${widget.extraWaitingCharge}",
                        valueColor: Colors.red.shade600,
                        icon: Icons.add_circle_outline,
                        iconColor: Colors.red.shade600,
                      ),

                    Divider(height: 40.h, thickness: 1.8, color: Color(0xFF006970)),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Total Payable Amount", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                        Text("₹$totalAmount",
                            style: GoogleFonts.inter(fontSize: 17.sp, fontWeight: FontWeight.bold, color: Color(0xFF006970))),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 40.h),

            // Rate Button
            SizedBox(
              width: double.infinity,
              height: 45.h,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => GiveRatingScreen(
                    driverId: widget.driverId,
                    driverName: widget.driverName,
                    driverLastName: widget.driverLastName,
                    driverImage: widget.driverImage,
                  )));
                },
                icon: Icon(Icons.star_rounded, size: 20),
                label: Text("Rate Your Ride", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006970),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 8,
                ),
              ),
            ),

SizedBox(height: 20.h,),
          SizedBox(
            width: double.infinity,
            height: 45.h,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => HomeScreen(forceSocketRefresh: true),
                  ),
                      (route) => false,
                );
              },
              // icon: Icon(Icons.star_rounded, size: 20),
              label: Text("Go To Home", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF006970),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                elevation: 8,
              ),
            ),
          ),


            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }
}








