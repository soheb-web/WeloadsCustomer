import 'package:cached_network_image/cached_network_image.dart';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/network/api.state.dart';
import '../../config/utils/pretty.dio.dart';
import '../../data/Model/SubmitRatingModel.dart';

class GiveRatingScreen extends StatefulWidget {
  final String driverId;
  final String driverName;
  final String driverLastName;
  final String driverImage;
  const GiveRatingScreen({
    super.key,
    required this.driverId,
    required this.driverName,
    required this.driverLastName,
    required this.driverImage

  });

  @override
  State<GiveRatingScreen> createState() => _GiveRatingScreenState();
}

class _GiveRatingScreenState extends State<GiveRatingScreen> {
  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  bool isLoading = false;

  final List<String> emojis = ['Poor', 'Fair', 'Good', 'Great', 'Excellent'];
  final List<Color> starColors = [
    Colors.red.shade400,
    Colors.orange.shade400,
    Colors.yellow.shade600,
    Colors.lightGreen,
    Colors.green,
  ];

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }





  void submitRating() async {
    if (selectedRating == 0) {
      Fluttertoast.showToast(msg: "Please ask user to select a rating");
      return;
    }

    setState(() => isLoading = true);

    final request = SubmitRatingRequest(
      driverId: widget.driverId,
      rating: selectedRating,
      comment: commentController.text.trim().isEmpty
          ? "No comment"
          : commentController.text.trim(),
    );

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.reviewRating(request);

      Fluttertoast.showToast(
        msg: response.message,
        backgroundColor: response.error ? Colors.red : Colors.green,
        textColor: Colors.white,
      );

      if (!response.error) {
        await Future.delayed(const Duration(milliseconds: 600));

        if (!mounted) return;

        // SAFE + CLEAN: पुराना stack हटाओ, नया HomeScreen डालो
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => HomeScreen(forceSocketRefresh: true),
            ),
                (route) => false,
          );
        });
      }
    } catch (e) {
      // log("Rating submit error: $e");
      Fluttertoast.showToast(
        msg: "Failed! Check internet.",
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Text(
          "Rate Your Ride",
          style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 16.sp),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Driver Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    // CircleAvatar(
                    //   radius: 40.r,
                    //   backgroundColor: Colors.orange.shade100,
                    //   child: Icon(Icons.person, size: 50, color: Color(0xFF006970)),
                    // ),
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: Colors.grey.shade200,
                      child: ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: widget.driverImage,
                          fit: BoxFit.cover,
                          width: 60.r,
                          height: 60.r,
                          placeholder: (context, url) => CircularProgressIndicator(strokeWidth: 2),
                          errorWidget: (context, url, error) => Icon(Icons.person, size: 30.r, color: Colors.grey),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text("How was your ride?", style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 8.h),
                    Text("Driver Name: ${widget.driverName} ${widget.driverLastName}", style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30.h),
            Text("Tap to rate", style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700)),
            SizedBox(height: 16.h),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                final isSelected = i < selectedRating;
                return GestureDetector(
                  onTap: () => setState(() => selectedRating = i + 1),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    margin: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      children: [
                        Text(emojis[i], style: TextStyle(fontSize: 12.sp)),
                        SizedBox(height: 8.h),
                        Icon(
                          isSelected ? Icons.star : Icons.star_border,
                          size: 35.sp,
                          color: isSelected ? starColors[i] : Colors.grey.shade300,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),

            if (selectedRating > 0) ...[
              SizedBox(height: 12.h),
              Text(emojis[selectedRating - 1],
                  style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: starColors[selectedRating - 1])),
            ],

            SizedBox(height: 30.h),

            // Comment
            TextField(
              controller: commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Share your experience (optional)",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Color(0xFF006970), width: 2)),
                contentPadding: EdgeInsets.all(16.w),
              ),
            ),

            SizedBox(height: 30.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : submitRating,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF006970),
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  elevation: 3,
                ),
                child: isLoading
                    ? SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
                    : Text(
                  "Submit Review",
                  style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }
}