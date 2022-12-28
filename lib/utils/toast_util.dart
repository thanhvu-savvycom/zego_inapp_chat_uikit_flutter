import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_zimkit/compnents/internals/icon_defines.dart';
import 'package:zego_zimkit/utils/custom_theme.dart';

enum ToastType { SUCCESS, WARNING, ERROR, INFORM }

class ToastUtil {
  static void showToast(BuildContext context, String? text,
      {ToastType? type = ToastType.ERROR, bool? isPrefixIcon = true}) {
    Color backgroundColor = bgError;
    Color iconColor = danger2;
    Color textColor = neutral2;
    String iconData = PrebuiltChatIconUrls.iconWarning;
    if (type == ToastType.WARNING) {
      iconData = PrebuiltChatIconUrls.iconWarning;
      iconColor = orange;
      backgroundColor = bgWarning;
    } else if (type == ToastType.SUCCESS) {
      iconData = PrebuiltChatIconUrls.iconTickCircle;
      iconColor = success1;
      backgroundColor = bgSuccess;
    } else if (type == ToastType.INFORM) {
      iconData = PrebuiltChatIconUrls.iconNotification;
      iconColor = blue;
      backgroundColor = bgInform;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FToast fToast = FToast();
      fToast.init(context);
      fToast.removeQueuedCustomToasts();
      Widget toast = Container(
        width: 1.sw,
        margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.h),
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.r), color: backgroundColor),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isPrefixIcon == true
                ? Container(
                    margin: EdgeInsets.only(right: 10.w), child: PrebuiltChatImage.asset(iconData, height: 24.h, color: iconColor))
                : Container(),
            Expanded(
              child: Text(text ?? "", style: Theme.of(context).textTheme.subTitle.copyWith(color: textColor)),
            ),
            // SizedBox(
            //   width: 8.w,
            // ),
            // GestureDetector(
            //   onTap: () => fToast.removeCustomToast(),
            //   child: Icon(
            //     CupertinoIcons.xmark,
            //     size: 16.h,
            //     color: textColor,
            //   ),
            // )
          ],
        ),
      );

      if (text != null && text.isNotEmpty) {
        fToast.showToast(
          child: toast,
          gravity: ToastGravity.TOP,
          positionedToastBuilder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).padding.top,
              left: 0,
              right: 0,
              child: child,
            );
          },
          toastDuration: const Duration(seconds: 3),
        );
      }
    });
  }
}
