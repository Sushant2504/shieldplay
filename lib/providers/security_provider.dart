import 'package:flutter/material.dart';
import '../services/security_service.dart';

class SecurityProvider extends ChangeNotifier {
  final SecurityService _securityService;
  bool _isScreenshotProtectionEnabled = true;
  bool _isSecureMode = false;
  String _watermarkText = 'ShieldPlay';
  int _screenshotCount = 0;

  SecurityProvider(this._securityService) {
    _initialize();
  }

  Future<void> _initialize() async {
    await _securityService.initialize();
    _securityService.enableScreenshotProtection(
      onScreenshotAttempt: _handleScreenshotAttempt,
    );
  }

  void _handleScreenshotAttempt() {
    if (!_isScreenshotProtectionEnabled) return;
    
    _screenshotCount++;
    notifyListeners();
    SecurityService.showScreenshotWarning();
  }

  bool get isScreenshotProtectionEnabled => _isScreenshotProtectionEnabled;
  bool get isSecureMode => _isSecureMode;
  String get watermarkText => _watermarkText;
  int get screenshotCount => _screenshotCount;

  void toggleScreenshotProtection() {
    _isScreenshotProtectionEnabled = !_isScreenshotProtectionEnabled;
    if (_isScreenshotProtectionEnabled) {
      _securityService.enableScreenshotProtection(
        onScreenshotAttempt: _handleScreenshotAttempt,
      );
    } else {
      _securityService.disableScreenshotProtection();
    }
    notifyListeners();
  }

  void toggleSecureMode() {
    _isSecureMode = !_isSecureMode;
    notifyListeners();
  }

  void setWatermarkText(String text) {
    _watermarkText = text;
    notifyListeners();
  }

  void resetScreenshotCount() {
    _screenshotCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _securityService.disableScreenshotProtection();
    super.dispose();
  }
} 