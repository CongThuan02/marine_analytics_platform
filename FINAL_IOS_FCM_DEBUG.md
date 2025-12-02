# 🔍 Debug cuối cùng - iOS không nhận FCM

## ❌ Vấn đề
Đã có FCM token nhưng không nhận được notification từ Firebase Console

## 🎯 Checklist quan trọng

### 1. Kiểm tra Notification Settings trên iPhone

**Bước 1**: Mở Settings trên iPhone
**Bước 2**: Notifications
**Bước 3**: Tìm app "PAMELA CRUISE" (hoặc tên app)
**Bước 4**: Kiểm tra:

```
✅ Allow Notifications: PHẢI BẬT (màu xanh)
✅ Lock Screen: PHẢI BẬT
✅ Notification Center: PHẢI BẬT  
✅ Banners: PHẢI BẬT
✅ Sounds: PHẢI BẬT
✅ Badges: PHẢI BẬT
✅ Show Previews: Always hoặc When Unlocked
```

**Nếu tất cả đều TẮT** → Đây là vấn đề!
- App chưa xin quyền notification
- Hoặc user đã từ chối

**Giải pháp**:
1. Xóa app khỏi iPhone
2. Cài lại: `flutter run`
3. Khi được hỏi quyền notification → Nhấn **"Allow"**

### 2. Kiểm tra Do Not Disturb / Focus

**Bước 1**: Vuốt xuống từ góc trên bên phải
**Bước 2**: Kiểm tra:
- 🌙 Do Not Disturb: PHẢI TẮT
- 🎯 Focus: PHẢI TẮT

**Nếu BẬT** → Notification sẽ bị chặn!

### 3. Kiểm tra app state khi test

**Quan trọng**: iOS xử lý notification khác nhau tùy app state:

#### App đang FOREGROUND (đang mở):
- Notification có thể KHÔNG hiển thị banner
- Nhưng app vẫn nhận được (xem console log)
- Cần code để hiển thị trong app

#### App đang BACKGROUND (minimize):
- Notification PHẢI hiển thị
- Có âm thanh
- Hiển thị trong Notification Center

#### App đã CLOSED (force quit):
- Notification PHẢI hiển thị
- Có âm thanh
- Nhấn vào → mở app

**Test đúng cách**:
1. Mở app
2. Nhấn Home button (minimize app)
3. Gửi notification từ Firebase Console
4. Phải thấy notification

### 4. Kiểm tra APNs Key trong Firebase

**Bước 1**: Firebase Console → ⚙️ Settings → Project settings
**Bước 2**: Tab "Cloud Messaging"
**Bước 3**: Scroll xuống "Apple app configuration"
**Bước 4**: Tìm app: vn.coquan.test

**Phải thấy**:
```
APNs Authentication Key
Key ID: LFX7Q8LB8V
Team ID: V2L86238CN
```

**Nếu KHÔNG thấy** → Đây là vấn đề!
- APNs key chưa upload
- Hoặc upload sai

### 5. Kiểm tra APNs Environment

File `ios/Runner/Runner.entitlements` hiện tại:
```xml
<key>aps-environment</key>
<string>development</string>
```

**Vấn đề**: 
- `development` chỉ hoạt động với debug build
- Nếu build release → cần `production`

**Giải pháp**:
```bash
# Thử đổi sang production
./fix_ios_apns_environment.sh
```

### 6. Test Local Notification trước

**Mục đích**: Xác định vấn đề ở đâu

**Bước 1**: Mở app
**Bước 2**: Settings → "Test thông báo cục bộ"
**Bước 3**: Nhấn nút test

**Nếu NHẬN ĐƯỢC local notification**:
- ✅ Quyền notification OK
- ✅ iOS settings OK
- → Vấn đề ở FCM/APNs

**Nếu KHÔNG nhận được local notification**:
- ❌ Quyền notification bị từ chối
- → Xóa app và cài lại

## 🛠️ Giải pháp từng bước

### Giải pháp 1: Reset quyền notification

```bash
# Xóa app
# Trên iPhone: Long press app → Remove App → Delete App

# Cài lại
flutter clean
flutter run

# Khi được hỏi quyền → Nhấn "Allow"
```

