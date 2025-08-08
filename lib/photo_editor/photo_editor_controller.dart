import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image_cropper/image_cropper.dart';
import '../shared/app_colors.dart';

class PhotoEditorController {
  final ImagePicker _imagePicker = ImagePicker();
  final List<String> availableEmojis = [
    '😀',
    '😂',
    '😍',
    '🥰',
    '😎',
    '🤩',
    '😊',
    '🤔',
    '🤗',
    '🙄',
    '😴',
    '🥳',
    '😭',
    '🤯',
    '🥺',
    '❤️',
    '🔥',
    '✨',
    '⭐',
    '🎉',
  ];

  // 从相册选择图片
  Future<File?> pickImageFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // 使用相机拍照
  Future<File?> takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 90,
      preferredCameraDevice: CameraDevice.rear,
    );
    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // 保存编辑后的图片
  Future<bool> saveEditedImage(
    String imagePath,
    List<dynamic> stickers, {
    GlobalKey? widgetKey,
  }) async {
    try {
      // 不预先检查权限，直接尝试保存
      // iOS和Android系统会在需要时自动请求权限

      if (widgetKey != null) {
        try {
          // 使用RepaintBoundary捕获整个编辑界面
          final boundary = widgetKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
          if (boundary != null) {
            // 捕获整个编辑界面为图像
            final image = await boundary.toImage(pixelRatio: 3.0);
            final byteData = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            if (byteData != null) {
              final buffer = byteData.buffer.asUint8List();

              // 保存到临时目录
              final directory = await getTemporaryDirectory();
              final path =
                  '${directory.path}/edited_${DateTime.now().millisecondsSinceEpoch}.png';
              final file = File(path);
              await file.writeAsBytes(buffer);

              // 直接尝试使用字节数据保存
              if (Platform.isIOS) {
                try {
                  // 方法1: 使用字节数据保存
                  final result = await ImageGallerySaver.saveImage(
                    buffer,
                    quality: 100,
                    name:
                        "florsovivexa_${DateTime.now().millisecondsSinceEpoch}",
                  );

                  if (result['isSuccess'] == true) {
                    return true;
                  }

                  // 方法2: 如果字节保存失败，尝试使用文件路径
                  final fileResult = await ImageGallerySaver.saveFile(
                    file.path,
                  );

                  return fileResult['isSuccess'] ?? false;
                } catch (e) {
                  // 方法3: 如果上述方法都失败，尝试直接保存字节数据
                  final dataResult = await ImageGallerySaver.saveImage(
                    buffer,
                    quality: 100,
                    isReturnImagePathOfIOS: true,
                  );

                  // 方法4: 如果所有方法都失败，尝试使用UIImageWriteToSavedPhotosAlbum方式
                  if (!(dataResult['isSuccess'] ?? false)) {
                    final tempDir = await getTemporaryDirectory();
                    final tempPath =
                        '${tempDir.path}/final_save_attempt_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final tempFile = File(tempPath);
                    await tempFile.writeAsBytes(buffer);

                    final finalResult = await ImageGallerySaver.saveFile(
                      tempPath,
                      isReturnPathOfIOS: true,
                    );

                    return finalResult['isSuccess'] ?? false;
                  }

                  return dataResult['isSuccess'] ?? false;
                }
              } else {
                // Android保存方法
                final result = await ImageGallerySaver.saveFile(file.path);

                return result['isSuccess'] ?? false;
              }
            }
          }
        } catch (e) {}
      }

      // 如果无法捕获界面，则直接保存原图
      if (Platform.isIOS) {
        final bytes = await File(imagePath).readAsBytes();
        try {
          final result = await ImageGallerySaver.saveImage(
            bytes,
            quality: 100,
            name: "florsovivexa_${DateTime.now().millisecondsSinceEpoch}",
          );

          return result['isSuccess'] ?? false;
        } catch (e) {
          // 尝试使用另一种方式保存
          try {
            final result = await ImageGallerySaver.saveFile(imagePath);

            return result['isSuccess'] ?? false;
          } catch (e2) {
            return false;
          }
        }
      } else {
        final result = await ImageGallerySaver.saveFile(imagePath);

        return result['isSuccess'] ?? false;
      }
    } catch (e) {
      return false;
    }
  }

  // 裁剪图片
  Future<File?> cropImage(File image) async {
    try {
      final cropper = ImageCropper();
      final croppedFile = await cropper.cropImage(
        sourcePath: image.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: AppColors.brandDark,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
            activeControlsWidgetColor: AppColors.brandTeal,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
            rotateButtonsHidden: false,
            rotateClockwiseButtonHidden: false,
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      if (croppedFile != null) {
        return File(croppedFile.path);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // 将贴纸应用到图片上
  Future<File?> applyStickersToImage(
    File originalImage,
    List<dynamic> stickers,
  ) async {
    try {
      // 在实际应用中，这里应该使用Canvas将贴纸绘制到图片上
      // 这是一个简化的实现
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/edited_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImage = await originalImage.copy(path);
      return newImage;
    } catch (e) {
      return null;
    }
  }
}
