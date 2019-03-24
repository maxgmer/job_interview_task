import 'package:flutter/cupertino.dart';
import 'package:video_app/blocs/camera_bloc.dart';
import 'package:video_app/blocs/video_list_bloc.dart';
import 'package:video_app/blocs/video_player_bloc.dart';

/// This class is basically a container for BLoCs
/// BloCs are used to decouple views and logic.
/// Views get values from BLoCs without caring how they were created.
class Providers extends InheritedWidget {
  final VideoListBloc videoListBloc;
  final CameraBloc cameraBloc;
  final VideoPlayerBloc videoPlayerBloc;

  Providers({Key key, Widget child})
      : videoListBloc = VideoListBloc(),
        cameraBloc = CameraBloc(),
        videoPlayerBloc = VideoPlayerBloc(),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) => true;

  /// Methods for getting BLoCs
  static VideoListBloc getVideoListBloc(BuildContext context) => (context.inheritFromWidgetOfExactType(Providers) as Providers).videoListBloc..initializeControllers();
  static CameraBloc getCameraBloc(BuildContext context) => (context.inheritFromWidgetOfExactType(Providers) as Providers).cameraBloc;
  static VideoPlayerBloc getVideoPlayerBloc(BuildContext context) => (context.inheritFromWidgetOfExactType(Providers) as Providers).videoPlayerBloc;
}