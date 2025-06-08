import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/home_screen.dart';
import 'screens/player_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/security_status_screen.dart';
import 'providers/video_provider.dart';
import 'providers/security_provider.dart';
import 'providers/screenshot_provider.dart';
import 'providers/theme_provider.dart';
import 'services/video_service.dart';
import 'services/security_service.dart';
import 'services/screenshot_service.dart';
import 'utils/ui_utils.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services
  final videoService = VideoService();
  final securityService = SecurityService();
  final screenshotService = ScreenshotService();
  
  // Initialize services that require async setup
  await Future.wait([
    securityService.initialize(),
    screenshotService.initialize(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => VideoProvider(videoService),
        ),
        ChangeNotifierProvider(
          create: (_) => SecurityProvider(securityService),
        ),
        ChangeNotifierProvider(
          create: (_) => ScreenshotProvider(screenshotService),
        ),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: AppConstants.appName,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.light(
              primary: AppConstants.primaryColor,
              secondary: AppConstants.secondaryColor,
              background: Colors.grey[50]!,
              surface: Colors.white,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.black87,
              onSurface: Colors.black87,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[50],
              foregroundColor: Colors.black87,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            scaffoldBackgroundColor: Colors.grey[50],
            textTheme: TextTheme(
              titleLarge: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: TextStyle(
                color: Colors.black87,
              ),
              bodyMedium: TextStyle(
                color: Colors.black87,
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.black87,
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.dark(
              primary: AppConstants.primaryColor,
              secondary: AppConstants.secondaryColor,
              background: Colors.grey[900]!,
              surface: Colors.grey[800]!,
              onPrimary: Colors.white,
              onSecondary: Colors.white,
              onBackground: Colors.white,
              onSurface: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey[900],
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
            ),
            cardTheme: CardThemeData(
              color: Colors.grey[800],
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            scaffoldBackgroundColor: Colors.grey[900],
            textTheme: TextTheme(
              titleLarge: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              titleMedium: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              bodyLarge: TextStyle(
                color: Colors.white,
              ),
              bodyMedium: TextStyle(
                color: Colors.white,
              ),
            ),
            iconTheme: IconThemeData(
              color: Colors.white,
            ),
            dividerTheme: DividerThemeData(
              color: Colors.grey[700],
            ),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.grey[900],
              selectedItemColor: AppConstants.primaryColor,
              unselectedItemColor: Colors.grey[400],
            ),
          ),
          themeMode: themeProvider.themeMode,
          routerConfig: GoRouter(
            initialLocation: '/',
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/player/:id',
                builder: (context, state) {
                  final videoId = state.pathParameters['id']!;
                  return PlayerScreen(videoId: videoId);
                },
              ),
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                path: '/security',
                builder: (context, state) => const SecurityStatusScreen(),
              ),
            ],
          ),
        );
      },
    );
  }
}