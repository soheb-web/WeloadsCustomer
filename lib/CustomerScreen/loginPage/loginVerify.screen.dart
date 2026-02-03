/*



import 'package:delivery_mvp_app/CustomerScreen/loginPage/controller/loginVerifyController.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

class LoginVerifyScreen extends StatefulWidget {
  final String token;
  final String email;

  const LoginVerifyScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<LoginVerifyScreen> createState() => _LoginVerifyScreenState();
}

class _LoginVerifyScreenState extends State<LoginVerifyScreen>
    with LoginVerifyController<LoginVerifyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),

              /// LOGO
              Image.asset(
                "assets/scooter.png",
                width: 84.w,
                height: 72.h,
              ),

              SizedBox(height: 40.h),

              /// TITLE
              Text(
                "Verify Your Number",
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006970),
                ),
              ),

              SizedBox(height: 8.h),

              /// SUBTITLE
              Text(
                "Please enter a 4-digit code sent\nto your phone",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.grey.shade600,
                ),
              ),

              SizedBox(height: 32.h),

              /// OTP FIELD (IMAGE STYLE)
              OtpPinField(
                key: loginVerifyotpKey,
                maxLength: 4,
                fieldHeight: 45.h,
                fieldWidth: 45.w,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                keyboardType: TextInputType.number,

                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006970),
                  ),
                  activeFieldBackgroundColor: Colors.white,
                  defaultFieldBackgroundColor: Colors.white,
                  activeFieldBorderColor: Color(0xFF006970),
                  defaultFieldBorderColor: Color(0xFF006970),
                ),

                otpPinFieldDecoration:
                OtpPinFieldDecoration.custom,

                onChange: (value) {
                  otp = value;
                },

                onSubmit: (value) {
                  otp = value;
                },
              ),

              SizedBox(height: 16.h),

              /// TIMER + RESEND
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "0:59 ",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF006970),
                    ),
                  ),
                  Text(
                    "Resend OTP",
                    style: GoogleFonts.inter(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 40.h),

              /// VERIFY BUTTON
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF006970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  onPressed: loading
                      ? null
                      : () {
                    verifyLogin(widget.token);
                  },
                  child: loading
                      ? SizedBox(
                    width: 26.w,
                    height: 26.h,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "VERIFY",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),

              // SizedBox(height: 28.h),

              Expanded(child: SizedBox()),




              Text(
                "Don’t have an account?",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4F4F4F),
                ),
              ),
              GestureDetector(
                onTap: (){
                  resendOTP(widget.email, );
                },
                child: Text(
                  "Try again",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF006970),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
*//*


import 'dart:async';

import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/loginPage/controller/loginVerifyController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

import '../../config/utils/navigatorKey.dart';

class LoginVerifyScreen extends StatefulWidget {
  final String token;
  final String email; // in your case this is actually the phone number

  const LoginVerifyScreen({
    super.key,
    required this.token,
    required this.email,
  });

  @override
  State<LoginVerifyScreen> createState() => _LoginVerifyScreenState();
}

class _LoginVerifyScreenState extends State<LoginVerifyScreen>
    with LoginVerifyController<LoginVerifyScreen> {
  // ────────────────────────────────────────────────
  //  Mask phone number (first 2 + last 2 digits visible)
  // ────────────────────────────────────────────────
  String get maskedPhone {
    final phone = widget.email.trim();
    if (phone.length != 10) return phone;

    return "${phone.substring(0, 2)}${'*' * 6}${phone.substring(8)}";
    // Example: 9876543210 → 98******10
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),

              // Logo
              Image.asset(
                "assets/scooter.png",
                width: 84.w,
                height: 72.h,
              ),

              SizedBox(height: 40.h),

              // Title
              Text(
                "Verify Your Number",
                style: GoogleFonts.inter(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF006970),
                ),
              ),

              SizedBox(height: 8.h),

              // Subtitle with masked phone number
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: "Code sent to ",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B7280), // gray-600
                      ),
                    ),
                    TextSpan(
                      text: "+91 $maskedPhone",
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006970),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),

              // OTP field
              OtpPinField(
                key: loginVerifyotpKey,
                maxLength: 4,
                fieldHeight: 50.h,
                fieldWidth: 50.w,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                keyboardType: TextInputType.number,
                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006970),
                  ),
                  activeFieldBackgroundColor: Colors.white,
                  defaultFieldBackgroundColor: Colors.white,
                  activeFieldBorderColor: const Color(0xFF006970),
                  defaultFieldBorderColor: const Color(0xFFCBD5E1),
                  fieldBorderWidth: 1.5,
                  errorFieldBorderColor: Colors.red,
                ),
                otpPinFieldDecoration: OtpPinFieldDecoration.defaultPinBoxDecoration,
                onChange: (value) {
                  otp = value;
                },
                onSubmit: (value) {
                  otp = value;
                  if (otp.length == 4 && !loading) {
                    verifyLogin(widget.token);
                  }
                },
              ),

              SizedBox(height: 24.h),

              // Resend OTP section with timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!canResend) ...[
                    Text(
                      "Resend in 0:${resendTimer.toString().padLeft(2, '0')}",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF006970),
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  GestureDetector(
                    onTap: canResend && !loading ? resendOTP : null,
                    child: Text(
                      "Resend OTP",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: canResend
                            ? const Color(0xFF006970)
                            : Colors.grey.shade400,
                        decoration:
                        canResend ? TextDecoration.underline : null,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 48.h),

              // VERIFY button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: loading || otp.length != 4
                      ? null
                      : () => verifyLogin(widget.token),
                  child: loading
                      ? SizedBox(
                    width: 26.w,
                    height: 26.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    "VERIFY",
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Bottom sign up section
              Text(
                "Don’t have an account?",
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF4F4F4F),
                ),
              ),

              GestureDetector(
                onTap: () {
                  // TODO: Navigate to Register screen
                  // Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterScreen()));
                },
                child: Text(
                  "Sign up",
                  style: GoogleFonts.inter(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006970),
                  ),
                ),
              ),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}*/

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';

