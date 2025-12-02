#!/bin/bash

echo "🔧 SỬA APNs ENVIRONMENT CHO iOS"
echo "================================"
echo ""

echo "📋 Vấn đề:"
echo "   iOS không nhận notification có thể do APNs environment không đúng"
echo "   - development: Dùng cho debug build"
echo "   - production: Dùng cho release build"
echo ""

echo "🔍 Kiểm tra hiện tại:"
echo "---"
cat ios/Runner/Runner.entitlements | grep -A 1 "aps-environment"
echo ""

echo "🛠️ Giải pháp:"
echo "================================"
echo ""

echo "Thử 1: Đổi sang PRODUCTION"
echo "---"
echo "Sửa file ios/Runner/Runner.entitlements:"
echo ""
cat << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>production</string>
</dict>
</plist>
EOF
echo ""

echo "Sau đó:"
echo "1. flutter clean"
echo "2. flutter run --release"
echo "3. Test lại notification"
echo ""

echo "Thử 2: Kiểm tra Xcode Signing"
echo "---"
echo "1. Mở: open ios/Runner.xcworkspace"
echo "2. Runner target → Signing & Capabilities"
echo "3. Kiểm tra:"
echo "   - Team: Đã chọn chưa?"
echo "   - Signing Certificate: Có certificate nào không?"
echo "   - Provisioning Profile: Có profile nào không?"
echo ""

echo "Thử 3: Tạo lại APNs Certificate"
echo "---"
echo "1. Vào: https://developer.apple.com/account/resources/certificates/list"
echo "2. Tạo certificate mới:"
echo "   - Apple Push Notification service SSL (Sandbox & Production)"
echo "3. Download và cài đặt vào Keychain"
echo "4. Export certificate (.p12)"
echo "5. Upload vào Firebase Console"
echo ""

echo "================================"
echo "🎯 CÁCH NHANH NHẤT"
echo "================================"
echo ""
echo "Tôi sẽ tự động đổi sang production và rebuild:"
echo ""

read -p "Đổi sang production và rebuild? (y/n) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "1️⃣ Đổi sang production..."
    cat > ios/Runner/Runner.entitlements << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>aps-environment</key>
	<string>production</string>
</dict>
</plist>
EOF
    echo "   ✅ Đã đổi sang production"
    echo ""
    
    echo "2️⃣ Clean build..."
    flutter clean
    cd ios
    rm -rf build Pods .symlinks Podfile.lock
    pod install
    cd ..
    echo "   ✅ Cleaned"
    echo ""
    
    echo "3️⃣ Rebuild..."
    flutter pub get
    echo "   ✅ Ready"
    echo ""
    
    echo "================================"
    echo "✅ HOÀN TẤT!"
    echo "================================"
    echo ""
    echo "Bây giờ chạy:"
    echo "   flutter run --release"
    echo ""
    echo "Sau đó test lại notification từ Firebase Console"
    echo ""
else
    echo "Đã hủy"
fi
