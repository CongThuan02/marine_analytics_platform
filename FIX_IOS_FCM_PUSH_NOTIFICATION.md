# 🔧 Sửa lỗi iOS không nhận FCM Push Notification

## ❌ Vấn đề
iOS không nhận được push notification từ Firebase Cloud Messaging (FCM)

## ✅ Nguyên nhân đã tìm ra
Chưa thêm **Push Notifications capability** trong Xcode project

## 🛠️ Giải pháp - Làm theo thứ tự

### Bước 1: Mở Xcode workspace
```bash
open ios/Runner.xcworkspace
```

**LƯU Ý**: Phải mở file `.xcworkspace`, KHÔNG phải `.xcodeproj`

### Bước 2: Thêm Push Notifications Capability

1. Trong Xcode, chọn **Runner** (icon màu xanh ở sidebar bên trái)
2. Chọn tab **Signing & Capabilities** (ở giữa màn hình)
3. Click nút **+ Capability** (góc trên bên trái)
4. Tìm và chọn **Push Notifications**
5. Sẽ thấy "Push Notifications" xuất hiện trong danh sách capabilities

### Bước 3: Kiểm tra Background Modes

Trong cùng tab **Signing & Capabilities**:
1. Tìm section **Background Modes** (đã có sẵn)
2. Đảm bảo đã check:
   - ✅ **Remote notifications**
   - ✅ **Background fetch**

### Bước 4: Kiểm tra Signing

Trong tab **Signing & Capabilities**:
1. Chọn **Team** của bạn (cần Apple Developer account)
2. Hoặc check **Automatically manage signing**
3. Đảm bảo **Bundle Identifier** là: `vn.coquan.test`

### Bước 5: Upload APNs Key vào Firebase Console

**Quan trọng**: iOS FCM cần APNs key để hoạt động!

#### Tạo APNs Authentication Key:
1. Vào https://developer.apple.com/account/resources/authkeys/list
2. Click nút **+** để tạo key mới
3. Đặt tên: "Firebase FCM Key"
4. Check: **Apple Push Notifications service (APNs)**
5. Click **Continue** → **Register** → **Download**
6. Lưu file `.p8` và ghi nhớ **Key ID** và **Team ID**

#### Upload vào Firebase:
1. Vào Firebase Console: https://console.firebase.google.com
2. Chọn project **marine-analytics-platform**
3. Settings (⚙️) → **Project settings**
4. Tab **Cloud Messaging**
5. Scroll xuống **Apple app configuration**
6. Click **Upload** trong section **APNs Authentication Key**
7. Upload file `.p8`, nhập **Key ID** và **Team ID**

### Bước 6: Clean và Rebuild

```bash
# Clean project
flutter clean
cd ios
rm -rf Pods .symlinks Podfile.lock
pod install
cd ..

# Get dependencies
flutter pub get

# Build và chạy trên REAL DEVICE
flutter run
```

**LƯU Ý**: FCM KHÔNG hoạt động trên iOS Simulator! Phải test trên thiết bị thật.

### Bước 7: Test FCM

1. Chạy app trên **real iOS device**
2. Khi được hỏi, chấp nhận quyền notification
3. Đợi 3-5 giây để FCM khởi tạo
4. Nhấn logo 3 lần để xem FCM token
5. Phải thấy dialog hiển thị token

### Bước 8: Gửi test notification

Có 3 cách test:

#### Cách 1: Từ Firebase Console
1. Firebase Console → **Cloud Messaging**
2. Click **Send your first message**
3. Nhập title và body
4. Click **Send test message**
5. Paste FCM token từ app
6. Click **Test**

#### Cách 2: Từ Supabase Edge Function
```sql
-- Trong Supabase SQL Editor
SELECT send_fcm_notification(
  'YOUR_FCM_TOKEN_HERE',
  'Test Title',
  'Test Body',
  jsonb_build_object('type', 'test')
);
```

#### Cách 3: Từ curl
```bash
curl -X POST https://fcm.googleapis.com/v1/projects/marine-analytics-platform/messages:send \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test",
        "body": "Test notification"
      }
    }
  }'
```

## 🔍 Kiểm tra nhanh

Chạy script kiểm tra:
```bash
./check_ios_fcm.sh
```

Phải thấy:
```
✅ Bundle ID khớp nhau!
✅ Push Notifications đã được thêm
✅ Remote notification đã được bật
✅ Tất cả cấu hình cơ bản đã OK!
```

## 📱 Console logs mong đợi

Khi chạy app, phải thấy trong console:
```
✅ FCM initialized successfully
✅ FCM: User granted permission
📱 FCM Token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
Firebase registration token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
✅ FCM token saved to database
```

## ❌ Troubleshooting

### Token vẫn null?
1. ✅ Đảm bảo chạy trên **real device** (không phải simulator)
2. ✅ Đã upload APNs key vào Firebase Console
3. ✅ Đã thêm Push Notifications capability trong Xcode
4. ✅ Đã chấp nhận quyền notification
5. ✅ Bundle ID khớp với Firebase config

### Không được hỏi quyền notification?
```bash
# Xóa app và cài lại
flutter clean
flutter run
```

### Build error "No provisioning profile"?
1. Mở Xcode
2. Signing & Capabilities
3. Chọn Team
4. Hoặc check "Automatically manage signing"

### "aps-environment" error?
File `Runner.entitlements` đã được cập nhật tự động. Nếu vẫn lỗi:
```bash
cd ios
pod install
cd ..
flutter clean
flutter run
```

## 📋 Checklist cuối cùng

- [ ] Đã mở Xcode workspace
- [ ] Đã thêm Push Notifications capability
- [ ] Đã check Remote notifications trong Background Modes
- [ ] Đã chọn Team trong Signing
- [ ] Đã upload APNs key vào Firebase Console
- [ ] Đã clean và rebuild project
- [ ] Đang test trên real device (không phải simulator)
- [ ] Đã chấp nhận quyền notification
- [ ] FCM token hiển thị khi nhấn logo 3 lần
- [ ] Nhận được test notification

## 🎯 Kết quả mong đợi

Sau khi hoàn thành:
- ✅ App build thành công trên iOS
- ✅ FCM token được tạo và hiển thị
- ✅ Token được lưu vào database
- ✅ Nhận được push notification từ Firebase
- ✅ Notification hiển thị cả khi app đang foreground và background

## 📞 Vẫn không được?

Cung cấp thông tin sau để debug:
1. Console logs khi chạy app
2. Screenshot Signing & Capabilities trong Xcode
3. Có thấy Push Notifications trong capabilities không?
4. Đã upload APNs key vào Firebase chưa?
5. Đang test trên simulator hay real device?
6. FCM token có hiển thị không?

---

**Tóm tắt**: Vấn đề chính là chưa thêm Push Notifications capability trong Xcode. Sau khi thêm và upload APNs key vào Firebase, iOS sẽ nhận được push notification bình thường.