### Giải pháp 2: Đổi APNs environment

```bash
# Đổi sang production
./fix_ios_apns_environment.sh

# Hoặc thủ công:
# Sửa ios/Runner/Runner.entitlements
# Đổi "development" thành "production"

flutter clean
cd ios && pod install && cd ..
flutter run --release
```

### Giải pháp 3: Kiểm tra Firebase APNs key

1. Vào Firebase Console
2. Project settings → Cloud Messaging
3. Xem có APNs key không
4. Nếu không có → Upload APNs key mới

**Cách tạo APNs key**:
```
1. https://developer.apple.com/account/resources/authkeys/list
2. Create key (+)
3. Tên: Firebase FCM
4. Check: Apple Push Notifications service (APNs)
5. Download file .p8
6. Upload vào Firebase với Key ID và Team ID
```

### Giải pháp 4: Test với app ở background

```bash
# Chạy app
flutter run

# Trên iPhone:
1. Mở app
2. Nhấn Home button (minimize)
3. Gửi test message từ Firebase Console
4. Phải thấy notification
```

## 📊 Debug với Xcode Console

### Bước 1: Kết nối iPhone và xem logs

```bash
# Chạy app từ Xcode để xem logs
open ios/Runner.xcworkspace

# Hoặc xem device logs
# Xcode → Window → Devices and Simulators
# Chọn iPhone → Open Console
```

### Bước 2: Gửi notification và xem logs

**Logs mong đợi khi nhận notification**:

#### App foreground:
```
📨 Foreground message: Test iOS
   Body: Test notification
   Data: {...}
```

#### App background:
```
📨 Background message: Test iOS
```

**Nếu KHÔNG có log gì**:
- Notification không đến device
- Vấn đề ở APNs key hoặc token

**Nếu có log nhưng không hiển thị**:
- Vấn đề ở notification settings
- Hoặc Do Not Disturb đang bật

## 🎯 Test Case đầy đủ

### Test 1: Local Notification
```
Settings → Test thông báo cục bộ
Kết quả mong đợi: Nhận được notification
```

### Test 2: FCM Token
```
Settings → Xem FCM Token
Kết quả mong đợi: Hiển thị token dài
```

### Test 3: Firebase Console (App Background)
```
1. Minimize app
2. Firebase Console → Send test message
3. Paste token → Test
Kết quả mong đợi: Nhận được notification
```

### Test 4: Firebase Console (App Closed)
```
1. Force quit app (vuốt lên từ app switcher)
2. Firebase Console → Send test message
3. Paste token → Test
Kết quả mong đợi: Nhận được notification
```

## 📋 Checklist cuối cùng

Trước khi test, đảm bảo:
- [ ] App đang chạy trên real iPhone (không phải simulator)
- [ ] Notification settings đã BẬT (Allow Notifications: ON)
- [ ] Do Not Disturb đã TẮT
- [ ] Focus mode đã TẮT
- [ ] iPhone có internet (WiFi hoặc 4G)
- [ ] APNs key đã upload vào Firebase Console
- [ ] Bundle ID khớp: vn.coquan.test
- [ ] FCM token đã lấy từ Settings
- [ ] Token đã paste đúng vào Firebase Console
- [ ] App đang ở BACKGROUND khi test (không phải foreground)

## 🔧 Nếu vẫn không được

Thử các bước sau theo thứ tự:

1. **Xóa app và cài lại** → Chấp nhận quyền notification
2. **Test local notification** → Xác nhận quyền OK
3. **Đổi APNs environment sang production** → Rebuild
4. **Kiểm tra APNs key trong Firebase** → Upload lại nếu cần
5. **Test với app ở background** → Không phải foreground
6. **Xem Xcode console logs** → Tìm lỗi cụ thể

---

**Câu hỏi debug**:
1. Local notification có hoạt động không? (Test trong Settings)
2. App state khi test? (Foreground/Background/Closed)
3. Notification settings trên iPhone đã bật chưa?
4. Do Not Disturb có đang bật không?
5. Có thấy log gì trong Xcode console không?
