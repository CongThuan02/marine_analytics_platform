# Fix iOS Signing for Bundle ID: vn.coquan.test

## The Issue
After changing bundle ID to `vn.coquan.test`, iOS needs a new provisioning profile.

## Quick Fix

### Option 1: Open in Xcode (Recommended)
```bash
open ios/Runner.xcworkspace
```

Then in Xcode:
1. Select **Runner** project in left sidebar
2. Select **Runner** target
3. Go to **Signing & Capabilities** tab
4. Make sure **Automatically manage signing** is checked
5. Select your **Team** (Apple Development: hoangthuan.it02@gmail.com)
6. Xcode will automatically create provisioning profile for `vn.coquan.test`
7. Close Xcode
8. Run `flutter run` again

### Option 2: Run on Simulator (No signing needed)
```bash
# List simulators
flutter devices

# Run on simulator
flutter run -d "iPhone 15 Pro"  # or any simulator name
```

### Option 3: Clean and Retry
```bash
# Clean everything
flutter clean
rm -rf ios/build
rm -rf ios/Pods
rm -rf ios/Podfile.lock

# Reinstall
cd ios
pod install
cd ..

# Try again
flutter run
```

## Current Bundle IDs
- **Android**: `vn.coquan.test`
- **iOS**: `vn.coquan.test`

## Note
The bundle ID `vn.coquan.test` is now set. You just need to configure signing in Xcode once, then it will work.
