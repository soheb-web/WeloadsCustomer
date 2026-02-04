import 'dart:developer';

import 'package:delivery_mvp_app/CustomerScreen/packerMover.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../config/network/api.state.dart';
import '../config/utils/pretty.dio.dart';
import '../data/Model/CreatePickersAndMoverBooking.dart';
import '../data/Model/RecommendedModel.dart';
import 'NotifierFolder/NotifierPage.dart'; // ← ye file import zaroori hai

final recommendController = FutureProvider.autoDispose<RecommendedModel>((
  ref,
) async {
  final service = APIStateNetwork(callPrettyDio());
  return await service.recommendedList();
});

class SelectPickupSlotPage extends ConsumerStatefulWidget {
  const SelectPickupSlotPage({super.key});

  @override
  ConsumerState<SelectPickupSlotPage> createState() =>
      _SelectPickupSlotPageState();
}

class _SelectPickupSlotPageState extends ConsumerState<SelectPickupSlotPage> {
  List<DateTime> dates = [];
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    for (int i = 0; i < 90; i++) {
      dates.add(today.add(Duration(days: i)));
    }

    // Agar previous screen se date set hai to usko select kar lo
    final preSelected = ref.read(selectedDateProvider);
    if (preSelected != null) {
      final idx = dates.indexWhere(
        (d) =>
            d.year == preSelected.year &&
            d.month == preSelected.month &&
            d.day == preSelected.day,
      );
      if (idx != -1) selectedIndex = idx;
    } else {
      ref.read(selectedDateProvider.notifier).state = dates[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncAddOns = ref.watch(recommendController);
    final selectedDate =
        ref.watch(selectedDateProvider) ?? dates[selectedIndex];
    final monthYear = DateFormat('MMMM yyyy').format(selectedDate);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF1D3557),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Packer & Mover",
          style: GoogleFonts.inter(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                color: const Color(0xFF006970),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            child: Row(
              children: [
                _stepCircle(Icons.check_circle, const Color(0xFF006970)),
                _progressLine(),
                _stepCircle(Icons.check_circle, const Color(0xFF006970)),
                _progressLine(),
                _stepCircle(Icons.calendar_today, const Color(0xFF006970)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Moving Details", style: _labelStyle(active: true)),
                Text("Add Item", style: _labelStyle(active: true)),
                Text("Schedule", style: _labelStyle(active: true)),
              ],
            ),
          ),
          const Divider(
            color: Color(0xFF006970),
            thickness: 1.2,
            indent: 16,
            endIndent: 16,
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const SizedBox(height: 20),
                    // Text("Select Shifting Date", style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                    // const SizedBox(height: 4),
                    // Text(monthYear, style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey[700])),
                    const SizedBox(height: 16),

                    // SizedBox(
                    //   height: 90.h,
                    //   child: ListView.builder(
                    //     scrollDirection: Axis.horizontal,
                    //     itemCount: dates.length,
                    //     itemBuilder: (context, index) {
                    //       final d = dates[index];
                    //       final selected = selectedIndex == index;
                    //       return GestureDetector(
                    //         onTap: () {
                    //           setState(() => selectedIndex = index);
                    //           ref.read(selectedDateProvider.notifier).state = d;
                    //         },
                    //         child: Container(
                    //           width: 88.w,
                    //           margin: EdgeInsets.only(right: 10.w),
                    //           decoration: BoxDecoration(
                    //             color: selected ? const Color(0xFFE0F7FA) : Colors.white,
                    //             border: Border.all(color: selected ? const Color(0xFF006970) : Colors.grey.shade300),
                    //             borderRadius: BorderRadius.circular(12),
                    //           ),
                    //           child: Column(
                    //             mainAxisAlignment: MainAxisAlignment.center,
                    //             children: [
                    //               Text(DateFormat('dd').format(d), style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold)),
                    //               Text(index == 0 ? "Today" : DateFormat('EEE').format(d), style: GoogleFonts.inter(fontSize: 13.sp)),
                    //               const SizedBox(height: 6),
                    //               Text("₹1,702", style: GoogleFonts.inter(fontSize: 15.sp, color: const Color(0xFF006970))),
                    //             ],
                    //           ),
                    //         ),
                    //       );
                    //     },
                    //   ),
                    // ),
                    const SizedBox(height: 32),

                    Text(
                      "Recommended Add-ons",
                      style: GoogleFonts.inter(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),

                    asyncAddOns.when(
                      data: (model) {
                        final list = model.data ?? [];
                        if (list.isEmpty)
                          return const Text(
                            "No add-ons available",
                            style: TextStyle(color: Colors.grey),
                          );
                        return Column(
                          children: list.map(_buildAddOnCard).toList(),
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (e, st) => Text(
                        "Error loading add-ons: $e",
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom fixed bar
          Container(
            color: const Color(0xFFE8F5F5),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Selected Date",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      DateFormat('dd MMM yyyy').format(selectedDate),
                      style: GoogleFonts.inter(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.access_time,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Select Time Slot",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 14.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => const PickupSlotBottomSheet(),
                    );
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _buildAddOnCard(Datum item) {
    final key = item.key?.toLowerCase() ?? "";
    String desc = "";
    int cover = 0;

    if (key.contains("single")) {
      desc = "Basic single layer protection";
      cover = 20000;
    } else if (key.contains("multi")) {
      desc = "Premium multi-layer packing";
      cover = 50000;
    } else if (key.contains("unpack")) {
      desc = "Unpacking service at destination";
      cover = 15000;
    }

    final currentAddOn = ref.watch(selectedAddOnsProvider);
    final isActive = currentAddOn?.name == item.name;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name ?? "Add-on",
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "₹${item.value ?? '0'}",
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          color: const Color(0xFF006970),
                        ),
                      ),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    if (isActive) {
                      ref.read(selectedAddOnsProvider.notifier).state = null;
                    } else {
                      ref.read(selectedAddOnsProvider.notifier).state = AddOns(
                        name: item.name,
                        description: desc,
                        price: int.tryParse(item.value ?? "0") ?? 0,
                        isSelected: true,
                      );
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isActive ? Colors.green : const Color(0xFF006970),
                    ),
                    backgroundColor: isActive
                        ? Colors.green.withOpacity(0.1)
                        : null,
                  ),
                  child: Text(isActive ? "Remove" : "Add"),
                ),
              ],
            ),
            // if (desc.isNotEmpty) ...[
            //   const SizedBox(height: 8),
            //   Text(
            //     desc,
            //     style: GoogleFonts.inter(
            //       fontSize: 13.sp,
            //       color: Colors.grey[700],
            //     ),
            //   ),
            // ],
            // if (cover > 0) ...[
            //   const SizedBox(height: 8),
            //   Text("Cover up to ₹${NumberFormat.decimalPattern('en_IN').format(cover)}", style: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF006970))),
            // ],
          ],
        ),
      ),
    );
  }

  Widget _stepCircle(IconData icon, Color color) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }

  Widget _progressLine() {
    return Expanded(
      child: Container(height: 2.h, color: const Color(0xFF006970)),
    );
  }

  TextStyle _labelStyle({bool active = false}) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: active ? const Color(0xFF006970) : Colors.grey[700],
  );
}

