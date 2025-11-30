# iOS FCM Checklist - Làm theo thứ tự

## ✅ Đã hoàn thành tự động
- [x] Cập nhật AppDelegate.swift với Firebase config
- [x] Thêm UIBackgroundModes vào Info.plist
- [x] Cài đặt Firebase pods
- [x] Cập nhật FCM service để không cần login

## 🔧 CẦN LÀM THÊM (Quan trọng!)

### 1. Mở Xcode và thêm Capabilities
```bash
open ios/Runner.xcworkspace
```

Trong Xcode:
- [ ] Chọn **Runner** target (icon màu xanh bên trái)
- [ ] Tab **Signing & Capabilities**
- [ ] Click **+ Capability** → Thêm **Push Notifications**
- [ ] Click **+ Capability** → Thêm **Background Modes**
  - [ ] Check: **Remote notifications**
  - [ ] Check: **Background fetch**

### 2. Kiểm tra Bundle ID
- [ ] Tab **General** trong Xcode
- [ ] **Bundle Identifier** phải là: `vn.coquan.test`
- [ ] Chọn **Team** (cần Apple Developer account)

### 3. Cấu hình APNs trong Firebase Console

#### Option A: APNs Authentication Key (Khuyến nghị)
- [ ] Vào https://developer.apple.com/account/resources/authkeys/list
- [ ] Create a new key (+)
- [ ] Tên: "Firebase FCM Key"
- [ ] Check: **Apple Push Notifications service (APNs)**
- [ ] Download file .p8 và lưu Key ID
- [ ] Vào Firebase Console → Project Settings → Cloud Messaging
- [ ] Upload APNs Authentication Key với Key ID và Team ID

#### Option B: APNs Certificate (Cách cũ)
- [ ] Tạo Push Certificate trong Apple Developer
- [ ] Upload vào Firebase Console

### 4. Cấu hình lại Firebase với bundle ID đúng
```bash
# Chạy script
./fix_ios_fcm.sh

# Hoặc thủ công
flutterfire configure \
  --project=marine-analytics-platform \
  --platforms=ios \
  --ios-bundle-id=vn.coquan.test \
  --out=lib/firebase_options.dart \
  --yes
```

### 5. Build và test trên REAL DEVICE
```bash
flutter clean
flutter pub get
flutter run
```

**LƯU Ý**: FCM KHÔNG hoạt động trên iOS Simulator!

### 6. Test FCM token
- [ ] Mở app trên real device
- [ ] Chấp nhận quyền notification khi được hỏi
- [ ] Đợi 3-5 giây
- [ ] Nhấn logo 3 lần
- [ ] Phải thấy dialog với FCM token

## 🔍 Kiểm tra nhanh

### Bundle ID khớp chưa?
```bash
# Check project
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | head -1

# Check Firebase config
grep "BUNDLE_ID" ios/Runner/GoogleService-Info.plist

# Phải giống nhau: vn.coquan.test
```

### Console logs phải thấy:
```
✅ FCM initialized successfully
✅ FCM: User granted permission
📱 FCM Token: [token string]
Firebase registration token: [token string]
```

## ❌ Nếu vẫn không được

### Token null?
1. Đảm bảo chạy trên **real device** (không phải simulator)
2. Xóa app và cài lại để được hỏi quyền notification lại
3. Kiểm tra APNs key đã upload vào Firebase chưa
4. Kiểm tra Bundle ID khớp chưa
5. Kiểm tra đã thêm Push Notifications capability chưa

### Build error?
```bash
cd ios
rm -rf Pods .symlinks Podfile.lock
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### "No provisioning profile" error?
1. Mở Xcode
2. Signing & Capabilities
3. Chọn Team
4. Hoặc check "Automatically manage signing"

## 📱 Yêu cầu tối thiểu

- ✅ macOS (để build iOS)
- ✅ Xcode installed
- ✅ Real iOS device (không phải simulator)
- ✅ Apple Developer account (free hoặc paid)
- ✅ APNs certificate/key trong Firebase Console

## 🎯 Kết quả mong đợi

Sau khi hoàn thành checklist:
- App build thành công trên iOS
- FCM token hiển thị khi nhấn logo 3 lần
- Token được lưu vào database sau login
- Nhận được push notification

## 📞 Cần giúp đỡ?

Nếu vẫn không được, cung cấp:
1. Console logs khi chạy app
2. Bundle ID trong Xcode
3. Bundle ID trong GoogleService-Info.plist
4. Screenshot Signing & Capabilities trong Xcode
5. Có APNs key trong Firebase Console chưa?
