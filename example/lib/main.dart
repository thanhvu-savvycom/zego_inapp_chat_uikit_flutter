import 'package:flutter/material.dart';
import 'package:zego_imkit/zego_imkit.dart';
import 'login_page.dart';

const int ZEGO_APP_ID = 1320879700;
const String ZEGO_APP_SIGN = '858a0ac7130d9c1b32f52afd1e013bdc2ddd5f7e3c2ddb7eb27b2ece503bf769';

void main() {
  ZegoIMKit().init(
    appID: ZEGO_APP_ID, // your appid
    appSign: ZEGO_APP_SIGN, // your appSign
  );
  runApp(const ZegoIMKitDemo());
}

class ZegoIMKitDemo extends StatelessWidget {
  const ZegoIMKitDemo({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zego IMKit Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const ZegoIMKitDemoLoginPage(),
    );
  }
}
