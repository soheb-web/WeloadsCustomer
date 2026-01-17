/*
import 'package:delivery_mvp_app/CustomerScreen/selectPickupSlot.page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/Model/PackerCategoryAndSubcategoryModel.dart';
import '../data/controller/getProfileController.dart';



class CheckPriceOraddItemPage extends ConsumerStatefulWidget {
  const CheckPriceOraddItemPage({super.key});
  @override
  ConsumerState<CheckPriceOraddItemPage> createState() => _CheckPriceOraddItemPageState();
}

class _CheckPriceOraddItemPageState extends ConsumerState<CheckPriceOraddItemPage> {
  int selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  void _scrollToSection(String categoryName) {
    final key = _sectionKeys[categoryName];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(getPackersCategoryController);

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

      body: Column(
        children: [

           SizedBox(height: 25.h),
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Row(
              children: [
                buildStepCircle(icon: Icons.done, color: const Color(0xFF006970)),
                buildLine(),
                buildStepCircle(icon: Icons.shopping_bag, color: const Color(0xFF006970)),
                buildLine(),
                buildStepCircle(icon: Icons.calendar_month, color: const Color(0xFF8B8B8B)),
              ],
            ),
          ),
           SizedBox(height: 5.h),
           Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Moving Details", style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF006970))),
                Text("Add Item",     style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF006970))),
                Text("Schedule",     style: GoogleFonts.inter(fontSize: 12.sp)),
              ],
            ),
          ),
           SizedBox(height: 12.h),
           const Divider(color: Color(0xFF086E86)),
           Expanded(
             child: asyncData.when(
               data: (model) {
                 final categories = model.data?.category ?? [];
                  final subCategoryGroups = model.data?.subCategory ?? [];

                    if (categories.isEmpty) {
                       return const Center(child: Text("No categories found"));
                       }

                // Make sure keys exist
                for (final cat in categories) {
                  final name = cat.name ?? "Unknown";
                  _sectionKeys.putIfAbsent(name, () => GlobalKey());
                }

                final selectedCategoryName = categories[selectedTabIndex.clamp(0, categories.length - 1)].name ?? "";

                return Column(
                  children: [

                    SizedBox(height: 20.h),

                    // ── Horizontal category tabs ────────────────────────
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.w),
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(categories.length, (i) {
                            final cat = categories[i];
                            final name = cat.name ?? "Unknown";
                            final selected = i == selectedTabIndex;

                            return Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4.w),
                              child: InkWell(
                                onTap: () {
                                  setState(() => selectedTabIndex = i);
                                  _scrollToSection(name);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: selected ? const Color(0xFF006970) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(5.r),
                                  ),
                                  child: Text(
                                    name,
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      color: selected ? Colors.white : Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Search field (you can make it functional later)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 15.w),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search items...",
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF006970)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                            borderSide: const BorderSide(color: Color(0xFF006970)),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // ── Scrollable sections ─────────────────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Column(
                            children: categories.map((cat) {
                              final name = cat.name ?? "Unknown";
                              final group = subCategoryGroups.firstWhere(
                                    (g) => g.name == name,
                                orElse: () => DataSubCategory(name: name, subCategories: []),
                              );

                              return ItemCategorySection(
                                key: _sectionKeys[name],
                                categoryName: name,
                                subCategories: group.subCategories ?? [],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),

                  ],
                );
              },

              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stk) => Center(child: Text("Error: $err")),
            ),
          ),
          // ── Bottom bar (placeholder – add real count later) ────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "No items selected",
                  style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w500),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(130.w, 40.h),
                    backgroundColor: const Color(0xFF006970),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.r)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const SelectPickupSlotPage()),
                    );
                  },
                  child: Text(
                    "Check Price",
                    style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  // You can keep your helper methods
  Widget buildStepCircle({required IconData icon, required Color color}) {
    return CircleAvatar(
      radius: 12.r,
      backgroundColor: color,
      child: Icon(icon, size: 16.sp, color: Colors.white),
    );
  }
  Widget buildLine() => Expanded(
    child: Container(
      height: 2.h,
      color: const Color(0xFF006970),
      margin: EdgeInsets.symmetric(horizontal: 8.w),
    ),
  );
}

class ItemCategorySection extends StatelessWidget {
  final String categoryName;
  final List<SubCategorySubCategory> subCategories;

  const ItemCategorySection({
    super.key,
    required this.categoryName,
    required this.subCategories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Container(
        padding: EdgeInsets.all(14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.black.withOpacity(0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              categoryName,
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            const Divider(),

            if (subCategories.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    "No items available",
                    style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13.sp),
                  ),
                ),
              )
            else
              ...subCategories.map((sub) => _buildExpansionTile(sub,context)),
          ],
        ),
      ),
    );
  }

  Widget _buildExpansionTile(SubCategorySubCategory sub, BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        leading: const Icon(Icons.chair_alt_outlined, color: Color(0xFF006970)),
        title: Text(
          sub.name ?? "Unnamed",
          style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (sub.innerCategory ?? []).map((itemName) {
                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF006970)),
                  title: Text(
                    itemName,
                    style: GoogleFonts.inter(fontSize: 13.sp),
                  ),
                  trailing: const Icon(Icons.add, size: 20, color: Color(0xFF006970)),
                  onTap: () {
                    // TODO: Add to selection / cart
                    // Example: ScaffoldMessenger.of(context).showSnackBar(...)
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}*/

