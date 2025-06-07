import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;
  bool _isScreenshotProtectionEnabled = false;
  int _screenshotCount = 0;
  bool _isSecureMode = false;
  String _watermarkText = '';
  bool _isInitialized = false;

  SecurityProvider(this._securityService) {
    _initialize();
  }

  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  int get screenshotCount => _screenshotCount;
  bool get isSecureMode => _isSecureMode;
  String get watermarkText => _watermarkText;
  bool get isInitialized => _isInitialized;

  Future<void> _initialize() async {
    try {
      _isScreenshotProtectionEnabled =
          await _securityService.isScreenshotProtectionEnabled();
      _screenshotCount = await _securityService.getScreenshotCount();
      _isSecureMode = await _securityService.isSecureModeEnabled();
      _watermarkText = await _securityService.getWatermarkText();
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing SecurityProvider: $e');
    }
  }

  Future<void> toggleScreenshotProtection() async {
    if (_isScreenshotProtectionEnabled) {
      await _securityService.disableScreenshotProtection();
    } else {
      await _securityService.enableScreenshotProtection();
    }
    _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
    notifyListeners();
  }

  Future<void> incrementScreenshotCount() async {
    _screenshotCount++;
    await _securityService.setScreenshotCount(_screenshotCount);
    notifyListeners();
  }

  Future<void> resetScreenshotCount() async {
    _screenshotCount = 0;
    await _securityService.setScreenshotCount(_screenshotCount);
    notifyListeners();
  }

  Future<void> setWatermarkText(String text) async {
    if (!_isInitialized) return;

    try {
      _watermarkText = text;
      await _securityService.setWatermarkText(text);
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting watermark text: $e');
      // Revert the state if the operation failed
      _watermarkText = _securityService.getWatermarkText();
      notifyListeners();
    }
  }

  Future<void> toggleSecureMode() async {
    if (!_isInitialized) return;

    try {
      _isSecureMode = !_isSecureMode;
      await _securityService.setSecureMode(_isSecureMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling secure mode: $e');
      // Revert the state if the operation failed
      _isSecureMode = !_isSecureMode;
      notifyListeners();
    }
  }

  String getWatermarkTextWithTimestamp() {
    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '$_watermarkText - $timestamp';
  }
} 