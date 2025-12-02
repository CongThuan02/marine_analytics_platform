# 🔑 Kiểm tra APNs Key trong Firebase Console

## Vấn đề hiện tại
Xcode đã cấu hình đúng nhưng iOS vẫn không nhận FCM push notification.

## Nguyên nhân có thể
**Chưa upload APNs Authentication Key vào Firebase Console**

iOS FCM yêu cầu APNs key để gửi notification. Không có key này, Firebase không thể gửi notification đến iOS device.

## ✅ Cách kiểm tra

### 1. Kiểm tra trong Firebase Console

1. Vào: https://console.firebase.google.com
2. Chọn project: **marine-analytics-platform**
3. Click ⚙️ Settings → **Project settings**
4. Tab **Cloud Messaging**
5. Scroll xuống phần **Apple app configuration**
6. Tìm app với Bundle ID: **vn.coquan.test**

**Kiểm tra xem có APNs key chưa:**
- Nếu thấy "APNs Authentication Key" với Key ID → ✅ Đã có
- Nếu thấy "Upload" button → ❌ Chưa có, cần upload

### 2. Nếu chưa có APNs key

#### Bước A: Tạo APNs Authentication Key

1. Vào: https://developer.apple.com/account/resources/authkeys/list
2. Đăng nhập với Apple Developer account
3. Click nút **+** (Create a key)
4. Điền thông tin:
   - **Key Name**: Firebase FCM Key (hoặc tên bất kỳ)
   - Check: ✅ **Apple Push Notifications service (APNs)**
5. Click **Continue**
6. Click **Register**
7. Click **Download** để tải file `.p8`
8. **LƯU Ý**: Lưu file này cẩn thận, chỉ download được 1 lần!
9. Ghi nhớ:
   - **Key ID**: Hiển thị trên trang (dạng: ABC123DEF4)
   - **Team ID**: Tìm ở https://developer.apple.com/account (góc trên phải)

#### Bước B: Upload vào Firebase Console

1. Quay lại Firebase Console → Cloud Messaging
2. Trong phần **Apple app configuration**
3. Click **Upload** trong section **APNs Authentication Key**
4. Điền thông tin:
   - **APNs auth key**: Upload file `.p8` vừa download
   - **Key ID**: Nhập Key ID (từ bước A.9)
   - **Team ID**: Nhập Team ID (từ bước A.9)
5. Click **Upload**

### 3. Sau khi upload APNs key

#### Clean và rebuild app:
```bash
flutter clean
cd ios
rm -rf Pods .symlinks Podfile.lock
pod install
cd ..
flutter pub get
```

#### Build và test trên REAL DEVICE:
```bash
flutter run
```

**QUAN TRỌNG**: 
- ❌ iOS Simulator KHÔNG hỗ trợ FCM
- ✅ Phải test trên iPhone/iPad thật

### 4. Test FCM token

1. Chạy app trên real device
2. Chấp nhận quyền notification khi được hỏi
3. Đợi 3-5 giây
4. Nhấn logo 3 lần
5. Phải thấy dialog hiển thị FCM token

**Console logs mong đợi:**
```
✅ FCM initialized successfully
✅ FCM: User granted permission
📱 FCM Token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
Firebase registration token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
✅ FCM token saved to database
```

### 5. Test gửi notification

#### Từ Firebase Console:
1. Firebase Console → **Cloud Messaging**
2. Click **Send your first message**
3. Nhập:
   - **Notification title**: Test
   - **Notification text**: Test notification
4. Click **Next**
5. Chọn app iOS
6. Click **Next** → **Next**
7. Click **Review** → **Publish**

Hoặc gửi test message:
1. Click **Send test message**
2. Paste FCM token từ app
3. Click **Test**

## 🔍 Debug nếu vẫn không nhận được

### Kiểm tra console logs:

**Nếu thấy:**
```
❌ FCM: User declined permission
```
→ Xóa app và cài lại để được hỏi quyền lại

**Nếu thấy:**
```
Failed to register for remote notifications: ...
```
→ Kiểm tra APNs key đã upload đúng chưa

**Nếu không thấy FCM token:**
→ Kiểm tra:
1. Đang chạy trên real device (không phải simulator)
2. APNs key đã upload vào Firebase
3. Bundle ID khớp: vn.coquan.test
4. Đã chấp nhận quyền notification

### Kiểm tra APNs certificate:

```bash
# Kiểm tra entitlements
cat ios/Runner/Runner.entitlements

# Phải thấy:
# <key>aps-environment</key>
# <string>development</string>
```

### Test với curl (nếu có server key):

```bash
# Lấy FCM token từ app
# Thay YOUR_FCM_TOKEN và YOUR_SERVER_KEY

curl -X POST https://fcm.googleapis.com/v1/projects/marine-analytics-platform/messages:send \
  -H "Authorization: Bearer YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "message": {
      "token": "YOUR_FCM_TOKEN",
      "notification": {
        "title": "Test from curl",
        "body": "This is a test notification"
      },
      "apns": {
        "payload": {
          "aps": {
            "alert": {
              "title": "Test from curl",
              "body": "This is a test notification"
            },
            "sound": "default"
          }
        }
      }
    }
  }'
```

## 📋 Checklist

- [ ] Đã vào Firebase Console
- [ ] Đã kiểm tra có APNs key chưa
- [ ] Nếu chưa có: Đã tạo APNs key từ Apple Developer
- [ ] Đã upload APNs key vào Firebase Console
- [ ] Đã clean và rebuild app
- [ ] Đang test trên real device (không phải simulator)
- [ ] Đã chấp nhận quyền notification
- [ ] FCM token hiển thị khi nhấn logo 3 lần
- [ ] Đã gửi test notification từ Firebase Console
- [ ] Nhận được notification

## 🎯 Kết quả mong đợi

Sau khi upload APNs key và test trên real device:
- ✅ FCM token được tạo thành công
- ✅ Token hiển thị khi nhấn logo 3 lần
- ✅ Nhận được test notification từ Firebase Console
- ✅ Notification hiển thị cả khi app foreground và background

---

**Tóm tắt**: Xcode đã cấu hình đúng. Bước tiếp theo là upload APNs key vào Firebase Console và test trên real device.
