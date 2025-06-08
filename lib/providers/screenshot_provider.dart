import 'package:flutter/material.dart';
import '../services/screenshot_service.dart';

class ScreenshotProvider extends ChangeNotifier {
  final ScreenshotService _screenshotService;
  bool _isScreenshotProtectionEnabled = false;
  int _screenshotCount = 0;

  ScreenshotProvider(this._screenshotService) {
    _initialize();
  }

  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  int get screenshotCount => _screenshotCount;

  Future<void> _initialize() async {
    _isScreenshotProtectionEnabled = await _screenshotService.isScreenshotProtectionEnabled();
    _screenshotCount = await _screenshotService.getScreenshotCount();
    notifyListeners();
  }

  Future<void> toggleScreenshotProtection() async {
    _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
    await _screenshotService.setSecureMode(_isScreenshotProtectionEnabled);
    notifyListeners();
  }

  Future<void> resetScreenshotCount() async {
    _screenshotCount = 0;
    await _screenshotService.resetScreenshotCount();
    notifyListeners();
  }
} 