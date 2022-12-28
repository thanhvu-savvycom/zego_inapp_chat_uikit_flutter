import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import '../internals/icon_defines.dart';

class ZIMKitAvatar extends StatelessWidget {
  const ZIMKitAvatar(
      {Key? key, required this.userID, this.height, this.width})
      : super(key: key);
  final String userID;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
        return SizedBox(
          width: width ?? 32.r,
          height: height ?? 32.r,
          child: FutureBuilder(
            // TODO auto update user's avatar
            future: ZIMKit().queryUser(userID),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return (snapshot.data as ZIMUserFullInfo).icon;
              } else {
                return PrebuiltChatImage.asset(
                    PrebuiltChatIconUrls.iconAvatar, width: width, height: height);
              }
            },
          ),
        );
      },
    );
  }
}
