import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/services.dart';
import 'package:video_app/blocs/providers.dart';
import 'package:video_app/blocs/video_player_bloc.dart';
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
  ChewieController _videoControllerWrapper;
  VideoPlayerController _videoController;


  @override
  void initState() {
    super.initState();
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
              Chewie(
                controller: _videoControllerWrapper,
              ),
              Flexible(
                child: Column(
                  children: <Widget>[
                    Text(
                      "Stop the video at any point. Then press start clipping."
                      "After that go to another part of the video and press stop clipping."
                      "The part you have have chosen will be clipped out (saved)."
                      "You can clip out as many parts, as you want."
                      "The parts you didn't choose will be removed from the video.",
                      softWrap: true,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        RaisedButton(
                          child: Text("Start clipping"),
                          onPressed: () =>
                              videoPlayerBloc.addCropTime(_videoController.value.position.inSeconds),
                        ),
                        RaisedButton(
                          child: Text("Stop clipping"),
                          onPressed: () =>
                              videoPlayerBloc.addCropTime(_videoController.value.position.inSeconds),
                        ),
                        RaisedButton(
                          child: Text("Finish clipping"),
                          onPressed: () => videoPlayerBloc.cropAndSave(widget.movie.path),
                        )
                      ],
                    ),
                    Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: StreamBuilder<Object>(
                        stream: videoPlayerBloc.cropTimesString,
                        initialData: "",
                        builder: (context, cropTimes) {
                          if (!cropTimes.hasData) {
                            return Container();
                          }
                          return Text("Parts that would be clipped out:\n"
                              "${cropTimes.data}");
                        }
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