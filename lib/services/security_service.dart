import 'package:shared_preferences/shared_preferences.dart';

class SecurityService {
  static const String _screenshotProtectionKey = 'screenshot_protection';
  static const String _screenshotCountKey = 'screenshot_count';
  static const String _watermarkTextKey = 'watermark_text';
  static const String _secureModeKey = 'secure_mode';

  late SharedPreferences _prefs;

  SecurityService();

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<bool> isScreenshotProtectionEnabled() async {
    return _prefs.getBool(_screenshotProtectionKey) ?? false;
  }

  Future<void> enableScreenshotProtection() async {
    await _prefs.setBool(_screenshotProtectionKey, true);
  }

  Future<void> disableScreenshotProtection() async {
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
} 