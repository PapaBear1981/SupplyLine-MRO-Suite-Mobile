# SupplyLine MRO Suite Mobile - Complete Setup Guide

This guide will walk you through setting up the Flutter mobile app for the SupplyLine MRO Suite.

## Quick Start

If you already have Flutter installed, you can quickly get started:

```bash
cd supplyline/SupplyLine-MRO-Suite-Mobile
flutter pub get
flutter run
```

## Detailed Setup Instructions

### Step 1: Install Flutter SDK

#### Windows (Recommended Method)
1. **Download Flutter SDK**:
   - Go to https://flutter.dev/docs/get-started/install/windows
   - Download the latest stable release
   - Extract to `C:\flutter`

2. **Update PATH**:
   - Open System Properties → Advanced → Environment Variables
   - Add `C:\flutter\bin` to your PATH
   - Restart your terminal

3. **Verify Installation**:
   ```cmd
   flutter doctor
   ```

#### Alternative: Using Chocolatey (Windows)
```cmd
# Run as Administrator
choco install flutter
```

#### macOS
```bash
# Using Homebrew
brew install --cask flutter

# Or download manually from https://flutter.dev/docs/get-started/install/macos
```

#### Linux
```bash
# Using Snap
sudo snap install flutter --classic

# Or download manually from https://flutter.dev/docs/get-started/install/linux
```

### Step 2: Install Development Tools

#### Android Studio (Recommended)
1. Download from https://developer.android.com/studio
2. Install Android SDK
3. Install Flutter and Dart plugins
4. Accept Android licenses: `flutter doctor --android-licenses`

#### VS Code (Alternative)
1. Install VS Code
2. Install Flutter extension
3. Install Dart extension

### Step 3: Set Up Mobile App

1. **Navigate to the mobile app directory**:
   ```bash
   cd supplyline/SupplyLine-MRO-Suite-Mobile
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run Flutter Doctor**:
   ```bash
   flutter doctor
   ```
   Fix any issues reported by Flutter Doctor.

4. **Configure Backend URL**:
   Edit `lib/core/config/app_config.dart`:
   ```dart
   static const String baseUrl = 'http://your-backend-url:5000';
   ```

### Step 4: Run the App

#### For Development
```bash
# Run on connected device
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
```

#### For Production Build
```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## Troubleshooting

### Common Issues

#### Flutter not found
- Ensure Flutter is in your PATH
- Restart your terminal/IDE
- Run `flutter doctor` to verify installation

#### Android SDK issues
- Install Android Studio
- Run `flutter doctor --android-licenses`
- Ensure Android SDK is properly configured

#### iOS issues (macOS only)
- Install Xcode from App Store
- Run `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer`
- Accept Xcode license: `sudo xcodebuild -license`

#### Dependencies issues
- Run `flutter clean`
- Run `flutter pub get`
- Restart your IDE

### Getting Help

1. **Flutter Doctor**: Always start with `flutter doctor`
2. **Official Documentation**: https://flutter.dev/docs
3. **GitHub Issues**: Create an issue in the repository
4. **Flutter Community**: https://flutter.dev/community

## Development Workflow

### Making Changes
1. Make your changes to the code
2. Hot reload: Press `r` in the terminal or save in your IDE
3. Hot restart: Press `R` in the terminal

### Testing
```bash
# Run tests
flutter test

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Building for Release
```bash
# Android
flutter build apk --release
flutter build appbundle --release

# iOS (macOS only)
flutter build ios --release
```

## Next Steps

Once you have the app running:

1. **Configure API endpoints** in `lib/core/config/app_config.dart`
2. **Test authentication** with the backend
3. **Explore the app features** and functionality
4. **Customize the app** for your specific needs

## Project Structure Overview

```
lib/
├── core/                 # Core functionality
│   ├── config/          # Configuration
│   ├── models/          # Data models
│   ├── services/        # API and storage services
│   └── theme/           # App theming
├── features/            # Feature modules
│   ├── auth/           # Authentication
│   ├── dashboard/      # Dashboard
│   ├── tools/          # Tool management
│   └── profile/        # User profile
└── main.dart           # App entry point
```

## Support

For additional support:
- Check the main [README.md](README.md)
- Review the [Flutter documentation](https://flutter.dev/docs)
- Create an issue in the GitHub repository
