import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;
  bool _isScreenshotProtectionEnabled = true;
  bool _isSecureMode = false;
  int _screenshotCount = 0;
  String _watermarkText = 'ShieldPlay';
  bool _isInitialized = false;

  SecurityProvider(this._securityService) {
    _initialize();
    _initializeScreenshotProtection();
  }

  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  bool get isSecureMode => _isSecureMode;
  int get screenshotCount => _screenshotCount;
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

  void _initializeScreenshotProtection() {
    if (_isScreenshotProtectionEnabled) {
      _securityService.enableScreenshotProtection(
        onScreenshotAttempt: _handleScreenshotAttempt,
      );
    }
  }

  void _handleScreenshotAttempt() {
    _screenshotCount++;
    notifyListeners();
    
    // Show a popup notification
    _showScreenshotWarning();
  }

  void _showScreenshotWarning() {
    // We'll use a static method to show the dialog since we don't have direct access to BuildContext
    SecurityService.showScreenshotWarning();
  }

  void toggleScreenshotProtection() {
    _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
    if (_isScreenshotProtectionEnabled) {
      _initializeScreenshotProtection();
    } else {
      _securityService.disableScreenshotProtection();
    }
    notifyListeners();
  }

  void toggleSecureMode() {
    _isSecureMode = !_isSecureMode;
    if (_isSecureMode) {
      _isScreenshotProtectionEnabled = true;
      _initializeScreenshotProtection();
    }
    notifyListeners();
  }

  void resetScreenshotCount() {
    _screenshotCount = 0;
    notifyListeners();
  }

  void setWatermarkText(String text) {
    _watermarkText = text;
    notifyListeners();
  }

  String getWatermarkTextWithTimestamp() {
    final now = DateTime.now();
    final timestamp = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';
    return '$_watermarkText - $timestamp';
  }
} 