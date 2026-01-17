import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../config/network/api.state.dart';
import '../../config/utils/pretty.dio.dart';
import '../../data/Model/AllIndiaBodyModel.dart';
import 'LocationaPage.dart';
import 'home.screen.dart';

class AllIndiaParcelBookingScreen extends StatefulWidget {
  const AllIndiaParcelBookingScreen({super.key});

  @override
  State<AllIndiaParcelBookingScreen> createState() => _AllIndiaParcelBookingScreenState();
}

class _AllIndiaParcelBookingScreenState extends State<AllIndiaParcelBookingScreen> {
  // Controllers
  final _pickupController = TextEditingController();
  final _dropController = TextEditingController();
  final _weightController = TextEditingController();

  // Real lat/long storage
  double? _pickupLat;
  double? _pickupLng;
  double? _dropLat;
  double? _dropLng;

  // Other state
  String? _selectedParcelSize;
  String? _weightUnit = "Kg";
  DateTime? _pickupDate;
  TimeOfDay? _pickupTime;
  String? _selectedGoodsType;
  bool _insurance = false;
  List<String> _specialHandling = [];

  bool _showPickupClear = false;
  bool _showDropClear = false;
  bool _isSubmitting = false;

  final List<String> _parcelSizes = ["Small", "Medium", "Large"];
  final List<String> _goodsTypes = ["Electronics", "Furniture", "Food", "Others"];

  bool _fragile = false;
  bool _heavy = false;
  bool _refrigerated = false;

