# 🚀 Hướng dẫn test FCM trên iOS - Nhanh gọn

## ✅ Đã chuẩn bị
- Xcode: Push Notifications capability ✓
- Xcode: Background Modes ✓  
- Firebase: APNs key uploaded ✓
- Bundle ID: vn.coquan.test ✓

## 📱 Cách test - 3 bước đơn giản

### Bước 1: Clean và build
```bash
./test_ios_fcm_now.sh
```

Hoặc thủ công:
```bash
flutter clean
cd ios && rm -rf Pods .symlinks Podfile.lock && pod install && cd ..
flutter pub get
```

### Bước 2: Chạy trên real device
```bash
flutter run
```

**QUAN TRỌNG**: 
- ❌ KHÔNG test trên Simulator (không hỗ trợ FCM)
- ✅ Phải test trên iPhone/iPad thật

### Bước 3: Lấy FCM token

**Cách 1: Từ Settings (MỚI)**
1. Mở app
2. Vào tab **Settings** (⚙️)
3. Scroll xuống phần "Kiểm tra & Debug"
4. Nhấn **"Xem FCM Token"**
5. Copy token

**Cách 2: Từ Logo**
1. Mở app
2. Nhấn logo 3 lần
3. Copy token

## 🔔 Test gửi notification

### Từ Firebase Console:
1. Vào: https://console.firebase.google.com
2. Chọn project: **marine-analytics-platform**
3. **Messaging** → **Send your first message**
4. Nhập:
   - Title: "Test iOS"
   - Body: "Test notification từ Firebase"
5. Click **Next**
6. Chọn **Send test message**
7. Paste FCM token
8. Click **Test**

### Kết quả mong đợi:
- ✅ Notification hiển thị trên iPhone
- ✅ Có âm thanh thông báo
- ✅ Nhấn vào notification → mở app

## 📊 Console logs mong đợi

Khi chạy app, phải thấy:
```
✅ FCM initialized successfully
✅ FCM: User granted permission
📱 FCM Token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
Firebase registration token: eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9...
✅ FCM token saved to database
```

## ❌ Troubleshooting nhanh

### Token null?
1. Đảm bảo chạy trên **real device**
2. Chấp nhận quyền notification
3. Đợi 5-10 giây rồi thử lại

### Không nhận notification?
1. Kiểm tra APNs key đã upload vào Firebase ✓
2. Kiểm tra Bundle ID khớp: `vn.coquan.test` ✓
3. Kiểm tra đã chấp nhận quyền notification
4. Thử gửi lại từ Firebase Console

### Build error?
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter run
```

## 🎯 Checklist cuối

- [ ] Đã clean project
- [ ] Đã chạy trên real device (không phải simulator)
- [ ] Đã chấp nhận quyền notification
- [ ] FCM token hiển thị trong Settings hoặc khi nhấn logo 3 lần
- [ ] Đã copy token
- [ ] Đã gửi test message từ Firebase Console
- [ ] Nhận được notification trên iPhone

---

**Tóm tắt**: Bây giờ có 2 cách lấy FCM token:
1. Vào Settings → "Xem FCM Token" (dễ nhất)
2. Nhấn logo 3 lần (cách cũ)

Sau khi có token, gửi test message từ Firebase Console để kiểm tra.
