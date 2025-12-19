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

class _LoginScreenState extends State<LoginScreen>
    with LoginController<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Form(
        key: loginformKey,
        child: Padding(
          padding:  EdgeInsets.only(left: 30.w,right: 30.w),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 66.h),
                Center(
                  child: Image.asset(
                    "assets/scooter.png",
                    width: 84.w,
                    height: 72.h,
                  ),
                ),

            Expanded(child: SizedBox()),

                      Text(
                        "Welcome Back!",
                        style: GoogleFonts.inter(
                          fontSize: 30.sp,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006970),
                        ),
                      ),
                      SizedBox(height: 4.h),
                Text(
                  "Login to Continue your\nDeliveries",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color:  Colors.grey
                  ),
                ),


                Expanded(child: SizedBox()),
                SizedBox(),
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
                child: TextFormField(
                  controller: emailController, // rename if possible -> phoneController
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w400,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly, // ✅ only numbers
                  ],
                  decoration: InputDecoration(
                    counterText: "", // hide maxLength counter
                    prefixIcon: Icon(
                      Icons.call,
                      color: Colors.grey.shade500,
                      size: 20.sp,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    hintText: "Enter your phone number",
                    hintStyle: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade400,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 14.h,
                      horizontal: 20.w,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter phone number";
                    }
                    if (value.length != 10) {
                      return "Enter valid 10 digit phone number";
                    }
                    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
                      return "Invalid phone number";
                    }
                    return null;
                  },
                ),
              ),


                      SizedBox(height: 30.h),





              Container(
                width: double.infinity,
                height: 50.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08), // ✅ same as TextField
                      blurRadius: 12,
                      spreadRadius: 1,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006970),
                    elevation: 0, // ❗ shadow Container handle karega
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  onPressed: loadind ? null : loginUser,
                  child: loadind
                      ? SizedBox(
                    width: 30.w,
                    height: 30.h,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "GET OTP",
                    style: GoogleFonts.inter(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 7.h),







            Expanded(child: SizedBox()),

                      Text(
                        "Don’t have an account?",
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF4F4F4F),
                        ),
                      ),
                      InkWell(
                        onTap: (){

                          Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
                        },
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.inter(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF006970),
                          ),
                        ),
                      ),



                      SizedBox(height: 30.h),
                    ],
                  ),
          ),
        ),
            ),


    );
  }
}
