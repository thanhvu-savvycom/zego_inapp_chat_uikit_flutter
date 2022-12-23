import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zego_imkit/compnents/internals/icon_defines.dart';
import 'package:zego_imkit/services/services.dart';
import 'package:zego_imkit/utils/custom_theme.dart';

class ZegoTextMessage extends StatelessWidget {
  const ZegoTextMessage({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
  }) : super(key: key);

  final ZegoIMKitMessage message;
  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onLongPress;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ZIMMessage>(
      valueListenable: message.data,
      builder: (context, ZIMMessage msg, child) {
        ZIMTextMessage message = msg as ZIMTextMessage;
        return Flexible(
          child: GestureDetector(
              onTap: () => onPressed?.call(context, this.message, () {}),
              onLongPress: () => onLongPress?.call(context, this.message, () {
                    Clipboard.setData(ClipboardData(text: message.message));
                  }),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: message.isSender ? blue4 : neutral7,
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                ),
                child: Text(
                  message.message,
                  style: Theme.of(context).textTheme.body1.copyWith(color: message.isSender ? white : dark1),
                  textAlign: message.isSender ? TextAlign.right : TextAlign.left,
                ),
              )
              // Container(
              // decoration: BoxDecoration(
              //   color: Theme.of(context).primaryColor.withOpacity(message.isSender ? 1 : 0.1),
              //   borderRadius: BorderRadius.circular(18),
              // ),
              // padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              // child: Text(
              //   message.message,
              //   textAlign: TextAlign.left,
              //   style: TextStyle(color: message.isSender ? Colors.white : Theme.of(context).textTheme.bodyText1!.color),
              // ),
              // ),
              ),
        );
      },
    );
  }

  Widget _senderMessageWidget(BuildContext context, ZIMTextMessage message) {
    return Container(
      margin: EdgeInsets.only(right: 20.w),
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (4 / 5).sw),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                  style: Theme.of(context).textTheme.smallNormal.copyWith(color: dark7),
                ),
                7.horizontalSpace,
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: blue4,
                      borderRadius: BorderRadius.all(Radius.circular(16.r)),
                    ),
                    child: Text(
                      message.message,
                      style: Theme.of(context).textTheme.body1.copyWith(color: white),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
              ],
            ),
            4.verticalSpace,
            PrebuiltChatImage.asset(
                message.sentStatus == ZIMMessageSentStatus.success
                    ? PrebuiltChatIconUrls.iconSent
                    : PrebuiltChatIconUrls.iconSending,
                width: 12.r,
                height: 12.r)
          ],
        ),
      ),
    );
  }

  Widget _receiverMessageWidget(BuildContext context, ZIMTextMessage message) {
    return Container(
      margin: EdgeInsets.only(left: 20.w),
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: (4 / 5).sw),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            PrebuiltChatImage.asset(PrebuiltChatIconUrls.iconAvatar, width: 32.r, height: 32.r),
            12.horizontalSpace,
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: neutral7,
                  borderRadius: BorderRadius.all(Radius.circular(16.r)),
                ),
                child: Text(
                  message.message,
                  style: Theme.of(context).textTheme.body1,
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            7.horizontalSpace,
            Text(
              DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
              style: Theme.of(context).textTheme.smallNormal.copyWith(color: dark7),
            ),
          ],
        ),
      ),
    );
  }
}
