
 /// We moved out all the values for two things:
 /// 1. Convenience, if we want to modify layout.
 /// 2. Moving out strings, it is easier to replace direct
 ///    variable access with getters, which would return localized strings.
class ListScreenValues {
  static const double navBarPaddingTop = 4.0;
  static const double navBarPaddingBottom = 9.0;
  static const double navBarRecordButtonTextPaddingTop = 35.0;
  static const double navBarIconTextSize = 15.0;

  static double navBarCropX = 35.0;
  static double navBarCropY = 7.0;

  static String saveString = "Save";
  static String backString = "Back";
  static String deleteString = "Delete";
  static String recordVideoString = "Record a video!";
  static String fabHintString = "Tap to record a video.";
  static String listTileTextBeginning = "Full video name";
  static String listTileTextBeginningSave = "Press to save";

  static double fabCropTop = 15.0;
  static double fabCropBottom = 26.0;

  static double listTilePadding = 14.0;
  static double listTileNumberSize = 23.0;
  static double listTileTextSize = 14.0;

}

class CameraScreenValues {
  static double recordTimeFontSize = 22.0;
  static double recordRectCornerRounding = 10.0;
}