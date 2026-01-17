/*

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'instantDelivery.screen.dart';

class LocationPickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color iconColor;
  final IconData icon;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool isPickup; // true → use PickupPage style, false → DropPage style

  const LocationPickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconColor,
    required this.icon,
    this.showClearButton = false,
    this.onClear,
    this.isPickup = true,
  });

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isPickup
                ? PickupPage(pickController: controller)
                : DropPage(dropController: controller),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.15),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.text.isEmpty ? "Tap to select location" : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showClearButton && controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20.sp, color: Colors.grey),
                onPressed: onClear ?? () => controller.clear(),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}*/


// lib/widgets/location_picker_field.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'instantDelivery.screen.dart';
// import '../DropPage.dart';         // if you still want separate pages

class LocationPickerField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final Color iconColor;
  final IconData icon;
  final bool showClearButton;
  final VoidCallback? onClear;
  final bool isPickup; // true → use PickupPage style, false → DropPage style

  // NEW: Yeh callback se parent screen ko real lat/long milega
  final void Function(double lat, double lng)? onLocationPicked;

  const LocationPickerField({
    super.key,
    required this.controller,
    required this.label,
    required this.iconColor,
    required this.icon,
    this.showClearButton = false,
    this.onClear,
    this.isPickup = true,
    this.onLocationPicked, // ← yeh add kiya
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => isPickup
                ? PickupPage(
              pickController: controller,
              onLocationPicked: onLocationPicked, // ← yahan pass kar rahe hain
            )
                : DropPage(
              dropController: controller,
              onLocationDrop: onLocationPicked, // ← yahan bhi
            ),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withOpacity(0.15),
              ),
              child: Icon(icon, color: iconColor, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    controller.text.isEmpty ? "Tap to select location" : controller.text,
                    style: GoogleFonts.inter(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: controller.text.isEmpty ? Colors.grey : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (showClearButton && controller.text.isNotEmpty)
              IconButton(
                icon: Icon(Icons.clear, size: 20.sp, color: Colors.grey),
                onPressed: onClear ?? () => controller.clear(),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}