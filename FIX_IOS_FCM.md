# Fix FCM trên iOS

## Vấn đề

FCM không hoạt động trên iOS do:
1. ❌ Bundle ID không khớp giữa project và Firebase
2. ❌ Thiếu Push Notifications capability
3. ❌ Thiếu Background Modes capability
4. ❌ AppDelegate chưa được cấu hình đúng
5. ❌ Có thể thiếu APNs certificate trong Firebase Console

## Giải pháp

### Bước 1: Chạy script tự động

```bash
./fix_ios_fcm.sh
```

Script này sẽ:
- Kiểm tra Bundle ID
- Cấu hình lại Firebase với FlutterFire CLI
- Clean và rebuild iOS project
- Cài đặt lại pods

### Bước 2: Cấu hình Xcode (BẮT BUỘC)

#### 2.1. Mở project trong Xcode
```bash
open ios/Runner.xcworkspace
```

#### 2.2. Thêm Push Notifications capability
1. Chọn **Runner** target (màu xanh)
2. Tab **Signing & Capabilities**
3. Click **+ Capability**
4. Tìm và thêm **Push Notifications**

#### 2.3. Thêm Background Modes capability
1. Click **+ Capability** lần nữa
2. Tìm và thêm **Background Modes**
3. Check các options:
   - ✅ **Remote notifications**
   - ✅ **Background fetch**

#### 2.4. Kiểm tra Bundle Identifier
1. Tab **General**
2. Đảm bảo **Bundle Identifier** là: `vn.coquan.test`
3. Chọn **Team** (cần Apple Developer account)

### Bước 3: Cấu hình APNs trong Firebase Console

#### 3.1. Tạo APNs Key (khuyến nghị)
1. Vào [Apple Developer](https://developer.apple.com/account/resources/authkeys/list)
2. Keys → Create a new key (+)
3. Đặt tên: "Firebase FCM Key"
4. Check: **Apple Push Notifications service (APNs)**
5. Continue → Register → Download key (.p8 file)
6. **LƯU Ý**: Key ID và Team ID

#### 3.2. Upload APNs Key vào Firebase
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Project Settings → Cloud Messaging
3. Tab **Apple app configuration**
4. Upload APNs Authentication Key:
   - Key ID: (từ bước 3.1)
   - Team ID: (từ Apple Developer account)
   - Upload file .p8

### Bước 4: Build và test

```bash
# Clean
flutter clean

# Get dependencies
flutter pub get

# Run on real device (FCM không hoạt động trên simulator)
flutter run
```

## Các thay đổi đã thực hiện

### ✅ File: `ios/Runner/AppDelegate.swift`

Đã thêm:
- Import Firebase modules
- Configure Firebase trong `didFinishLaunchingWithOptions`
- Register for remote notifications
- Set FCM messaging delegate
- Handle token refresh
- Implement `MessagingDelegate`

### ✅ File: `ios/Runner/Info.plist`

Đã thêm:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

## Kiểm tra

### 1. Kiểm tra Bundle ID khớp

```bash
# Check project.pbxproj
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj

# Check GoogleService-Info.plist
grep "BUNDLE_ID" ios/Runner/GoogleService-Info.plist

# Phải giống nhau: vn.coquan.test
```

### 2. Kiểm tra capabilities trong Xcode

Mở Xcode và verify:
- ✅ Push Notifications có trong Signing & Capabilities
- ✅ Background Modes có trong Signing & Capabilities
- ✅ Remote notifications được check
- ✅ Background fetch được check

### 3. Test FCM token

```bash
# Run trên real device
flutter run

# Xem console log, phải thấy:
# ✅ FCM initialized successfully
# 📱 FCM Token: [token string]
# Firebase registration token: [token string]
```

### 4. Test bằng logo

1. Mở app trên real device
2. Đợi vài giây để FCM khởi tạo
3. Nhấn logo 3 lần
4. Phải thấy dialog với FCM token

## Troubleshooting

### Token vẫn null trên iOS

#### Nguyên nhân 1: Chạy trên simulator
**Giải pháp**: FCM chỉ hoạt động trên real device iOS

#### Nguyên nhân 2: Chưa có APNs certificate
**Giải pháp**: 
1. Tạo APNs key trong Apple Developer
2. Upload vào Firebase Console (xem Bước 3)

#### Nguyên nhân 3: Chưa cấp quyền notification
**Giải pháp**:
1. Xóa app khỏi device
2. Cài lại: `flutter run`
3. Chấp nhận quyền notification khi được hỏi

#### Nguyên nhân 4: Bundle ID không khớp
**Giải pháp**:
```bash
# Kiểm tra
grep "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj
grep "BUNDLE_ID" ios/Runner/GoogleService-Info.plist

# Nếu không khớp, chạy lại
./fix_ios_fcm.sh
```

#### Nguyên nhân 5: Thiếu capabilities
**Giải pháp**: Mở Xcode và thêm Push Notifications + Background Modes

### Build error

```bash
# Clean everything
flutter clean
cd ios
rm -rf Pods .symlinks Podfile.lock
pod deintegrate
pod install
cd ..

# Rebuild
flutter pub get
flutter run
```

### "No valid code signing" error

**Giải pháp**:
1. Mở Xcode: `open ios/Runner.xcworkspace`
2. Select Runner target
3. Signing & Capabilities → Team → Chọn team của bạn
4. Hoặc chọn "Automatically manage signing"

### APNs certificate error trong Firebase

**Giải pháp**:
1. Tạo APNs Authentication Key mới (xem Bước 3.1)
2. Upload vào Firebase Console
3. Đợi vài phút để Firebase xử lý
4. Rebuild app

## Lưu ý quan trọng

### 🔴 FCM trên iOS yêu cầu:
1. **Real device** (không hoạt động trên simulator)
2. **Apple Developer account** (để sign app)
3. **APNs certificate/key** (trong Firebase Console)
4. **Push Notifications capability** (trong Xcode)
5. **Background Modes capability** (trong Xcode)

### 🔴 Quyền notification:
- iOS yêu cầu user chấp nhận quyền notification
- Chỉ hỏi 1 lần, nếu từ chối phải xóa app và cài lại
- Hoặc vào Settings → App → Notifications để bật lại

### 🔴 Testing:
- Luôn test trên real device
- Đợi vài giây sau khi mở app để FCM khởi tạo
- Check console log để debug

## Debug logs

### Logs thành công:
```
✅ FCM initialized successfully
✅ FCM: User granted permission
📱 FCM Token: [long token string]
Firebase registration token: [token string]
✅ FCM token saved to database
```

### Logs lỗi:
```
❌ FCM init error: [error message]
⚠️ User declined permission
Failed to register for remote notifications: [error]
```

## Kết quả mong đợi

Sau khi fix:
- ✅ App build thành công trên iOS
- ✅ FCM token được lấy trên real device
- ✅ Logo nhấn 3 lần hiển thị token
- ✅ Token được lưu vào database sau login
- ✅ Nhận được notification khi có alert

## Tài liệu tham khảo

- [Firebase iOS Setup](https://firebase.google.com/docs/ios/setup)
- [FCM iOS Client](https://firebase.google.com/docs/cloud-messaging/ios/client)
- [APNs Overview](https://developer.apple.com/documentation/usernotifications)
- [FlutterFire Messaging](https://firebase.flutter.dev/docs/messaging/overview)
