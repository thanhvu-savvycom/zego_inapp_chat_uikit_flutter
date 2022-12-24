import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_imkit/utils/custom_theme.dart';
import '../compnents/common/single_tap_detector.dart';
import 'utils.dart';

const int MAX_SEND_IMAGE_CHAT = 5;
const int LIMIT_CHAT_IMAGES_IN_MB = 50;
const int LIMIT_CHAT_VIDEO_IN_MB = 100;

class PickImagesUtils {
  static String msg_open_image_setting = "Làm ơn mở cài đặt ứng dụng và cho phép truy cập máy ảnh và bộ sưu tập.";
  static String take_photo = "Chụp ảnh";
  static String open_gallery = "Chọn trong thư viện";
  static String cancel = "Huỷ";
  static String label_pick_image = "Chọn ảnh";
  static String label_pick_video = "Chọn video";
  static String label_record_video = "Quay video";

  static showAvatarActionSheet(
    BuildContext context, {
    ValueChanged<List<String>>? onResultImagesFromGallery,
    ValueChanged<String>? onResultImageFromCamera,
    required ImagePicker imagePicker,
  }) async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        imagePicker.pickImage(source: ImageSource.camera).then((file) {
                          if (!isEmpty(file)) {
                            onResultImageFromCamera?.call(file?.path ?? '');
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(take_photo,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor))),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        imagePicker.pickMultiImage().then((files) {
                          onResultImagesFromGallery?.call(files.map((e) => e.path).toList());
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text(open_gallery,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)))
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(cancel, style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)),
                )));
  }

  static takePictureFromCamera(
    BuildContext context, {
    ValueChanged<XFile>? onResultImageFromCamera,
    required ImagePicker imagePicker,
  }) async {
    if (Platform.isIOS && await Permission.camera.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    var permission = await Permission.camera.request();
    if (Platform.isAndroid && permission.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    if (permission.isGranted) {
      imagePicker.pickImage(source: ImageSource.camera).then((file) {
        if (!isEmpty(file)) {
          onResultImageFromCamera?.call(file!);
        }
      });
    }
  }

  static recordVideo(
    BuildContext context, {
    ValueChanged<XFile>? onResultRecordVideo,
    required ImagePicker imagePicker,
  }) async {
    if (Platform.isIOS &&
        (await Permission.camera.isPermanentlyDenied || await Permission.microphone.isPermanentlyDenied)) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    var permissionCamera = await Permission.camera.request();
    var permissionMicro = await Permission.microphone.request();
    if (Platform.isAndroid && (permissionCamera.isPermanentlyDenied || permissionMicro.isPermanentlyDenied)) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    if (permissionCamera.isGranted && permissionMicro.isGranted) {
      imagePicker
          .pickVideo(
              source: ImageSource.camera,
              maxDuration: const Duration(minutes: 1),
              preferredCameraDevice: CameraDevice.rear)
          .then((file) {
        if (!isEmpty(file)) {
          onResultRecordVideo?.call(file!);
        }
      });
    }
  }

  static takeMultiplePictureOrVideoFromGallery(
    BuildContext context, {
    ValueChanged<List<XFile>>? onResultImagesFromGallery,
    ValueChanged<XFile?>? onResultVideoFromGallery,
    required ImagePicker imagePicker,
  }) async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        takeMultiplePictureGallery(context,
                            imagePicker: imagePicker, onResultImagesFromGallery: onResultImagesFromGallery);
                        Navigator.of(context).pop();
                      },
                      child: Text(label_pick_image,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor))),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        takeVideoGallery(context,
                            imagePicker: imagePicker, onResultVideoFromGallery: onResultVideoFromGallery);
                        Navigator.of(context).pop();
                      },
                      child: Text(label_pick_video,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)))
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(cancel,
                      style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)),
                )));
  }

  static takeMultiplePictureGallery(
    BuildContext context, {
    ValueChanged<List<XFile>>? onResultImagesFromGallery,
    required ImagePicker imagePicker,
  }) async {
    //ios
    if (Platform.isIOS &&
        (await Permission.photos.isPermanentlyDenied || await Permission.photosAddOnly.isPermanentlyDenied)) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }

    var permission = await Permission.storage.request();

    //android
    if (Platform.isAndroid && permission.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }

    if ((Platform.isAndroid && permission.isGranted) ||
        (Platform.isIOS &&
            (await Permission.photos.request().isGranted ||
                await Permission.photosAddOnly.request().isGranted ||
                await Permission.photos.request().isLimited ||
                await Permission.photosAddOnly.request().isLimited))) {
      imagePicker.pickMultiImage().then((files) {
        onResultImagesFromGallery?.call(files);
      });
      return;
    }
  }

  static takeVideoGallery(
    BuildContext context, {
    ValueChanged<XFile?>? onResultVideoFromGallery,
    required ImagePicker imagePicker,
  }) async {
    //ios
    if (Platform.isIOS &&
        (await Permission.photos.isPermanentlyDenied || await Permission.photosAddOnly.isPermanentlyDenied)) {
      showPopupYesNoButton(
          context: context,
          contentText: "",
          submitCallback: () {
            openAppSettings();
          });
      return;
    }

    var permission = await Permission.storage.request();

    //android
    if (Platform.isAndroid && permission.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: msg_open_image_setting,
          submitCallback: () {
            openAppSettings();
          });
      return;
    }

    if ((Platform.isAndroid && permission.isGranted) ||
        (Platform.isIOS &&
            (await Permission.photos.request().isGranted ||
                await Permission.photosAddOnly.request().isGranted ||
                await Permission.photos.request().isLimited ||
                await Permission.photosAddOnly.request().isLimited))) {
      imagePicker.pickVideo(source: ImageSource.gallery).then((files) {
        onResultVideoFromGallery?.call(files);
      });
      return;
    }
  }

  static pickCameraOrRecordVideo(
    BuildContext context, {
    ValueChanged<XFile>? onResultImageFromCamera,
    ValueChanged<XFile?>? onResultRecordVideo,
    required ImagePicker imagePicker,
  }) async {
    showCupertinoModalPopup(
        context: context,
        builder: (_) => CupertinoActionSheet(
                actions: [
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        takePictureFromCamera(context,
                            imagePicker: imagePicker, onResultImageFromCamera: onResultImageFromCamera);
                        Navigator.of(context).pop();
                      },
                      child: Text(take_photo,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor))),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        recordVideo(context, imagePicker: imagePicker, onResultRecordVideo: onResultRecordVideo);
                        Navigator.of(context).pop();
                      },
                      child: Text(label_record_video,
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)))
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(cancel,
                      style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)),
                )));
  }

  static Future<bool> isValidSizeOfFiles({required List<XFile> files, required int limitSizeInMB}) async {
    int totalSizeInBytes = 0;
    for (var file in files) {
      totalSizeInBytes += await file.length();
    }
    double sizeInMB = totalSizeInBytes / (1024 * 1024);
    print('size of video: $sizeInMB');
    return sizeInMB <= limitSizeInMB;
  }

  static Future showPopupYesNoButton(
      {required BuildContext context,
      required String contentText,
      String? submitText,
      String? cancelText,
      VoidCallback? submitCallback,
      VoidCallback? cancelCallback,
      bool dismissible = false,
      String? titleText}) {
    return showDialog(
        barrierDismissible: dismissible,
        context: context,
        builder: (context) {
          return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.r),
              ),
              title: Text(titleText ?? "", style: Theme.of(context).textTheme.title4),
              content: Text(
                contentText,
                style: Theme.of(context).textTheme.subTitle.copyWith(color: dark1),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SingleTapDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        cancelCallback?.call();
                      },
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(15.h),
                          child: Text(
                            cancelText ?? "Không",
                            style: Theme.of(context).textTheme.labelHighLight.copyWith(color: darkRed),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    SingleTapDetector(
                      onTap: () {
                        if (submitCallback != null) submitCallback();
                        Navigator.of(context).pop();
                      },
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(15.h),
                          child: Text(
                            submitText ?? "Có",
                            style: Theme.of(context).textTheme.labelHighLight.copyWith(color: darkBlue),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                )
              ]);
        });
  }

  static bool isEmpty(Object? text) {
    if (text is String) return text.isEmpty;
    if (text is List) return text.isEmpty;
    return text == null;
  }
}
