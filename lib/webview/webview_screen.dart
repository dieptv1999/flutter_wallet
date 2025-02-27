import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_wallet/webview/models/browser_model.dart';
import 'package:flutter_wallet/webview/models/webview_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'browser.dart';

late final WEB_ARCHIVE_DIR;

late final TAB_VIEWER_BOTTOM_OFFSET_1;
late final TAB_VIEWER_BOTTOM_OFFSET_2;
late final TAB_VIEWER_BOTTOM_OFFSET_3;

const TAB_VIEWER_TOP_OFFSET_1 = 0.0;
const TAB_VIEWER_TOP_OFFSET_2 = 10.0;
const TAB_VIEWER_TOP_OFFSET_3 = 20.0;

const TAB_VIEWER_TOP_SCALE_TOP_OFFSET = 250.0;
const TAB_VIEWER_TOP_SCALE_BOTTOM_OFFSET = 230.0;

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({Key? key}) : super(key: key);

  @override
  WebViewScreenState createState() => WebViewScreenState();
}

class WebViewScreenState extends State<WebViewScreen> {
  void launchWebView() async {
    WidgetsFlutterBinding.ensureInitialized();

    WEB_ARCHIVE_DIR = (await getApplicationSupportDirectory()).path;

    if (Platform.isIOS) {
      TAB_VIEWER_BOTTOM_OFFSET_1 = 130.0;
      TAB_VIEWER_BOTTOM_OFFSET_2 = 140.0;
      TAB_VIEWER_BOTTOM_OFFSET_3 = 150.0;
    } else {
      TAB_VIEWER_BOTTOM_OFFSET_1 = 110.0;
      TAB_VIEWER_BOTTOM_OFFSET_2 = 120.0;
      TAB_VIEWER_BOTTOM_OFFSET_3 = 130.0;
    }

    await FlutterDownloader.initialize(
        debug: true // optional: set false to disable printing logs to console
        );

    await Permission.camera.request();
    await Permission.microphone.request();
    await Permission.storage.request();
  }

  @override
  void initState() {
    launchWebView();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => WebViewModel(),
        ),
        ChangeNotifierProxyProvider<WebViewModel, BrowserModel>(
          update: (context, webViewModel, browserModel) {
            browserModel!.setCurrentWebViewModel(webViewModel);
            return browserModel;
          },
          create: (BuildContext context) => BrowserModel(null),
        ),
      ],
      child: MaterialApp(
          title: 'Browser Modal',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const Browser(),
          }),
    );
  }
}
