import 'package:flutter/foundation.dart';
import 'package:screen_brightness/screen_brightness.dart';

class BrightnessUtils {
  static Future<void> setMaxBrightness() async {
    try {
      if (kIsWeb) {
        // Web: Optional - could add wakelock_web or JS interop here
        // For now, brightness control is limited on web
        return;
      } else {
        // iOS/Android: Set brightness to maximum
        await ScreenBrightness().setScreenBrightness(1.0);
      }
    } catch (e) {
      // Handle any errors gracefully
      if (kDebugMode) {
        print('Error setting brightness: $e');
      }
    }
  }

  static Future<void> resetBrightness() async {
    try {
      if (kIsWeb) {
        return;
      } else {
        // Reset to system brightness
        await ScreenBrightness().resetScreenBrightness();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error resetting brightness: $e');
      }
    }
  }
}