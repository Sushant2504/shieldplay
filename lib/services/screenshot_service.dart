import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class ScreenshotService {
  static const String _screenshotProtectionKey = 'screenshot_protection';
  static const String _screenshotCountKey = 'screenshot_count';
  static const platform = MethodChannel('com.shieldplay.screenshot');
  static const _screenshotEventChannel = EventChannel('com.shieldplay.screenshot/events');
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  StreamSubscription? _screenshotSubscription;
  Function? _onScreenshotAttempt;

  ScreenshotService();

  Future<void> initialize() async {
    try {
      await platform.invokeMethod('initializeScreenshotProtection');
      _isInitialized = true;
    } catch (e) {
      print('Error initializing screenshot protection: $e');
    }
  }

  Future<bool> isScreenshotProtectionEnabled() async {
    return _isInitialized;
  }

  void enableScreenshotProtection({Function? onScreenshotAttempt}) {
    _onScreenshotAttempt = onScreenshotAttempt;
    _screenshotSubscription?.cancel();
    _screenshotSubscription = _screenshotEventChannel
        .receiveBroadcastStream()
        .listen(_handleScreenshotEvent);
  }

  void disableScreenshotProtection() {
    _screenshotSubscription?.cancel();
    _screenshotSubscription = null;
    _onScreenshotAttempt = null;
  }

  void _handleScreenshotEvent(dynamic event) {
    if (_onScreenshotAttempt != null) {
      _onScreenshotAttempt!();
    }
  }

  Future<void> setSecureMode(bool enabled) async {
    try {
      await platform.invokeMethod('setSecureMode', {'enabled': enabled});
    } catch (e) {
      print('Error setting secure mode: $e');
    }
  }

  Future<int> getScreenshotCount() async {
    return 0; // Implement if you want to track screenshot attempts
  }

  Future<void> setScreenshotCount(int count) async {
    // Implement if you want to track screenshot attempts
  }

  Future<void> resetScreenshotCount() async {
    // Implement if you want to track screenshot attempts
  }
} 