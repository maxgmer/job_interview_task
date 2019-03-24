import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_app/blocs/providers.dart';
import 'package:video_app/blocs/video_player_bloc.dart';
import 'package:video_app/screens/screen_values.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';

class VideoPlayer extends StatefulWidget {
  final FileSystemEntity movie;

  VideoPlayer(this.movie);

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer>
    with WidgetsBindingObserver {
  /// Wrapper for video player UI
  ChewieController _videoControllerWrapper;
  /// Video player without UI
  VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    /// Fix orientation and init video player.
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _videoController = VideoPlayerController.file(File(widget.movie.path));
    _videoControllerWrapper = ChewieController(
      aspectRatio: _videoController.value.aspectRatio,
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
      allowFullScreen: false
    );
  }

  @override
  Widget build(BuildContext context) {
    VideoPlayerBloc videoPlayerBloc = Providers.getVideoPlayerBloc(context);
    return MaterialApp(
      home: Scaffold(
        body: Column(
            children: <Widget>[
              /// Video player.
              Chewie(controller: _videoControllerWrapper),
              Flexible(
                child: Column(
                  children: <Widget>[
                    Text(
                      VideoPlayerValues.introductionText,
                      softWrap: true,
                    ),
                    StreamBuilder<bool>(
                        stream: videoPlayerBloc.isClipping,
                        initialData: false,
                        builder: (context, isClipping) {
                          return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                /// Clipping buttons
                                RaisedButton(
                                  child: Text(
                                      isClipping.data ? VideoPlayerValues.stopClippingString :
                                      VideoPlayerValues.startClippingString
                                  ),
                                  onPressed: () {
                                    videoPlayerBloc.addCropTime(_videoController.value.position.inSeconds);
                                    videoPlayerBloc.clippingSink.add(!isClipping.data);
                                  },
                                ),
                                RaisedButton(
                                  child: Text(VideoPlayerValues.finishClippingString),
                                  onPressed: () {
                                    /// We don't clip, if user has not marked where to stop clipping
                                    if (isClipping.data) {
                                      final snackBar = SnackBar(
                                        content: Text("${VideoPlayerValues.clippingNotFinishedString}"),
                                      );
                                      Scaffold.of(context).showSnackBar(snackBar);
                                      return;
                                    }

                                    videoPlayerBloc.cropAndSave(widget.movie.path);
                                    final snackBar = SnackBar(
                                      content: Text("${VideoPlayerValues.clippingFinishedString}"),
                                    );
                                    Scaffold.of(context).showSnackBar(snackBar);
                                  },
                                )
                              ],
                          );
                        },
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: VideoPlayerValues.clipTimeTextPadding),
                      child: StreamBuilder<Object>(
                          stream: videoPlayerBloc.cropTimesString,
                          initialData: "",
                          builder: (context, cropTimes) {
                            if (!cropTimes.hasData) {
                              return Container();
                            }

                            /// Clip times user chose.
                            return Text("${VideoPlayerValues.clipTimeStartText}:\n"
                              "${cropTimes.data}");
                          },
                      ),
                    )
                  ],
                ),
              ),
            ]
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoControllerWrapper.dispose();
    _videoController.dispose();
  }
}