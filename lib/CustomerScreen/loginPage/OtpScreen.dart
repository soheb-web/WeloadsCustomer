import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class OtpScreenNew extends StatefulWidget {
  const OtpScreenNew({super.key});

  @override
  State<OtpScreenNew> createState() => _OtpScreenNewState();
}

class _OtpScreenNewState extends State<OtpScreenNew> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  bool loading = false;

  void verifyOtp() {
    if (_formKey.currentState!.validate()) {
      setState(() => loading = true);

      // TODO: call verify OTP API
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 66.h),

                Image.asset(
                  "assets/scooter.png",
                  width: 84.w,
                  height: 72.h,
                ),

                const Spacer(),

                Text(
                  "verify your number",
                  style: GoogleFonts.inter(
                    fontSize: 30.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF006970),
                  ),
                ),

                SizedBox(height: 6.h),

                Text(
                  "Please Enter a 4-Digt Code Send to your Phone",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),

                const Spacer(),

                /// 🔢 OTP FIELD
                // Container(
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(30.r),
                //     border: Border(
                //       top: BorderSide(
                //         color: Colors.grey.shade300,
                //         width: 1,
                //       ),
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.08),
                //         blurRadius: 12,
                //         spreadRadius: 1,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: TextFormField(
                //     controller: otpController,
                //     keyboardType: TextInputType.number,
                //     maxLength: 6,
                //     textAlign: TextAlign.center,
                //     inputFormatters: [
                //       FilteringTextInputFormatter.digitsOnly,
                //     ],
                //     style: GoogleFonts.inter(
                //       fontSize: 18.sp,
                //       fontWeight: FontWeight.w600,
                //       letterSpacing: 6,
                //       color: Colors.grey.shade800,
                //     ),
                //     decoration: InputDecoration(
                //       counterText: "",
                //       hintText: "Enter OTP",
                //       hintStyle: GoogleFonts.inter(
                //         fontSize: 14.sp,
                //         color: Colors.grey.shade400,
                //         letterSpacing: 2,
                //       ),
                //       filled: true,
                //       fillColor: Colors.transparent,
                //       border: InputBorder.none,
                //       enabledBorder: InputBorder.none,
                //       focusedBorder: InputBorder.none,
                //       errorBorder: InputBorder.none,
                //       focusedErrorBorder: InputBorder.none,
                //       contentPadding: EdgeInsets.symmetric(
                //         vertical: 14.h,
                //       ),
                //     ),
                //     validator: (value) {
                //       if (value == null || value.isEmpty) {
                //         return "Please enter OTP";
                //       }
                //       if (value.length != 6) {
                //         return "Enter valid 6 digit OTP";
                //       }
                //       return null;
                //     },
                //   ),
                // ),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              child: PinCodeTextField(
                  appContext: context,
                  length: 4, // ✅ 4 DIGIT ONLY
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  animationType: AnimationType.fade,
                  autoFocus: true,
                  enableActiveFill: true,
                  cursorColor: const Color(0xFF006970),
                  textStyle: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],

                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(10.r),
                    fieldHeight: 55.h,
                    fieldWidth: 55.w,

                    activeFillColor: Colors.transparent,
                    inactiveFillColor: Colors.transparent,
                    selectedFillColor: Colors.transparent,

                    inactiveColor: Colors.transparent,
                    activeColor: Colors.transparent,
                    selectedColor: Colors.transparent,
                  ),

                  backgroundColor: Colors.transparent,
                  // animationDura
              )),


                  SizedBox(height: 30.h),

                /// 🔘 VERIFY BUTTON
                Container(
                  width: double.infinity,
                  height: 50.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006970),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                    ),
                    onPressed: loading ? null : verifyOtp,
                    child: loading
                        ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    )
                        : Text(
                      "VERIFY OTP",
                      style: GoogleFonts.inter(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                /// 🔁 RESEND
                RichText(
                  text: TextSpan(
                    text: "Didn’t receive OTP? ",
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                    children: [
                      TextSpan(
                        text: "Resend",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF006970),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // TODO: resend OTP
                          },
                      ),
                    ],
                  ),
                ),

                const Spacer(),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
