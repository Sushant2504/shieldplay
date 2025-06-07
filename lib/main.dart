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
import 'services/video_service.dart';
import 'services/security_service.dart';
import 'services/screenshot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  final videoService = VideoService();
  final securityService = SecurityService();
  final screenshotService = ScreenshotService();
  
  await videoService.initialize();
  await securityService.initialize();
  await screenshotService.initialize();

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
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ShieldPlay',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
  }
}