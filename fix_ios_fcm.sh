#!/bin/bash

echo "🍎 Fix iOS FCM Configuration"
echo "=============================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}❌ This script must be run on macOS${NC}"
    exit 1
fi

echo -e "${BLUE}📋 Current Bundle ID in project.pbxproj:${NC}"
grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -2

echo ""
echo -e "${BLUE}📋 Current Bundle ID in GoogleService-Info.plist:${NC}"
grep -A 1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist

echo ""
echo -e "${YELLOW}⚠️  Bundle IDs must match!${NC}"
echo ""

# Ask user to confirm
read -p "Do you want to reconfigure Firebase for iOS? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Skipping Firebase reconfiguration"
else
    echo ""
    echo "🔧 Reconfiguring Firebase..."
    
    # Check if FlutterFire CLI is installed
    if ! command -v flutterfire &> /dev/null; then
        echo "📦 Installing FlutterFire CLI..."
        dart pub global activate flutterfire_cli
        export PATH="$PATH":"$HOME/.pub-cache/bin"
    fi
    
    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        echo "📦 Installing Firebase CLI..."
        npm install -g firebase-tools
    fi
    
    echo "🔐 Logging into Firebase..."
    firebase login
    
    echo ""
    echo "⚙️  Running FlutterFire configure..."
    flutterfire configure \
      --project=marine-analytics-platform \
      --platforms=ios \
      --ios-bundle-id=vn.coquan.test \
      --out=lib/firebase_options.dart \
      --yes
fi

echo ""
echo "🧹 Cleaning iOS build..."
cd ios
rm -rf Pods
rm -rf .symlinks
rm -rf Flutter/Flutter.framework
rm -rf Flutter/App.framework
rm -rf Flutter/Flutter.podspec
rm Podfile.lock 2>/dev/null

echo ""
echo "📦 Installing pods..."
pod deintegrate
pod install

cd ..

echo ""
echo -e "${GREEN}✅ iOS FCM configuration complete!${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Open Xcode: open ios/Runner.xcworkspace"
echo "2. Select Runner target → Signing & Capabilities"
echo "3. Add capability: Push Notifications"
echo "4. Add capability: Background Modes"
echo "   - Check: Remote notifications"
echo "   - Check: Background fetch"
echo "5. Build and run: flutter run"
echo ""
echo "💡 Testing FCM on iOS:"
echo "   - Run app on real device (FCM doesn't work on simulator)"
echo "   - Accept notification permission when prompted"
echo "   - Tap logo 3 times to see FCM token"
echo ""
echo -e "${YELLOW}⚠️  Important:${NC}"
echo "   - FCM requires a real iOS device (not simulator)"
echo "   - You need Apple Developer account for Push Notifications"
echo "   - APNs certificate must be configured in Firebase Console"
