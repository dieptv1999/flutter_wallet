import 'dart:io';
import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:device_preview/device_preview.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_wallet/ui/screen/notification_page.dart';
import 'package:flutter_wallet/ui/screen/sign_in.dart';
import 'package:flutter_wallet/ui/screen/sign_up.dart';
import 'package:flutter_wallet/util/constant.dart';
import 'package:flutter_wallet/util/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print(
      "Handling a background message: ${message.messageId} ${message.notification?.body} ${Platform.isIOS ? message.notification?.apple?.imageUrl : message.notification?.android?.imageUrl}");
  Random random = Random.secure();
  AwesomeNotifications().createNotification(
      content: NotificationContent(
          channelKey: 'basic_channel',
          body: message.notification?.body,
          title: message.notification?.title,
          notificationLayout: NotificationLayout.BigPicture,
          bigPicture: Platform.isIOS
              ? message.notification?.apple?.imageUrl
              : message.notification?.android?.imageUrl,
          id: random.nextInt(10000)));
}

void init() async {
  WidgetsFlutterBinding.ensureInitialized();
  final AwesomeNotifications awesomeNotifications = AwesomeNotifications();
  awesomeNotifications.initialize(null, [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests',
        defaultColor: const Color(0xFF9D50DD),
        ledColor: Colors.white)
  ]);
  await awesomeNotifications.isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });

  await Firebase.initializeApp();
  FirebaseMessaging.onMessage.listen(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  FirebaseMessaging.instance.getToken().then((value) => print(value));
}

void main() {
  init();
  runApp(
    DevicePreview(
      enabled: kIsWeb ? false : !kReleaseMode,
      builder: (_) => const MyApp(),
    ),
  );
}

ThemeManager _themeManager = ThemeManager();

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey(debugLabel: "Main Navigator");

  @override
  void initState() {
    _themeManager.addListener(themeListener);
    AwesomeNotifications()
        .actionStream
        .listen((ReceivedNotification receivedNotification) {
      navigatorKey.currentState?.pushNamed("notification", arguments: {
        // id: receivedNotification.id
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _themeManager.removeListener(themeListener);
    super.dispose();
  }

  themeListener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      title: 'Wallet',
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.deepOrange,
        brightness: Brightness.light,
        accentColor: Colors.deepOrangeAccent,
      ),
      darkTheme: ThemeData(
        primaryColor: Colors.white,
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.deepPurple,
        brightness: Brightness.dark,
      ),
      routes: <String, WidgetBuilder>{
        "home": (BuildContext context) => const SignInPage(),
        "notification": (BuildContext context) => const NotificationPage(),
      },
      initialRoute: "home",
      // home: const SignInPage(),
    );
  }
}
