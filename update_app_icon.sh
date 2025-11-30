#!/bin/bash

echo "🔄 Updating app icon..."

# Step 1: Generate new icons
echo "📱 Generating launcher icons..."
flutter pub run flutter_launcher_icons

# Step 2: Clean build
echo "🧹 Cleaning build..."
flutter clean

# Step 3: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 4: For iOS - reinstall pods
if [ -d "ios" ]; then
    echo "🍎 Updating iOS pods..."
    cd ios
    rm -rf Pods Podfile.lock
    pod install
    cd ..
fi

echo "✅ Done! Now run:"
echo "   1. Uninstall old app from device"
echo "   2. flutter run"
