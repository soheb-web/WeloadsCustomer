import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../config/network/api.state.dart';
import '../../../config/utils/navigatorKey.dart';
import '../../../config/utils/pretty.dio.dart';
import '../../../data/Model/loginBodyModel.dart';
import '../../../data/Model/loginVerifyBodyModel.dart';
import '../../Chat/chating.page.dart' as Hive;
import '../../home.screen.dart';
import '../loginVerify.screen.dart';

mixin LoginController<T extends StatefulWidget> on State<T> {
  final loginformKey = GlobalKey<FormState>();
  final phoneController = TextEditingController();

  bool isShow = true;
  bool loadind = false;
  bool loading = false;

  /// ✅ SHARED LOGIN TOKEN
  static String? loginToken;

  /// OTP
  String otp = "";

  /// RESEND
  int resendTimer = 60;
  bool canResend = false;
  Timer? _timer;

  /* --------------------------------------------------
   * DEVICE TOKEN
   * -------------------------------------------------- */

  Future<String> _getDeviceToken() async {
    try {
      return await FirebaseMessaging.instance.getToken() ?? "unknown_device";
    } catch (e) {
      log("Device token error: $e");
      return "unknown_device";
    }
  }

  /* --------------------------------------------------
   * LOGIN → SEND OTP
   * -------------------------------------------------- */

  Future<void> loginUser() async {
    if (!loginformKey.currentState!.validate()) return;

    setState(() => loadind = true);

    try {
      final body = LoginBodyModel(
        loginType: phoneController.text.trim(),
        deviceId: await _getDeviceToken(),
      );

      final service = APIStateNetwork(callPrettyDio());
      final response = await service.login(body);

      if (response.error == false) {
        /// ✅ SAVE TOKEN
        loginToken = response.data?.token;

        Fluttertoast.showToast(
          msg: response.message ?? "OTP sent successfully",
        );

        if (!mounted) return;

        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (_) => LoginVerifyScreen(
              phone: phoneController.text.trim(),
            ),
          ),
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Login failed");
      }
    } catch (e) {
      log("Login error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => loadind = false);
    }
  }

  /* --------------------------------------------------
   * OTP VERIFY
   * -------------------------------------------------- */

  Future<void> verifyLogin() async {
    if (otp.length != 4) {
      Fluttertoast.showToast(msg: "Enter 4 digit OTP");
      return;
    }

    if (loginToken == null) {
      Fluttertoast.showToast(msg: "Session expired, please login again");
      return;
    }

    setState(() => loading = true);

    try {
      final body = LoginverifyBodyModel(
        token: loginToken!,
        otp: otp,
      );

      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyLogin(body);

      if (response.error == false) {
        final box = Hive.box;
        await box.put("token", response.data!.token);
        await box.put("email", response.data!.email);
        await box.put("firstName", response.data!.firstName);
        await box.put("lastName", response.data!.lastName);
        await box.put("phone", response.data!.phone);
        await box.put("id", response.data!.id);

        Fluttertoast.showToast(msg: response.message ?? "Login successful");

        if (!mounted) return;

        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (_) => const HomeScreen()),
              (route) => false,
        );
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Invalid OTP");
        otp = "";
        loginVerifyotpKey.currentState?.clearOtp();
      }
    } catch (e) {
      log("Verify error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  /* --------------------------------------------------
   * RESEND OTP
   * -------------------------------------------------- */

  Future<void> resendOTP({required String phone}) async {
    if (!canResend) return;

    setState(() => loading = true);

    try {
      final body = LoginBodyModel(
        loginType: phone.trim(),  // ✅ Use phone from widget
        deviceId: await _getDeviceToken(),
      );

      final service = APIStateNetwork(callPrettyDio());
      final response = await service.login(body);

      if (response.error == false) {
        loginToken = response.data?.token;
        Fluttertoast.showToast(msg: "OTP resent successfully");
        startResendTimer();
      } else {
        Fluttertoast.showToast(msg: response.message ?? "Resend failed");
      }
    } catch (e) {
      log("Resend error: $e");
      Fluttertoast.showToast(msg: "Something went wrong");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }


  /* --------------------------------------------------
   * TIMER (CALL FROM SCREEN)
   * -------------------------------------------------- */

  void startResendTimer() {
    resendTimer = 60;
    canResend = false;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer > 0) {
        setState(() => resendTimer--);
      } else {
        timer.cancel();
        setState(() => canResend = true);
      }
    });
  }

  void disposeController() {
    phoneController.dispose();
    _timer?.cancel();
  }



}
