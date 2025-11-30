#!/bin/bash

# Script tự động cấu hình lại Firebase sau khi đổi bundleId
# Sử dụng Firebase CLI (FlutterFire CLI)

echo "🔥 Bắt đầu cấu hình lại Firebase..."

# Kiểm tra Firebase CLI đã cài chưa
if ! command -v firebase &> /dev/null; then
    echo "❌ Firebase CLI chưa được cài đặt!"
    echo "📦 Cài đặt Firebase CLI..."
    npm install -g firebase-tools
fi

# Kiểm tra FlutterFire CLI đã cài chưa
if ! command -v flutterfire &> /dev/null; then
    echo "❌ FlutterFire CLI chưa được cài đặt!"
    echo "📦 Cài đặt FlutterFire CLI..."
    dart pub global activate flutterfire_cli
fi

# Đăng nhập Firebase (nếu chưa đăng nhập)
echo "🔐 Kiểm tra đăng nhập Firebase..."
firebase login

# Cấu hình lại Firebase cho Flutter project
echo "⚙️  Cấu hình lại Firebase với bundleId mới..."
flutterfire configure \
  --project=marine-analytics-platform \
  --platforms=android,ios \
  --android-package-name=vn.coquan.test \
  --ios-bundle-id=vn.coquan.test \
  --out=lib/firebase_options.dart \
  --yes

# Xóa cache và build cũ
echo "🧹 Xóa cache và build cũ..."
flutter clean

# Lấy dependencies
echo "📦 Lấy dependencies..."
flutter pub get

# Cấu hình lại Android
echo "🤖 Cấu hình lại Android..."
cd android
./gradlew clean
cd ..

# Cấu hình lại iOS (nếu trên macOS)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Cấu hình lại iOS..."
    cd ios
    pod deintegrate
    pod install
    cd ..
fi

echo "✅ Hoàn tất! Firebase đã được cấu hình lại."
echo ""
echo "📝 Các bước tiếp theo:"
echo "1. Kiểm tra file google-services.json trong android/app/"
echo "2. Kiểm tra file GoogleService-Info.plist trong ios/Runner/"
echo "3. Chạy app để test FCM: flutter run"
