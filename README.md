# ShieldPlay - Secure Video Player

ShieldPlay is a Flutter-based video player application with advanced security features designed to protect private video content. The app provides a secure environment for viewing sensitive videos with features like screenshot protection, secure mode, and dynamic watermarking.

## Features

### Security Features
- **Screenshot Protection**: Prevents users from taking screenshots of private content
- **Secure Mode**: Enables additional security features and restricts video controls
- **Dynamic Watermarking**: Adds customizable watermarks to videos with timestamp
- **Screenshot Attempt Tracking**: Monitors and logs screenshot attempts

### Video Player Features
- Support for both local and network videos
- Multiple video quality options
- Adjustable playback speed
- Full-screen mode
- Video progress tracking
- Cache management for network videos

### UI/UX Features
- Dark/Light theme support
- Grid and List view options
- Search functionality
- Playlist organization
- Modern Material Design 3 interface

## Technical Implementation

### Architecture
- Provider pattern for state management
- Service-based architecture for core functionality
- Clean separation of concerns between UI and business logic

### Key Components
- `VideoProvider`: Manages video playback and state
- `SecurityProvider`: Handles security features and settings
- `ScreenshotProvider`: Manages screenshot protection and tracking
- `ThemeProvider`: Controls app theming and appearance

## CI/CD Pipeline

The project uses GitHub Actions with Fastlane for automated deployment:

### iOS Pipeline
```yaml
- Fastlane match for certificate and provisioning profile management
- Automated version bumping
- App Store deployment
- TestFlight distribution
```

### Android Pipeline
```yaml
- Automated version bumping
- Play Store deployment
- Internal testing track distribution
```

### Pipeline Features
- Automated testing
- Code signing
- Version management
- Release notes generation
- Automated deployment to stores

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Xcode (for iOS development)
- Android Studio (for Android development)
- Fastlane (for CI/CD)

### Installation
1. Clone the repository:
```bash
git clone https://github.com/yourusername/shieldplay.git
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Environment Setup
1. Configure Fastlane:
```bash
cd ios && fastlane init
cd android && fastlane init
```

2. Set up environment variables for CI/CD:
```bash
# Add to your CI/CD secrets
FASTLANE_USER=your_app_store_connect_email
FASTLANE_PASSWORD=your_app_specific_password
MATCH_PASSWORD=your_match_encryption_password
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Fastlane team for the CI/CD tools
- All contributors who have helped shape this project
