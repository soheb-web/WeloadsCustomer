/*
import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/otpPage/otp.screen.dart';
import 'package:delivery_mvp_app/config/network/api.state.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/config/utils/pretty.dio.dart';
import 'package:delivery_mvp_app/data/Model/registerBodyModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

mixin Registercontroller<T extends StatefulWidget> on State<T> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  Future<String> fcmGetToken() async {
    // Permission request करें (iOS/Android पर जरूरी)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: true, // iOS के लिए provisional permission
      carPlay: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permission');
      return "no_permission"; // Return a fallback string instead of void
    }

    // FCM Token निकालें
    String? token = await FirebaseMessaging.instance.getToken();
    // setState(() {
    //   _fcmToken = token;
    // });
    print('FCM Token: $token'); // Console में print होगा - moved before return
    return token ?? "unknown_device";
  }


  void registerUser() async {
    final deviceId = await fcmGetToken();
    if (!registerformKey.currentState!.validate()) {
      setState(() => isLoading = false);
      return;
    }
    setState(() => isLoading = true);
    final body = RegisterBodyModel(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
      email: emailController.text,
      phone: phoneNumberController.text,
      // password: passwordController.text,
      deviceId: deviceId,
    );
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.userRegister(body);

      if (response.error == false) {
        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
            builder: (context) => OtpScreen(token: response.data!.token),
          ),
          (route) => false,
        );
        setState(() {
          isLoading = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          isLoading = false;
        });
      }
    } catch (e, st) {
      setState(() {
        isLoading = false;
      });
      log("${e.toString()} / ${st.toString()}");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      // );
    }
  }


}
*/

import 'dart:developer';
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/config/utils/navigatorKey.dart';
import 'package:delivery_mvp_app/data/Model/verifyRegisterBodyModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../../../config/network/api.state.dart';
import '../../../config/utils/pretty.dio.dart';
import '../../../data/Model/registerBodyModel.dart';

mixin Registercontroller<T extends StatefulWidget> on State<T> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final phoneNumberController = TextEditingController();
  final emailController = TextEditingController();

  bool isLoading = false;

  /// 🔐 STORE REGISTER TOKEN
  String? registerToken;

  Future<void> registerUserApi({
    required RegisterBodyModel body,
    required Function(String token) onSuccess,
    Function(String message)? onError,
  }) async {
    setState(() => isLoading = true);

    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.userRegister(body);

      if (response.error == false) {
        registerToken = response.data?.token;

        onSuccess?.call(registerToken!);
      } else {
        onError?.call(response.message);
      }
    } catch (e) {
      onError?.call(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  String otp = "";
  bool loading = false;

  void sendOTP() async {
    final body = VerifyRegisterBodyModel(token: registerToken!, otp: otp);
    setState(() {
      loading = true;
    });
    try {
      final service = APIStateNetwork(callPrettyDio());
      final response = await service.verifyRegister(body);
      if (response.error == false) {
        var box = Hive.box("folder");
        await box.put("token", response.data!.token);
        await box.put("email", response.data!.email);
        await box.put("firstName", response.data!.firstName);
        await box.put("lastName", response.data!.lastName);
        await box.put("phone", response.data!.phone);
        await box.put("id", response.data!.id);

        Fluttertoast.showToast(msg: response.message);
        Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(builder: (context) => HomeScreen()),
              (route) => false,
        );
        setState(() {
          loading = false;
        });
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          loading = false;
          otp = "";
        });
        registerVerifyotpKey.currentState!.clearOtp();
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
      setState(() {
        loading = false;
      });
      Fluttertoast.showToast(msg: "Error");
    }
  }
}