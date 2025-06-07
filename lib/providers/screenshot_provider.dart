import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/screenshot_service.dart';

class ScreenshotProvider extends ChangeNotifier {
  final ScreenshotService _screenshotService;
  static const platform = MethodChannel('com.shieldplay.screenshot');
  bool _isScreenshotProtectionEnabled = false;
  int _screenshotCount = 0;

  ScreenshotProvider(this._screenshotService) {
    _initialize();
    _setupMethodCallHandler();
  }

  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  int get screenshotCount => _screenshotCount;

  Future<void> _initialize() async {
    _isScreenshotProtectionEnabled = await _screenshotService.isScreenshotProtectionEnabled();
    _screenshotCount = await _screenshotService.getScreenshotCount();
    notifyListeners();
  }

  void _setupMethodCallHandler() {
    platform.setMethodCallHandler((call) async {
      if (call.method == 'onScreenshotTaken') {
        await _handleScreenshot();
      }
    });
  }

  Future<void> _handleScreenshot() async {
    if (_isScreenshotProtectionEnabled) {
      _screenshotCount++;
      await _screenshotService.setScreenshotCount(_screenshotCount);
      notifyListeners();
    }
  }

  Future<void> toggleScreenshotProtection() async {
    _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
    if (_isScreenshotProtectionEnabled) {
      await _screenshotService.enableScreenshotProtection();
    } else {
      await _screenshotService.disableScreenshotProtection();
    }
    notifyListeners();
  }

  Future<void> resetScreenshotCount() async {
    _screenshotCount = 0;
    await _screenshotService.resetScreenshotCount();
    notifyListeners();
  }

  @override
  void dispose() {
    platform.setMethodCallHandler(null);
    super.dispose();
  }
} 