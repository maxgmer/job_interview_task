import 'dart:core';
import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_app/blocs/camera_bloc.dart';
import 'package:video_app/blocs/providers.dart';
import 'package:video_app/screen_values.dart';
import 'package:video_app/util.dart';

class CameraScreen extends StatefulWidget {
  static const String TAG = "CameraScreen";

  @override
  State<StatefulWidget> createState() => _CameraState();
}

class _CameraState extends State<StatefulWidget> {
  CameraController controller;

  @override
  void initState() {

    /// Prevent screen from rotating
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.initState();

    /// Check, if camera hardware found
    if (CameraBloc.cameras != null) {
      /// Initialize camera controller, so user can see camera output and record it
      controller = CameraController(CameraBloc.cameras[0], ResolutionPreset.high);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    /// Controller could be null if there is no camera hardware found
    /// by the time the layout is built
    if (controller == null) {
      Navigator.pop(context);
    }

    /// Check for init
    if (!controller.value.isInitialized) {
      return Container();
    }

    /// Get bloc with value streams we
    /// need in views
    CameraBloc cameraBloc = Providers.getCameraBloc(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          /// Unfortunately, camera output's aspect ratio
          /// can be different from phone's screen ratio.
          /// That is why we save camera's aspect ratio, filling
          /// up the space left with black container with record button.
          AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller)
          ),
          StreamBuilder<int>(
              stream: cameraBloc.timerSecondsElapsed,
              initialData: 0,
              builder: (context, secondsRecording) {

                if (!secondsRecording.hasData) {
                  return Container();
                }

                /// Seconds elapsed since recording start.
                /// Don't be confused with this, just converts plain seconds to minutes and seconds
                /// and adds 0 to seconds if seconds since last minute < 10
                return Text(
                  "${(secondsRecording.data / 60).floor()}:"
                      "${secondsRecording.data % 60 < 10 ? "0${secondsRecording.data % 60}" : secondsRecording.data % 60}",
                  style: TextStyle(color: Colors.white, fontSize: CameraScreenValues.recordTimeFontSize),
                );
              }
          ),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                StreamBuilder<Object>(
                  stream: cameraBloc.recording,
                  initialData: false,
                  builder: (context, recording) {
                    if (!recording.hasData) {
                      return Container();
                    }

                    return FloatingActionButton(
                      mini: recording.data,
                      shape: recording.data ?
                        RoundedRectangleBorder(borderRadius: BorderRadius.circular(CameraScreenValues.recordRectCornerRounding)):
                        CircleBorder(),
                      backgroundColor: Colors.red,
                      onPressed: () {
                        cameraBloc.recordingSink.add(!recording.data);
                        switchVideoRecording(recording.data);
                      },
                    );
                  }
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Start recording, if not recording yet
  /// If already recording, stop and save
  void switchVideoRecording(bool recording) async {
    String appDir = await Util.getMoviesDir();
    String movieName = "movie(${DateTime.now().millisecondsSinceEpoch.toString()}).mp4";
    final String moviePath = appDir + movieName;

    if (recording) {
      await controller.stopVideoRecording();
    } else {
      await controller.startVideoRecording(moviePath);
    }
  }
}


