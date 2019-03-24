package com.example.video_app;
import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    //listens for flutter cropVideo native method call and invokes accordingly
    new MethodChannel(getFlutterView(), "example.com/cropVideo").setMethodCallHandler(
            (call, result) -> {
                if (call.method.equals(NativeApi.CROP_VIDEO_METHOD)) {
                    NativeApi.cropVideo(
                            call.argument(NativeApi.CROP_VIDEO_METHOD_ARG1),
                            call.argument(NativeApi.CROP_VIDEO_METHOD_ARG2),
                            call.argument(NativeApi.CROP_VIDEO_METHOD_ARG3),
                            result
                    );
                } else {
                    //if flutter invokes another method, send notImplemented
                    result.notImplemented();
                }
            });
  }
}