//
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:google_fonts/google_fonts.dart';
//
// import '../data/Model/CreatePickersAndMoverBooking.dart'; // Product model yahan se
// import '../data/Model/PackerCategoryAndSubcategoryModel.dart';
// import '../data/controller/getProfileController.dart';
// import 'NotifierFolder/NotifierPage.dart';
// import 'selectPickupSlot.page.dart';
//
// class CheckPriceOraddItemPage extends ConsumerStatefulWidget {
//   const CheckPriceOraddItemPage({super.key});
//
//   @override
//   ConsumerState<CheckPriceOraddItemPage> createState() => _CheckPriceOraddItemPageState();
// }
//
// class _CheckPriceOraddItemPageState extends ConsumerState<CheckPriceOraddItemPage> {
//   int selectedTabIndex = 0;
//   final ScrollController _scrollController = ScrollController();
//   final Map<String, GlobalKey> _sectionKeys = {};
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _scrollToSection(String categoryName) {
//     final key = _sectionKeys[categoryName];
//     if (key?.currentContext != null) {
//       Scrollable.ensureVisible(
//         key!.currentContext!,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final asyncData = ref.watch(getPackersCategoryController);
//     final selectedProducts = ref.watch(selectedProductsProvider);
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D3557)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: Text(
//           "Add Items",
//           style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {},
//             child: Text(
//               "FAQs",
//               style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF006970)),
//             ),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//             child: Row(
//               children: [
//                 _buildStepCircle(Icons.check_circle, const Color(0xFF006970)),
//                 _buildProgressLine(),
//                 _buildStepCircle(Icons.shopping_bag, const Color(0xFF006970)),
//                 _buildProgressLine(),
//                 _buildStepCircle(Icons.calendar_today, const Color(0xFF8B8B8B)),
//               ],
//             ),
//           ),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 24.w),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text("Moving Details", style: _stepLabel(active: true)),
//                 Text("Add Item", style: _stepLabel(active: true)),
//                 Text("Schedule", style: _stepLabel(active: false)),
//               ],
//             ),
//           ),
//           const Divider(color: Color(0xFF006970), thickness: 1.2, indent: 16, endIndent: 16),
//
//           Expanded(
//             child: asyncData.when(
//               data: (model) {
//                 final categories = model.data?.category ?? [];
//                 final subCategoryGroups = model.data?.subCategory ?? [];
//
//                 if (categories.isEmpty) {
//                   return const Center(child: Text("No categories available", style: TextStyle(color: Colors.grey)));
//                 }
//
//                 // Initialize section keys
//                 for (final cat in categories) {
//                   final name = cat.name ?? "Unknown";
//                   _sectionKeys.putIfAbsent(name, () => GlobalKey());
//                 }
//
//                 return Column(
//                   children: [
//                     const SizedBox(height: 16),
//
//                     // Horizontal category tabs
//                     SizedBox(
//                       height: 48.h,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         itemCount: categories.length,
//                         itemBuilder: (context, i) {
//                           final cat = categories[i];
//                           final selected = i == selectedTabIndex;
//                           return Padding(
//                             padding: EdgeInsets.only(right: 8.w),
//                             child: GestureDetector(
//                               onTap: () {
//                                 setState(() => selectedTabIndex = i);
//                                 _scrollToSection(cat.name ?? "Unknown");
//                               },
//                               child: Chip(
//                                 label: Text(
//                                   cat.name ?? "Category",
//                                   style: GoogleFonts.inter(
//                                     fontSize: 13.sp,
//                                     color: selected ? Colors.white : Colors.black87,
//                                   ),
//                                 ),
//                                 backgroundColor: selected ? const Color(0xFF006970) : Colors.grey.shade200,
//                                 padding: EdgeInsets.symmetric(horizontal: 16.w),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Search bar
//                     Padding(
//                       padding: EdgeInsets.symmetric(horizontal: 16.w),
//                       child: TextField(
//                         decoration: InputDecoration(
//                           hintText: "Search items (e.g. Sofa, Bed)",
//                           prefixIcon: const Icon(Icons.search, color: Color(0xFF006970)),
//                           filled: true,
//                           fillColor: Colors.grey.shade100,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                             borderSide: BorderSide.none,
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 16),
//
//                     // Category sections
//                     Expanded(
//                       child: ListView.builder(
//                         controller: _scrollController,
//                         padding: EdgeInsets.symmetric(horizontal: 16.w),
//                         itemCount: categories.length,
//                         itemBuilder: (context, i) {
//                           final cat = categories[i];
//                           final name = cat.name ?? "Unknown";
//                           final subGroup = subCategoryGroups.firstWhere(
//                                 (g) => g.name == name,
//                             orElse: () => DataSubCategory(name: name, subCategories: []),
//                           );
//
//                           return ItemCategorySection(
//                             key: _sectionKeys[name],
//                             categoryName: name,
//                             subCategories: subGroup.subCategories ?? [],
//                             onItemAdded: (itemName) {
//                               // Add item to selected products
//                               final current = ref.read(selectedProductsProvider);
//                               final existing = current.firstWhere(
//                                     (p) => p.item == itemName,
//                                 orElse: () => Product(item: itemName, quantity: 0),
//                               );
//
//                               final updated = List<Product>.from(current);
//                               if (existing.quantity == 0) {
//                                 updated.add(Product(item: itemName, quantity: 1));
//                               } else {
//                                 final idx = updated.indexWhere((p) => p.item == itemName);
//                                 updated[idx] = Product(item: itemName, quantity: existing.quantity! + 1);
//                               }
//
//                               ref.read(selectedProductsProvider.notifier).state = updated;
//                               Fluttertoast.showToast(msg: "$itemName added");
//                             },
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 );
//               },
//               loading: () => const Center(child: CircularProgressIndicator()),
//               error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
//             ),
//           ),
//
//           // Bottom bar with selected count
//           Container(
//             padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4))],
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "${selectedProducts.fold<int>(0, (sum, p) => sum + (p.quantity ?? 0))} items selected",
//                       style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600),
//                     ),
//                     if (selectedProducts.isNotEmpty)
//                       Text(
//                         "Total items: ${selectedProducts.length}",
//                         style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700]),
//                       ),
//                   ],
//                 ),
//                 ElevatedButton.icon(
//                   icon: const Icon(Icons.arrow_forward, size: 18),
//                   label: Text("Proceed", style: GoogleFonts.inter(fontSize: 14.sp, fontWeight: FontWeight.w600)),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: selectedProducts.isEmpty ? Colors.grey : const Color(0xFF006970),
//                     padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                   ),
//                   onPressed: selectedProducts.isEmpty
//                       ? null
//                       : () {
//                     Navigator.push(
//                       context,
//                       CupertinoPageRoute(builder: (_) => const SelectPickupSlotPage()),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStepCircle(IconData icon, Color color) {
//     return Container(
//       width: 32.w,
//       height: 32.h,
//       decoration: BoxDecoration(shape: BoxShape.circle, color: color),
//       child: Icon(icon, color: Colors.white, size: 20.sp),
//     );
//   }
//
//   Widget _buildProgressLine() {
//     return Expanded(child: Container(height: 2.h, color: const Color(0xFF006970)));
//   }
//
//   TextStyle _stepLabel({bool active = false}) => GoogleFonts.inter(
//     fontSize: 13.sp,
//     fontWeight: FontWeight.w500,
//     color: active ? const Color(0xFF006970) : Colors.grey[700],
//   );
// }
//
// class ItemCategorySection extends StatelessWidget {
//   final String categoryName;
//   final List<SubCategorySubCategory> subCategories;
//   final Function(String) onItemAdded;
//
//   const ItemCategorySection({
//     super.key,
//     required this.categoryName,
//     required this.subCategories,
//     required this.onItemAdded,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.only(bottom: 24.h),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             categoryName,
//             style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black87),
//           ),
//           const SizedBox(height: 12),
//           if (subCategories.isEmpty)
//             const Padding(
//               padding: EdgeInsets.all(24),
//               child: Center(child: Text("No items in this category", style: TextStyle(color: Colors.grey))),
//             )
//           else
//             ...subCategories.map((sub) => _buildSubCategory(sub)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSubCategory(SubCategorySubCategory sub) {
//     final items = sub.innerCategory ?? [];
//     return Card(
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       elevation: 1,
//       child: ExpansionTile(
//         title: Text(
//           sub.name ?? "Items",
//           style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600),
//         ),
//         leading: const Icon(Icons.category_outlined, color: Color(0xFF006970)),
//         childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
//         children: items.map((itemName) {
//           return ListTile(
//             dense: true,
//             leading: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF006970)),
//             title: Text(itemName, style: GoogleFonts.inter(fontSize: 14.sp)),
//             trailing: IconButton(
//               icon: const Icon(Icons.add_box_rounded, color: Color(0xFF006970)),
//               onPressed: () {
//                 onItemAdded(itemName);
//               },
//             ),
//           );
//         }).toList(),
//       ),
//     );
//   }
// }



