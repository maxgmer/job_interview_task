import 'dart:typed_data';
import 'package:flutter/services.dart';

class NativeApi {
  static const _cropVideoNativeMethodName = "cropVideo";
  static const CROP_VIDEO_METHOD_ARG1 = "partsToSaveAfterCroppingSec";
  static const CROP_VIDEO_METHOD_ARG2 = "clipInputPath";
  static const CROP_VIDEO_METHOD_ARG3 = "clipOutputPath";
  static const _methodChannel = const MethodChannel('example.com/cropVideo');
  static Future<String> cropVideo(Int32List partsToSaveAfterCroppingSec,
  String clipInputPath, String clipOutputPath) async {
    return await _methodChannel.invokeMethod(_cropVideoNativeMethodName,
        <String, dynamic> {
            CROP_VIDEO_METHOD_ARG1: partsToSaveAfterCroppingSec,
            CROP_VIDEO_METHOD_ARG2: clipInputPath,
            CROP_VIDEO_METHOD_ARG3: clipOutputPath
        });
  }
}