
import 'package:firebase_messaging/firebase_messaging.dart';

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