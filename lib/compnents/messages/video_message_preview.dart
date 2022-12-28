import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:zego_zimkit/services/services.dart';
import 'package:zego_zimkit/utils/custom_theme.dart';

class ZIMKitVideoMessagePreview extends StatelessWidget {
  const ZIMKitVideoMessagePreview(this.message, {Key? key}) : super(key: key);

  final ZIMKitMessage message;

  @override
  Widget build(BuildContext context) {
    final message = this.message.zim as ZIMVideoMessage;
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: message.videoFirstFrameLocalPath.isNotEmpty
              ? Image.file(
                  File(message.videoFirstFrameLocalPath),
                  fit: BoxFit.cover,
                )
              : CachedNetworkImage(
                  imageUrl: message.videoFirstFrameDownloadUrl,
                  fit: BoxFit.cover,
                  errorWidget: (context, _, __) => const Icon(Icons.error),
                  placeholder: (context, url) => const Icon(Icons.video_file_outlined),
                ),
        ),
        Container(
          height: 25,
          width: 25,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.play_arrow,
            size: 16,
            color: Colors.white,
          ),
        ),
        Visibility(
          visible: message.videoDuration > 0,
          child: Positioned(
              bottom: 8.h,
              right: 8.h,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 7.w),
                decoration: BoxDecoration(
                  color: white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  _printDuration(
                    Duration(seconds: message.videoDuration),
                  ),
                  style: Theme.of(context).textTheme.tooltip.copyWith(color: dark7),
                ),
              )),
        )
      ],
    );
  }

  String _printDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }
}
