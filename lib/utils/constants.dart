import 'package:flutter/material.dart';

class AppConstants {
  // App Info
  static const String appName = 'ShieldPlay';
  static const String appVersion = '1.0.0';

  // Theme
  static const Color primaryColor = Color(0xFF2196F3);
  static const Color secondaryColor = Color(0xFF03A9F4);
  static const Color backgroundColor = Color(0xFF121212);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Colors.grey;
  static const Color cardColor = Color(0xFF1E1E1E);

  // Video Player
  static const double videoAspectRatio = 16 / 9;
  static const Duration watermarkUpdateInterval = Duration(seconds: 30);
  static const Duration controlsHideDelay = Duration(seconds: 3);
  static const Duration seekStep = Duration(seconds: 10);
  static const Duration doubleTapSeekDuration = Duration(seconds: 10);

  // Cache
  static const int maxCacheSize = 1024 * 1024 * 1024; // 1GB
  static const String cacheDirectory = 'video_cache';

  // Supported Video Formats
  static const List<String> supportedFormats = [
    'mp4',
    'mkv',
    'avi',
    'mov',
    'wmv',
    'flv',
    'webm',
    'm4v',
    '3gp',
  ];

  // Network
  static const Duration networkTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);

  // Security
  static const String watermarkDefaultText = 'ShieldPlay';
  static const double watermarkOpacity = 0.7;
  static const double watermarkFontSize = 16.0;
  static const Duration securityCheckInterval = Duration(seconds: 1);

  // UI
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double defaultIconSize = 24.0;
  static const double defaultSpacing = 8.0;
  static const double gridSpacing = 8.0;
  static const int gridCrossAxisCount = 2;
} 