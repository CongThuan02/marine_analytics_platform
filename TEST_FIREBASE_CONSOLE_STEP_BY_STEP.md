# 📲 Test FCM từ Firebase Console - Từng bước chi tiết

## 🎯 Mục tiêu
Test gửi notification trực tiếp từ Firebase Console đến iPhone để xác nhận FCM hoạt động.

## 📋 Chuẩn bị

### Bước 1: Lấy FCM Token
1. Mở app trên iPhone (phải là real device, không phải simulator)
2. Vào tab **Settings** (⚙️)
3. Scroll xuống phần "Kiểm tra & Debug"
4. Nhấn **"Xem FCM Token"**
5. Nhấn nút **"Sao chép"**
6. Token đã được copy vào clipboard

**Token sẽ có dạng:**
```
eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCJ9.eyJhcHBJZCI6IjE6MzExOTE1NDE5MTk4Omlvczp...
```

### Bước 2: Kiểm tra app đã chấp nhận quyền notification
1. Mở **Settings** trên iPhone
2. **Notifications**
3. Tìm app **PAMELA CRUISE** (hoặc tên app của bạn)
4. Đảm bảo:
   - ✅ **Allow Notifications**: ON
   - ✅ **Lock Screen**: ON
   - ✅ **Notification Center**: ON
   - ✅ **Banners**: ON
   - ✅ **Sounds**: ON

## 🚀 Test từ Firebase Console

### Cách 1: Send Test Message (Khuyến nghị - Nhanh nhất)

#### Bước 1: Vào Firebase Console
1. Mở trình duyệt
2. Vào: https://console.firebase.google.com
3. Đăng nhập
4. Chọn project: **marine-analytics-platform**

#### Bước 2: Vào Cloud Messaging
1. Sidebar bên trái → **Messaging** (hoặc **Engage** → **Messaging**)
2. Click nút **"Send your first message"** (hoặc **"New campaign"**)

#### Bước 3: Gửi Test Message
1. Trong màn hình "Create notification":
   - **Notification title**: `Test iOS`
   - **Notification text**: `Test notification từ Firebase`
   - (Bỏ qua Notification image)

2. Ở góc trên bên phải, click **"Send test message"**

3. Trong popup "Add an FCM registration token":
   - Paste FCM token vừa copy
   - Click **"+"** để thêm token
   - Token sẽ xuất hiện trong danh sách

4. Click nút **"Test"**

#### Bước 4: Kiểm tra kết quả
- ✅ Notification phải hiển thị trên iPhone ngay lập tức
- ✅ Có âm thanh thông báo
- ✅ Hiển thị cả khi app đang foreground hoặc background
- ✅ Nhấn vào notification → mở app

### Cách 2: Send to All Users (Nếu muốn test campaign)

#### Bước 1-2: Giống Cách 1

#### Bước 3: Tạo Campaign
1. Điền notification:
   - **Notification title**: `Test iOS Campaign`
   - **Notification text**: `Test notification campaign`

2. Click **"Next"**

3. **Target** (Chọn đối tượng):
   - Chọn app: **myapp (vn.coquan.test)**
   - Hoặc chọn **"All users"**

4. Click **"Next"**

5. **Scheduling**:
   - Chọn **"Now"**

6. Click **"Next"**

7. **Additional options** (Quan trọng cho iOS):
   - Expand **"Custom data"** (nếu cần)
   - Expand **"Sound"**: Chọn **"default"**
   - Expand **"Badge"**: Nhập **"1"**

8. Click **"Review"**

9. Click **"Publish"**

#### Bước 4: Kiểm tra
- Notification sẽ được gửi trong vài giây
- Kiểm tra trên iPhone

## 🔍 Debug nếu không nhận được

### Kiểm tra 1: Console logs trong Xcode
1. Kết nối iPhone vào Mac
2. Mở Xcode
3. **Window** → **Devices and Simulators**
4. Chọn iPhone
5. Click **"Open Console"**
6. Gửi test message từ Firebase
7. Xem có log gì không

**Logs mong đợi khi nhận notification:**
```
📨 Foreground message: Test iOS
   Body: Test notification từ Firebase
   Data: {...}
```

Hoặc nếu app ở background:
```
📨 Background message: Test iOS
```

