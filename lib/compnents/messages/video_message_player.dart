import 'dart:async';
import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zego_zimkit/compnents/common/single_tap_detector.dart';
import 'package:zego_zimkit/services/defines.dart';
import 'package:zego_zimkit/utils/custom_theme.dart';

class ZIMKitVideoMessagePlayer extends StatefulWidget {
  const ZIMKitVideoMessagePlayer(this.message, {Key? key}) : super(key: key);

  final ZIMKitMessage message;

  @override
  State<ZIMKitVideoMessagePlayer> createState() =>
      ZIMKitVideoMessagePlayerState();
}

class ZIMKitVideoMessagePlayerState extends State<ZIMKitVideoMessagePlayer> {
  BetterPlayerController? _betterPlayerController;
  YoutubePlayerController? _youtubeController;
  String? youtubeId;

  @override
  void dispose() async {
    _betterPlayerController?.dispose(forceDispose: true);
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    final ZIMVideoMessage message = widget.message.data.value as ZIMVideoMessage;
    youtubeId = YoutubePlayer.convertUrlToId(message.fileDownloadUrl);

    if (youtubeId == null) {
      BetterPlayerDataSource? betterPlayerDataSource;
      if (message.fileLocalPath.isNotEmpty && File(message.fileLocalPath).existsSync()) {
        betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.file, message.fileLocalPath);
      } else {
        betterPlayerDataSource = BetterPlayerDataSource(BetterPlayerDataSourceType.network, message.fileDownloadUrl);
      }

      _betterPlayerController = BetterPlayerController(
          const BetterPlayerConfiguration(
              autoPlay: true,
              showPlaceholderUntilPlay: false,
              // fullScreenByDefault: true,
              fit: BoxFit.contain,
              autoDetectFullscreenAspectRatio: true),
          betterPlayerDataSource: betterPlayerDataSource);
    } else {
      _youtubeController = YoutubePlayerController(
        initialVideoId: YoutubePlayer.convertUrlToId(youtubeId!) ?? '',
        flags: const YoutubePlayerFlags(
          useHybridComposition: false,
          forceHD: true,
          captionLanguage: 'vi',
        ),
      );
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Container(
              alignment: Alignment.center,
              color: black,
              child: youtubeId == null ? _normalVideoWidget() : _youtubeVideoWidget()),
          if (isPortrait)
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: EdgeInsets.only(top: 60.h, left: 20.w),
                child: SingleTapDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Icon(
                    CupertinoIcons.arrow_left,
                    color: white,
                    size: 22.w,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _normalVideoWidget() {
    return _betterPlayerController == null
        ? const SizedBox()
        : BetterPlayer(
            controller: _betterPlayerController!,
          );
  }

  Widget _youtubeVideoWidget() {
    return _youtubeController == null
        ? const SizedBox()
        : YoutubePlayer(
            aspectRatio: 16 / 9,
            bottomActions: [
              CurrentPosition(),
              10.horizontalSpace,
              ProgressBar(
                isExpanded: true,
                colors: ProgressBarColors(
                    playedColor: white,
                    handleColor: white,
                    bufferedColor: white.withOpacity(0.3),
                    backgroundColor: white.withOpacity(0.5)),
              ),
              10.horizontalSpace,
              RemainingDuration(),
              FullScreenButton(),
            ],
            controller: _youtubeController!);
  }
}
