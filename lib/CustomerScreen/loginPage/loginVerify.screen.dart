/*
import 'package:delivery_mvp_app/CustomerScreen/loginPage/controller/loginVerifyController.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_pin_field/otp_pin_field.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class LoginVerifyScreen extends StatefulWidget {
  final String token;
  final String email;
  final String pass;
  const LoginVerifyScreen({
    super.key,
    required this.token,
    required this.email,
    required this.pass,
  });

  @override
  State<LoginVerifyScreen> createState() => _LoginVerifyScreenState();
}

class _LoginVerifyScreenState extends State<LoginVerifyScreen>
    with LoginVerifyController<LoginVerifyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: SingleChildScrollView(
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
            Padding(
              padding: EdgeInsets.only(left: 24.w, right: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 28.h),
                  Text(
                    "Enter the 4-digit code",
                    style: GoogleFonts.inter(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF111111),
                      letterSpacing: -1,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Please input  the verification code sent to your phone number 23480*******90",
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4F4F4F),
                    ),
                  ),
                  TextButton(
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 30.h),
                      padding: EdgeInsets.only(left: 0, top: 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () {},
                    child: Text(
                      "Change Number?",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF006970),
                      ),
                    ),
                  ),
                  SizedBox(height: 26.h),
                  OtpPinField(
                    key: loginVerifyotpKey,
                    maxLength: 4,
                    fieldHeight: 50.h,
                    fieldWidth: 44.w,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    keyboardType: TextInputType.number,
                    otpPinFieldStyle: OtpPinFieldStyle(
                      textStyle: GoogleFonts.inter(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2D2D2D),
                      ),
                      activeFieldBackgroundColor: Color(0xFFF0F5F5),
                      defaultFieldBackgroundColor: Color(0xFFF0F5F5),
                      activeFieldBorderColor: Colors.transparent,
                      defaultFieldBorderColor: Colors.transparent,
                    ),
                    otpPinFieldDecoration:
                        OtpPinFieldDecoration.defaultPinBoxDecoration,
                    onSubmit: (text) {},
                    onChange: (value) {
                      setState(() {
                        otp = value;
                      });
                    },
                  ),



                SizedBox(height: 20.h),
                  Text.rich(
                    TextSpan(
                      text: "Didn’t get any code yet? ",
                      style: GoogleFonts.inter(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF4F4F4F),
                      ),
                      children: [
                        TextSpan(
                          text: "Resend code",
                          style: GoogleFonts.inter(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF006970),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              resendOTP(widget.email, '');
                            },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(327.w, 50.h),
                      backgroundColor: Color(0xFF006970),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                        side: BorderSide.none,
                      ),
                    ),
                    onPressed: loading
                        ? null
                        : () async {
                            verifyLogin(widget.token);
                          },
                    child: loading
                        ? Center(
                            child: SizedBox(
                              width: 30.w,
                              height: 30.h,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.w,
                              ),
                            ),
                          )
                        : Text(
                            "Verify",
                            style: GoogleFonts.inter(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                  ),
                  SizedBox(height: 25.h),
                  Center(
                    child: Text(
                      "By signing up, you agree to snap",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                      ),
                    ),
                  ),
                  Center(
                    child: Text.rich(
                      TextSpan(
                        text: "Terms of Service ",
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF111111),
                          decoration: TextDecoration.underline,
                        ),
                        children: [
                          TextSpan(
                            text: "and",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              decoration: TextDecoration.none,
                            ),
                          ),
                          TextSpan(
                            text: " Privacy Policy.",
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF111111),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/



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
  // final String pass;

  const LoginVerifyScreen({
    super.key,
    required this.token,
    required this.email,
    // required this.pass,
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
              /// BOTTOM TEXT
              // Text.rich(
              //   TextSpan(
              //     text: "Didn't receive the code? ",
              //     style: GoogleFonts.inter(
              //       fontSize: 13.sp,
              //       fontWeight: FontWeight.w400,
              //       color: Colors.grey.shade600,
              //     ),
              //     children: [
              //       TextSpan(
              //         text: "Try again",
              //         style: GoogleFonts.inter(
              //           fontSize: 13.sp,
              //           fontWeight: FontWeight.w600,
              //           color: Color(0xFF006970),
              //         ),
              //         recognizer: TapGestureRecognizer()
              //           ..onTap = () {
              //             resendOTP(widget.email, '');
              //           },
              //       ),
              //     ],
              //   ),
              // ),




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
