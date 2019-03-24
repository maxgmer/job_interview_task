
 /// We moved out all the values for two things:
 /// 1. Convenience, if we want to modify layout.
 /// 2. Moving out strings, it is easier to replace direct
 ///    variable access with getters, which would return localized strings.
class ListScreenValues {
  static const double navBarPaddingTop = 4.0;
  static const double navBarPaddingBottom = 9.0;
  static const double navBarRecordButtonTextPaddingTop = 35.0;
  static const double navBarIconTextSize = 15.0;

  static const double navBarCropX = 35.0;
  static const double navBarCropY = 7.0;

  static const String saveString = "Save";
  static const String savedToString = "Saved to";
  static const String backString = "Back";
  static const String deleteString = "Delete";
  static const String recordVideoString = "Record a video!";
  static const String fabHintString = "Tap to record a video.";
  static const String listTileTextBeginning = "Full video name";
  static const String listTileTextBeginningSave = "Press to save";

  static const double fabCropTop = 15.0;
  static const double fabCropBottom = 26.0;

  static const double listTilePadding = 14.0;
  static const double listTileNumberSize = 23.0;
  static const double listTileTextSize = 14.0;

}

class CameraScreenValues {
  static const double recordTimeFontSize = 22.0;
  static const double recordRectCornerRounding = 10.0;
}

class VideoPlayerValues {
  static const String introductionText =
      "Stop the video at any point. Then press start clipping."
      "After that go to another part of the video and press stop clipping."
      "The part you have have chosen will be clipped out (saved)."
      "You can clip out as many parts, as you want."
      "The parts you didn't choose will be removed from the video.";

  static const String startClippingString = "Start clipping";
  static const String stopClippingString = "Stop clipping";
  static const String finishClippingString = "Finish clipping";
  static const double clipTimeTextPadding = 20.0;
  static const String clipTimeStartText = "Parts that would be clipped out";
  static const String clippingFinishedString = "Clipping is finished!";
  static const String clippingNotFinishedString = "Clipping not finished, press Stop clipping.";
}