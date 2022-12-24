import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zego_imkit/compnents/internals/icon_defines.dart';
import 'package:zego_imkit/services/services.dart';
import 'package:zego_imkit/utils/custom_theme.dart';

import '../common/common.dart';
import 'audio_message.dart';
import 'file_message.dart';
import 'image_message.dart';
import 'text_message.dart';
import 'video_message.dart';
import 'widgets/widgets.dart';

export 'audio_message.dart';
export 'text_message.dart';
export 'video_message.dart';

class ZegoIMKitMessageWidget extends StatelessWidget {
  const ZegoIMKitMessageWidget({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
  }) : super(key: key);

  final ZegoIMKitMessage message;
  final Widget Function(BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)? avatarBuilder;
  final Widget Function(BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)? statusBuilder;
  final Widget Function(BuildContext context, ZegoIMKitMessage message, Widget defaultWidget)? timestampBuilder;
  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onPressed;
  final void Function(BuildContext context, ZegoIMKitMessage message, Function defaultAction)? onLongPress;

  // TODO default onPressed onLongPress action
  // TODO custom meesage
  Widget buildMessage(BuildContext context, ZegoIMKitMessage message) {
    switch (message.data.value.type) {
      case ZIMMessageType.text:
        return ZegoTextMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.audio:
        return ZegoAudioMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.video:
        return ZegoVideoMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.file:
        return ZegoFileMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.image:
        return ZegoImageMessage(onLongPress: onLongPress, onPressed: onPressed, message: message);

      default:
        return Text(message.data.value.type.toString());
    }
  }

  Widget buildStatus(BuildContext context, ZegoIMKitMessage message) {
    // Widget defaultStatusWidget = ZegoMessageStatusDot(message);
    Widget defaultStatusWidget = ValueListenableBuilder<ZIMMessage>(
        valueListenable: message.data,
        builder: (context, ZIMMessage message, child) {
          String? icon;
          if (message.sentStatus == ZIMMessageSentStatus.success) {
            icon = PrebuiltChatIconUrls.iconSent;
          } else if (message.sentStatus == ZIMMessageSentStatus.failed) {
            icon = PrebuiltChatIconUrls.iconWarning;
          } else {
            icon = PrebuiltChatIconUrls.iconSending;
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              4.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  PrebuiltChatImage.asset(icon, width: 12.r, height: 12.r),
                  Visibility(
                    visible: message.sentStatus == ZIMMessageSentStatus.failed,
                    child: Padding(
                      padding: EdgeInsets.only(left: 6.w),
                      child: Text(
                        "Không gửi được tin nhắn",
                        style: Theme.of(context).textTheme.smallNormal.copyWith(color: danger, height: 1),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        });
    return statusBuilder?.call(context, message, defaultStatusWidget) ?? defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context, ZegoIMKitMessage message) {
    Widget defaultAvatarWidget = Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: ZegoIMKitAvatar(userID: message.senderUserID),
    );
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ?? defaultAvatarWidget;
  }

  Widget buildTime(BuildContext context, ZegoIMKitMessage message) {
    return ValueListenableBuilder<ZIMMessage>(
        valueListenable: message.data,
        builder: (context, ZIMMessage message, child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              child: Text(
                DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                style: Theme.of(context).textTheme.smallNormal.copyWith(color: dark7),
              ));
        });
  }

  // TODO how to custom layout
  // TODO timestamp
  Widget localMessage(BuildContext context, ZegoIMKitMessage message) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            buildTime(context, message),
            buildMessage(context, message),
          ],
        ),
        // buildAvatar(context, message),
        buildStatus(context, message),
      ],
    );
  }

  Widget remoteMessage(BuildContext context, ZegoIMKitMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        buildAvatar(context, message),
        buildMessage(context, message),
        buildTime(context, message),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (message.isSender) ? localMessage(context, message) : remoteMessage(context, message);
  }
}
