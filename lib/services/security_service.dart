import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _screenshotProtectionKey = 'screenshot_protection';
  static const String _screenshotCountKey = 'screenshot_count';
  static const String _watermarkTextKey = 'watermark_text';
  static const String _secureModeKey = 'secure_mode';
  static bool _isScreenshotProtectionEnabled = false;
  static Function? _onScreenshotAttempt;

  late SharedPreferences _prefs;

  SecurityService();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _isScreenshotProtectionEnabled = _prefs.getBool(_screenshotProtectionKey) ?? true;
  }

  Future<bool> isScreenshotProtectionEnabled() async {
    return _prefs.getBool(_screenshotProtectionKey) ?? false;
  }

  Future<void> enableScreenshotProtection({Function? onScreenshotAttempt}) async {
    _isScreenshotProtectionEnabled = true;
    _onScreenshotAttempt = onScreenshotAttempt;
    SystemChannels.platform.setMethodCallHandler((call) async {
      if (call.method == 'SystemNavigator.pop' || 
          call.method == 'SystemNavigator.screenshot') {
        if (_isScreenshotProtectionEnabled) {
          _onScreenshotAttempt?.call();
          return null; // Prevent the screenshot
        }
      }
      return null;
    });
    await _prefs.setBool(_screenshotProtectionKey, true);
  }

  Future<void> disableScreenshotProtection() async {
    _isScreenshotProtectionEnabled = false;
    _onScreenshotAttempt = null;
    SystemChannels.platform.setMethodCallHandler(null);
    await _prefs.setBool(_screenshotProtectionKey, false);
  }

  Future<int> getScreenshotCount() async {
    return _prefs.getInt(_screenshotCountKey) ?? 0;
  }

  Future<void> setScreenshotCount(int count) async {
    await _prefs.setInt(_screenshotCountKey, count);
  }

  String getWatermarkText() {
    return _prefs.getString(_watermarkTextKey) ?? 'ShieldPlay';
  }

  Future<void> setWatermarkText(String text) async {
    await _prefs.setString(_watermarkTextKey, text);
  }

  bool isSecureModeEnabled() {
    return _prefs.getBool(_secureModeKey) ?? false;
  }

  Future<void> setSecureMode(bool enabled) async {
    await _prefs.setBool(_secureModeKey, enabled);
  }

  static void showScreenshotWarning() {
    // Get the navigator key from the app
    final context = navigatorKey.currentContext;
    if (context == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Screenshot Blocked'),
        content: const Text(
          'Screenshots are not allowed in secure mode to protect content privacy.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Global navigator key for accessing context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(); 