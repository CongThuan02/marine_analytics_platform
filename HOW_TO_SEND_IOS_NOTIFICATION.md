# 📲 Cách gửi notification đúng cho iOS

## ⚠️ Vấn đề thường gặp

iOS FCM có yêu cầu đặc biệt về payload. Nếu gửi sai format, notification sẽ không hiển thị.

## ✅ Cách 1: Từ Firebase Console (Đơn giản nhất)

### Bước 1: Lấy FCM Token
1. Mở app trên iPhone
2. Vào Settings → "Xem FCM Token"
3. Copy token

### Bước 2: Gửi Test Message
1. Vào Firebase Console: https://console.firebase.google.com
2. Chọn project: **marine-analytics-platform**
3. **Messaging** → **Send your first message**
4. Click **Send test message** (góc trên phải)
5. Paste FCM token vào ô "Add an FCM registration token"
6. Click **Test**

**LƯU Ý**: 
- ❌ KHÔNG dùng "Send to all users" hoặc "Select topic"
- ✅ Phải dùng "Send test message" với token cụ thể

### Bước 3: Kiểm tra
- App có thể ở foreground hoặc background
- Notification phải hiển thị
- Có âm thanh thông báo

## ✅ Cách 2: Từ Firebase Console (Campaign)

1. **Messaging** → **New campaign** → **Firebase Notification messages**
2. **Notification**:
   - Title: "Test iOS"
   - Text: "Test notification"
3. Click **Next**
4. **Target**:
   - Chọn app iOS: **myapp (vn.coquan.test)**
5. Click **Next**
6. **Scheduling**: Now
7. Click **Next**
8. **Additional options**:
   - iOS sound: **default**
   - iOS badge: **1**
9. Click **Review** → **Publish**

## ✅ Cách 3: Từ Supabase Edge Function

Kiểm tra xem Edge Function có gửi đúng format cho iOS không:

```typescript
// supabase/functions/send-fcm-notification/index.ts

const message = {
  token: fcmToken,
  notification: {
    title: title,
    body: body,
  },
  // QUAN TRỌNG: Thêm apns config cho iOS
  apns: {
    payload: {
      aps: {
        alert: {
          title: title,
          body: body,
        },
        sound: 'default',
        badge: 1,
      },
    },
  },
  // Android config
  android: {
    notification: {
      title: title,
      body: body,
      sound: 'default',
      channelId: 'alerts_channel',
    },
  },
  data: data,
};
```

## ✅ Cách 4: Test bằng curl

```bash
# Lấy Server Key từ Firebase Console
# Project Settings → Cloud Messaging → Server key

curl -X POST https://fcm.googleapis.com/fcm/send \
  -H "Authorization: key=YOUR_SERVER_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "to": "YOUR_FCM_TOKEN",
    "notification": {
      "title": "Test iOS",
      "body": "Test notification từ curl"
    },
    "apns": {
      "payload": {
        "aps": {
          "alert": {
            "title": "Test iOS",
            "body": "Test notification từ curl"
          },
          "sound": "default",
          "badge": 1
        }
      }
    },
    "priority": "high"
  }'
```

## 🔍 Debug: Kiểm tra console logs

Khi gửi notification, kiểm tra Xcode console:

### Nếu nhận được (foreground):
```
📨 Foreground message: Test iOS
   Body: Test notification
   Data: {...}
```

### Nếu nhận được (background):
```
📨 Background message: Test iOS
```

### Nếu KHÔNG nhận được:
- Không có log gì → Notification không đến device
- Kiểm tra:
  1. Token có đúng không?
  2. APNs key đã upload vào Firebase?
  3. Bundle ID có khớp không?
  4. Device có bật notification không?

## ⚙️ Kiểm tra cài đặt iOS

### 1. Notification Settings
1. Mở **Settings** trên iPhone
2. **Notifications**
3. Tìm app **PAMELA CRUISE**
4. Kiểm tra:
   - ✅ Allow Notifications: ON
   - ✅ Lock Screen: ON
   - ✅ Notification Center: ON
   - ✅ Banners: ON
   - ✅ Sounds: ON
   - ✅ Badges: ON

### 2. Do Not Disturb / Focus
1. Kiểm tra **Do Not Disturb** đã TẮT
2. Kiểm tra **Focus** mode đã TẮT

### 3. Network
1. Kiểm tra iPhone có kết nối internet
2. Thử cả WiFi và 4G/5G

## 🎯 Test từng bước

### Test 1: Local Notification (Không cần FCM)
1. Vào Settings trong app
2. Nhấn "Test thông báo cục bộ"
3. Phải thấy notification

**Nếu KHÔNG thấy** → Vấn đề ở quyền notification của iOS
**Nếu THẤY** → Quyền notification OK, vấn đề ở FCM

### Test 2: FCM Token
1. Vào Settings
2. Nhấn "Xem FCM Token"
3. Phải thấy token dài

**Nếu token null** → Vấn đề ở FCM initialization
**Nếu có token** → FCM đã khởi tạo OK

### Test 3: Firebase Console Test Message
1. Copy FCM token
2. Gửi test message từ Firebase Console
3. Phải nhận được notification

**Nếu KHÔNG nhận** → Vấn đề ở APNs key hoặc Firebase config

## 🔧 Troubleshooting

### Vấn đề 1: Token có nhưng không nhận notification

**Nguyên nhân**: APNs key không đúng hoặc chưa upload

**Giải pháp**:
1. Kiểm tra Firebase Console → Cloud Messaging
2. Xem có APNs Authentication Key không
3. Key ID và Team ID có đúng không
4. Thử xóa và upload lại APNs key

### Vấn đề 2: Chỉ nhận được khi app foreground

**Nguyên nhân**: Thiếu `apns` payload

**Giải pháp**: Thêm `apns` config khi gửi notification (xem Cách 3)

### Vấn đề 3: Notification không có âm thanh

**Nguyên nhân**: Thiếu `sound` trong payload

**Giải pháp**: Thêm `"sound": "default"` trong apns payload

### Vấn đề 4: Entitlements error

**Nguyên nhân**: File entitlements bị sửa trong build

**Giải pháp**: Đã fix bằng script `fix_ios_entitlements_error.sh`

## 📋 Checklist cuối cùng

- [ ] FCM token hiển thị trong Settings
- [ ] Local notification hoạt động (test trong Settings)
- [ ] Notification settings trên iPhone đã bật
- [ ] Do Not Disturb đã tắt
- [ ] APNs key đã upload vào Firebase Console
- [ ] Bundle ID khớp: vn.coquan.test
- [ ] Đã gửi test message từ Firebase Console
- [ ] Đã kiểm tra console logs trong Xcode

## 🎯 Kết quả mong đợi

Sau khi làm đúng các bước:
- ✅ Gửi test message từ Firebase Console
- ✅ Notification hiển thị trên iPhone (cả foreground và background)
- ✅ Có âm thanh thông báo
- ✅ Nhấn vào notification → mở app

---

**Nếu vẫn không được**: Cung cấp thông tin sau để debug:
1. Console logs khi chạy app (copy toàn bộ)
2. FCM token (để test)
3. Screenshot notification settings trên iPhone
4. App đang ở foreground hay background khi test?
5. Có thấy log gì trong Xcode console khi gửi notification không?
