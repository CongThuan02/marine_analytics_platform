# Feature: Local Notification khi vượt giới hạn chất thải

## Tổng quan
Khi người dùng thêm lịch sử chất thải và tổng lượng chất thải trong tháng vượt quá giới hạn đã đặt, hệ thống sẽ tự động hiển thị local notification cảnh báo.

## Tính năng

### ✅ Tự động kiểm tra giới hạn
- Sau khi thêm waste entry, tự động tính tổng lượng chất thải trong tháng
- So sánh với giới hạn đã đặt cho area và waste type
- Hiển thị notification nếu vượt quá

### ✅ Notification chi tiết
- Tiêu đề: "⚠️ Waste Limit Exceeded!"
- Nội dung:
  - Tên area và waste type
  - Tổng lượng hiện tại và phần trăm
  - Giới hạn đã đặt
  - Lượng vượt quá

### ✅ Hoạt động offline
- Local notification không cần internet
- Hiển thị ngay lập tức trên device
- Không phụ thuộc vào FCM server

## Các file đã tạo/cập nhật

### 1. Service mới: `LocalNotificationService`
**File:** `lib/core/services/local_notification_service.dart`

**Chức năng:**
- Initialize local notifications
- Tạo notification channel
- Kiểm tra waste limit
- Hiển thị notification khi vượt giới hạn

**Methods:**
```dart
// Khởi tạo
await LocalNotificationService().initialize();

// Kiểm tra và thông báo
await LocalNotificationService().checkAndNotifyWasteLimit(
  areaId: 'area-id',
  wasteTypeId: 'waste-type-id',
  quantity: 100.0,
  areaName: 'Area A',
  wasteTypeName: 'Plastic',
);

// Hiển thị notification đơn giản
await LocalNotificationService().showNotification(
  title: 'Title',
  body: 'Body',
);
```

### 2. Cập nhật: `WasteEntryRepository`
**File:** `lib/data/repositories/waste_entry_repository.dart`

**Thay đổi:**
- Thêm method `_checkWasteLimitAndNotify()`
- Gọi method này sau khi insert waste entry thành công
- Tự động kiểm tra và hiển thị notification

### 3. Cập nhật: `main.dart`
**File:** `lib/main.dart`

**Thay đổi:**
- Import `LocalNotificationService`
- Khởi tạo service trong `main()` function
- Initialize trước khi run app

## Cách hoạt động

### Flow khi thêm waste entry:

```
1. User điền form và submit
   ↓
2. WasteEntryRepository.createWasteEntry()
   ↓
3. Insert vào database
   ↓
4. _checkWasteLimitAndNotify()
   ↓
5. Query tổng lượng chất thải trong tháng
   ↓
6. Query giới hạn đã đặt
   ↓
7. So sánh: totalQuantity > limitValue?
   ↓
8. Nếu YES → Show local notification
   ↓
9. Return success message
```

### Logic kiểm tra giới hạn:

```dart
// 1. Lấy tổng lượng trong tháng hiện tại
SELECT SUM(quantity) FROM waste_entries
WHERE area_id = ? 
  AND waste_type_id = ?
  AND date >= first_day_of_month
  AND date <= last_day_of_month

// 2. Lấy giới hạn
SELECT limit_value FROM waste_limits
WHERE area_id = ?
  AND waste_type_id = ?

// 3. So sánh
if (totalQuantity > limitValue) {
  showNotification();
}
```

## Ví dụ notification

### Notification hiển thị:
```
┌─────────────────────────────────┐
│ ⚠️ Waste Limit Exceeded!        │
│                                 │
│ Kitchen - Plastic               │
│ Total: 125.5 (125.5%)          │
│ Limit: 100.0                   │
│ Exceeded by: 25.5              │
└─────────────────────────────────┘
```

