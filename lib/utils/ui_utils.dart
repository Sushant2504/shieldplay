import 'package:flutter/material.dart';
import 'constants.dart';

class UiUtils {
  static ThemeData getDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryColor,
      scaffoldBackgroundColor: AppConstants.backgroundColor,
      cardColor: AppConstants.cardColor,
      colorScheme: ColorScheme.dark(
        primary: AppConstants.primaryColor,
        secondary: AppConstants.primaryColor,
        surface: AppConstants.cardColor,
        background: AppConstants.backgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.backgroundColor,
        foregroundColor: AppConstants.textColor,
        elevation: 0,
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppConstants.primaryColor,
        unselectedLabelColor: AppConstants.secondaryTextColor,
        indicatorColor: AppConstants.primaryColor,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: AppConstants.textColor),
        bodyMedium: TextStyle(color: AppConstants.textColor),
        titleLarge: TextStyle(color: AppConstants.textColor),
        titleMedium: TextStyle(color: AppConstants.textColor),
      ),
      iconTheme: const IconThemeData(
        color: AppConstants.textColor,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryColor,
          foregroundColor: AppConstants.textColor,
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: AppConstants.textColor,
      ),
    );
  }

  static Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppConstants.primaryColor),
      ),
    );
  }

  static Widget buildErrorWidget(String message, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  static Widget buildEmptyWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            size: 64,
            color: AppConstants.secondaryTextColor,
          ),
          const SizedBox(height: AppConstants.defaultSpacing),
          Text(
            message,
            style: TextStyle(
              color: AppConstants.secondaryTextColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppConstants.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static Future<bool> showConfirmationDialog(
    BuildContext context,
    String title,
    String message,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  static Widget buildWatermark(String text) {
    return Opacity(
      opacity: AppConstants.watermarkOpacity,
      child: Text(
        text,
        style: TextStyle(
          color: AppConstants.textColor,
          fontSize: AppConstants.watermarkFontSize,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
} 