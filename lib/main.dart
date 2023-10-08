import 'dart:convert';

import 'package:fire_fcm/firebase_options.dart';
import 'package:fire_fcm/notification_services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

// broadcast receiver listen when app in background
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

// hanlde background message
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print("notifications title in background:  ${message.notification!.title}");
    print("notifications body in background:   ${message.notification!.body}");
    print("notifications body in background:   ${message.data.toString()}");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirebaseFCM(),
    );
  }
}

class FirebaseFCM extends StatefulWidget {
  const FirebaseFCM({super.key});

  @override
  State<FirebaseFCM> createState() => _FirebaseFCMState();
}

class _FirebaseFCMState extends State<FirebaseFCM> {
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    // when app in background or termminate state
    notificationServices.setupInteractMessage(context);
//  referesh your device token if it is expire
    notificationServices.isTokenRefresh();
// get token of Device
    notificationServices.getDeviceToken().then((value) {
      if (kDebugMode) {
        print('device token:');
        print(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
            onPressed: () {
              notificationServices.getDeviceToken().then((value) async {
                // define payload
                var data = {
                  'to': value.toString(),

                  // notification title
                  'notification': {
                    'title': 'Sohail',
                    'body': 'Subscribe to my channel',
                    "sound": "jetsons_doorbell.mp3"
                  },
                  'android': {
                    'notification': {
                      'notification_count': 23,
                    },
                  },
                  // payload data
                  'data': {'type': 'msj', 'id': 'Sohail Anwar'}
                };

                await http.post(
                    Uri.parse('https://fcm.googleapis.com/fcm/send'),
                    body: jsonEncode(data),
                    headers: {
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization':
                          'key=AAAAungKYpI:APA91bGZRcKTfEtlly2vSyl3OSzBL9eowm4uja7wPmbG6NDA4icBrGdBtfW5fY2mxIEyF9qhZvPxF6J28P7yZ5pIep6cFOFTh5uU0YuZB8YzsUI2HjuWxHvyZWoa0T-rp56mbY1cv_cw'
                    });
              });
            },
            child: const Text("Send Nptification")),
      ),
    );
  }
}