import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/Model/CreatePickersAndMoverBooking.dart';
import '../data/Model/PackerCategoryAndSubcategoryModel.dart';
import '../data/controller/getProfileController.dart';
import 'NotifierFolder/NotifierPage.dart';
import 'selectPickupSlot.page.dart';

class CheckPriceOraddItemPage extends ConsumerStatefulWidget {
  const CheckPriceOraddItemPage({super.key});

  @override
  ConsumerState<CheckPriceOraddItemPage> createState() => _CheckPriceOraddItemPageState();
}

class _CheckPriceOraddItemPageState extends ConsumerState<CheckPriceOraddItemPage> {
  int selectedTabIndex = 0;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _sectionKeys = {};

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSection(String categoryName) {
    final key = _sectionKeys[categoryName];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final asyncData = ref.watch(getPackersCategoryController);
    final selectedProducts = ref.watch(selectedProductsProvider);

    final totalQuantity = selectedProducts.fold<int>(0, (sum, p) => sum + (p.quantity ?? 0));
    final totalItems = selectedProducts.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1D3557)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Add Items",
          style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(
              "FAQs",
              style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF006970)),
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
                _buildStepCircle(Icons.check_circle, const Color(0xFF006970)),
                _buildProgressLine(),
                _buildStepCircle(Icons.shopping_bag, const Color(0xFF006970)),
                _buildProgressLine(),
                _buildStepCircle(Icons.calendar_today, const Color(0xFF8B8B8B)),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Moving Details", style: _stepLabel(active: true)),
                Text("Add Item", style: _stepLabel(active: true)),
                Text("Schedule", style: _stepLabel(active: false)),
              ],
            ),
          ),
          const Divider(color: Color(0xFF006970), thickness: 1.2, indent: 16, endIndent: 16),

          Expanded(
            child: asyncData.when(
              data: (model) {
                final categories = model.data?.category ?? [];
                final subCategoryGroups = model.data?.subCategory ?? [];

                if (categories.isEmpty) {
                  return const Center(child: Text("No categories available", style: TextStyle(color: Colors.grey)));
                }

                // Initialize section keys
                for (final cat in categories) {
                  final name = cat.name ?? "Unknown";
                  _sectionKeys.putIfAbsent(name, () => GlobalKey());
                }

                return Column(
                  children: [
                    const SizedBox(height: 16),

                    // Category tabs
                    SizedBox(
                      height: 48.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: categories.length,
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final selected = i == selectedTabIndex;
                          return Padding(
                            padding: EdgeInsets.only(right: 8.w),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => selectedTabIndex = i);
                                _scrollToSection(cat.name ?? "Unknown");
                              },
                              child: Chip(
                                label: Text(
                                  cat.name ?? "Category",
                                  style: GoogleFonts.inter(fontSize: 13.sp, color: selected ? Colors.white : Colors.black87),
                                ),
                                backgroundColor: selected ? const Color(0xFF006970) : Colors.grey.shade200,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Search
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Search items (Sofa, Bed, Fridge...)",
                          prefixIcon: const Icon(Icons.search, color: Color(0xFF006970)),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Items list
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        itemCount: categories.length,
                        itemBuilder: (context, i) {
                          final cat = categories[i];
                          final name = cat.name ?? "Unknown";
                          final subGroup = subCategoryGroups.firstWhere(
                                (g) => g.name == name,
                            orElse: () => DataSubCategory(name: name, subCategories: []),
                          );

                          return ItemCategorySection(
                            key: _sectionKeys[name],
                            categoryName: name,
                            subCategories: subGroup.subCategories ?? [],
                            onItemToggled: (itemName, newQuantity) {
                              final current = ref.read(selectedProductsProvider);
                              final updated = List<Product>.from(current);

                              final existingIndex = updated.indexWhere((p) => p.item == itemName);

                              if (newQuantity > 0) {
                                if (existingIndex == -1) {
                                  updated.add(Product(item: itemName, quantity: newQuantity));
                                } else {
                                  updated[existingIndex] = Product(item: itemName, quantity: newQuantity);
                                }
                              } else if (existingIndex != -1) {
                                updated.removeAt(existingIndex);
                              }

                              ref.read(selectedProductsProvider.notifier).state = updated;
                              if (newQuantity > 0) {
                                Fluttertoast.showToast(msg: "$itemName × $newQuantity added");
                              } else {
                                Fluttertoast.showToast(msg: "$itemName removed");
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text("Error: $err", style: const TextStyle(color: Colors.red))),
            ),
          ),

          // Bottom Bar
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "$totalQuantity items selected",
                      style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w700),
                    ),
                    if (totalItems > 0)
                      Text(
                        "($totalItems unique)",
                        style: GoogleFonts.inter(fontSize: 13.sp, color: Colors.grey[700]),
                      ),
                  ],
                ),

                ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18,
                  color: Colors.white,
                  ),
                  label: Text("Proceed", style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15.sp, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: totalQuantity == 0 ? Colors.grey.shade400 : const Color(0xFF006970),
                    padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: totalQuantity == 0
                      ? null
                      : () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => const SelectPickupSlotPage()),
                    );
                  },
                ),


              ],
            ),
          ),

          SizedBox(height: 50.h,)
        ],
      ),
    );
  }

  Widget _buildStepCircle(IconData icon, Color color) {
    return Container(
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      child: Icon(icon, color: Colors.white, size: 20.sp),
    );
  }

  Widget _buildProgressLine() {
    return Expanded(child: Container(height: 2.h, color: const Color(0xFF006970)));
  }

  TextStyle _stepLabel({bool active = false}) => GoogleFonts.inter(
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
    color: active ? const Color(0xFF006970) : Colors.grey[700],
  );
}

