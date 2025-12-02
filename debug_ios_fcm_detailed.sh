#!/bin/bash

echo "🔍 DEBUG iOS FCM CHI TIẾT"
echo "================================"
echo ""

echo "1️⃣ Kiểm tra Bundle ID"
echo "---"
XCODE_BUNDLE=$(grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
FIREBASE_BUNDLE=$(grep -A 1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
echo "Xcode:    $XCODE_BUNDLE"
echo "Firebase: $FIREBASE_BUNDLE"

if [ "$XCODE_BUNDLE" = "$FIREBASE_BUNDLE" ]; then
    echo "✅ Bundle ID khớp"
else
    echo "❌ Bundle ID KHÔNG khớp!"
fi
echo ""

echo "2️⃣ Kiểm tra Entitlements"
echo "---"
cat ios/Runner/Runner.entitlements
echo ""

echo "3️⃣ Kiểm tra Info.plist - Background Modes"
echo "---"
if grep -q "remote-notification" ios/Runner/Info.plist; then
    echo "✅ Remote notification enabled"
else
    echo "❌ Remote notification CHƯA enabled"
fi
echo ""

echo "4️⃣ Kiểm tra Firebase config"
echo "---"
GCM_ID=$(grep -A 1 "GCM_SENDER_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
APP_ID=$(grep -A 1 "GOOGLE_APP_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
echo "GCM Sender ID: $GCM_ID"
echo "Google App ID: $APP_ID"
echo ""

echo "5️⃣ Kiểm tra AppDelegate.swift"
echo "---"
if grep -q "FirebaseApp.configure()" ios/Runner/AppDelegate.swift; then
    echo "✅ Firebase initialized"
else
    echo "❌ Firebase CHƯA initialized"
fi

if grep -q "registerForRemoteNotifications" ios/Runner/AppDelegate.swift; then
    echo "✅ Remote notifications registered"
else
    echo "❌ Remote notifications CHƯA registered"
fi

if grep -q "Messaging.messaging().delegate" ios/Runner/AppDelegate.swift; then
    echo "✅ FCM delegate set"
else
    echo "❌ FCM delegate CHƯA set"
fi
echo ""

echo "6️⃣ Kiểm tra Pods"
echo "---"
if [ -f "ios/Podfile.lock" ]; then
    FIREBASE_VERSION=$(grep "Firebase/Messaging" ios/Podfile.lock | head -1 | sed 's/.*(\(.*\))/\1/')
    echo "Firebase/Messaging: $FIREBASE_VERSION"
else
    echo "❌ Podfile.lock không tồn tại"
fi
echo ""

echo "================================"
echo "📋 CHECKLIST DEBUG"
echo "================================"
echo ""
echo "Khi chạy app, kiểm tra console logs:"
echo ""
echo "✅ Phải thấy:"
echo "   - Firebase registration token: [token]"
echo "   - ✅ FCM initialized successfully"
echo "   - ✅ FCM: User granted permission"
echo "   - 📱 FCM Token: [token]"
echo ""
echo "❌ Nếu thấy:"
echo "   - Failed to register for remote notifications"
echo "   - User declined permission"
echo "   - Token null"
echo ""
echo "🔧 BƯỚC TIẾP THEO:"
echo "================================"
echo ""
echo "1. Chạy app và copy console logs đầy đủ"
echo "2. Vào Settings → Xem FCM Token"
echo "3. Copy token và test từ Firebase Console"
echo "4. Kiểm tra xem có nhận được notification không"
echo ""
echo "📱 LƯU Ý QUAN TRỌNG:"
echo "   - Phải test trên REAL DEVICE (không phải simulator)"
echo "   - Phải chấp nhận quyền notification"
echo "   - App có thể ở foreground hoặc background"
echo "   - Kiểm tra Do Not Disturb đã tắt chưa"
echo ""
