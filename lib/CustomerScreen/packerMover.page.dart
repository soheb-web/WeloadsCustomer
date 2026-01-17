/*
import 'package:delivery_mvp_app/CustomerScreen/checkPriceOrAddItem.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/Model/CreatePickersAndMoverBooking.dart';
import 'LocationaPage.dart';

class PackerMoverPage extends StatefulWidget {
  const PackerMoverPage({super.key});

  @override
  State<PackerMoverPage> createState() => _PackerMoverPageState();
}

class _PackerMoverPageState extends State<PackerMoverPage> {
  int select = 0;
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  bool showPickupClear = false;
  bool showDropClear = false;
  @override
  void initState() {
    super.initState();
    pickupController.addListener(() {
      setState(() {
        showPickupClear = pickupController.text.isNotEmpty;
      });
    });

    dropController.addListener(() {
      setState(() {
        showDropClear = dropController.text.isNotEmpty;
      });
    });
  }
  @override
  void dispose() {
    pickupController.dispose();
    super.dispose();
  }
  void _clearText() {
    pickupController.clear();
  }
  void _submitText() {
    // Do something with text
    print('Submitted: ${pickupController.text}');
  }
  String? selectedDateText;
  void _showToday() {
    DateTime today = DateTime.now();
    setState(() {
      selectedDateText = "${today.day}-${today.month}-${today.year}";
    });
  }
  void _showTomorrow() {
    DateTime tomorrow = DateTime.now().add(const Duration(days: 1));
    setState(() {
      selectedDateText = "${tomorrow.day}-${tomorrow.month}-${tomorrow.year}";
    });
  }
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006970), // header color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF006970), // button color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        selectedDateText = "${picked.day}-${picked.month}-${picked.year}";
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),

      appBar: AppBar(
        backgroundColor: Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: Color(0xFFFFFFFF),
            shape: CircleBorder(),
            onPressed: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "Packer & Mover",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Color(0xFF111111),
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: Color(0xFF006970),
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),

      body:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      buildStepCircle(
                        icon: Icons.location_on,
                        color: Color(0xFF006970),
                      ),
                      buildLine(),
                      buildStepCircle(
                        icon: Icons.add,
                        color: Color(0xFF006970),
                      ),
                      buildLine(),
                      buildStepCircle(
                        icon: Icons.calendar_month,
                        color: Color(0xFF8B8B8B),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Moving Details",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Add Item",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                      letterSpacing: -1,
                    ),
                  ),
                  Text(
                    "Schedule",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            Divider(color: Color(0xFF086E86)),
            SizedBox(height: 20.h),
            Container(
              margin: EdgeInsets.only(left: 15.w, right: 15.w),
              padding: EdgeInsets.only(
                left: 12.w,
                right: 12.w,
                top: 10.h,
                bottom: 10.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6.r),
                color: Color(0xFFF2F2F2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () {
                      setState(() {
                        select = 0;
                      });
                    },
                    child: Container(
                      width: 152.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: select == 0
                            ? Color(0xFF006970)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "Within City",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: select == 0
                                ? Color(0xFFFFFFFF)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        select = 1;
                      });
                    },
                    child: Container(
                      width: 152.w,
                      height: 35.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6.r),
                        color: select == 1
                            ? Color(0xFF006970)
                            : Colors.transparent,
                      ),
                      child: Center(
                        child: Text(
                          "Between City",
                          style: GoogleFonts.inter(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                            color: select == 1
                                ? Color(0xFFFFFFFF)
                                : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
         */
