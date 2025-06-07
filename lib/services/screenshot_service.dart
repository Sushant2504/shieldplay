import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class ScreenshotService {
  static const String _screenshotProtectionKey = 'screenshot_protection';
  static const String _screenshotCountKey = 'screenshot_count';
  static const platform = MethodChannel('com.shieldplay.screenshot');
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  ScreenshotService();

  Future<void> initialize() async {
    if (_isInitialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  bool isScreenshotProtectionEnabled() {
    if (!_isInitialized) return false;
    return _prefs.getBool(_screenshotProtectionKey) ?? false;
  }

  Future<void> enableScreenshotProtection() async {
    if (!_isInitialized) return;
    
    try {
      await platform.invokeMethod('enableScreenshotProtection');
      await _prefs.setBool(_screenshotProtectionKey, true);
    } catch (e) {
      throw Exception('Failed to enable screenshot protection: $e');
    }
  }

  Future<void> disableScreenshotProtection() async {
    if (!_isInitialized) return;
    
    try {
      await platform.invokeMethod('disableScreenshotProtection');
      await _prefs.setBool(_screenshotProtectionKey, false);
    } catch (e) {
      throw Exception('Failed to disable screenshot protection: $e');
    }
  }

  int getScreenshotCount() {
    if (!_isInitialized) return 0;
    return _prefs.getInt(_screenshotCountKey) ?? 0;
  }

  Future<void> setScreenshotCount(int count) async {
    if (!_isInitialized) return;
    await _prefs.setInt(_screenshotCountKey, count);
  }

  Future<void> handleScreenshot() async {
    final count = await getScreenshotCount();
    await setScreenshotCount(count + 1);
  }

  Future<void> resetScreenshotCount() async {
    if (!_isInitialized) return;
    await _prefs.setInt(_screenshotCountKey, 0);
  }
} 