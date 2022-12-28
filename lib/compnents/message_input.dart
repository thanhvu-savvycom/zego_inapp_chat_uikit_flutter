import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_zimkit/utils/toast_util.dart';

import '../services/services.dart';
import '../utils/custom_theme.dart';
import '../utils/pick_images_utils.dart';
import 'common/single_tap_detector.dart';
import 'internals/icon_defines.dart';
import 'messages/widgets/widgets.dart';
import 'package:zego_zimkit/compnents/messages/widgets/widgets.dart';
import 'package:zego_zimkit/services/services.dart';

class ZIMKitMessageInput extends StatefulWidget {
  const ZIMKitMessageInput({
    Key? key,
    required this.conversationID,
    this.conversationType = ZIMConversationType.peer,
    this.onMessageSent,
    this.preMessageSending,
    this.editingController,
    this.showPickFileButton = true,
    this.actions = const [],
    this.inputDecoration,
    this.theme,
    this.appName
  }) : super(key: key);

  /// The conversationID of the conversation to send message.
  final String conversationID;

  /// The conversationType of the conversation to send message.
  final ZIMConversationType conversationType;

  /// By default, [ZegoMessageInput] will show a button to pick file.
  /// If you don't want to show this button, set [showPickFileButton] to false.
  final bool showPickFileButton;

  /// To add your own action, use the [actions] parameter like this:
  ///
  /// use [actions] like this to add your custom actions:
  ///
  /// actions: [
  ///   ZIMKitMessageInputAction.left(IconButton(
  ///     icon: Icon(
  ///       Icons.mic,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.leftInside(IconButton(
  ///     icon: Icon(
  ///       Icons.sentiment_satisfied_alt_outlined,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.rightInside(IconButton(
  ///     icon: Icon(
  ///       Icons.cabin,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  ///   ZIMKitMessageInputAction.right(IconButton(
  ///     icon: Icon(
  ///       Icons.sd,
  ///       color: Theme.of(context).textTheme.bodyText1!.color!.withOpacity(0.64),
  ///     ),
  ///     onPressed: () {},
  ///   )),
  /// ],
  final List<ZIMKitMessageInputAction>? actions;

  /// Called when a message is sent.
  final void Function(ZIMKitMessage)? onMessageSent;

  /// Called before a message is sent.
  final FutureOr<ZIMKitMessage> Function(ZIMKitMessage)? preMessageSending;

  /// The TextField's decoration.
  final InputDecoration? inputDecoration;

  /// The [TextEditingController] to use. if not provided, a default one will be created.
  final TextEditingController? editingController;

  // theme
  final ThemeData? theme;

  final String? appName;

  @override
  State<ZIMKitMessageInput> createState() => _ZIMKitMessageInputState();
}

class _ZIMKitMessageInputState extends State<ZIMKitMessageInput> {
  // TODO RestorableTextEditingController
  final TextEditingController _defaultEditingController =
      TextEditingController();
  TextEditingController get _editingController =>
      widget.editingController ?? _defaultEditingController;

