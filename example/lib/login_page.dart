import 'dart:math';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';
import 'home_page.dart';
import 'utils.dart';

final String testRandomUserID = Random().nextInt(10000).toString();
final String testRandomUserName = randomName();

class ZIMKitDemoLoginPage extends StatefulWidget {
  const ZIMKitDemoLoginPage({Key? key}) : super(key: key);

  @override
  State<ZIMKitDemoLoginPage> createState() => _ZIMKitDemoLoginPageState();
}

class _ZIMKitDemoLoginPageState extends State<ZIMKitDemoLoginPage> {
  /// Users who use the same callID can in the same call.
  final userID = TextEditingController(text: testRandomUserID);
  final userName = TextEditingController(text: testRandomUserName);

  @override
  void initState() {
    super.initState();
    userID.text = testRandomUserID;
    userName.text = testRandomUserName;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: userID,
                        decoration: const InputDecoration(labelText: "user ID"),
                      ),
                      TextFormField(
                        controller: userName,
                        decoration:
                            const InputDecoration(labelText: "user name"),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await ZIMKit().connectUser(
                              id: userID.text, name: userName.text);
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (context) => const ZIMKitDemoHomePage(),
                            ),
                          );
                        },
                        child: const Text("login"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