/*   fetchLocation(
              Color(0xFF006970),
              Icons.arrow_upward,
              pickupController,
              "Pickup location",
              showPickupClear,
            ),*//*

            LocationPickerField(
              controller: pickupController,
              label: "Pickup location",
              iconColor: const Color(0xFF006970),
              icon: Icons.arrow_upward,
              showClearButton: showPickupClear,
              onClear: () => setState(() {
                pickupController.clear();
                showPickupClear = false;
              }),
              isPickup: true,
            ),

            ServiceBuild(
              name: "Service lift available at pickup",
              work: "A working service lift will reduce the overall quote",
            ),
*/
/*
            fetchLocation(
              Color(0xFFDC1818),
              Icons.arrow_downward,
              dropController,
              "Drop location",
              showDropClear,
            ),*//*


            LocationPickerField(
              controller: dropController,
              label: "Drop location",
              iconColor: const Color(0xFFDC1818),
              icon: Icons.arrow_downward,
              showClearButton: showDropClear,
              onClear: () => setState(() {
                dropController.clear();
                showDropClear = false;
              }),
              isPickup: false,
            ),

            ServiceBuild(
              name: "Service lift available at drop",
              work: "A working service lift will reduce the overall quote",
            ),

            SizedBox(height: 20.h),
            InkWell(
              onTap: () {
                _pickDate(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 15.w, right: 15.w),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Color(0xFF000000)),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Shifting date",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                        Text(
                          selectedDateText == null
                              ? 'No date selected'
                              : selectedDateText!,
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF000000),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150.w, 35.h),
                    backgroundColor: Color(0xFF006970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      side: BorderSide.none,
                    ),
                  ),
                  onPressed: () {
                    _showToday();
                  },
                  child: Text(
                    "Today",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 20.w),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(150.w, 35.h),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.r),
                      side: BorderSide(color: Color(0xFF006970), width: 1.w),
                    ),
                  ),
                  onPressed: () {
                    _showTomorrow();
                  },
                  child: Text(
                    "Tomorrow",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF006970),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 25.h),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(330.w, 55.h),
                  backgroundColor: Color(0xFF006970),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide.none,
                  ),
                ),
                onPressed: () {




                  onPressed: () {
                    final pickup = Dropoff(
                      location: pickupController.text.trim(),
                      lat: 28.6272,   // ← yahan real lat/long aayega (map se ya API se)
                      long: 77.3726,
                      serviceListAvailable: true,          // ← service lift switch se
                      florNo: 2,                           // ← floor number input se
                    );

                    final drop = Dropoff(
                      location: dropController.text.trim(),
                      lat: 28.6469,
                      long: 77.3691,
                      serviceListAvailable: false,
                      florNo: 4,
                    );

                    ref.read(pickupLocationProvider.notifier).state = pickup;
                    ref.read(dropoffLocationProvider.notifier).state = drop;
                    // products abhi nahi hai → CheckPriceOraddItemPage se aayega

                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => CheckPriceOraddItemPage()),
                    );
                  },


                */
/*  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => CheckPriceOraddItemPage(),
                    ),
                  );*//*

                },
                child: Text(
                  "Check Price",
                  style: GoogleFonts.inter(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20.h),


          ],
        ),
      ),
    );
  }

  Widget fetchLocation(
    Color color,
    IconData icon,
    TextEditingController controller,
    String labelText,
    bool showClear,
  ) {
    return Container(
      margin: EdgeInsets.only(top: 25.h, left: 15.w, right: 15.w),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              controller.clear();
            },
            child: Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
              child: Icon(icon, color: Colors.white, size: 15.sp),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.only(
                  left: 15.w,
                  right: 15.w,
                  top: 10.h,
                  bottom: 10.h,
                ),
                border: InputBorder.none,
                labelText: labelText,
                labelStyle: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          if (showClear)
            InkWell(
              onTap: () {
                controller.clear();
              },
              child: Container(
                width: 24.w,
                height: 24.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey,
                ),
                child: Icon(
                  Icons.clear_sharp,
                  color: Colors.white,
                  size: 15.sp,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ServiceBuild extends StatefulWidget {
  final String name;
  final String work;
  const ServiceBuild({super.key, required this.name, required this.work});

  @override
  State<ServiceBuild> createState() => _ServiceBuildState();
}

class _ServiceBuildState extends State<ServiceBuild> {
  bool isCheck = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15.w, right: 15.w, top: 20.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.name,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                widget.work,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xff000000),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Spacer(),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              activeColor: Colors.blue,
              value: isCheck,
              onChanged: (value) {
                setState(() {
                  isCheck = !isCheck;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class buildStepCircle extends StatelessWidget {
  final IconData icon;
  final Color? color;
  const buildStepCircle({super.key, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30.w,
      height: 30.h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 16.sp),
    );
  }
}

class buildLine extends StatelessWidget {
  const buildLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(height: 1.2.h, color: Color(0xFF086E86)),
    );
  }
}
*/





