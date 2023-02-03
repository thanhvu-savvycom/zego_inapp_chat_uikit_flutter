import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:zego_zimkit/compnents/internals/icon_defines.dart';
import 'package:zego_zimkit/services/services.dart';
import 'package:zego_zimkit/utils/custom_theme.dart';

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

class ZIMKitMessageWidget extends StatelessWidget {
  const ZIMKitMessageWidget({
    Key? key,
    required this.message,
    this.onPressed,
    this.onLongPress,
    this.statusBuilder,
    this.avatarBuilder,
    this.timestampBuilder,
    this.isSameUserPreviousMsg = false,
    this.isSameUserNextMsg = false,
  }) : super(key: key);

  final ZIMKitMessage message;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      avatarBuilder;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      statusBuilder;
  final Widget Function(
          BuildContext context, ZIMKitMessage message, Widget defaultWidget)?
      timestampBuilder;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onPressed;
  final void Function(
          BuildContext context, ZIMKitMessage message, Function defaultAction)?
      onLongPress;
  final bool isSameUserPreviousMsg, isSameUserNextMsg;

  // TODO default onPressed onLongPress action
  // TODO custom meesage
  Widget buildMessage(BuildContext context, ZIMKitMessage message) {
    switch (message.data.value.type) {
      case ZIMMessageType.text:
        return ZIMKitTextMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.audio:
        return ZIMKitAudioMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.video:
        return ZIMKitVideoMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.file:
        return ZIMKitFileMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);
      case ZIMMessageType.image:
        return ZIMKitImageMessage(
            onLongPress: onLongPress, onPressed: onPressed, message: message);

      default:
        return Text(message.data.value.type.toString());
    }
  }

  Widget buildStatus(BuildContext context, ZIMKitMessage message) {
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
                        style: Theme.of(context)
                            .textTheme
                            .smallNormal
                            .copyWith(color: danger, height: 1),
                      ),
                    ),
                  )
                ],
              ),
            ],
          );
        });
    return statusBuilder?.call(context, message, defaultStatusWidget) ??
        defaultStatusWidget;
  }

  Widget buildAvatar(BuildContext context, ZIMKitMessage message) {
    Widget defaultAvatarWidget = Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: ZIMKitAvatar(userID: message.senderUserID),
    );
    return avatarBuilder?.call(context, message, defaultAvatarWidget) ??
        defaultAvatarWidget;
  }

  Widget buildTime(BuildContext context, ZIMKitMessage message) {
    return ValueListenableBuilder<ZIMMessage>(
        valueListenable: message.data,
        builder: (context, ZIMMessage message, child) {
          return Padding(
              padding: EdgeInsets.symmetric(horizontal: 7.w),
              child: Text(
                DateFormat.Hm().format(
                    DateTime.fromMillisecondsSinceEpoch(message.timestamp)),
                style: Theme.of(context)
                    .textTheme
                    .smallNormal
                    .copyWith(color: dark7),
              ));
        });
  }

  Widget buildSenderName(BuildContext context, ZIMKitMessage message) {
    return FutureBuilder(
      // TODO auto update user's avatar
      future: ZIMKit().queryUser(message.senderUserID),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: EdgeInsets.only(bottom: 5.h),
            child: Text(
              (snapshot.data as ZIMUserFullInfo).baseInfo.userName ?? "",
              style: Theme.of(context)
                  .textTheme
                  .smallNormal
                  .copyWith(color: dark9),
            ),
          );
        } else {
          return Container();
          // return PrebuiltChatImage.asset(
          //     PrebuiltChatIconUrls.iconAvatar, width: width, height: height);
        }
      },
    );
  }

  // TODO how to custom layout
  // TODO timestamp
  Widget localMessage(BuildContext context, ZIMKitMessage message) {
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
        Visibility(
            visible: !isSameUserNextMsg, child: buildStatus(context, message)),
      ],
    );
  }

  Widget remoteMessage(BuildContext context, ZIMKitMessage message) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // buildAvatar(context, message),
        Padding(
          padding: EdgeInsets.only(right: 12.w),
          child: Icon(
            CupertinoIcons.person_circle_fill,
            size: 32.r,
          ),
        ),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildSenderName(context, message),
              buildMessage(context, message),
            ],
          ),
        ),
        buildTime(context, message),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return (message.isSender)
        ? localMessage(context, message)
        : remoteMessage(context, message);
  }
}
