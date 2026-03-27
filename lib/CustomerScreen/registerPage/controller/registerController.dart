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

      if (response.error == false || response.code == 0) {
        registerToken = response.data?.token;
        log("REGISTER TOKEN: $registerToken");

        onSuccess?.call(registerToken!);
      } else {
        onError?.call(response.message);
      }
    } catch (e, st) {
      onError?.call(e.toString());
      log(st.toString());
      log(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  String otp = "";
  bool loading = false;

  // void sendOTP() async {
  //   final body = VerifyRegisterBodyModel(token: registerToken!, otp: otp);
  //   setState(() {
  //     loading = true;
  //   });
  //   try {
  //     final service = APIStateNetwork(callPrettyDio());
  //     final response = await service.verifyRegister(body);
  //     if (response.error == false) {
  //       var box = Hive.box("folder");
  //       await box.put("token", response.data!.token);
  //       await box.put("email", response.data!.email);
  //       await box.put("firstName", response.data!.firstName);
  //       await box.put("lastName", response.data!.lastName);
  //       await box.put("phone", response.data!.phone);
  //       await box.put("id", response.data!.id);
  //       Fluttertoast.showToast(msg: response.message);
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         CupertinoPageRoute(builder: (context) => HomeScreen()),
  //         (route) => false,
  //       );
  //       setState(() {
  //         loading = false;
  //       });
  //     } else {
  //       Fluttertoast.showToast(msg: response.message);
  //       setState(() {
  //         loading = false;
  //         otp = "";
  //       });
  //       registerVerifyotpKey.currentState!.clearOtp();
  //     }
  //   } catch (e, st) {
  //     log("${e.toString()} / ${st.toString()}");
  //     setState(() {
  //       loading = false;
  //     });
  //     Fluttertoast.showToast(msg: "Error");
  //   }
  // }

  void sendOTP(String token) async {
    if (token.isEmpty) {
      Fluttertoast.showToast(msg: "Invalid token, please register again");
      return;
    }

    final body = VerifyRegisterBodyModel(token: token, otp: otp);

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
      } else {
        Fluttertoast.showToast(msg: response.message);
        setState(() {
          otp = "";
        });
        registerVerifyotpKey.currentState?.clearOtp(); // ✅ safe call
      }
    } catch (e, st) {
      log("${e.toString()} / ${st.toString()}");
      Fluttertoast.showToast(msg: "Error");
    } finally {
      setState(() {
        loading = false;
      });
    }
  }
}
