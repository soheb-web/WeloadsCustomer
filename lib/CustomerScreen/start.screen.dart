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

/*

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
}*/

import 'package:delivery_mvp_app/CustomerScreen/home.screen.dart';
import 'package:delivery_mvp_app/CustomerScreen/onbording.screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gif/gif.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> with TickerProviderStateMixin {
  late GifController controller;

  @override
  void initState() {
    super.initState();
    controller = GifController(vsync: this);

    // 5 सेकंड बाद ऑटोमैटिक नेविगेशन
    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      var box = Hive.box("folder");
      var token = box.get("token");

      Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
          builder: (context) => token == null ? const OnbordingScreen() : const HomeScreen(),
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
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // GIF (आपका splash1.gif)
            SizedBox(
              width: 220.w,
              height: 220.h,
              child: Gif(
                image: const AssetImage("assets/gif/splash1.gif"),
                controller: controller,
                autostart: Autostart.loop,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 40.h),

            // Company Name - We Loads
            Text(
              "We Loads",
              style: GoogleFonts.poppins(
                fontSize: 42.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF006970), // आपका ब्रांड कलर
                letterSpacing: 1.5,
                height: 1.0,
              ),
            ),

            SizedBox(height: 8.h),

            // Tagline (ऑप्शनल - चाहो तो हटा देना)
            Text(
              "Fast • Safe • Reliable",
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                letterSpacing: 2.0,
              ),
            ),

            SizedBox(height: 80.h),

            // छोटा सा लोडिंग इंडिकेटर (ऑप्शनल लेकिन प्रोफेशनल लगता है)
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF006970)),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}