class ItemCategorySection extends StatelessWidget {
  final String categoryName;
  final List<SubCategorySubCategory> subCategories;
  final Function(String, int) onItemToggled; // itemName, newQuantity

  const ItemCategorySection({
    super.key,
    required this.categoryName,
    required this.subCategories,
    required this.onItemToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            categoryName,
            style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          if (subCategories.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: Text("No items in this category", style: TextStyle(color: Colors.grey))),
            )
          else
            ...subCategories.map((sub) => _buildSubCategory(sub)),
        ],
      ),
    );
  }

  Widget _buildSubCategory(SubCategorySubCategory sub) {
    final items = sub.innerCategory ?? [];
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ExpansionTile(
        title: Text(sub.name ?? "Items", style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600)),
        leading: const Icon(Icons.category_outlined, color: Color(0xFF006970)),
        childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
        children: items.map((itemName) {
          return Consumer(builder: (context, ref, child) {
            final selectedProducts = ref.watch(selectedProductsProvider);
            final quantity = selectedProducts.firstWhere(
                  (p) => p.item == itemName,
              orElse: () => Product(item: itemName, quantity: 0),
            ).quantity ?? 0;

            return ListTile(
              dense: true,
              leading: const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF006970)),
              title: Text(itemName, style: GoogleFonts.inter(fontSize: 14.sp)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (quantity > 0)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => onItemToggled(itemName, quantity - 1),
                    ),
                  Container(
                    width: 40.w,
                    alignment: Alignment.center,
                    child: Text(
                      "$quantity",
                      style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded, color: Color(0xFF006970)),
                    onPressed: () => onItemToggled(itemName, quantity + 1),
                  ),
                ],
              ),
            );
          });
        }).toList(),
      ),
    );
  }
}