  @override
  void initState() {
    super.initState();
    _pickupController.addListener(() => setState(() => _showPickupClear = _pickupController.text.isNotEmpty));
    _dropController.addListener(() => setState(() => _showDropClear = _dropController.text.isNotEmpty));
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null && mounted) setState(() => _pickupDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null && mounted) setState(() => _pickupTime = picked);
  }

  Future<void> _submitBooking() async {
    if (_selectedParcelSize == null ||
        _weightController.text.trim().isEmpty ||
        _pickupController.text.trim().isEmpty ||
        _dropController.text.trim().isEmpty ||
        _pickupDate == null ||
        _pickupTime == null ||
        _selectedGoodsType == null) {
      Fluttertoast.showToast(msg: "कृपया सभी आवश्यक जानकारी भरें", gravity: ToastGravity.CENTER);
      return;
    }

    setState(() => _isSubmitting = true);

    final weightValue = double.tryParse(_weightController.text.trim()) ?? 0.0;

    final body = AllIndiaBodyModel(
      parcelSize: _selectedParcelSize!.toLowerCase(),
      weight: Weight(value: weightValue.toInt(), unit: _weightUnit!.toLowerCase()),
      goodsType: _selectedGoodsType!.toLowerCase(),
      specialHandling: _specialHandling.isEmpty ? null : _specialHandling,
      insuranceRequired: _insurance,
      pickupSchedule: PickupSchedule(
        serviceDate: _pickupDate,
        pickupTiming: _pickupTime!.format(context),
        dayLabel: DateFormat('EEEE').format(_pickupDate!),
      ),
      pickup: Dropoff(
        location: _pickupController.text.trim(),
        lat: _pickupLat ?? 0.0,
        long: _pickupLng ?? 0.0,
      ),
      dropoff: Dropoff(
        location: _dropController.text.trim(),
        lat: _dropLat ?? 0.0,
        long: _dropLng ?? 0.0,
      ),
    );

    try {
      final api = APIStateNetwork(callPrettyDio());
      final res = await api.allIndiaBooking(body);

      setState(() => _isSubmitting = false);

      if (res == null) {
        Fluttertoast.showToast(msg: "Server se कोई response नहीं मिला", backgroundColor: Colors.red);
        return;
      }

      // Error case
      if (res.code != 0 || res.error == true) {
        final errorMsg = res.message ?? "Booking failed - unknown error";
        Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red, toastLength: Toast.LENGTH_LONG);
        log("Booking failed → Code: ${res.code} | Error: ${res.error} | Msg: $errorMsg");
        return;
      }

      // Success case
      final data = res.data;
      if (data == null || data.txId == null || data.txId!.isEmpty) {
        Fluttertoast.showToast(msg: "Booking successful लेकिन TXID नहीं मिला", backgroundColor: Colors.orange);
        return;
      }

      // Dynamic success message
      final successMsgLines = <String>[
        "Order Placed Successfully!",
        "TXID: ${data.txId}",
      ];

      if (data.status != null && data.status!.isNotEmpty) {
        successMsgLines.add("Status: ${data.status}");
      }

      if (data.amount != null && data.amount != 0) {
        successMsgLines.add("Amount: ₹${data.amount}");
      }

      if (data.createdAt != null) {
        successMsgLines.add("Booked on: ${DateFormat('dd MMM yyyy, hh:mm a').format(data.createdAt!)}");
      }

      final successMsg = successMsgLines.join("\n");

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
          title: Row(
            children: [
              Icon(Icons.local_shipping_rounded, color: Colors.green, size: 32.sp),
              SizedBox(width: 12.w),
              Text("Success!", style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              "आपका ऑर्डर प्लेस हो गया है!\n\nWeloads टीम जल्द ही आपसे संपर्क करेगी order confirm करने के लिए।\n\n$successMsg",
              style: GoogleFonts.inter(fontSize: 15.sp, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                );
              },
              child: Text(
                "OK",
                style: GoogleFonts.inter(fontSize: 16.sp, color: const Color(0xFF006970), fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );

      log("Booking Success → TXID: ${data.txId} | Status: ${data.status} | Created: ${data.createdAt}");

    } catch (e, stack) {
      setState(() => _isSubmitting = false);
      log("All India Booking Exception: $e\n$stack");
      Fluttertoast.showToast(
        msg: "Network error ya server issue - कृपया दोबारा प्रयास करें",
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("All India Parcel", style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardSection(
              title: "Parcel Details",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Parcel Size"),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: _parcelSizes.map((size) {
                      final selected = _selectedParcelSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: selected,
                        onSelected: (_) => setState(() => _selectedParcelSize = size),
                        selectedColor: const Color(0xFF006970),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16.h),
                  _buildLabel("Weight"),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: "Enter weight",
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      DropdownButton<String>(
                        value: _weightUnit,
                        items: ["Kg", "Ton"].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                        onChanged: (v) => setState(() => _weightUnit = v),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            _buildCardSection(
              title: "Locations",
              child: Column(
                children: [
                  LocationPickerField(
                    controller: _pickupController,
                    label: "Pickup Location",
                    iconColor: const Color(0xFF006970),
                    icon: Icons.arrow_upward,
                    showClearButton: _showPickupClear,
                    onClear: () {
                      _pickupController.clear();
                      setState(() {
                        _showPickupClear = false;
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
                  SizedBox(height: 16.h),
                  LocationPickerField(
                    controller: _dropController,
                    label: "Drop Location",
                    iconColor: const Color(0xFFDC1818),
                    icon: Icons.arrow_downward,
                    showClearButton: _showDropClear,
                    onClear: () {
                      _dropController.clear();
                      setState(() {
                        _showDropClear = false;
                        _dropLat = null;
                        _dropLng = null;
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
                ],
              ),
            ),

            SizedBox(height: 20.h),

            _buildCardSection(
              title: "Pickup Schedule",
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF006970)),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _pickupDate != null ? DateFormat('dd MMM yyyy').format(_pickupDate!) : "Select Date",
                                style: GoogleFonts.inter(fontSize: 14.sp),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: _selectTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time, color: Color(0xFF006970)),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _pickupTime != null ? _pickupTime!.format(context) : "Select Time",
                                style: GoogleFonts.inter(fontSize: 14.sp),
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

            SizedBox(height: 20.h),

            _buildCardSection(
              title: "Goods & Handling",
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Type of Goods"),
                  DropdownButtonFormField<String>(
                    value: _selectedGoodsType,
                    hint: const Text("Select type"),
                    items: _goodsTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                    onChanged: (v) => setState(() => _selectedGoodsType = v),
                    decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r))),
                  ),
                  SizedBox(height: 16.h),
                  _buildLabel("Special Handling"),
                  Wrap(
                    spacing: 12.w,
                    runSpacing: 12.h,
                    children: [
                      _buildToggleChip("Fragile", _fragile, (v) => setState(() => _fragile = v)),
                      _buildToggleChip("Heavy", _heavy, (v) => setState(() => _heavy = v)),
                      _buildToggleChip("Refrigerated", _refrigerated, (v) => setState(() => _refrigerated = v)),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Checkbox(value: _insurance, activeColor: const Color(0xFF006970), onChanged: (v) => setState(() => _insurance = v ?? false)),
                      Text("Insurance Required", style: GoogleFonts.inter(fontSize: 14.sp)),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 40.h),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton.icon(
                icon: _isSubmitting
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.local_shipping, color: Colors.white),
                label: Text(_isSubmitting ? "Submitting..." : "Submit Booking", style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006970),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                  elevation: 6,
                ),
                onPressed: _isSubmitting ? null : _submitBooking,
              ),
            ),

            SizedBox(height: 80.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _buildToggleChip(String label, bool selected, ValueChanged<bool> onChanged) {
    return FilterChip(
      label: Text(label, style: GoogleFonts.inter(fontSize: 13.sp)),
      selected: selected,
      onSelected: onChanged,
      selectedColor: const Color(0xFF006970).withOpacity(0.2),
      checkmarkColor: const Color(0xFF006970),
      backgroundColor: Colors.white,
      shape: StadiumBorder(side: BorderSide(color: Colors.grey.shade300)),
    );
  }

  Widget _buildLabel(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600));
  }
}