import '../../config/utils/navigatorKey.dart';
import 'controller/loginController.dart';

class LoginVerifyScreen extends StatefulWidget {

  final String phone; // actually phone number

  const LoginVerifyScreen({super.key, required this.phone});

  @override
  State<LoginVerifyScreen> createState() => _LoginVerifyScreenState();
}


class _LoginVerifyScreenState extends State<LoginVerifyScreen> with LoginController<LoginVerifyScreen> {

  String get maskedPhone {
    final p = widget.phone.trim();
    if (p.length != 10) return p;
    return "${p.substring(0, 2)}${'*' * 6}${p.substring(8)}"; // 98******45
  }


  @override
  void initState() {
    super.initState();

    // ✅ Start resend timer when screen opens
    startResendTimer();
  }

  @override
  void dispose() {
    disposeController(); // dispose mixin stuff
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 60.h),
              Image.asset("assets/scooter.png", width: 84.w, height: 72.h),
              SizedBox(height: 40.h),

              Text(
                "Verify Your Number",
                style: GoogleFonts.inter(fontSize: 22.sp, fontWeight: FontWeight.w600, color: const Color(0xFF006970)),
              ),
              SizedBox(height: 8.h),

              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: "Code sent to ", style: TextStyle(fontSize: 14, color: Colors.grey)),
                    TextSpan(
                      text: "+91 $maskedPhone",
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF006970)),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 40.h),


              OtpPinField(
                key: loginVerifyotpKey,
                maxLength: 4,
                fieldHeight: 50.h,
                fieldWidth: 50.w,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                keyboardType: TextInputType.number,
                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006970),
                  ),
                  activeFieldBackgroundColor: Colors.white,
                  defaultFieldBackgroundColor: Colors.white,
                  activeFieldBorderColor: const Color(0xFF006970),
                  defaultFieldBorderColor: const Color(0xFFCBD5E1),
                  fieldBorderWidth: 1.5,
                  // errorFieldBorderColor: Colors.red,
                ),
                otpPinFieldDecoration: OtpPinFieldDecoration.defaultPinBoxDecoration,
                onChange: (value) {
                  otp = value;
                },
                onSubmit: (value) {
                  otp = value;
                  if (otp.length == 4 && !loading) {
                    verifyLogin();
                  }
                },
              ),


              SizedBox(height: 32.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!canResend)
                    Text(
                      "Resend in 0:${resendTimer.toString().padLeft(2, '0')}",
                      style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF006970)),
                    ),
                  if (!canResend) SizedBox(width: 12.w),


                  GestureDetector(
                    onTap: canResend && !loading ? () => resendOTP(phone: widget.phone) : null,
                    child: Text(
                      "Resend OTP",
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: canResend ? const Color(0xFF006970) : Colors.grey,
                        decoration: canResend ? TextDecoration.underline : null,
                      ),
                    ),
                  ),


                ],
              ),

              SizedBox(height: 48.h),

              SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: loading || otp.length != 4 ? null : () => verifyLogin(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  ),
                  child: loading
                      ? const SizedBox(width: 26, height: 26, child: CircularProgressIndicator(color: Colors.white))
                      : Text(
                    "VERIFY",
                    style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),

              const Spacer(),

              Text("Don’t have an account?", style: GoogleFonts.inter(fontSize: 14.sp, color: Colors.grey.shade700)),
              GestureDetector(
                onTap: () {
                  // Navigator.push(... RegisterScreen());
                },
                child: Text(
                  "Sign up",
                  style: GoogleFonts.inter(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF006970)),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}