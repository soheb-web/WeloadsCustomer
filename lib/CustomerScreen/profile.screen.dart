/*
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/PaymenetPage.dart';
import 'package:delivery_mvp_app/CustomerScreen/deliveryHistory.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/support.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/updateUserProfile.page.dart';
import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'AllIndiaDeliveryHistory.dart';
import 'PackerMoverDeliveryHistory.dart';
import 'TransactionScreen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const ProfileScreen(this.socket, {super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> showLogoutDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Logout",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006970),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () async {
                log("Clear data....");
                Navigator.pop(context);

                final box = await Hive.box("folder");

                await box.clear();

                Fluttertoast.showToast(msg: "Sign out successfully");

                Navigator.pushAndRemoveUntil(
                  context,
                  CupertinoPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    var box = Hive.box("folder");
    var token = box.get("token");
    final provider = ref.watch(getProfileController);
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: provider.when(
        data: (profile) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 80.h),
              Center(
                child: Container(
                  width: 72.w,
                  height: 72.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFA8DADC),
                  ),
                  child: Center(
                    child:
                        (profile.data?.empty?.activePaths?.paths?.image !=
                                null &&
                            profile
                                .data!
                                .empty!
                                .activePaths!
                                .paths!
                                .image!
                                .isNotEmpty)
                        ? ClipOval(
                            child: Image.network(
                              profile.data!.doc!.image ??
                                  "https://upload.wikimedia.org/wikipedia/commons/8/89/Portrait_Placeholder.png",
                              fit: BoxFit.cover,
                              width: 72.w,
                              height: 72.h,
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                    Icons.person,
                                    size: 40.sp,
                                    color: Colors.grey,
                                  ),
                            ),
                          )
                        : Text(
                            "${profile.data?.doc?.firstName?[0].toUpperCase() ?? ''}${profile.data?.doc?.lastName?[0].toUpperCase() ?? ''}",
                            style: GoogleFonts.inter(
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF4F4F4F),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 5.h),
              Center(
                child: Text(
                  "${profile.data!.doc!.firstName} ${profile.data!.doc!.lastName}",
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Center(
                child: Text(
                  "Wallet: ₹${profile.data!.wallet!.balance!.toStringAsFixed(0)}",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    // fontWeight: FontWeight.w600, // Bold for better look
                    color: const Color.fromARGB(255, 29, 53, 87),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Divider(
                color: Color(0xFFB0B0B0),
                thickness: 1,
                endIndent: 24,
                indent: 24,
              ),
              buildProfile(Icons.edit, "Edit Profile", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => UpdateUserProfilePage(),
                  ),
                );
              }),

              buildProfile(Icons.payment, "Payment", () {

                Navigator.push(context, MaterialPageRoute(builder: (context)=>AddMoneyToWalletPage()));
              }),

              buildProfile(Icons.payment, "Transaction History", () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>TransactionHistoryPage()));
              }),

              buildProfile(Icons.history, "Delivery History", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => DeliveryHistoryScreen(widget.socket),
                  ),
                );
              }),

              buildProfile(Icons.payment, "All India Delivery History", () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>
                    PackerMoverDeliveryHistory()
                ));

              }),

              buildProfile(Icons.payment, "Packer Mover Delivery History", () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>AllIndiaDeliveryHistory()));
              }),



              buildProfile(Icons.contact_support, "Support/FAQ", () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => SupportPage(widget.socket),
                  ),
                );
              }),

              SizedBox(height: 50.h),
              InkWell(
                onTap: () {
                  showLogoutDialog();
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: 24.w),
                    SvgPicture.asset("assets/SvgImage/signout.svg"),
                    SizedBox(width: 10.w),
                    Text(
                      "Sign out",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Color.fromARGB(186, 29, 53, 87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        error: (error, stackTrace) {
          log("${error.toString()} /n ${stackTrace.toString()}");
          return Center(child: Text(error.toString()));
        },
        loading: () => Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget buildProfile(IconData icon, String name, VoidCallback ontap) {
    return GestureDetector(
      onTap: ontap,
      child: Container(
        margin: EdgeInsets.only(left: 24.w, top: 25.h),
        child: Row(
          children: [
            Icon(icon, color: Color(0xFFB0B0B0)),
            SizedBox(width: 10.w),
            Text(
              name,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: Color.fromARGB(186, 29, 53, 87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




*/
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/PaymenetPage.dart';
import 'package:delivery_mvp_app/CustomerScreen/deliveryHistory.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/support.page.dart';
import 'package:delivery_mvp_app/CustomerScreen/updateUserProfile.page.dart';
import 'package:delivery_mvp_app/data/controller/getProfileController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'AllIndiaDeliveryHistory.dart';
import 'HistoryPage.dart';
import 'PackerMoverDeliveryHistory.dart';
import 'QrScannerPage.dart';
import 'QrTransactionHistory.dart';
import 'TransactionScreen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final IO.Socket socket;
  const ProfileScreen(this.socket, {super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _refresh() async {
    // The simplest and most reliable way with autoDispose FutureProvider
    ref.invalidate(getProfileController);
    // Alternative (if you ever switch to AsyncNotifierProvider):
    // ref.read(getProfileController.notifier).fetchProfile();
  }

  Future<void> showLogoutDialog() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Logout", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006970),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final box = await Hive.box("folder");
    await box.clear();

    Fluttertoast.showToast(msg: "Sign out successfully");

    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      CupertinoPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Re-fetch every time screen is shown (most reliable for this use-case)
    ref.invalidate(getProfileController);
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(getProfileController);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF006970),
        child: profileAsync.when(
          skipLoadingOnRefresh: false,           // ← important: show spinner on pull-to-refresh
          skipLoadingOnReload: false,
          data: (profile) {
            final doc = profile.data?.doc;
            final wallet = profile.data?.wallet;

            final String firstName = doc?.firstName ?? '';
            final String lastName = doc?.lastName ?? '';
            final String? imageUrl = doc?.image;
            final num balance = wallet?.balance ?? 0.0;

            final String initials =
                (firstName.isNotEmpty ? firstName[0].toUpperCase() : '') +
                    (lastName.isNotEmpty ? lastName[0].toUpperCase() : '');

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 80.h),

                  // Avatar + name + wallet (same as before, just cleaned up null handling)
                  Center(
                    child: Container(
                      width: 72.w,
                      height: 72.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFA8DADC),
                      ),
                      child: Center(
                        child: (imageUrl != null && imageUrl.isNotEmpty)
                            ? ClipOval(
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            width: 72.w,
                            height: 72.h,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            ),
                          ),
                        )
                            : Text(
                          initials,
                          style: GoogleFonts.inter(
                            fontSize: 32.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF4F4F4F),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Center(
                    child: Text(
                      '$firstName $lastName'.trim(),
                      style: GoogleFonts.inter(fontSize: 18.sp, fontWeight: FontWeight.w500),
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Center(
                    child: Text(
                      "Wallet: ₹${balance.toStringAsFixed(0)}",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        color: const Color.fromARGB(255, 29, 53, 87),
                      ),
                    ),
                  ),

                  SizedBox(height: 24.h),
                  const Divider(indent: 24, endIndent: 24, color: Color(0xFFB0B0B0)),

                  // Menu items (unchanged logic, just const where possible)
                  _buildTile(Icons.edit, "Edit Profile", () {
                    Navigator.push(context, CupertinoPageRoute(builder: (_) => const UpdateUserProfilePage()));
                  }),

                  _buildTile(Icons.payment, "Payment", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMoneyToWalletPage()));
                  }),

                  _buildTile(Icons.receipt_long, "Transaction History", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                  }),

 
                  _buildTile(Icons.receipt_long, "Qr Scanner", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const QrTransactionHistory()));
                  }),

                  _buildTile(Icons.history, "Delivery History", () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => DeliveryHistoryScreen(widget.socket)),
                    );
                  }),

                  _buildTile(Icons.local_shipping, "All India Delivery History", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const PackerMoverDeliveryHistory()));
                  }),

                  _buildTile(Icons.local_shipping_outlined, "Packer Mover Delivery History", () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AllIndiaDeliveryHistory()));
                  }),

                  _buildTile(Icons.contact_support, "Support/FAQ", () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(builder: (_) => SupportPage(widget.socket)),
                    );
                  }),

                  SizedBox(height: 40.h),

                  InkWell(
                    onTap: showLogoutDialog,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/SvgImage/signout.svg"),
                          SizedBox(width: 12.w),
                          Text(
                            "Sign out",
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              color: const Color.fromARGB(186, 29, 53, 87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 60.h),
                ],
              ),
            );
          },

          error: (err, stk) => Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text("Error: $err", textAlign: TextAlign.center),
                ),
                ElevatedButton(
                  onPressed: _refresh,
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),

          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.only(left: 24.w, top: 20.h, bottom: 4.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFB0B0B0), size: 24),
            SizedBox(width: 12.w),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                color: const Color.fromARGB(186, 29, 53, 87),
              ),
            ),
          ],
        ),
      ),
    );
  }
}







