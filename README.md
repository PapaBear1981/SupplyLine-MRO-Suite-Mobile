# SupplyLine MRO Suite Mobile

A Flutter mobile application for the SupplyLine MRO Suite - Tool control program for aerospace tooling.

## Overview

This mobile app provides a convenient way to manage aerospace tools on-the-go, allowing users to:
- Check out and return tools
- Scan QR codes for quick tool identification
- View tool status and availability
- Generate reports
- Manage user profiles

**🚀 Status: Foundation Complete - Ready for Phase 2 Development**

This initial release establishes the complete foundation with remote-first architecture, authentication, and core systems. Ready for tool management feature development.

## Features

### Current Features
- ✅ User authentication and authorization
- ✅ Dashboard with quick actions
- ✅ Modern Material Design 3 UI
- ✅ Dark/Light theme support
- ✅ Secure local storage
- ✅ API integration with backend

### Planned Features
- 🔄 Tool management (CRUD operations)
- 🔄 QR code scanning
- 🔄 Barcode generation
- 🔄 Offline mode support
- 🔄 Push notifications
- 🔄 Report generation
- 🔄 Camera integration for tool photos
- 🔄 Advanced search and filtering

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)

   ### Windows Installation:
   ```bash
   # Option 1: Using Chocolatey (run as Administrator)
   choco install flutter

   # Option 2: Manual Installation
   # 1. Download Flutter SDK from https://flutter.dev/docs/get-started/install/windows
   # 2. Extract to C:\flutter
   # 3. Add C:\flutter\bin to your PATH environment variable
   # 4. Run 'flutter doctor' to verify installation
   ```

   ### macOS Installation:
   ```bash
   # Using Homebrew:
   brew install --cask flutter

   # Or download from https://flutter.dev/docs/get-started/install/macos
   ```

   ### Linux Installation:
   ```bash
   # Using Snap:
   sudo snap install flutter --classic

   # Or download from https://flutter.dev/docs/get-started/install/linux
   ```

2. **Android Studio** or **VS Code** with Flutter extensions

3. **Android SDK** (for Android development)

4. **Xcode** (for iOS development, macOS only)

5. **Git** (for version control)

## Installation

1. **Clone the repository** (if not already done):
   ```bash
   git clone https://github.com/PapaBear1981/SupplyLine-MRO-Suite.git
   cd SupplyLine-MRO-Suite/supplyline/SupplyLine-MRO-Suite-Mobile
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify Flutter installation**:
   ```bash
   flutter doctor
   ```

4. **Run the app**:
   ```bash
   # For development
   flutter run

   # For specific platform
   flutter run -d android
   flutter run -d ios
   ```

## Configuration

### Backend API Configuration

Update the API configuration in `lib/core/config/app_config.dart`:

```dart
class AppConfig {
  // Update this to your backend URL
  static const String baseUrl = 'http://your-backend-url:5000';
  // ... other configurations
}
```

### Development vs Production

For development, the app is configured to connect to `http://localhost:5000`.
For production, update the `baseUrl` in `AppConfig` to your production server URL.

## Project Structure

```
lib/
├── core/
│   ├── config/          # App configuration
│   ├── models/          # Data models
│   ├── router/          # Navigation routing
│   ├── services/        # API and storage services
│   └── theme/           # App theming
├── features/
│   ├── auth/            # Authentication feature
│   ├── dashboard/       # Dashboard feature
│   ├── tools/           # Tool management feature
│   ├── reports/         # Reports feature
│   └── profile/         # User profile feature
└── main.dart            # App entry point
```

## Architecture

The app follows **Clean Architecture** principles with:

- **Riverpod** for state management
- **Go Router** for navigation
- **Dio** for HTTP requests
- **Hive** for local storage
- **Material Design 3** for UI components

## API Integration

The mobile app integrates with the SupplyLine MRO Suite backend API:

### Authentication Endpoints
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `POST /api/v1/auth/refresh` - Token refresh

### Tools Endpoints
- `GET /api/v1/tools` - Get tools list
- `GET /api/v1/tools/{id}` - Get tool details
- `POST /api/v1/tools/checkout` - Checkout tool
- `POST /api/v1/tools/return` - Return tool

### Reports Endpoints
- `GET /api/v1/reports/tool-usage` - Tool usage reports
- `GET /api/v1/reports/user-activity` - User activity reports

## Development

### Running in Development Mode

1. Start the backend server:
   ```bash
   cd ../SupplyLine-MRO-Suite/backend
   python app.py
   ```

2. Start the Flutter app:
   ```bash
   flutter run
   ```

### Building for Production

#### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

#### iOS
```bash
flutter build ios --release
```

## Testing

Run tests with:
```bash
flutter test
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.

## Support

For support, please contact the development team or create an issue in the repository.

## Changelog

### Version 1.0.0 (Initial Release)
- Basic authentication system
- Dashboard with quick actions
- Navigation structure
- API integration framework
- Local storage implementation
- Material Design 3 UI
