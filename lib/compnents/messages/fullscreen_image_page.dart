import 'dart:io';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FullscreenImagePage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialPosition;
  final bool isNetwork;

  const FullscreenImagePage({Key? key, required this.imageUrls, this.isNetwork = true, this.initialPosition = 0})
      : super(key: key);

  @override
  _FullscreenImagePageState createState() => _FullscreenImagePageState();
}

class _FullscreenImagePageState extends State<FullscreenImagePage> {
  late ExtendedPageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = ExtendedPageController(initialPage: widget.initialPosition);
    // SystemChrome.setEnabledSystemUIOverlays([]);
  }

  @override
  void dispose() {
    //SystemChrome.restoreSystemUIOverlays();
    // SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Center(
            child: ExtendedImageGesturePageView.builder(
              itemCount: widget.imageUrls.length,
              controller: _pageController,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => widget.isNetwork
                  ? ExtendedImage.network(
                      widget.imageUrls[index],
                      fit: BoxFit.contain,
                      enableLoadState: true,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) =>
                          GestureConfig(inPageView: true, initialScale: 1.0, cacheGesture: false),
                    )
                  : ExtendedImage.file(
                      File(widget.imageUrls[index]),
                      fit: BoxFit.contain,
                      enableLoadState: true,
                      mode: ExtendedImageMode.gesture,
                      initGestureConfigHandler: (state) =>
                          GestureConfig(inPageView: true, initialScale: 1.0, cacheGesture: false),
                    ),
            ),
          ),
          Positioned(
              left: 5.w,
              top: 35.w,
              child: IconButton(icon: const Icon(CupertinoIcons.xmark), onPressed: () => Navigator.of(context).pop()))
        ],
      ),
    );
  }
}
