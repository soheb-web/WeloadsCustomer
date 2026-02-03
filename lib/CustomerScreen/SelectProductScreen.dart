/*
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'selectTrip.screen.dart';

class ProductTypeSelectScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final double pickupLat;
  final double pickupLon;
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
  final String pickupLocs;

  const ProductTypeSelectScreen(
      this.socket,
      this.pickupLat,
      this.pickupLon,
      this.dropLats,
      this.dropLons,
      this.dropNames,
      this.pickupLocs, {
        super.key,
      });

  @override
  ConsumerState<ProductTypeSelectScreen> createState() =>
      _ProductTypeSelectScreenState();
}

class _ProductTypeSelectScreenState
    extends ConsumerState<ProductTypeSelectScreen> {

  String? selectedProduct;

  final Color primaryColor = const Color(0xFF0A7C7B);

  final List<String> productTypes = [
    "Documents",
    "Electronics",
    "Groceries",
    "Food",
    "Others",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "What are you sending?",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 📍 PICKUP + DROP CARD
            _locationCard(),

            const SizedBox(height: 22),

            /// 📦 TITLE
            const Text(
              "Select product type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            /// 📦 PRODUCT TYPES
            Expanded(
              child: ListView(
                children: productTypes.map(_productTile).toList(),
              ),
            ),

            /// ➡️ CONTINUE BUTTON
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: selectedProduct == null
                      ? null
                      : () async {
                    if (!mounted) return;

                    await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SelectTripScreen(
                          widget.socket,
                          widget.pickupLat,
                          widget.pickupLon,
                          widget.dropLats,
                          widget.dropLons,
                          widget.dropNames,
                          selectedProduct!,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= LOCATION CARD =================

  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [

          /// 🚀 PICKUP
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: widget.dropNames.isEmpty ? 0 : 36,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pickup Location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.pickupLocs,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_location_alt_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 📍 DROPS
          ...List.generate(widget.dropNames.length, (index) {
            final isLast = index == widget.dropNames.length - 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.dropNames[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= PRODUCT TILE =================

  Widget _productTile(String type) {
    final isSelected = selectedProduct == type;

    return

      InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selectedProduct = type;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 14),
            Text(
              type,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );

  }
}
*/


import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'selectTrip.screen.dart';

class ProductTypeSelectScreen extends ConsumerStatefulWidget {
  final IO.Socket? socket;
  final double pickupLat;
  final double pickupLon;
  final List<double> dropLats;
  final List<double> dropLons;
  final List<String> dropNames;
  final String pickupLocs;

  const ProductTypeSelectScreen(
      this.socket,
      this.pickupLat,
      this.pickupLon,
      this.dropLats,
      this.dropLons,
      this.dropNames,
      this.pickupLocs, {
        super.key,
      });

  @override
  ConsumerState<ProductTypeSelectScreen> createState() =>
      _ProductTypeSelectScreenState();
}

class _ProductTypeSelectScreenState
    extends ConsumerState<ProductTypeSelectScreen> {
  String? selectedProduct;
  final TextEditingController _detailsController = TextEditingController();

  final Color primaryColor = const Color(0xFF0A7C7B);

  final List<String> productTypes = [
    "Documents",
    "Electronics",
    "Groceries",
    "Food",
    "Others",
  ];

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),

      /// 🔹 APP BAR
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        title: const Text(
          "What are you sending?",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: const BackButton(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 📍 PICKUP + DROP CARD
            _locationCard(),

            const SizedBox(height: 22),

            /// 📦 TITLE
            const Text(
              "Select product type",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 14),

            /// 📦 PRODUCT TYPES + CONDITIONAL DETAILS FIELD
            Expanded(
              child: ListView(
                children: [
                  ...productTypes.map((type) => _productTile(type)),

                  // TextField sirf "Others" select hone par dikhega
                  if (selectedProduct == "Others") ...[
                    const SizedBox(height: 16),
                    _detailsTextField(),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),

            /// ➡️ CONTINUE BUTTON
            SafeArea(
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: selectedProduct == null
                      ? null
                      : () async {
                    if (!mounted) return;

                    // "Others" ke case mein details bhi bhej sakte ho
                    final details = selectedProduct == "Others"
                        ? _detailsController.text.trim()
                        : selectedProduct;

                    await Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => SelectTripScreen(
                          widget.socket,
                          widget.pickupLat,
                          widget.pickupLon,
                          widget.dropLats,
                          widget.dropLons,
                          widget.dropNames,
                          details!,
                          // Agar SelectTripScreen mein details parameter banana ho to yahan pass kar dena
                          // details: details,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= DETAILS TEXT FIELD (sirf Others ke liye) =================
  Widget _detailsTextField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryColor.withOpacity(0.4), width: 1.2),
      ),
      child: TextField(
        controller: _detailsController,
        maxLines: 3,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText:
          "Kya bhej rahe ho bhai? (jaise: gift box, 3kg dry fruits, medicines, etc.)",
          hintStyle: TextStyle(color: Colors.grey.shade500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  // ================= LOCATION CARD =================
  Widget _locationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          /// 🚀 PICKUP
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 2,
                    height: widget.dropNames.isEmpty ? 0 : 36,
                    color: Colors.grey.shade300,
                  ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pickup Location",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.pickupLocs,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.edit_location_alt_outlined,
                color: Colors.grey,
                size: 20,
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 📍 DROPS
          ...List.generate(widget.dropNames.length, (index) {
            final isLast = index == widget.dropNames.length - 1;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: 2,
                          height: 32,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      widget.dropNames[index],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ================= PRODUCT TILE =================
  Widget _productTile(String type) {
    final isSelected = selectedProduct == type;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        setState(() {
          selectedProduct = type;

          // Jab "Others" se hat rahe ho to details clear kar do
          if (type != "Others") {
            _detailsController.clear();
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade200,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected ? primaryColor : Colors.grey,
            ),
            const SizedBox(width: 14),
            Text(
              type,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isSelected ? primaryColor : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}











