import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class SecurityUtils {
  static const String _prefsKeyWatermark = 'watermark_text';
  static const String _prefsKeySecureMode = 'secure_mode';
  static const String _prefsKeyScreenshotProtection = 'screenshot_protection';
  static const String _prefsKeyScreenshotCount = 'screenshot_count';

  // Watermark
  static Future<String> getWatermarkText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_prefsKeyWatermark) ?? AppConstants.watermarkDefaultText;
  }

  static Future<void> setWatermarkText(String text) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyWatermark, text);
  }

  // Secure Mode
  static Future<bool> isSecureModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKeySecureMode) ?? false;
  }

  static Future<void> setSecureMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeySecureMode, enabled);
  }

  // Screenshot Protection
  static Future<bool> isScreenshotProtectionEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefsKeyScreenshotProtection) ?? true;
  }

  static Future<void> setScreenshotProtection(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKeyScreenshotProtection, enabled);
  }

  // Screenshot Count
  static Future<int> getScreenshotCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefsKeyScreenshotCount) ?? 0;
  }

  static Future<void> incrementScreenshotCount() async {
    final prefs = await SharedPreferences.getInstance();
    final count = await getScreenshotCount();
    await prefs.setInt(_prefsKeyScreenshotCount, count + 1);
  }

  static Future<void> resetScreenshotCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyScreenshotCount, 0);
  }

  // Platform-specific screenshot detection
  static Future<void> enableScreenshotProtection() async {
    if (Platform.isAndroid) {
      await const MethodChannel('com.shieldplay.screenshot')
          .invokeMethod('enableScreenshotProtection');
    } else if (Platform.isIOS) {
      await const MethodChannel('com.shieldplay.screenshot')
          .invokeMethod('enableScreenshotProtection');
    }
  }

  static Future<void> disableScreenshotProtection() async {
    if (Platform.isAndroid) {
      await const MethodChannel('com.shieldplay.screenshot')
          .invokeMethod('disableScreenshotProtection');
    } else if (Platform.isIOS) {
      await const MethodChannel('com.shieldplay.screenshot')
          .invokeMethod('disableScreenshotProtection');
    }
  }

  // Cache Security
  static Future<String> getSecureCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final secureDir = Directory('${appDir.path}/secure_cache');
    if (!await secureDir.exists()) {
      await secureDir.create(recursive: true);
    }
    return secureDir.path;
  }

  static Future<void> clearSecureCache() async {
    final secureDir = await getSecureCacheDirectory();
    final dir = Directory(secureDir);
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  }
} 