import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zego_imkit/utils/custom_theme.dart';
import '../compnents/common/single_tap_detector.dart';
import 'utils.dart';

class PickImagesUtils {
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
                          if (file != null) {
                            onResultImageFromCamera?.call(file.path);
                          }
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("Chụp ảnh",
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor))),
                  CupertinoActionSheetAction(
                      onPressed: () async {
                        imagePicker.pickMultiImage().then((files) {
                          onResultImagesFromGallery?.call(files.map((e) => e.path).toList());
                        });
                        Navigator.of(context).pop();
                      },
                      child: Text("Chọn trong thư viện",
                          style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)))
                ],
                cancelButton: CupertinoActionSheetAction(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text("Huỷ", style: Theme.of(context).textTheme.subTitle.copyWith(color: actionTextColor)),
                )));
  }

  static takePictureFromCamera(
    BuildContext context, {
    ValueChanged<String>? onResultImageFromCamera,
    required ImagePicker imagePicker,
  }) async {
    if (Platform.isIOS && await Permission.camera.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: "Làm ơn mở cài đặt ứng dụng và cho phép truy cập máy ảnh và bộ sưu tập.",
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    var permission = await Permission.camera.request();
    if (Platform.isAndroid && permission.isPermanentlyDenied) {
      showPopupYesNoButton(
          context: context,
          contentText: "Làm ơn mở cài đặt ứng dụng và cho phép truy cập máy ảnh và bộ sưu tập.",
          submitCallback: () {
            openAppSettings();
          });
      return;
    }
    if (permission.isGranted) {
      imagePicker.pickImage(source: ImageSource.camera).then((file) {
        if (file != null) {
          onResultImageFromCamera?.call(file.path);
        }
      });
    }
  }

  static takeMultiplePictureFromGallery(
    BuildContext context, {
    ValueChanged<List<String>>? onResultImagesFromGallery,
    required ImagePicker imagePicker,
  }) async {
    //ios
    if (Platform.isIOS &&
        (await Permission.photos.isPermanentlyDenied || await Permission.photosAddOnly.isPermanentlyDenied)) {
      showPopupYesNoButton(
          context: context,
          contentText: "Làm ơn mở cài đặt ứng dụng và cho phép truy cập máy ảnh và bộ sưu tập.",
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
          contentText: "Làm ơn mở cài đặt ứng dụng và cho phép truy cập máy ảnh và bộ sưu tập.",
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
        onResultImagesFromGallery?.call(files.map((e) => e.path).toList());
      });
      return;
    }
  }

  static Future<bool> isValidSizeOfFiles({required List<XFile> files, required int limitSizeInMB}) async {
    int totalSizeInBytes = 0;
    for (var file in files) {
      totalSizeInBytes += await file.length();
    }
    double sizeInMB = totalSizeInBytes / (1024 * 1024);
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
}
