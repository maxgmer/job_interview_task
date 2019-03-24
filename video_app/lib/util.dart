import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Utility class.
/// Helps to work with storage.
class Util {
  static const String _movieDir = "/Movies/video_app_movies/";
  static const String _externalMovieDir = "/JobTaskSavedMovies/";

  static Future<String> getMoviesDir() async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final String dirPath = appDir.path + _movieDir;
    await Directory(dirPath).create(recursive: true);
    return dirPath;
  }

  static Future deleteMovies() async {
    final String dirPath = await getMoviesDir();
    await Directory(dirPath).delete(recursive: true);
  }

  static Future<String> saveMovie(FileSystemEntity filesList) async {
    File file = File(filesList.path);
    Directory externalMovieDir = await getExternalStorageDirectory();
    externalMovieDir = Directory(externalMovieDir.path + _externalMovieDir);
    externalMovieDir.create(recursive: true);
    List<String> splitMoviePath = filesList.path.split("/");
    String savePath = externalMovieDir.path + splitMoviePath[splitMoviePath.length - 1];
    await file.copy(savePath);
    file.delete();
    return savePath;
  }
}