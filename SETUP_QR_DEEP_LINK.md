# Setup QR Code Deep Linking

## Overview
QR code chứa deep link URL để mở app và navigate đến màn hình cụ thể.

**Deep Link Format**: `marineanalytics://ships`

## 1. Xem QR Code trong App

Thêm button vào Settings page để mở QR code:

```dart
ElevatedButton(
  onPressed: () => context.push('/qr-code'),
  child: const Text('View QR Code'),
)
```

## 2. Cấu hình iOS (ios/Runner/Info.plist)

Thêm vào file `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>com.example.marineanalyticsplatform</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>marineanalytics</string>
    </array>
  </dict>
</array>
```

## 3. Cấu hình Android (android/app/src/main/AndroidManifest.xml)

Thêm intent-filter vào MainActivity:

```xml
<activity
    android:name=".MainActivity"
    ...>
    
    <!-- Existing intent filters -->
    <intent-filter>
        <action android:name="android.intent.action.MAIN"/>
        <category android:name="android.intent.category.LAUNCHER"/>
    </intent-filter>
    
    <!-- Deep Link intent filter -->
    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        
        <!-- Deep link scheme -->
        <data
            android:scheme="marineanalytics"
            android:host="ships" />
        <data
            android:scheme="marineanalytics"
            android:host="alerts" />
        <data
            android:scheme="marineanalytics"
            android:host="home" />
    </intent-filter>
</activity>
```

## 4. Test Deep Link

### Test trên iOS:
```bash
xcrun simctl openurl booted marineanalytics://ships
```

### Test trên Android:
```bash
adb shell am start -W -a android.intent.action.VIEW -d "marineanalytics://ships" com.example.marine_analytics_platform
```

## 5. Sử dụng

1. Mở app và vào Settings
2. Nhấn "View QR Code"
3. QR code sẽ hiển thị
4. Scan QR code bằng camera thiết bị khác
5. App sẽ mở và navigate đến History page

## 6. Các Deep Link có sẵn

- `marineanalytics://ships` - Mở History page
- `marineanalytics://alerts` - Mở Alerts page  
- `marineanalytics://home` - Mở Home page

## 7. Tạo QR Code mới

Để tạo QR code cho route khác, chỉnh sửa `deepLinkUrl` trong `lib/presentation/views/qr_code_page.dart`:

```dart
const deepLinkUrl = 'marineanalytics://YOUR_ROUTE';
```

## Troubleshooting

### iOS không mở app
- Kiểm tra Info.plist đã thêm CFBundleURLSchemes
- Rebuild app: `flutter clean && flutter run`

### Android không mở app
- Kiểm tra AndroidManifest.xml đã thêm intent-filter
- Kiểm tra package name đúng
- Rebuild app: `flutter clean && flutter run`

### Deep link không navigate
- Kiểm tra console logs: `🔗 Deep link received`
- Kiểm tra route đã được thêm trong `app_router.dart`
- Kiểm tra `_handleDeepLink` trong `main.dart`
