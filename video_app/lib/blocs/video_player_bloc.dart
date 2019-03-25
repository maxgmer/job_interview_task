import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:video_app/native_api.dart';

class VideoPlayerBloc {

  /// Array with all crop times.
  List<int> _cropTimes = List<int>();

  /// If user started clipping
  BehaviorSubject<bool> _clippingController = BehaviorSubject<bool>();
  get isClipping => _clippingController.stream;
  get clippingSink => _clippingController.sink;

  /// String with all crop times.
  BehaviorSubject<String> _cropTimesController = BehaviorSubject<String>();
  get cropTimesString => _cropTimesController.stream;

  /// Adds new crop time to array and updates crop times string used by views.
  /// Then throws this string into cropTimesController stream.
  void addCropTime(int secondsToCropAt) {

    /// Cut fromSeconds cannot be later than cut toSeconds
    /// So we dissmiss such clip requests.
    if (_cropTimes.length != 0 &&
        secondsToCropAt < _cropTimes[_cropTimes.length - 1]) {
      return;
    }

    _cropTimes.add(secondsToCropAt);
    StringBuffer stringBuilder = StringBuffer();
    for (int i = 0; i < _cropTimes.length; i++) {
      String minutes = (_cropTimes[i] / 60).floor().toString();
      String seconds = (_cropTimes[i] % 60).toString();

      if ((i % 2) == 0) {
        stringBuilder.write(minutes);
        stringBuilder.write(":");
        /// Add 0 so that time is 0:01, not 0:1
        if (secondsToCropAt < 10) {
          stringBuilder.write("0");
        }
        stringBuilder.write(seconds);
        stringBuilder.write(" - ");
      } else {
        stringBuilder.write(minutes);
        stringBuilder.write(":");
        /// Add 0 so that time is 0:01, not 0:1
        if (secondsToCropAt < 10) {
          stringBuilder.write("0");
        }
        stringBuilder.write(seconds);
        stringBuilder.write("\n");
      }
    }
    _cropTimesController.add(stringBuilder.toString());
  }

  /// Crops and saves video. Calls a native method to do this.
  void cropAndSave(String inputPath) {
    if (_cropTimes.isEmpty) {
      return;
    }
    _cropTimes.sort();
    Int32List cropTimesList = Int32List.fromList(_cropTimes);
    String outputPath = inputPath.replaceAll(".mp4", "-clippedVideo.mp4");
    NativeApi.cropVideo(cropTimesList, inputPath, outputPath);

    _cropTimes.clear();
    _cropTimesController.add("");
  }

  /// Disposes of controller
  void dispose() {
    _cropTimesController.close();
    _clippingController.close();
  }
}