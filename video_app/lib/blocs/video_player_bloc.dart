import 'dart:typed_data';

import 'package:rxdart/rxdart.dart';
import 'package:video_app/native_api.dart';

class VideoPlayerBloc {

  List<int> _cropTimes = List<int>();

  BehaviorSubject<String> _cropTimesController = BehaviorSubject<String>();
  get cropTimesString => _cropTimesController.stream;

  void addCropTime(int seconds) {
    _cropTimes.add(seconds);
    StringBuffer stringBuilder = StringBuffer();
    for (int i = 0; i < _cropTimes.length; i++) {
      String minutes = (_cropTimes[i] / 60).floor().toString();
      String seconds = (_cropTimes[i] % 60).toString();

      if ((i % 2) == 0) {
        stringBuilder.write(minutes);
        stringBuilder.write(":");
        stringBuilder.write(seconds);
        stringBuilder.write(" - ");
      } else {
        stringBuilder.write(minutes);
        stringBuilder.write(":");
        stringBuilder.write(seconds);
        stringBuilder.write("\n");
      }
    }
    _cropTimesController.add(stringBuilder.toString());
  }

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

  void dispose() {
    _cropTimesController.close();
  }
}