# Debug Local Notification - Không cần FCM/Google

## Xác nhận: Local Notification hoạt động độc lập

✅ **Local notification KHÔNG cần:**
- Firebase/FCM
- Google Services
- Internet connection
- Server backend

✅ **Local notification CHỈ cần:**
- `flutter_local_notifications` package
- Quyền notification trên device
- App đang chạy (foreground hoặc background)

## Checklist Debug

### 1. Kiểm tra quyền notification

#### Android:
```bash
# Vào Settings → Apps → Your App → Notifications
# Đảm bảo "Allow notifications" được BẬT
```

#### iOS:
```bash
# Vào Settings → Your App → Notifications
# Đảm bảo "Allow Notifications" được BẬT
```

### 2. Kiểm tra initialization

Xem console log khi app start:
```
✅ Local notifications initialized
```

Nếu KHÔNG thấy log này → Service chưa được khởi tạo

### 3. Test đơn giản

Thêm button test vào Settings page:

```dart
ElevatedButton(
  onPressed: () async {
    await LocalNotificationService().showNotification(
      title: 'Test',
      body: 'This is a test notification',
    );
  },
  child: Text('Test Notification'),
)
```

### 4. Kiểm tra console logs

Khi thêm waste entry, phải thấy:
```
✅ Within limit. Total: 50.0, Limit: 100.0
// HOẶC
⚠️ Waste limit exceeded! Total: 125.5, Limit: 100.0
📬 Local notification shown: ⚠️ Waste Limit Exceeded!
```

## Các vấn đề thường gặp

### Vấn đề 1: Notification không hiển thị

**Nguyên nhân:** Quyền notification chưa được cấp

**Giải pháp:**
1. Xóa app khỏi device
2. Cài lại: `flutter run`
3. Khi được hỏi quyền notification → Chấp nhận

### Vấn đề 2: Không thấy log initialization

**Nguyên nhân:** Service chưa được khởi tạo trong main.dart

**Kiểm tra:** `lib/main.dart` phải có:
```dart
await LocalNotificationService().initialize();
```

### Vấn đề 3: Notification chỉ hiển thị khi app mở

**Nguyên nhân:** Đây là behavior bình thường của local notification

**Lưu ý:** 
- Local notification hiển thị ngay khi được gọi
- Nếu app đang foreground, notification vẫn hiển thị trong notification tray
- Nếu app đang background, notification hiển thị bình thường

### Vấn đề 4: Không có waste limit nào được set

**Nguyên nhân:** Chưa tạo waste limit

**Giải pháp:**
1. Vào Waste Limits page
2. Tạo limit mới:
   - Area: Kitchen
   - Waste Type: Plastic
   - Limit: 100
   - Period: monthly
3. Thêm waste entry vượt quá 100

## Test Script

### Test 1: Simple notification (không cần waste limit)

```dart
// Thêm vào bất kỳ page nào
FloatingActionButton(
  onPressed: () async {
    print('🔔 Testing notification...');
    await LocalNotificationService().showNotification(
      title: '✅ Test Success',
      body: 'If you see this, local notifications work!',
    );
    print('✅ Notification sent');
  },
  child: Icon(Icons.notifications),
)
```

### Test 2: Waste limit notification

```dart
FloatingActionButton(
  onPressed: () async {
    print('🔔 Testing waste limit notification...');
    await LocalNotificationService().showWasteLimitExceededNotification(
      areaName: 'Test Area',
      wasteTypeName: 'Test Waste',
      totalQuantity: 150.0,
      limitValue: 100.0,
      exceededBy: 50.0,
      percentage: '150.0',
      period: 'monthly',
    );
    print('✅ Waste limit notification sent');
  },
  child: Icon(Icons.warning),
)
```

## Quick Fix

### Thêm test button vào Settings page:

```dart
// lib/presentation/views/setting.dart

// Thêm vào body
ListTile(
  leading: Icon(Icons.notifications_active),
  title: Text('Test Local Notification'),
  subtitle: Text('Tap to test notification'),
  onTap: () async {
    await LocalNotificationService().showNotification(
      title: '✅ Test Notification',
      body: 'Local notification is working!',
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Notification sent! Check notification tray')),
    );
  },
),
```

## Kiểm tra từng bước

### Bước 1: Verify package installed
```bash
flutter pub get
# Kiểm tra pubspec.yaml có:
# flutter_local_notifications: ^latest_version
```

### Bước 2: Verify initialization
```bash
flutter run
# Xem console, phải thấy:
# ✅ Local notifications initialized
```

### Bước 3: Test simple notification
```dart
// Thêm button test như trên
// Nhấn button
// Kiểm tra notification tray
```

### Bước 4: Test waste limit flow
```bash
# 1. Tạo waste limit: Area A, Waste Type X, Limit 100
# 2. Thêm waste entry: Area A, Waste Type X, Quantity 60
#    → Không có notification (60 < 100)
# 3. Thêm waste entry: Area A, Waste Type X, Quantity 50
#    → CÓ notification (110 > 100)
```

## Console Logs để debug

### Logs thành công:
```
✅ Local notifications initialized
⚠️ Waste limit exceeded! Total: 125.5, Limit: 100.0
📬 Local notification shown: ⚠️ Waste Limit Exceeded!
```

### Logs khi không có limit:
```
ℹ️ No limit set for this area and waste type
```

### Logs khi trong giới hạn:
```
✅ Within limit. Total: 50.0, Limit: 100.0
```

### Logs lỗi:
```
❌ Error checking waste limit: [error message]
⚠️ Error checking waste limit: [error message]
```

## Platform-specific notes

### Android:
- Notification channel được tạo tự động
- Icon: `@mipmap/ic_launcher`
- Color: Red (#FF5252)
- Importance: High
- Sound & Vibration: Enabled

### iOS:
- Cần quyền notification (được hỏi lần đầu)
- Alert, Badge, Sound: Enabled
- Notification hiển thị trong Notification Center

## Nếu vẫn không được

### 1. Enable verbose logging

Thêm vào `LocalNotificationService`:
```dart
Future<void> showNotification(...) async {
  print('🔔 [DEBUG] Showing notification...');
  print('   Title: $title');
  print('   Body: $body');
  
  await _notifications.show(...);
  
  print('✅ [DEBUG] Notification shown');
}
```

### 2. Check notification settings

```dart
// Android
final androidImpl = _notifications.resolvePlatformSpecificImplementation<
    AndroidFlutterLocalNotificationsPlugin>();
final granted = await androidImpl?.areNotificationsEnabled();
print('Notifications enabled: $granted');
```

### 3. Restart app completely

```bash
# Kill app
flutter clean
flutter pub get
flutter run

# Chấp nhận quyền notification khi được hỏi
```

## Kết luận

Local notification **KHÔNG CẦN** FCM/Google. Nó hoạt động hoàn toàn độc lập trên device.

Nếu vẫn không thấy notification:
1. Kiểm tra quyền notification trong Settings
2. Xem console logs
3. Test với simple notification trước
4. Đảm bảo waste limit đã được tạo
5. Đảm bảo tổng lượng vượt quá limit