class PickupSlotBottomSheet extends ConsumerStatefulWidget {
  const PickupSlotBottomSheet({super.key});

  @override
  ConsumerState<PickupSlotBottomSheet> createState() =>
      _PickupSlotBottomSheetState();
}

class _PickupSlotBottomSheetState extends ConsumerState<PickupSlotBottomSheet> {
  int selectedPeriod = 0;
  int? selectedSlotIndex;

  final Map<int, List<String>> periods = {
    0: [
      "8:00 AM - 9:00 AM",
      "9:00 AM - 10:00 AM",
      "10:00 AM - 11:00 AM",
      "11:00 AM - 12:00 PM",
    ],
    1: [
      "12:00 PM - 1:00 PM",
      "1:00 PM - 2:00 PM",
      "2:00 PM - 3:00 PM",
      "3:00 PM - 4:00 PM",
    ],
    2: [
      "4:00 PM - 5:00 PM",
      "5:00 PM - 6:00 PM",
      "6:00 PM - 7:00 PM",
      "7:00 PM - 8:00 PM",
    ],
  };

  @override
  Widget build(BuildContext context) {
    final date = ref.watch(selectedDateProvider);
    final times = periods[selectedPeriod] ?? [];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 5.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              "Choose Pickup Time",
              style: GoogleFonts.inter(
                fontSize: 19.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              date != null
                  ? DateFormat('EEEE, dd MMM yyyy').format(date)
                  : "Date not selected",
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                color: const Color(0xFF006970),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _periodButton(0, Icons.wb_sunny_outlined, "Morning"),
              _periodButton(1, Icons.cloud_outlined, "Afternoon"),
              _periodButton(2, Icons.nights_stay_outlined, "Evening"),
            ],
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: times.length,
              itemBuilder: (context, i) {
                final t = times[i];
                final active = selectedSlotIndex == i;
                return GestureDetector(
                  onTap: () => setState(() => selectedSlotIndex = i),
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: active ? const Color(0xFFE0F7FA) : Colors.white,
                      border: Border.all(
                        color: active
                            ? const Color(0xFF006970)
                            : Colors.grey.shade300,
                        width: active ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(t, style: GoogleFonts.inter(fontSize: 15.sp)),
                        const Spacer(),
                        Icon(
                          active ? Icons.check_circle : Icons.circle_outlined,
                          color: active ? const Color(0xFF006970) : Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006970),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: selectedSlotIndex == null
                ? null
                : () async {
                    final time = periods[selectedPeriod]![selectedSlotIndex!];
                    ref.read(selectedTimeProvider.notifier).state = time;

                    await _performBooking();

                    Navigator.pop(context);
                    // Navigator.push(context, MaterialPageRoute(builder: (context)=>PackerMoverPage()));

                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PackerMoverPage(),
                      ),
                      (route) =>
                          route.isFirst, // sab purane screens remove kar do
                    );
                  },
            child: Text(
              "Confirm & Create Booking",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 40.h),
        ],
      ),
    );
  }

  Widget _periodButton(int idx, IconData icon, String text) {
    final active = selectedPeriod == idx;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPeriod = idx;
          selectedSlotIndex = null;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFE0F7FA) : Colors.white,
          border: Border.all(
            color: active ? const Color(0xFF006970) : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF006970), size: 28.sp),
            const SizedBox(height: 6),
            Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Future<void> _performBooking() async {
  //   final refRead = ProviderScope.containerOf(context, listen: false);
  //
  //   final deliveryType = refRead.read(deliveryTypeProvider);
  //   final pickupLoc = refRead.read(pickupLocationProvider);
  //   final dropLoc = refRead.read(dropoffLocationProvider);
  //   final products = refRead.read(selectedProductsProvider);
  //   final date = refRead.read(selectedDateProvider);
  //   final time = refRead.read(selectedTimeProvider);
  //   final addOn = refRead.read(selectedAddOnsProvider);
  //   final amt = refRead.read(totalAmountProvider);
  //
  //   if ([pickupLoc, dropLoc, date, time].any((e) => e == null) || products.isEmpty) {
  //     Fluttertoast.showToast(msg: "कुछ जानकारी छूट गई है", gravity: ToastGravity.CENTER);
  //     return;
  //   }
  //
  //   final booking = CreatePickersAndMoverBooking(
  //     delivery: deliveryType,
  //     pickup: pickupLoc,
  //     dropoff: dropLoc,
  //     product: products,
  //     schedule: Schedule(
  //       serviceDate: date,
  //       pickupTiming: time,
  //       dayLabel: DateFormat('EEEE').format(date!),
  //     ),
  //     addOns: addOn,
  //     amount: amt > 0 ? amt : 2500, // fallback value
  //     paymentMethod: "cash",
  //   );
  //
  //   try {
  //     final api = APIStateNetwork(callPrettyDio());
  //     final res = await api.createPickersAndMoverBooking(booking);
  //
  //     if (res.code == 0) {
  //       final tx = res.data?.txId?.toString() ?? "";
  //       if (tx.isEmpty) {
  //         Fluttertoast.showToast(msg: "Booking failed - no transaction ID");
  //         return;
  //       }
  //       Fluttertoast.showToast(msg: "Booking Successful!\nTXID: $tx", toastLength: Toast.LENGTH_LONG);
  //       // yahan success page pe ja sakte ho
  //     }
  //
  //     else {
  //       Fluttertoast.showToast(msg: res.message ?? "Booking failed", toastLength: Toast.LENGTH_LONG);
  //     }
  //   } catch (e, stack) {
  //     log("Booking failed: $e\n$stack");
  //     Fluttertoast.showToast(msg: "Network error - please try again", toastLength: Toast.LENGTH_LONG);
  //   }
  // }

  Future<void> _performBooking() async {
    final refRead = ProviderScope.containerOf(context, listen: false);

    final deliveryType = refRead.read(deliveryTypeProvider);
    final pickupLoc = refRead.read(pickupLocationProvider);
    final dropLoc = refRead.read(dropoffLocationProvider);
    final products = refRead.read(selectedProductsProvider);
    final date = refRead.read(selectedDateProvider);
    final time = refRead.read(selectedTimeProvider);
    final addOn = refRead.read(selectedAddOnsProvider);
    final amt = refRead.read(totalAmountProvider);

    // Basic validation
    if ([pickupLoc, dropLoc, date, time].any((e) => e == null) ||
        products.isEmpty) {
      Fluttertoast.showToast(
        msg: "कुछ जानकारी छूट गई है",
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    final booking = CreatePickersAndMoverBooking(
      delivery: deliveryType,
      pickup: pickupLoc,
      dropoff: dropLoc,
      product: products,
      schedule: Schedule(
        serviceDate: date,
        pickupTiming: time,
        dayLabel: DateFormat('EEEE').format(date!),
      ),
      addOns: addOn,
      amount: 0,
      paymentMethod: "cash",
    );

    try {
      final api = APIStateNetwork(callPrettyDio());
      final res = await api.createPickersAndMoverBooking(booking);

      // ────────────────────────────────────────────────
      // Response ko properly handle kar rahe hain
      // ────────────────────────────────────────────────

      if (res == null) {
        Fluttertoast.showToast(
          msg: "Server se कोई response नहीं मिला",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
        );
        return;
      }

      // Error case - code != 0 ya error == true
      if (res.code != 0 || res.error == true) {
        final errorMsg = res.message ?? "Booking failed - unknown error";
        Fluttertoast.showToast(
          msg: errorMsg,
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.red,
          gravity: ToastGravity.CENTER,
        );
        log(
          "Booking failed → Code: ${res.code} | Error: ${res.error} | Msg: $errorMsg",
        );
        return;
      }

      // Success case - code == 0 aur error != true
      final data = res.data;
      if (data == null || data.txId == null || data.txId!.isEmpty) {
        Fluttertoast.showToast(
          msg: "Booking successful लेकिन transaction ID नहीं मिला",
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange,
        );
        return;
      }

      // Final success message with useful info
      final successMsg = [
        "Booking Successful!",
        "TXID: ${data.txId}",
        if (data.status != null) "Status: ${data.status}",
        if (data.amount != null) "Amount: ₹${data.amount}",
        "Date: ${DateFormat('dd MMM yyyy').format(DateTime.fromMillisecondsSinceEpoch(data.createdAt ?? 0))}",
      ].join("\n");

      Fluttertoast.showToast(
        msg: successMsg,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );

      log(
        "Booking Success → TXID: ${data.txId} | Status: ${data.status} | Amount: ${data.amount}",
      );

      // Optional: yahan success screen pe navigate kar sakte ho
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => BookingSuccessScreen(txId: data.txId!)));
    } catch (e, stack) {
      log("Booking Exception: $e\n$stack");
      Fluttertoast.showToast(
        msg: "Network error ya server issue - कृपया दोबारा प्रयास करें",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }
}
