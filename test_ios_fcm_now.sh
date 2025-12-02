#!/bin/bash

echo "🚀 CHUẨN BỊ TEST iOS FCM"
echo "================================"
echo ""

echo "✅ Đã kiểm tra:"
echo "   - Xcode: Push Notifications capability ✓"
echo "   - Xcode: Background Modes ✓"
echo "   - Firebase: APNs key uploaded ✓"
echo "   - Bundle ID: vn.coquan.test ✓"
echo ""

echo "📱 BƯỚC TIẾP THEO:"
echo "================================"
echo ""

echo "1️⃣ Clean project"
flutter clean
echo "   ✅ Cleaned"
echo ""

echo "2️⃣ Clean iOS pods"
cd ios
rm -rf Pods .symlinks Podfile.lock
echo "   ✅ Removed old pods"
echo ""

echo "3️⃣ Install pods"
pod install
echo "   ✅ Pods installed"
cd ..
echo ""

echo "4️⃣ Get dependencies"
flutter pub get
echo "   ✅ Dependencies ready"
echo ""

echo "================================"
echo "✅ SẴN SÀNG TEST!"
echo "================================"
echo ""

echo "🔴 QUAN TRỌNG:"
echo "   - Phải test trên REAL DEVICE (iPhone/iPad thật)"
echo "   - KHÔNG test trên Simulator (không hỗ trợ FCM)"
echo ""

echo "📋 CÁCH TEST:"
echo ""
echo "1. Kết nối iPhone/iPad vào máy Mac"
echo "2. Chạy lệnh:"
echo "   flutter run"
echo ""
echo "3. Chọn device iOS thật (không phải simulator)"
echo ""
echo "4. Khi app mở:"
echo "   - Chấp nhận quyền notification khi được hỏi"
echo "   - Đợi 3-5 giây"
echo "   - Nhấn logo 3 lần"
echo "   - Phải thấy dialog với FCM token"
echo ""
echo "5. Test notification:"
echo "   - Vào Firebase Console → Cloud Messaging"
echo "   - Send test message"
echo "   - Paste FCM token"
echo "   - Click Test"
echo ""

echo "📊 Console logs mong đợi:"
echo "   ✅ FCM initialized successfully"
echo "   ✅ FCM: User granted permission"
echo "   📱 FCM Token: [long token string]"
echo "   Firebase registration token: [token string]"
echo "   ✅ FCM token saved to database"
echo ""

echo "🎯 Nếu thấy token → FCM đã hoạt động!"
echo ""
