import 'dart:async';

import 'package:camera/camera.dart';
import 'package:rxdart/rxdart.dart';

class CameraBloc {
  /// Camera hardware attached to the device.
  static List<CameraDescription> cameras;

  /// Used to calculate recording time.
  Stopwatch _stopwatch = Stopwatch();
  Timer _timer;

  CameraBloc() {
    /// Listen for recording state.
    /// We enable timer when recording is true
    _recordingStateController.listen((isRecording) {
      if (isRecording) {
        _startTimer();
      } else {
        _resetTimer();
      }
    });
    availableCameras().then((foundCameras) => cameras = foundCameras);
  }

  /// Stream with recording state. When recording state changes,
  /// everyone interested is notified.
  BehaviorSubject<bool> _recordingStateController = BehaviorSubject<bool>();
  get recording => _recordingStateController.stream;
  Sink<bool> get recordingSink => _recordingStateController.sink;

  /// Stream with seconds passed since start of the recording.
  /// Each second views are notified about the time change.
  BehaviorSubject<int> _timerController = BehaviorSubject<int>();
  get timerSecondsElapsed => _timerController.stream;


  /// Enable timer and connect stopwatch data to stream.
  void _startTimer() {
    _stopwatch.start();

    _timer = Timer.periodic(Duration(seconds: 1), (timer){
      _timerController.add((_stopwatch.elapsedMilliseconds / 1000).floor());
    });
  }

  /// Stop and reset timer.
  void _resetTimer() {
    _stopwatch.stop();
    _stopwatch.reset();
    _timer.cancel();
    _timerController.add(0);
  }

  /// Dispose of streams
  void dispose() {
    _recordingStateController.close();
    _timerController.close();
  }
}