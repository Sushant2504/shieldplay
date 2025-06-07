# Secure Video Player

A Flutter application that provides a secure video player with watermarking and screenshot protection features.

## Features

- Custom video player with basic controls
- Dynamic watermarking system with timestamp
- Screenshot detection and prevention
- Secure mode with additional restrictions
- Video caching for offline playback
- Clean, modern UI

## Setup Instructions

1. Clone the repository:
```bash
git clone https://github.com/yourusername/secure-video-player.git
cd secure-video-player
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
  ├── models/
  │   └── video_model.dart
  ├── providers/
  │   ├── video_provider.dart
  │   ├── security_provider.dart
  │   └── screenshot_provider.dart
  ├── screens/
  │   ├── home_screen.dart
  │   ├── player_screen.dart
  │   ├── settings_screen.dart
  │   └── security_status_screen.dart
  ├── services/
  │   ├── video_service.dart
  │   ├── security_service.dart
  │   └── screenshot_service.dart
  ├── widgets/
  │   └── custom_video_player.dart
  └── main.dart
```

## Testing Screenshot Detection

1. Launch the app on a physical device
2. Navigate to the video player screen
3. Try to take a screenshot using the device's screenshot shortcut
4. The app should detect the attempt and show a warning

## Known Limitations

- Screenshot detection may not work on all devices
- Watermark updates every 30 seconds
- Video caching is limited to 5 videos
- Secure mode restrictions are basic

## Architecture Decisions

- Used Provider for state management
- Implemented GoRouter for navigation
- Separated concerns into services and providers
- Used platform channels for screenshot detection

## Security Approach

- Screenshot protection using platform-specific implementations
- Watermarking with dynamic timestamps
- Secure mode with playback restrictions
- Video caching with size limits

## Future Improvements

- Add more video player controls
- Implement advanced watermarking options
- Add video quality selection
- Improve screenshot detection reliability
- Add more security features

## Dependencies

- flutter: ^3.0.0
- provider: ^6.0.5
- go_router: ^13.0.0
- video_player: ^2.8.1
- shared_preferences: ^2.2.2
- path_provider: ^2.1.1
- intl: ^0.18.1
- flutter_secure_storage: ^9.0.0
- permission_handler: ^11.0.1
- flutter_screen_lock: ^9.0.0
- flutter_secure_screen: ^1.0.0

## License

This project is licensed under the MIT License - see the LICENSE file for details.
