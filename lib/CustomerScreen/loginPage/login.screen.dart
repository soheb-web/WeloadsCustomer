import 'package:delivery_mvp_app/CustomerScreen/loginPage/controller/loginController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../registerPage/register.screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with LoginController<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: loginformKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 66.h),
                Image.asset("assets/scooter.png", width: 84.w, height: 72.h),

                const Spacer(),

                Text(
                  "Welcome Back!",
                  style: GoogleFonts.inter(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006970),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Login to Continue your\nDeliveries",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                const Spacer(),

                // Phone number field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border(top: BorderSide(color: Colors.grey.shade300)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade800),
                    decoration: InputDecoration(
                      counterText: "",
                      prefixIcon: Icon(Icons.phone, color: Colors.grey.shade500, size: 20.sp),
                      hintText: "Enter your phone number",
                      hintStyle: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade400),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 20.w),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return "Phone number is required";
                      if (v.length != 10) return "Enter 10 digits";
                      if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return "Invalid number";
                      return null;
                    },
                  ),
                ),

                SizedBox(height: 30.h),

                // GET OTP button
                SizedBox(
                  width: double.infinity,
                  height: 52.h,
                  child: ElevatedButton(
                    onPressed: loadind ? null : loginUser,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006970),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                    ),
                    child: loadind
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                        : Text(
                      "GET OTP",
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                Text(
                  "Don’t have an account?",
                  style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade700),
                ),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                  child: Text(
                    "Sign up",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF006970),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}