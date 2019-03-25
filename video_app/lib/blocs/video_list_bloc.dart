import 'dart:async';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:video_app/util.dart';

class VideoListBloc {

  /// Contains videos, found in the app directory.
  BehaviorSubject<List<FileSystemEntity>> _videosController = BehaviorSubject<List<FileSystemEntity>>();
  get videos => _videosController.stream;

  /// Contains bool, which indicates, if video saving mode is enabled.
  BehaviorSubject<bool> _saveModeController = BehaviorSubject<bool>();
  get saveMode => _saveModeController.stream;

  /// Enables save mode by adding to controller, which notifies all subscribers (views)
  void setSaveMode(bool enabled) => _saveModeController.add(enabled);

  /// Connect saved movies directory files to videos stream, which would be used by views.
  void initializeControllers() async {
    Stream<FileSystemEntity> moviesStream = Directory(await Util.getMoviesDir()).list();
    _videosController.add(await moviesStream.toList());
  }

  /// Dispose of streams
  void dispose() {
    _videosController.close();
    _saveModeController.close();
  }
}