/*
import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/registerPage/controller/registerController.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with Registercontroller<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Form(
      key: registerformKey,
      child: Scaffold(
        backgroundColor: Color(0xFFFFFFFF),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 66.h),
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
                      "Let’s get started",
                      style: GoogleFonts.inter(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111111),
                        letterSpacing: -1,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "Please input your details",
                      style: GoogleFonts.inter(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF4F4F4F),
                      ),
                    ),
                    SizedBox(height: 35.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            controller: firstNameController,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF293540),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF0F5F5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                  color: Color(0xFF006970),
                                  width: 1.w,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1.w,
                                ),
                              ),
                              hintText: "First Name",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF787B7B),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "First Name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(width: 20.w),
                        Expanded(
                          child: TextFormField(
                            keyboardType: TextInputType.name,
                            controller: lastNameController,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF293540),
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color(0xFFF0F5F5),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                  color: Color(0xFF1D3557),
                                  width: 1.w,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide.none,
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.r),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                  width: 1.w,
                                ),
                              ),
                              hintText: "Last Name",
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF787B7B),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Last Name is required";
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),
                    IntlPhoneField(
                      keyboardType: TextInputType.phone,
                      controller: phoneNumberController,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF293540),
                      ),
                      dropdownIconPosition: IconPosition.trailing,
                      dropdownIcon: Icon(Icons.keyboard_arrow_down),
                      flagsButtonMargin: EdgeInsets.only(
                        left: 10.w,
                        right: 6.w,
                        top: 4.h,
                        bottom: 4.h,
                      ),
                      flagsButtonPadding: EdgeInsetsGeometry.zero,
                      dropdownDecoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        filled: true,
                        fillColor: Color(0xFFF0F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide(
                            color: Color(0xFF006970),
                            width: 1.w,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide(color: Colors.red, width: 1.w),
                        ),
                        hintText: "You Phone Number",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF787B7B),
                        ),
                      ),

                      initialCountryCode: 'IN',
                      onChanged: (phone) {
                        print(phone.completeNumber);
                      },
                      validator: (value) {
                        if (value == null || value.number.isEmpty) {
                          return "Phone Name is required";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.h),
                    TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF293540),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFF0F5F5),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide(
                            color: Color(0xFF006970),
                            width: 1.w,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide.none,
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.r),
                          borderSide: BorderSide(color: Colors.red, width: 1.w),
                        ),
                        hintText: "Your Email",
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF787B7B),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Email is required";
                        }
                        String pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
                        RegExp regex = RegExp(pattern);
                        if (!regex.hasMatch(value.trim())) {
                          return "Enter a valid email";
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 30.h),


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
                      onPressed: isLoading
                          ? null
                          : () async {
                              registerUser();
                            },
                      child: isLoading
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
                              "Register",
                              style: GoogleFonts.inter(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFFFFFFF),
                              ),
                            ),
                    ),
                    SizedBox(height: 20.h),
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
                    SizedBox(height: 20.h),
                    Center(
                      child: Text.rich(
                        TextSpan(
                          text: "Already had an account? ",
                          style: GoogleFonts.inter(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4F4F4F),
                          ),
                          children: [
                            TextSpan(
                              text: "Sign in",
                              style: GoogleFonts.inter(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF006970),
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) => LoginScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 15.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/


import 'package:delivery_mvp_app/CustomerScreen/loginPage/login.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/registerPage/controller/registerController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../config/utils/navigatorKey.dart';
import '../../data/Model/registerBodyModel.dart';
import '../NotifierFolder/notificationservice1.dart';
import '../otpPage/otp.screen.dart';
import 'PrivacyPolicyScreen.dart';
import 'TermsConditionsScreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with Registercontroller<RegisterScreen> {

  bool isTermsAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Form(
        key: registerformKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 66.h),

                /// LOGO
                Center(
                  child: Image.asset(
                    "assets/scooter.png",
                    width: 84.w,
                    height: 72.h,
                  ),
                ),

                SizedBox(height: 28.h),

                Text(
                  "Let’s get started",
                  style: GoogleFonts.inter(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Please input your details",
                  style: GoogleFonts.inter(
                    fontSize: 12.sp,
                    color: const Color(0xFF4F4F4F),
                  ),
                ),

                SizedBox(height: 35.h),

                /// NAME
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: firstNameController,
                        hint: "First Name",
                        validator: (v) =>
                        v == null || v.isEmpty ? "First Name required" : null,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: _textField(
                        controller: lastNameController,
                        hint: "Last Name",
                        validator: (v) =>
                        v == null || v.isEmpty ? "Last Name required" : null,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                /// PHONE
                IntlPhoneField(
                  controller: phoneNumberController,
                  initialCountryCode: 'IN',
                  decoration: _inputDecoration("Your Phone Number"),
                  validator: (phone) {
                    if (phone == null ||
                        phone.completeNumber.isEmpty) {
                      return "Phone number required";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 30.h),

                /// EMAIL
                _textField(
                  controller: emailController,
                  hint: "Your Email",
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email required";
                    }
                    if (!RegExp(
                        r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                        .hasMatch(value)) {
                      return "Enter valid email";
                    }
                    return null;
                  },
                ),

                SizedBox(height: 24.h),

                /// TERMS & CONDITIONS
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: isTermsAccepted,
                      activeColor: const Color(0xFF006970),
                      onChanged: (val) {
                        setState(() {
                          isTermsAccepted = val ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: "I agree to the ",
                          style: GoogleFonts.inter(fontSize: 12.sp),
                          children: [
                            TextSpan(
                              text: "Terms of Service",
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                      const TermsConditionsScreen(),
                                    ),
                                  );
                                },
                            ),
                            const TextSpan(text: " and "),
                            TextSpan(
                              text: "Privacy Policy",
                              style: const TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (_) =>
                                      const PrivacyPolicyScreen(),
                                    ),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 30.h),

                /// REGISTER BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50.h),
                    backgroundColor: const Color(0xFF006970),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: isLoading
                      ? null
                      : () async {
                    if (!registerformKey.currentState!.validate()) return;

                    if (!isTermsAccepted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              "Please accept Terms & Conditions"),
                        ),
                      );
                      return;
                    }

                    // registerUser();
                    final deviceId = await fcmGetToken();

                    registerUserApi(
                      body: RegisterBodyModel(
                        firstName: firstNameController.text,
                        lastName: lastNameController.text,
                        email: emailController.text,
                        phone: phoneNumberController.text,
                        deviceId: deviceId,
                      ),
                      onSuccess: (token) {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => OtpScreen(
                              mobile: phoneNumberController.text,
                              registerBody: RegisterBodyModel(
                                firstName: firstNameController.text,
                                lastName: lastNameController.text,
                                email: emailController.text,
                                phone: phoneNumberController.text,
                                deviceId: deviceId,
                              ),
                            ),
                          ),
                        );
                      },
                      onError: (msg) {
                        Fluttertoast.showToast(msg: msg);
                      },
                    );

                  },
                  child: isLoading
                      ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                      : const Text("Register",style: TextStyle(color: Colors.white),),
                ),

                SizedBox(height: 20.h),

                /// LOGIN
                Center(
                  child: Text.rich(
                    TextSpan(
                      text: "Already had an account? ",
                      style: GoogleFonts.inter(fontSize: 14.sp),
                      children: [
                        TextSpan(
                          text: "Sign in",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF006970),
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) => LoginScreen(),
                                ),
                              );
                            },
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20.h),
              ],
            ),
          ),
        ),
      ),
    );
  }




  /// COMMON TEXTFIELD
  Widget _textField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(hint),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF0F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.r),
        borderSide: BorderSide.none,
      ),
    );
  }



}
