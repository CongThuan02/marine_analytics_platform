# Quick Test: Local Notification (Không cần FCM/Google)

## ✅ Xác nhận: Hoàn toàn độc lập

Local notification **KHÔNG CẦN**:
- ❌ Firebase/FCM
- ❌ Google Services  
- ❌ Internet
- ❌ Server backend

Local notification **CHỈ CẦN**:
- ✅ flutter_local_notifications package
- ✅ Quyền notification trên device
- ✅ App đang chạy

## 🚀 Test ngay trong 30 giây

### Bước 1: Chạy app
```bash
flutter run
```

### Bước 2: Vào Settings
1. Mở app
2. Tap vào tab **Settings** (icon ⚙️)

### Bước 3: Test notification
Trong Settings page, bạn sẽ thấy section **"Testing & Debug"** với 2 buttons:

#### Button 1: "Test Local Notification"
- Tap vào button này
- Notification sẽ hiển thị ngay lập tức
- Kiểm tra notification tray

#### Button 2: "Test Waste Limit Alert"  
- Tap vào button này
- Notification cảnh báo vượt giới hạn sẽ hiển thị
- Kiểm tra notification tray

### Bước 4: Kiểm tra notification tray
- **Android**: Vuốt xuống từ trên cùng màn hình
- **iOS**: Vuốt xuống từ trên cùng màn hình

## 📱 Kết quả mong đợi

### Test 1: Simple notification
```
┌─────────────────────────────┐
│ ✅ Test Success!            │
│                             │
│ Local notification is       │
│ working! No FCM/Google      │
│ needed.                     │
└─────────────────────────────┘
```

### Test 2: Waste limit alert
```
┌─────────────────────────────┐
│ ⚠️ Waste Limit Exceeded!    │
│                             │
│ Test Kitchen - Plastic      │
│ Waste                       │
│ Total: 125.5 (125.5%)      │
│ Limit: 100.0               │
│ Exceeded by: 25.5          │
└─────────────────────────────┘
```

## 🐛 Nếu không thấy notification

### 1. Kiểm tra quyền notification

#### Android:
```
Settings → Apps → Your App → Notifications
→ Đảm bảo "Allow notifications" BẬT
```

#### iOS:
```
Settings → Your App → Notifications  
→ Đảm bảo "Allow Notifications" BẬT
```

### 2. Xem console logs

Khi tap test button, phải thấy:
```
🔔 Testing local notification...
✅ Notification sent
```

Nếu thấy lỗi:
```
❌ Error: [error message]
```

### 3. Restart app và cấp quyền lại

```bash
# Xóa app khỏi device
# Cài lại
flutter run

# Khi được hỏi quyền notification → Chấp nhận
```

## 🎯 Test với waste entry thực tế

### Bước 1: Tạo waste limit
1. Vào **Waste Limits** page
2. Tap **+** để tạo mới
3. Điền:
   - Area: Kitchen
   - Waste Type: Plastic
   - Limit: 100
   - Period: monthly
4. Save

### Bước 2: Thêm waste entry (trong giới hạn)
1. Vào **History** page
2. Tap **+** để thêm mới
3. Điền:
   - Area: Kitchen
   - Waste Type: Plastic
   - Quantity: 60
4. Save
5. **Kết quả**: Không có notification (60 < 100)

### Bước 3: Thêm waste entry (vượt giới hạn)
1. Vào **History** page
2. Tap **+** để thêm mới
3. Điền:
   - Area: Kitchen
   - Waste Type: Plastic
   - Quantity: 50
4. Save
5. **Kết quả**: CÓ notification! (60 + 50 = 110 > 100)

## 📊 Console logs để debug

### Logs thành công:
```
✅ Local notifications initialized
🔔 Testing local notification...
✅ Notification sent
```

### Logs khi thêm waste entry:
```
⚠️ Waste limit exceeded! Total: 110.0, Limit: 100.0
📬 Local notification shown: ⚠️ Waste Limit Exceeded!
```

### Logs khi trong giới hạn:
```
✅ Within limit. Total: 60.0, Limit: 100.0
```

## 💡 Tips

### Tip 1: Test trên real device
- Local notification hoạt động tốt nhất trên real device
- Simulator/Emulator có thể có hạn chế

### Tip 2: Kiểm tra Do Not Disturb
- Đảm bảo device không ở chế độ Do Not Disturb
- Đảm bảo volume không bị tắt

### Tip 3: Xem notification history
- **Android**: Settings → Notifications → Notification history
- **iOS**: Notification Center

## ✅ Checklist

- [ ] App đã chạy thành công
- [ ] Vào Settings page
- [ ] Thấy section "Testing & Debug"
- [ ] Tap "Test Local Notification"
- [ ] Thấy snackbar "Notification sent"
- [ ] Kiểm tra notification tray
- [ ] Thấy notification "Test Success"
- [ ] Tap "Test Waste Limit Alert"
- [ ] Thấy notification "Waste Limit Exceeded"

## 🎉 Kết luận

Nếu bạn thấy notification sau khi tap test button:
- ✅ Local notification hoạt động hoàn hảo
- ✅ Không cần FCM/Google
- ✅ Hoạt động offline
- ✅ Sẵn sàng sử dụng trong production

Nếu không thấy notification:
1. Kiểm tra quyền notification
2. Xem console logs
3. Restart app
4. Đọc file DEBUG_LOCAL_NOTIFICATION.md
