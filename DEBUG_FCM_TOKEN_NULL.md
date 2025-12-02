# Debug: FCM Token Null/Not Ready Issue

## Vấn đề
Khi lấy FCM token bằng `FCMService().fcmToken`, nhận được `null` hoặc báo lỗi "FCM token chưa sẵn sàng".

## Nguyên nhân

### 1. Timing Issue - Token chưa được lấy
```dart
// ❌ SAI - Gọi ngay sau initialize()
await FCMService().initialize();
print(FCMService().fcmToken); // null - vì getToken() chưa hoàn thành
```

**Giải pháp**: `getToken()` là async và có thể mất 1-3 giây, đặc biệt lần đầu.

### 2. Quyền Notification chưa được cấp
```dart
final settings = await _messaging.requestPermission(...);
if (settings.authorizationStatus != AuthorizationStatus.authorized) {
  // User từ chối quyền → không có token
  return;
}
```

**Kiểm tra**: 
- iOS: Settings → App → Notifications → Bật ON
- Android: Settings → Apps → App → Notifications → Bật ON

### 3. Firebase/APNs chưa kết nối (iOS)
Trên iOS, FCM cần APNs certificate để hoạt động:
- APNs environment phải đúng (development/production)
- Push notification capability phải được bật
- GoogleService-Info.plist phải đúng

### 4. Network Issue
`getToken()` cần kết nối internet để lấy token từ Firebase server.

## Cách Debug

### Bước 1: Kiểm tra logs
```bash
# iOS
flutter run --verbose | grep -i "fcm\|apns\|token"

# Android  
flutter run --verbose | grep -i "fcm\|token"
```

Tìm các dòng:
- ✅ `FCM Token: fXXXXXXXXXXX...` → Thành công
- ❌ `FCM: User declined permission` → Không có quyền
- ❌ `Error getting FCM token` → Lỗi kết nối

### Bước 2: Test với await
```dart
// Đợi token sẵn sàng
final token = await FCMService().waitForToken();
if (token != null) {
  print('Token: $token');
} else {
  print('Không lấy được token');
}
```

### Bước 3: Kiểm tra quyền
```dart
final settings = await FirebaseMessaging.instance.getNotificationSettings();
print('Authorization: ${settings.authorizationStatus}');
// authorized = OK
// denied = User từ chối
// notDetermined = Chưa hỏi
```

## Giải pháp

### 1. Thêm method `waitForToken()` vào FCMService
```dart
/// Wait for FCM token to be ready (with timeout)
Future<String?> waitForToken({Duration timeout = const Duration(seconds: 10)}) async {
  if (_fcmToken != null) return _fcmToken;
  
  final completer = Completer<String?>();
  Timer? timer;
  
  // Listen for token
  final subscription = _messaging.onTokenRefresh.listen((token) {
    if (!completer.isCompleted) {
      completer.complete(token);
      timer?.cancel();
    }
  });
  
  // Set timeout
  timer = Timer(timeout, () {
    if (!completer.isCompleted) {
      completer.complete(null);
      subscription.cancel();
    }
  });
  
  // Try to get token immediately
  try {
    final token = await _messaging.getToken();
    if (token != null && !completer.isCompleted) {
      completer.complete(token);
      timer.cancel();
      subscription.cancel();
    }
  } catch (e) {
    print('Error getting token: $e');
  }
  
  return completer.future;
}
```

### 2. Sử dụng trong code
```dart
// Thay vì:
final token = FCMService().fcmToken; // Có thể null

// Dùng:
final token = await FCMService().waitForToken();
if (token != null) {
  // Sử dụng token
} else {
  // Xử lý lỗi
}
```

### 3. Kiểm tra quyền trước khi lấy token
```dart
Future<bool> checkPermission() async {
  final settings = await FirebaseMessaging.instance.getNotificationSettings();
  
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    return true;
  } else if (settings.authorizationStatus == AuthorizationStatus.notDetermined) {
    // Hỏi lại user
    final newSettings = await FirebaseMessaging.instance.requestPermission();
    return newSettings.authorizationStatus == AuthorizationStatus.authorized;
  }
  
  return false;
}
```

## Test Steps

1. **Xóa app và cài lại** - Reset quyền notification
2. **Chấp nhận quyền notification** khi app hỏi
3. **Kiểm tra logs** - Tìm "FCM Token: ..."
4. **Test trên cả iOS và Android** - Behavior khác nhau
5. **Test với/không có internet** - Token cần network

## Common Errors

### iOS: "Error getting FCM token: APNs device token not set"
**Nguyên nhân**: APNs chưa được cấu hình đúng

**Giải pháp**:
```bash
# Kiểm tra APNs
./check_ios_fcm.sh

# Fix APNs environment
./fix_ios_apns_environment.sh
```

### Android: "Error getting FCM token: SERVICE_NOT_AVAILABLE"
**Nguyên nhân**: Google Play Services không khả dụng

**Giải pháp**: Test trên thiết bị thật hoặc emulator có Google Play

### "FCM token is null after 10 seconds"
**Nguyên nhân**: 
- Không có internet
- Firebase chưa được init đúng
- Quyền bị từ chối

**Giải pháp**: Kiểm tra logs và quyền notification

## Checklist

- [ ] Firebase đã được init trong `main.dart`
- [ ] FCM service đã được init sau Firebase
- [ ] User đã cấp quyền notification
- [ ] App có kết nối internet
- [ ] iOS: APNs đã được cấu hình đúng
- [ ] Android: Google Play Services khả dụng
- [ ] Logs hiển thị "FCM Token: ..."
- [ ] Token được lưu vào database thành công
