# Fix FCM - Bundle ID không khớp

## Vấn đề phát hiện

### ❌ Package name không khớp:
- **Android build.gradle.kts**: `vn.coquan.test`
- **google-services.json**: `marine.analytics.platform.marine_analytics_platform`
- **iOS bundle ID**: `vn.coquan.test`
- **GoogleService-Info.plist**: `marine.analytics.platform.marineAnalyticsPlatform`

### ❌ Firebase chưa được khởi tạo đúng:
- Thiếu `options: DefaultFirebaseOptions.currentPlatform`
- FCM chỉ khởi tạo khi đã login (nhưng cần ở màn login/register)

## Giải pháp

### Bước 1: Cấu hình lại Firebase với FlutterFire CLI

```bash
# Cài đặt FlutterFire CLI (nếu chưa có)
dart pub global activate flutterfire_cli

# Đăng nhập Firebase
firebase login

# Cấu hình lại với bundleId mới
flutterfire configure \
  --project=marine-analytics-platform \
  --platforms=android,ios \
  --android-package-name=vn.coquan.test \
  --ios-bundle-id=vn.coquan.test \
  --out=lib/firebase_options.dart \
  --yes
```

### Bước 2: Cập nhật Firebase Console

#### Android:
1. Vào [Firebase Console](https://console.firebase.google.com/)
2. Chọn project `marine-analytics-platform`
3. Project Settings → Your apps → Android app
4. Thêm app mới hoặc cập nhật package name thành `vn.coquan.test`
5. Tải file `google-services.json` mới
6. Đặt vào `android/app/google-services.json`

#### iOS:
1. Vào Firebase Console → Your apps → iOS app
2. Thêm app mới hoặc cập nhật bundle ID thành `vn.coquan.test`
3. Tải file `GoogleService-Info.plist` mới
4. Đặt vào `ios/Runner/GoogleService-Info.plist`

### Bước 3: Clean và rebuild

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Android
cd android && ./gradlew clean && cd ..

# iOS (nếu trên macOS)
cd ios && pod deintegrate && pod install && cd ..

# Run app
flutter run
```

## Các thay đổi đã thực hiện

### ✅ File: `lib/main.dart`
```dart
// Thêm import
import 'package:marine_analytics_platform/firebase_options.dart';

// Sửa Firebase initialization
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);

// FCM khởi tạo luôn (không cần đợi login)
try {
  await FCMService().initialize();
  print('✅ FCM initialized successfully');
} catch (e) {
  print('⚠️ FCM init error: $e');
}
```

### ✅ File: `lib/core/services/fcm_service.dart`
```dart
// Thêm method để lưu token sau khi login
Future<void> saveFCMTokenAfterLogin() async {
  if (_fcmToken != null) {
    await _saveFCMToken(_fcmToken!);
  }
}

// Cập nhật _saveFCMToken để không fail khi chưa login
Future<void> _saveFCMToken(String token) async {
  try {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      print('ℹ️ User not logged in, FCM token not saved to database');
      return;
    }
    // ... rest of code
  }
}
```

## Kiểm tra sau khi fix

### 1. Kiểm tra Firebase đã khởi tạo
```bash
flutter run
# Xem log console, phải thấy:
# ✅ FCM initialized successfully
# 📱 FCM Token: [token string]
```

### 2. Kiểm tra lấy FCM token
- Mở màn hình login/register
- Nhấn logo 3 lần
- Phải thấy dialog hiển thị FCM token

### 3. Kiểm tra token được lưu vào database
```sql
-- Sau khi login
SELECT * FROM user_fcm_tokens WHERE user_id = '[your_user_id]';
```

## Troubleshooting

### Token vẫn null
1. Kiểm tra quyền notification:
   - Android: Settings → Apps → Your App → Notifications
   - iOS: Settings → Your App → Notifications

2. Kiểm tra log console:
   ```
   ✅ FCM: User granted permission
   📱 FCM Token: [token]
   ```

3. Nếu thấy "User declined permission":
   - Xóa app và cài lại
   - Chấp nhận quyền notification khi được hỏi

### Build error
1. Clean project:
   ```bash
   flutter clean
   rm -rf android/.gradle
   rm -rf ios/Pods
   rm -rf ios/.symlinks
   ```

2. Rebuild:
   ```bash
   flutter pub get
   cd android && ./gradlew clean && cd ..
   cd ios && pod install && cd ..
   flutter run
   ```

### Package name mismatch
- Đảm bảo package name trong `google-services.json` khớp với `build.gradle.kts`
- Đảm bảo bundle ID trong `GoogleService-Info.plist` khớp với Xcode project

## Lưu ý quan trọng

1. **Không commit file cấu hình Firebase** nếu chứa thông tin nhạy cảm
2. **Backup file cũ** trước khi thay thế
3. **Test trên cả Android và iOS** nếu build cho cả 2 platform
4. **Đợi vài giây** sau khi mở app để FCM khởi tạo xong

## Kết quả mong đợi

Sau khi fix:
- ✅ Firebase khởi tạo thành công với options đúng
- ✅ FCM token được lấy ngay khi mở app
- ✅ Logo có thể nhấn 3 lần để xem token
- ✅ Token được lưu vào database sau khi login
- ✅ Nhận được notification khi có alert
