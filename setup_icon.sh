#!/bin/bash

# Script to setup app icon for Flutter app
# Usage: ./setup_icon.sh [path_to_logo.png]

set -e

echo "🎨 Flutter App Icon Setup"
echo "========================="
echo ""

# Check if logo path is provided
if [ -z "$1" ]; then
    echo "❌ Error: Please provide path to logo image"
    echo "Usage: ./setup_icon.sh /path/to/logo.png"
    exit 1
fi

LOGO_PATH="$1"

# Check if logo file exists
if [ ! -f "$LOGO_PATH" ]; then
    echo "❌ Error: Logo file not found: $LOGO_PATH"
    exit 1
fi

echo "✅ Logo file found: $LOGO_PATH"
echo ""

# Create assets/images directory if not exists
echo "📁 Creating assets/images directory..."
mkdir -p assets/images

# Copy logo to assets
echo "📋 Copying logo to assets/images/logo.png..."
cp "$LOGO_PATH" assets/images/logo.png

echo "✅ Logo copied successfully"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."
flutter pub get

echo ""

# Generate icons
echo "🎨 Generating app icons..."
dart run flutter_launcher_icons

echo ""
echo "✅ App icons generated successfully!"
echo ""
echo "📱 Next steps:"
echo "1. Run: flutter clean"
echo "2. Run: flutter run"
echo "3. Check your app icon on the device"
echo ""
echo "🎉 Done!"