  final ValueNotifier<bool> isTyping = ValueNotifier(false);

  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: widget.theme ?? Theme.of(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        decoration: const BoxDecoration(color: Colors.white
            // color: Theme.of(context).scaffoldBackgroundColor,
            // boxShadow: [
            //   BoxShadow(
            //     offset: const Offset(0, 4),
            //     blurRadius: 32,
            //     color: Theme.of(context).primaryColor.withOpacity(0.15),
            //   ),
            // ],
            ),
        child: SafeArea(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ...buildActions(ZIMKitMessageInputActionLocation.left),
              SingleTapDetector(
                onTap: () {
                  PickImagesUtils.pickCameraOrRecordVideo(
                    context,
                    imagePicker: imagePicker,
                    onResultImageFromCamera: (file) {
                      if (file != null) {
                        onResultListMedia([file], true);
                      }
                    },
                    onResultRecordVideo: (file) {
                      if (file != null) {
                        onResultListMedia([file], false);
                      }
                    },
                  );
                  // ZegoIMKit().pickFiles().then((files) {
                  //   ZegoIMKit().sendMediaMessage(
                  //     widget.conversationID,
                  //     widget.conversationType,
                  //     files,
                  //     onMessageSent: widget.onMessageSent,
                  //     preMessageSending: widget.preMessageSending,
                  //   );
                  // });
                },
                child: PrebuiltChatImage.asset(
                  PrebuiltChatIconUrls.iconPickCamera,
                  width: 24.r,
                  height: 24.r,
                ),
              ),
              20.horizontalSpace,
              SingleTapDetector(
                onTap: () {
                  PickImagesUtils.takeMultiplePictureOrVideoFromGallery(
                    context,
                    imagePicker: imagePicker,
                    onResultImagesFromGallery: (images) {
                      onResultListMedia(images, true);
                    },
                    onResultVideoFromGallery: (file) {
                      if (file != null) {
                        onResultListMedia([file], false);
                      }
                    },
                  );
                  // ZegoIMKit().pickFiles().then((files) {
                  //   ZegoIMKit().sendMediaMessage(
                  //     widget.conversationID,
                  //     widget.conversationType,
                  //     files,
                  //     onMessageSent: widget.onMessageSent,
                  //     preMessageSending: widget.preMessageSending,
                  //   );
                  // });
                },
                child: PrebuiltChatImage.asset(
                  PrebuiltChatIconUrls.iconPickGallery,
                  width: 24.r,
                  height: 24.r,
                ),
              ),
              18.horizontalSpace,
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ...buildActions(ZIMKitMessageInputActionLocation.leftInside),
                    Expanded(
                      child: TextField(
                        onSubmitted: (value) => sendTextMessage(),
                        controller: _editingController,
                        onChanged: (value) => isTyping.value = value.isNotEmpty,
                        maxLength: 500,
                        maxLines: 5,
                        minLines: 1,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        cursorColor: dark1,
                        style: Theme.of(context).textTheme.subTitle.copyWith(
                              color: dark1,
                            ),
                        decoration: widget.inputDecoration ??
                            InputDecoration(
                              counterText: "",
                              hintText: 'Nhập tin nhắn',
                              filled: true,
                              fillColor: neutral7,
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              contentPadding: EdgeInsets.all(12.w),
                              hintStyle: Theme.of(context).textTheme.subTitle.copyWith(
                                color: neutral5,
                              ),
                            ),
                      ),
                    ),

                    // ValueListenableBuilder<bool>(
                    //   valueListenable: isTyping,
                    //   builder: (context, isTyping, child) {
                    //     return Builder(
                    //       builder: (context) {
                    //         if (isTyping) {
                    //           return Container(
                    //             height: 32,
                    //             width: 32,
                    //             decoration: BoxDecoration(
                    //               color: Theme.of(context).primaryColor,
                    //               shape: BoxShape.circle,
                    //             ),
                    //             child: IconButton(
                    //               padding: EdgeInsets.zero,
                    //               icon: const Icon(Icons.send, size: 16, color: Colors.white),
                    //               onPressed: () async {
                    //                 sendTextMessage();
                    //               },
                    //             ),
                    //           );
                    //         } else {
                    //           return Row(
                    //             children: [
                    //               if (widget.showPickFileButton)
                    //                 ZegoIMKitPickFileButton(
                    //                   onFilePicked: (List<PlatformFile> files) {
                    //                     ZegoIMKit().sendMediaMessage(
                    //                       widget.conversationID,
                    //                       widget.conversationType,
                    //                       files,
                    //                       onMessageSent: widget.onMessageSent,
                    //                       preMessageSending: widget.preMessageSending,
                    //                     );
                    //                   },
                    //                 ),
                    //               ...buildActions(ZegoMessageInputActionLocation.rightInside),
                    //             ],
                    //           );
                    //         }
                    //       },
                    //     );
                    //   },
                    // ),
                  ],
                ),
              ),
              16.horizontalSpace,
              ValueListenableBuilder<bool>(
                valueListenable: isTyping,
                builder: (context, isTyping, child) {
                  return SingleTapDetector(
                    onTap: isTyping
                        ? () {
                            sendTextMessage();
                          }
                        : null,
                    child: PrebuiltChatImage.asset(PrebuiltChatIconUrls.iconSend,
                        width: 32.r, height: 32.r, color: isTyping ? blue3 : dark11),
                  );
                },
              ),
              ...buildActions(ZIMKitMessageInputActionLocation.right),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendTextMessage() async {
    ZIMKit().sendTextMessage(
      widget.conversationID,
      widget.conversationType,
      _editingController.text,
      onMessageSent: widget.onMessageSent,
      preMessageSending: widget.preMessageSending,
    );
    _editingController.clear();
    isTyping.value = false;
    // TODO mac auto focus or not
    // TODO mobile auto focus or not
  }

  List<Widget> buildActions(ZIMKitMessageInputActionLocation location) {
    return widget.actions?.where((element) => element.location == location).map((e) => e.child).toList() ?? [];
  }

  void onResultListMedia(List<XFile> images, bool isImage) async {
    if (images.isEmpty) return;
    if (images.length > MAX_SEND_IMAGE_CHAT) {
      ToastUtil.showToast(context, "Chỉ được tải lên tối đa ${MAX_SEND_IMAGE_CHAT.toString()} ${isImage ? "ảnh" : "video"}!");
      return;
    }
    bool isValidSize =
    await PickImagesUtils.isValidSizeOfFiles(files: images, limitSizeInMB: LIMIT_CHAT_IMAGES_IN_MB);
    if (!isValidSize) {
      ToastUtil.showToast(context, "Tệp vượt quá giới hạn, xin vui lòng thử lại");
      return;
    }
    /*
    Call api send images
    */
    ZIMKit().sendMediaMessage2(
      widget.conversationID,
      widget.conversationType,
      images,
      onMessageSent: widget.onMessageSent,
      preMessageSending: widget.preMessageSending,
    );
  }
}

enum ZIMKitMessageInputActionLocation { left, right, leftInside, rightInside }

class ZIMKitMessageInputAction {
  const ZIMKitMessageInputAction(this.child,
      [this.location = ZIMKitMessageInputActionLocation.rightInside]);
  const ZIMKitMessageInputAction.left(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.left);
  const ZIMKitMessageInputAction.right(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.right);
  const ZIMKitMessageInputAction.leftInside(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.leftInside);
  const ZIMKitMessageInputAction.rightInside(Widget child)
      : this(child, ZIMKitMessageInputActionLocation.rightInside);

  final Widget child;
  final ZIMKitMessageInputActionLocation location;
}