import 'package:delivery_mvp_app/CustomerScreen/selectPickupSlot.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../data/Model/CreatePickersAndMoverBooking.dart';
import 'LocationaPage.dart'; // LocationPickerField yahan se aa raha hai
import 'NotifierFolder/NotifierPage.dart';
import 'checkPriceOrAddItem.page.dart'; // ya jo bhi next screen hai

class PackerMoverPage extends ConsumerStatefulWidget {
  const PackerMoverPage({super.key});

  @override
  ConsumerState<PackerMoverPage> createState() => _PackerMoverPageState();
}

class _PackerMoverPageState extends ConsumerState<PackerMoverPage> {
  int select = 0; // 0 → Within City, 1 → Between City
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  final pickupFloorController = TextEditingController(text: "0");
  final dropFloorController = TextEditingController(text: "0");
  bool showPickupClear = false;
  bool showDropClear = false;
  String? selectedDateText;
  @override
  void initState() {
    super.initState();
    pickupController.addListener(() {
      setState(() => showPickupClear = pickupController.text.isNotEmpty);
    });
    dropController.addListener(() {
      setState(() => showDropClear = dropController.text.isNotEmpty);
    });
  }
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;
  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    pickupFloorController.dispose();
    dropFloorController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF006970),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: const Color(0xFF006970)),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      setState(() {
        selectedDateText = DateFormat('dd-MM-yyyy').format(picked);
      });
      ref.read(selectedDateProvider.notifier).state = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pickupLift = ref.watch(serviceLiftPickupProvider);
    final dropLift = ref.watch(serviceLiftDropProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFFFF),
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: FloatingActionButton(
            mini: true,
            backgroundColor: const Color(0xFFFFFFFF),
            shape: const CircleBorder(),
            onPressed: () => Navigator.pop(context),
            child: Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: const Icon(Icons.arrow_back_ios, color: Color(0xFF1D3557)),
            ),
          ),
        ),
        title: Padding(
          padding: EdgeInsets.only(left: 20.w),
          child: Text(
            "Packer & Mover",
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF111111),
              letterSpacing: -1,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF006970),
                letterSpacing: -1,
              ),
            ),
          ),
        ],
      ),
      body:
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 25.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40.w),
              child: Row(
                children: [
                  buildStepCircle(icon: Icons.location_on, color: const Color(0xFF006970)),
                  buildLine(),
                  buildStepCircle(icon: Icons.add, color: const Color(0xFF006970)),
                  buildLine(),
                  buildStepCircle(icon: Icons.calendar_month, color: const Color(0xFF8B8B8B)),
                ],
              ),
            ),
            SizedBox(height: 5.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Moving Details", style: labelStyle(color: const Color(0xFF006970))),
                  Text("Add Item", style: labelStyle(color: const Color(0xFF006970))),
                  Text("Schedule", style: labelStyle()),
                ],
              ),
            ),
            SizedBox(height: 12.h),
            const Divider(color: Color(0xFF086E86)),

            // Delivery Type (Within City / Between City)
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Expanded(child: _buildTab(0, "Within City")),
                    SizedBox(width: 12.w),
                    Expanded(child: _buildTab(1, "Between City")),
                  ],
                ),
              ),
            ),

            LocationPickerField(
              controller: pickupController,
              label: "Pickup location",
              iconColor: const Color(0xFF006970),
              icon: Icons.arrow_upward,
              showClearButton: showPickupClear,
              onClear: () {
                pickupController.clear();
                setState(() {
                  showPickupClear = false;
                  _pickupLat = null;
                  _pickupLng = null;
                });
              },
              isPickup: true,
              onLocationPicked: (lat, lng) {
                setState(() {
                  _pickupLat = lat;
                  _pickupLng = lng;
                });
              },
            ),

         /*   ServiceBuild(
              name: "Service lift available at pickup",
              work: "A working service lift will reduce the overall quote",
              value: pickupLift,
              onChanged: (v) => ref.read(serviceLiftPickupProvider.notifier).state = v,
            ),

            _buildFloorInput("Pickup floor number", pickupFloorController),*/

            LocationPickerField(
              controller: dropController,
              label: "Drop location",
              iconColor: const Color(0xFFDC1818),
              icon: Icons.arrow_downward,
              showClearButton: showDropClear,
              onClear: () {
                dropController.clear();
                setState(() { showDropClear = false;
                  _dropLng=null;
                  _dropLng=null;

                });
              },
              isPickup: false,
              onLocationPicked: (lat, lng) {
                setState(() {
                  _dropLat = lat;
                  _dropLng = lng;
                });
              },
            ),


            SizedBox(height: 20.h),

            // Date Picker
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 15.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.black87, size: 22.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Shifting date", style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.black87)),
                          Text(
                            selectedDateText ?? "Select date",
                            style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _quickDateButton("Today", () {
                  final today = DateTime.now();
                  setState(() => selectedDateText = DateFormat('dd-MM-yyyy').format(today));
                  ref.read(selectedDateProvider.notifier).state = today;
                }),
                SizedBox(width: 16.w),
                _quickDateButton("Tomorrow", () {
                  final tomorrow = DateTime.now().add(const Duration(days: 1));
                  setState(() => selectedDateText = DateFormat('dd-MM-yyyy').format(tomorrow));
                  ref.read(selectedDateProvider.notifier).state = tomorrow;
                }),
              ],
            ),

            SizedBox(height: 40.h),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(330.w, 56.h),
                  backgroundColor: const Color(0xFF006970),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                onPressed: _handleCheckPrice,
                child: Text(
                  "Check Price & Continue",
                  style: GoogleFonts.inter(fontSize: 16.sp, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            SizedBox(height: 60.h),
          ],
        ),
      ),
    );
  }

  void _handleCheckPrice() {
    final pickupLoc = pickupController.text.trim();
    final dropLoc = dropController.text.trim();

    if (pickupLoc.isEmpty || dropLoc.isEmpty) {
      Fluttertoast.showToast(msg: "Pickup और Drop location दोनों भरें");
      return;
    }

    final date = ref.read(selectedDateProvider);
    if (date == null) {
      Fluttertoast.showToast(msg: "Shifting date चुनें");
      return;
    }

    // Save delivery type
    ref.read(deliveryTypeProvider.notifier).state = select == 0 ? "within_city" : "between_city";

    // Save pickup & dropoff with real user data
    ref.read(pickupLocationProvider.notifier).state = Dropoff(
      location: pickupLoc,
      lat: _pickupLat,
      long: _pickupLng,
      serviceListAvailable: ref.read(serviceLiftPickupProvider),
      florNo: int.tryParse(pickupFloorController.text) ?? 0,
    );

    ref.read(dropoffLocationProvider.notifier).state = Dropoff(
      location: dropLoc,
      lat: _dropLat,
      long: _dropLng,
      serviceListAvailable: ref.read(serviceLiftDropProvider),
      florNo: int.tryParse(dropFloorController.text) ?? 0,
    );

    // Next screen
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (_) => const CheckPriceOraddItemPage()),
    );

  }

  Widget _buildTab(int index, String label) {
    final selected = select == index;
    return GestureDetector(
      onTap: () => setState(() => select = index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF006970) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              color: selected ? Colors.white : Colors.black87,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloorInput(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: GoogleFonts.inter(fontSize: 14.sp),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        ),
      ),
    );
  }

  Widget _quickDateButton(String text, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: text == "Today" ? const Color(0xFF006970) : Colors.white,
        foregroundColor: text == "Today" ? Colors.white : const Color(0xFF006970),
        side: text == "Today" ? null : const BorderSide(color: Color(0xFF006970)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
      ),
      onPressed: onTap,
      child: Text(text, style: GoogleFonts.inter(fontSize: 14.sp)),
    );
  }

  TextStyle labelStyle({Color? color}) => GoogleFonts.inter(
    fontSize: 14.sp,
    fontWeight: FontWeight.w400,
    color: color ?? const Color(0xFF111111),
    letterSpacing: -0.5,
  );
}

// Progress circle & line widgets (same as before)
Widget buildStepCircle({required IconData icon, required Color color}) {
  return Container(
    width: 30.w,
    height: 30.h,
    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    child: Icon(icon, color: Colors.white, size: 18.sp),
  );
}

Widget buildLine() {
  return Expanded(child: Container(height: 1.5.h, color: const Color(0xFF086E86)));
}

// Service lift switch widget
class ServiceBuild extends StatelessWidget {
  final String name;
  final String work;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ServiceBuild({
    super.key,
    required this.name,
    required this.work,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text(work, style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700])),
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: const Color(0xFF006970),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}