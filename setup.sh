#!/bin/bash

echo "========================================"
echo "SupplyLine MRO Suite Mobile Setup"
echo "========================================"
echo

echo "Checking Flutter installation..."
if ! command -v flutter &> /dev/null; then
    echo "Flutter is not installed or not in PATH."
    echo
    echo "Please install Flutter first:"
    echo "1. Download Flutter SDK from https://flutter.dev/docs/get-started/install"
    echo "2. Extract to a location like /opt/flutter or ~/flutter"
    echo "3. Add the flutter/bin directory to your PATH"
    echo "4. Run 'flutter doctor' to verify installation"
    echo
    echo "For macOS with Homebrew:"
    echo "brew install --cask flutter"
    echo
    echo "For Linux:"
    echo "snap install flutter --classic"
    echo
    exit 1
fi

echo "Flutter is installed!"
echo

echo "Running Flutter Doctor..."
flutter doctor
echo

echo "Installing Flutter dependencies..."
flutter pub get
echo

echo "Checking for connected devices..."
flutter devices
echo

echo "========================================"
echo "Setup Complete!"
echo "========================================"
echo
echo "To run the app:"
echo "  flutter run"
echo
echo "To run on a specific device:"
echo "  flutter run -d android"
echo "  flutter run -d ios"
echo
echo "To build for release:"
echo "  flutter build apk --release"
echo "  flutter build appbundle --release"
echo
