import 'dart:async';
import 'dart:io';
import 'package:rxdart/rxdart.dart';
import 'package:video_app/util.dart';

class VideoListBloc {

  /// Controllers are containers, which have a Stream and a Sink inside.
  /// Stream has data flowing through. Usually views use it.
  /// Sink is a object we use to add data to Stream.
  BehaviorSubject<List<FileSystemEntity>> _videosController = BehaviorSubject<List<FileSystemEntity>>();
  get videos => _videosController.stream;


  BehaviorSubject<bool> _saveModeController = BehaviorSubject<bool>();
  get saveMode => _saveModeController.stream;

  void setSaveMode(bool enabled) => _saveModeController.add(enabled);

  /// Connect saved movies to videos stream, which would be used by views.
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