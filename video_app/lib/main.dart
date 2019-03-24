import 'package:flutter/material.dart';
import 'package:video_app/blocs/providers.dart';
import 'package:video_app/screens/video_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Providers(
      child: MaterialApp(
        title: 'Video app',
        theme: _createDefaultTheme(),
        home: VideoListScreen(),
      ),
    );
  }
}

/// Initialize theme
ThemeData _createDefaultTheme() =>
    ThemeData(
      splashColor: Colors.transparent,
      primaryColor: Color.fromRGBO(50, 50, 50, 1.0),
      primaryColorLight: Color.fromRGBO(230, 230, 230, 1.0),
      accentColor: Color.fromRGBO(123, 173, 69, 1.0),
    );

