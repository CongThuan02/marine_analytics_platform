#!/bin/bash

echo "🔧 SỬA LỖI ENTITLEMENTS"
echo "================================"
echo ""

echo "1️⃣ Clean Flutter build"
flutter clean
echo "   ✅ Cleaned"
echo ""

echo "2️⃣ Clean iOS build"
cd ios
rm -rf build
rm -rf Pods
rm -rf .symlinks
rm -rf Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*
echo "   ✅ Cleaned iOS"
echo ""

echo "3️⃣ Reinstall pods"
pod deintegrate
pod install
cd ..
echo "   ✅ Pods reinstalled"
echo ""

echo "4️⃣ Get Flutter dependencies"
flutter pub get
echo "   ✅ Dependencies ready"
echo ""

echo "================================"
echo "✅ HOÀN TẤT!"
echo "================================"
echo ""

echo "📱 Bây giờ chạy lại:"
echo "   flutter run"
echo ""

echo "Hoặc build từ Xcode:"
echo "   open ios/Runner.xcworkspace"
echo "   Product → Clean Build Folder (Shift+Cmd+K)"
echo "   Product → Build (Cmd+B)"
echo ""