### Android:
- Icon: App icon
- Color: Red (#FF5252)
- Sound: Default
- Vibration: Yes
- Priority: High

### iOS:
- Alert: Yes
- Badge: Yes
- Sound: Default

## Testing

### Test 1: Thêm waste entry vượt giới hạn
```bash
# 1. Tạo waste limit
Area: Kitchen
Waste Type: Plastic
Limit: 100 kg
Period: monthly

# 2. Thêm waste entries
Entry 1: 60 kg → No notification (60 < 100)
Entry 2: 50 kg → Show notification (110 > 100)
```

### Test 2: Thêm waste entry trong giới hạn
```bash
# 1. Tạo waste limit
Area: Deck
Waste Type: Food
Limit: 200 kg

# 2. Thêm waste entry
Entry: 50 kg → No notification (50 < 200)
```

### Test 3: Không có giới hạn
```bash
# 1. Không tạo waste limit

# 2. Thêm waste entry
Entry: 1000 kg → No notification (no limit set)
```

## Cấu hình

### Android Manifest
Đã có sẵn trong `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
```

### iOS Info.plist
Đã có sẵn trong `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## Troubleshooting

### Notification không hiển thị

#### 1. Kiểm tra quyền notification
**Android:**
- Settings → Apps → Your App → Notifications → Allow

**iOS:**
- Settings → Your App → Notifications → Allow Notifications

#### 2. Kiểm tra initialization
```dart
// Xem console log
✅ Local notifications initialized
```

#### 3. Kiểm tra waste limit đã tạo chưa
```sql
SELECT * FROM waste_limits 
WHERE area_id = ? AND waste_type_id = ?;
```

#### 4. Kiểm tra tổng lượng
```sql
SELECT SUM(quantity) FROM waste_entries
WHERE area_id = ? 
  AND waste_type_id = ?
  AND date >= ?
  AND date <= ?;
```

### Notification hiển thị sai thông tin

#### Kiểm tra area và waste type names
```dart
// Xem console log
⚠️ Waste limit exceeded! Total: 125.5, Limit: 100.0
```

### Build error

```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run
```

## Tùy chỉnh

### Thay đổi notification channel
```dart
// lib/core/services/local_notification_service.dart
const androidChannel = AndroidNotificationChannel(
  'waste_limit_alerts',  // ID
  'Waste Limit Alerts',  // Name
  description: 'Notifications when waste limit is exceeded',
  importance: Importance.high,
  playSound: true,
  enableVibration: true,
);
```

### Thay đổi notification style
```dart
const androidDetails = AndroidNotificationDetails(
  'waste_limit_alerts',
  'Waste Limit Alerts',
  importance: Importance.high,
  priority: Priority.high,
  playSound: true,
  enableVibration: true,
  color: Color(0xFFFF5252), // Đổi màu
);
```

### Thay đổi notification content
```dart
final title = '⚠️ Waste Limit Exceeded!';
final body = '$areaName - $wasteTypeName\n'
    'Total: ${totalQuantity.toStringAsFixed(1)} (${percentage}%)\n'
    'Limit: ${limitValue.toStringAsFixed(1)}\n'
    'Exceeded by: ${exceededBy.toStringAsFixed(1)}';
```

## Tính năng mở rộng

### 1. Navigate khi tap notification
```dart
void _onNotificationTapped(NotificationResponse response) {
  // Parse payload
  final parts = response.payload?.split(':');
  if (parts != null && parts[0] == 'waste_limit_exceeded') {
    // Navigate to alerts page
    appRouter.go('/alerts');
  }
}
```

### 2. Scheduled notifications
```dart
// Nhắc nhở định kỳ
await _notifications.zonedSchedule(
  id,
  'Weekly Waste Report',
  'Check your waste statistics',
  scheduledDate,
  notificationDetails,
  uiLocalNotificationDateInterpretation: ...,
  matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
);
```

### 3. Notification với actions
```dart
const androidDetails = AndroidNotificationDetails(
  'waste_limit_alerts',
  'Waste Limit Alerts',
  actions: [
    AndroidNotificationAction('view', 'View Details'),
    AndroidNotificationAction('dismiss', 'Dismiss'),
  ],
);
```

### 4. Progress notification
```dart
// Hiển thị progress bar
const androidDetails = AndroidNotificationDetails(
  'waste_limit_alerts',
  'Waste Limit Alerts',
  showProgress: true,
  maxProgress: 100,
  progress: 75, // 75%
);
```

## Kết luận

Feature này giúp:
- ✅ Cảnh báo ngay lập tức khi vượt giới hạn
- ✅ Không cần internet (local notification)
- ✅ Tự động kiểm tra sau mỗi lần thêm waste entry
- ✅ Hiển thị thông tin chi tiết và rõ ràng
- ✅ Hoạt động trên cả Android và iOS

User experience được cải thiện đáng kể với notification tức thì thay vì phải vào app để kiểm tra.
