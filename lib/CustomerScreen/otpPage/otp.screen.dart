import 'dart:async';

import 'package:delivery_mvp_app/CustomerScreen/otpPage/controller/otpController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import '../../config/utils/navigatorKey.dart';
import '../../data/Model/registerBodyModel.dart';
import '../registerPage/controller/registerController.dart';

class OtpScreen extends StatefulWidget {
  final String mobile;

  /// register request data (same as register screen)
  final RegisterBodyModel registerBody;

  const OtpScreen({
    super.key,
    required this.mobile,

    required this.registerBody,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

// class _OtpScreenState extends State<OtpScreen>
//     with OtpController<OtpScreen>, Registercontroller<OtpScreen> {

class _OtpScreenState extends State<OtpScreen>
    with Registercontroller<OtpScreen> {
  Timer? _timer;
  int _remainingSeconds = 60;
  bool canResend = false;
  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    canResend = false;
    _remainingSeconds = 60;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() => canResend = true);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  String get timerText {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 70.h),

              Center(
                child: Image.asset(
                  "assets/scooter.png",
                  width: 84.w,
                  height: 72.h,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                "Enter the 4-digit code",
                style: GoogleFonts.inter(fontSize: 20.sp),
              ),
              SizedBox(height: 6.h),
              Text(
                "Code sent to ${maskMobile(widget.mobile)}",
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  color: const Color(0xFF4F4F4F),
                ),
              ),

              SizedBox(height: 26.h),

              OtpPinField(
                key: registerVerifyotpKey,
                maxLength: 4, // Changed from 6 to 4
                fieldHeight: 56.h,
                fieldWidth:
                    70.w, // Increased width for better look with 4 boxes
                mainAxisAlignment: MainAxisAlignment
                    .spaceEvenly, // Better spacing for 4 fields
                keyboardType: TextInputType.number,
                otpPinFieldStyle: OtpPinFieldStyle(
                  textStyle: GoogleFonts.inter(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2D2D2D),
                  ),
                  activeFieldBackgroundColor: const Color(0xFFF0F5F5),
                  defaultFieldBackgroundColor: const Color(0xFFF0F5F5),
                  activeFieldBorderColor: Colors.transparent,
                  defaultFieldBorderColor: Colors.transparent,
                ),
                otpPinFieldDecoration:
                    OtpPinFieldDecoration.defaultPinBoxDecoration,
                onSubmit: (text) {
                  if (text.length == 4) {
                    // Auto trigger verification when 4 digits are entered
                    sendOTP();
                  }
                },
                onChange: (value) {
                  setState(() {
                    otp = value;
                  });
                },
              ),

              SizedBox(height: 20.h),

              /// TIMER / RESEND
              Center(
                child: canResend
                    ? Text.rich(
                        TextSpan(
                          text: "Didn’t receive OTP? ",
                          children: [
                            TextSpan(
                              text: "Resend OTP",
                              style: GoogleFonts.inter(
                                color: const Color(0xFF006970),
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = resendOtp,
                            ),
                          ],
                        ),
                      )
                    : Text(
                        "Resend OTP in $timerText",
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          color: Colors.grey,
                        ),
                      ),
              ),

              SizedBox(height: 30.h),

              /// VERIFY BUTTON
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50.h),
                  backgroundColor: const Color(0xFF006970),
                ),
                onPressed: otp.length == 4
                    ? () {
                        sendOTP();
                      }
                    : null,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Verify",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> resendOtp() async {
    if (!canResend) return;

    await registerUserApi(
      body: widget.registerBody,
      onSuccess: (_) {
        startTimer();
        Fluttertoast.showToast(msg: "OTP resent successfully");
      },
      onError: (msg) {
        Fluttertoast.showToast(msg: msg);
      },
    );
  }

  String maskMobile(String mobile) {
    if (mobile.length <= 4) return mobile;
    return mobile.replaceRange(2, mobile.length - 2, '*' * (mobile.length - 4));
  }
}
