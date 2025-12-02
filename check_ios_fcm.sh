#!/bin/bash

echo "🔍 KIỂM TRA CẤU HÌNH iOS FCM"
echo "================================"
echo ""

# 1. Check Bundle ID trong project
echo "1️⃣ Bundle ID trong Xcode project:"
XCODE_BUNDLE_ID=$(grep -m 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | sed 's/.*= \(.*\);/\1/')
echo "   $XCODE_BUNDLE_ID"
echo ""

# 2. Check Bundle ID trong Firebase config
echo "2️⃣ Bundle ID trong GoogleService-Info.plist:"
FIREBASE_BUNDLE_ID=$(grep -A 1 "BUNDLE_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
echo "   $FIREBASE_BUNDLE_ID"
echo ""

# 3. So sánh
if [ "$XCODE_BUNDLE_ID" = "$FIREBASE_BUNDLE_ID" ]; then
    echo "✅ Bundle ID khớp nhau!"
else
    echo "❌ Bundle ID KHÔNG khớp!"
    echo "   Xcode:    $XCODE_BUNDLE_ID"
    echo "   Firebase: $FIREBASE_BUNDLE_ID"
fi
echo ""

# 4. Check Push Notifications capability
echo "3️⃣ Kiểm tra Push Notifications capability:"
if grep -q "com.apple.Push" ios/Runner/Runner.entitlements 2>/dev/null; then
    echo "   ✅ Push Notifications đã được thêm"
else
    echo "   ❌ CHƯA có Push Notifications capability"
    echo "   👉 Cần mở Xcode và thêm Push Notifications trong Signing & Capabilities"
fi
echo ""

# 5. Check Background Modes
echo "4️⃣ Kiểm tra Background Modes:"
if grep -q "remote-notification" ios/Runner/Info.plist; then
    echo "   ✅ Remote notification đã được bật"
else
    echo "   ❌ CHƯA bật remote notification"
fi
echo ""

# 6. Check Firebase config file
echo "5️⃣ Kiểm tra GoogleService-Info.plist:"
if [ -f "ios/Runner/GoogleService-Info.plist" ]; then
    echo "   ✅ File tồn tại"
    
    # Check GCM_SENDER_ID
    GCM_ID=$(grep -A 1 "GCM_SENDER_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
    echo "   GCM Sender ID: $GCM_ID"
    
    # Check GOOGLE_APP_ID
    APP_ID=$(grep -A 1 "GOOGLE_APP_ID" ios/Runner/GoogleService-Info.plist | grep "string" | sed 's/.*<string>\(.*\)<\/string>/\1/')
    echo "   Google App ID: $APP_ID"
else
    echo "   ❌ File KHÔNG tồn tại"
fi
echo ""

# 7. Check Podfile
echo "6️⃣ Kiểm tra Podfile:"
if [ -f "ios/Podfile" ]; then
    echo "   ✅ Podfile tồn tại"
    IOS_VERSION=$(grep "platform :ios" ios/Podfile | sed "s/.*'\(.*\)'/\1/")
    echo "   iOS version: $IOS_VERSION"
else
    echo "   ❌ Podfile KHÔNG tồn tại"
fi
echo ""

# 8. Check Pods installed
echo "7️⃣ Kiểm tra Firebase Pods:"
if [ -f "ios/Podfile.lock" ]; then
    echo "   ✅ Pods đã được cài đặt"
    
    if grep -q "Firebase/Messaging" ios/Podfile.lock; then
        MESSAGING_VERSION=$(grep "Firebase/Messaging" ios/Podfile.lock | head -1 | sed 's/.*(\(.*\))/\1/')
        echo "   Firebase/Messaging: $MESSAGING_VERSION"
    else
        echo "   ⚠️  Firebase/Messaging không tìm thấy trong Podfile.lock"
    fi
else
    echo "   ❌ Pods CHƯA được cài đặt"
    echo "   👉 Chạy: cd ios && pod install"
fi
echo ""

# 9. Summary
echo "================================"
echo "📋 TÓM TẮT"
echo "================================"
echo ""

ISSUES=0

if [ "$XCODE_BUNDLE_ID" != "$FIREBASE_BUNDLE_ID" ]; then
    echo "❌ Bundle ID không khớp - CẦN SỬA"
    ISSUES=$((ISSUES + 1))
fi

if ! grep -q "com.apple.Push" ios/Runner/Runner.entitlements 2>/dev/null; then
    echo "❌ Chưa thêm Push Notifications capability - CẦN SỬA"
    echo "   👉 Mở Xcode: open ios/Runner.xcworkspace"
    echo "   👉 Signing & Capabilities → + Capability → Push Notifications"
    ISSUES=$((ISSUES + 1))
fi

if [ ! -f "ios/Podfile.lock" ]; then
    echo "❌ Chưa cài đặt Pods - CẦN SỬA"
    echo "   👉 Chạy: cd ios && pod install"
    ISSUES=$((ISSUES + 1))
fi

if [ $ISSUES -eq 0 ]; then
    echo "✅ Tất cả cấu hình cơ bản đã OK!"
    echo ""
    echo "🔔 BƯỚC TIẾP THEO:"
    echo "1. Đảm bảo đã upload APNs key vào Firebase Console"
    echo "2. Build app trên REAL DEVICE (không phải simulator)"
    echo "3. Chấp nhận quyền notification khi được hỏi"
    echo "4. Nhấn logo 3 lần để xem FCM token"
else
    echo ""
    echo "⚠️  Tìm thấy $ISSUES vấn đề cần sửa"
fi

echo ""
