/*
import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/onbording.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Future.delayed(Duration(seconds: 3), () {
      var box = Hive.box("folder");
      var token = box.get("token");



      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) {
            if (token == null) {
              return OnbordingScreen();
            } else {
              return HomeScreen();
            }
          },
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FAFB),
      body: Center(
        // child: SvgPicture.asset(
        //   "assets/SvgImage/delivery.svg",
        //   color: Colors.black,
        // ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Image.asset("assets/scooter.png"),
            Image.asset("assets/playstore.png"),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
*/


import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/onbording.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gif/gif.dart';
import 'package:hive/hive.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen>
    with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // ✅ initialize the controller properly
    controller = GifController(vsync: this);

    Future.delayed(Duration(seconds: 5), () {
      var box = Hive.box("folder");
      var token = box.get("token");

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) {
            if (token == null) {
              return OnbordingScreen();
            } else {
              return HomeScreen();
            }
          },
        ),
            (route) => false,
      );
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFFFF),
      body: Center(
        // child: SvgPicture.asset(
        //   "assets/SvgImage/delivery.svg",
        //   color: Colors.black,
        // ),
        child: Gif(
          image: AssetImage("assets/gif/splash1.gif"),
          autostart: Autostart.loop,
          alignment: Alignment.center,
          controller: controller,
          // width: 400.w,
          // height: 400.h,
          // fit: BoxFit.contain,
        ),
      ),
    );
  }
}