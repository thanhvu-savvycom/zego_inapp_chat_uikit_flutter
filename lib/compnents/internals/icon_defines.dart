// Flutter imports:
import 'package:flutter/material.dart';

class PrebuiltChatImage {
  static Image asset(String name, {double? height, double? width, Color? color}) {
    return Image.asset(
      name,
      package: "zego_imkit",
      height: height,
      width: width,
      color: color,
    );
  }
}

class PrebuiltChatIconUrls {
  static const String iconPickCamera = 'assets/icons/ic_pick_camera.png';
  static const String iconPickGallery = 'assets/icons/ic_pick_gallery.png';
  static const String iconPickImage = 'assets/icons/ic_pick_image.png';
  static const String iconAvatar = 'assets/icons/ic_avatar_receiver.png';
  static const String iconSend = 'assets/icons/ic_send.png';
  static const String iconSent = 'assets/icons/ic_sent.png';
  static const String iconSending = 'assets/icons/ic_sending.png';
  static const String iconWarning = 'assets/icons/ic_warning.png';
  static const String iconNotification = 'assets/icons/ic_notification.png';
  static const String iconTickCircle = 'assets/icons/ic_tick_circle.png';
}
