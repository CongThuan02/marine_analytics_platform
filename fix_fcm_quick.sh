#!/bin/bash

echo "🔧 Quick Fix FCM Bundle ID Issue"
echo "=================================="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if FlutterFire CLI is installed
if ! command -v flutterfire &> /dev/null; then
    echo -e "${YELLOW}⚠️  FlutterFire CLI not found${NC}"
    echo "📦 Installing FlutterFire CLI..."
    dart pub global activate flutterfire_cli
    
    # Add to PATH if needed
    export PATH="$PATH":"$HOME/.pub-cache/bin"
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${YELLOW}⚠️  Firebase CLI not found${NC}"
    echo "📦 Installing Firebase CLI..."
    npm install -g firebase-tools
fi

echo ""
echo "🔐 Logging into Firebase..."
firebase login

echo ""
echo "⚙️  Reconfiguring Firebase with correct bundle ID..."
echo "   Android package: vn.coquan.test"
echo "   iOS bundle ID: vn.coquan.test"
echo ""

flutterfire configure \
  --project=marine-analytics-platform \
  --platforms=android,ios \
  --android-package-name=vn.coquan.test \
  --ios-bundle-id=vn.coquan.test \
  --out=lib/firebase_options.dart \
  --yes

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Firebase configuration updated${NC}"
else
    echo -e "${RED}❌ Firebase configuration failed${NC}"
    exit 1
fi

echo ""
echo "🧹 Cleaning project..."
flutter clean

echo ""
echo "📦 Getting dependencies..."
flutter pub get

echo ""
echo "🤖 Cleaning Android build..."
cd android
./gradlew clean
cd ..

# Check if on macOS for iOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo ""
    echo "🍎 Cleaning iOS build..."
    cd ios
    pod deintegrate
    pod install
    cd ..
fi

echo ""
echo -e "${GREEN}✅ Done!${NC}"
echo ""
echo "📝 Next steps:"
echo "1. Run: flutter run"
echo "2. Open login/register screen"
echo "3. Tap logo 3 times to see FCM token"
echo ""
echo "💡 If token is still null:"
echo "   - Wait a few seconds after app opens"
echo "   - Check notification permissions"
echo "   - Check console logs for errors"
