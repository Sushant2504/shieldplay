import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/screenshot_service.dart';

class ScreenshotProvider extends ChangeNotifier {
  final ScreenshotService _screenshotService;
  static const String _screenshotCountKey = 'screenshot_count';
  bool _isScreenshotProtectionEnabled = false;
  int _screenshotCount = 0;
  late SharedPreferences _prefs;

  ScreenshotProvider(this._screenshotService) {
    _initialize();
  }

  ScreenshotService get screenshotService => _screenshotService;
  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  int get screenshotCount => _screenshotCount;

  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _screenshotCount = _prefs.getInt(_screenshotCountKey) ?? 0;
      _isScreenshotProtectionEnabled = await _screenshotService.isScreenshotProtectionEnabled();
      debugPrint('Initialized screenshot count: $_screenshotCount');
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing screenshot provider: $e');
    }
  }

  Future<void> incrementScreenshotCount() async {
    try {
      _screenshotCount++;
      await _prefs.setInt(_screenshotCountKey, _screenshotCount);
      debugPrint('Screenshot attempt recorded. Total attempts: $_screenshotCount');
      notifyListeners();
    } catch (e) {
      debugPrint('Error incrementing screenshot count: $e');
    }
  }

  Future<void> resetScreenshotCount() async {
    try {
      _screenshotCount = 0;
      await _prefs.setInt(_screenshotCountKey, 0);
      debugPrint('Screenshot count reset to 0');
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting screenshot count: $e');
    }
  }

  Future<void> toggleScreenshotProtection() async {
    try {
      _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
      await _screenshotService.setSecureMode(_isScreenshotProtectionEnabled);
      debugPrint('Screenshot protection ${_isScreenshotProtectionEnabled ? 'enabled' : 'disabled'}');
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling screenshot protection: $e');
    }
  }
} 