### Kiểm tra 2: Token có đúng không?
1. Copy token từ app
2. Paste vào notepad
3. Kiểm tra:
   - Token phải dài (khoảng 150-200 ký tự)
   - Không có khoảng trắng
   - Không bị cắt đứt

### Kiểm tra 3: APNs key trong Firebase
1. Firebase Console → ⚙️ **Settings** → **Project settings**
2. Tab **Cloud Messaging**
3. Scroll xuống **"Apple app configuration"**
4. Tìm app: **vn.coquan.test**
5. Kiểm tra có **"APNs Authentication Key"** không?
   - ✅ Nếu có: Hiển thị Key ID (VD: LFX7Q8LB8V)
   - ❌ Nếu không: Cần upload APNs key

### Kiểm tra 4: Do Not Disturb / Focus
1. Trên iPhone, vuốt xuống từ góc trên bên phải
2. Kiểm tra **Do Not Disturb** (biểu tượng mặt trăng) đã TẮT
3. Kiểm tra **Focus** mode đã TẮT

### Kiểm tra 5: Network
1. Kiểm tra iPhone có kết nối internet
2. Thử cả WiFi và 4G/5G
3. Tắt VPN nếu đang bật

## 📊 Kết quả mong đợi

### Khi gửi test message thành công:
1. Firebase Console hiển thị: **"Test message sent"**
2. iPhone nhận notification trong 1-2 giây
3. Notification hiển thị với:
   - Title: "Test iOS"
   - Body: "Test notification từ Firebase"
   - Icon: App icon
   - Sound: Âm thanh mặc định

### Khi app ở foreground:
- Notification vẫn hiển thị (banner ở trên cùng)
- Hoặc hiển thị trong app (tùy cấu hình)
- Console log: `📨 Foreground message: Test iOS`

### Khi app ở background/closed:
- Notification hiển thị trong Notification Center
- Nhấn vào → mở app
- Console log: `📨 Background message: Test iOS`

## ❌ Troubleshooting

### Lỗi: "Invalid registration token"
**Nguyên nhân**: Token không đúng hoặc đã hết hạn

**Giải pháp**:
1. Xóa app khỏi iPhone
2. Cài lại app
3. Lấy token mới
4. Thử lại

### Lỗi: "MismatchSenderId"
**Nguyên nhân**: Bundle ID không khớp với Firebase config

**Giải pháp**:
1. Kiểm tra Bundle ID trong Xcode: `vn.coquan.test`
2. Kiểm tra Bundle ID trong Firebase Console
3. Phải giống nhau

### Không có lỗi nhưng không nhận notification
**Nguyên nhân**: APNs key chưa upload hoặc không đúng

**Giải pháp**:
1. Kiểm tra APNs key trong Firebase Console
2. Nếu chưa có, tạo và upload APNs key mới
3. Xem hướng dẫn trong file: `check_firebase_apns.md`

### Token null trong app
**Nguyên nhân**: FCM chưa khởi tạo hoặc quyền notification bị từ chối

**Giải pháp**:
1. Kiểm tra console logs khi mở app
2. Phải thấy: `✅ FCM initialized successfully`
3. Nếu không thấy, xóa app và cài lại

## 🎯 Checklist cuối cùng

Trước khi test, đảm bảo:
- [ ] App đang chạy trên real iPhone (không phải simulator)
- [ ] Đã lấy FCM token từ Settings
- [ ] Token đã được copy chính xác
- [ ] Notification settings trên iPhone đã bật
- [ ] Do Not Disturb đã tắt
- [ ] iPhone có kết nối internet
- [ ] APNs key đã upload vào Firebase Console
- [ ] Bundle ID khớp: vn.coquan.test

## 📞 Nếu vẫn không được

Cung cấp thông tin sau:
1. **FCM Token**: (để tôi test)
2. **Console logs**: Copy toàn bộ logs khi mở app
3. **Firebase Console**: Screenshot khi gửi test message
4. **Notification Settings**: Screenshot settings trên iPhone
5. **APNs Key**: Có Key ID hiển thị trong Firebase không?
6. **App state**: App đang foreground hay background khi test?

---

**Lưu ý**: Nếu test từ Firebase Console thành công → FCM hoạt động OK → Vấn đề chỉ còn ở Edge Function (đã sửa rồi, cần deploy).
