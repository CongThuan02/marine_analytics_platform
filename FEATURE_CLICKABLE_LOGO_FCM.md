# Feature: Clickable Logo with FCM Token Display

## Tổng quan
Đã thêm logo có thể nhấn vào màn hình đăng nhập và đăng ký. Khi nhấn vào logo 3 lần, sẽ hiển thị FCM token của thiết bị.

## Các thay đổi

### 1. Widget mới: `ClickableLogo`
**File:** `lib/presentation/widgets/clickable_logo.dart`

Widget này bao gồm:
- Logo PAMELA CRUISE với animation khi nhấn
- Đếm số lần nhấn (3 lần để hiển thị FCM token)
- Dialog hiển thị FCM token với khả năng copy

**Tính năng:**
- ✅ Animation scale khi nhấn vào logo
- ✅ Đếm 3 lần nhấn để kích hoạt
- ✅ Hiển thị FCM token trong dialog
- ✅ Copy token vào clipboard
- ✅ Thông báo khi chưa có token

### 2. Cập nhật màn hình đăng nhập
**File:** `lib/presentation/views/login/page.dart`

Thêm:
```dart
const Center(
  child: ClickableLogo(
    logoSize: 80,
    titleFontSize: 32,
    subtitleFontSize: 16,
  ),
),
```

### 3. Cập nhật màn hình đăng ký
**File:** `lib/presentation/views/register/page.dart`

Thêm:
```dart
const ClickableLogo(
  logoSize: 70,
  titleFontSize: 28,
  subtitleFontSize: 14,
),
```

## Cách sử dụng

### Lấy FCM Token
1. Mở màn hình đăng nhập hoặc đăng ký
2. Nhấn vào logo 3 lần liên tiếp
3. Dialog sẽ hiển thị FCM token
4. Nhấn nút "Copy" để copy token vào clipboard

### Tùy chỉnh Logo
```dart
ClickableLogo(
  logoSize: 80,           // Kích thước logo
  titleFontSize: 32,      // Kích thước chữ "PAMELA"
  subtitleFontSize: 16,   // Kích thước chữ "CRUISE"
  showSubtitle: true,     // Hiển thị "CRUISE"
)
```

## Lưu ý kỹ thuật

### FCM Service
- Logo sử dụng `FCMService()` để lấy token
- Token được lưu trong `fcmToken` getter
- Nếu token chưa có, hiển thị thông báo chờ

### Animation
- Sử dụng `AnimationController` với duration 200ms
- Scale từ 1.0 xuống 0.95 khi nhấn
- Smooth animation với `Curves.easeInOut`

### Security
- Cần nhấn 3 lần mới hiển thị token (tránh lộ token vô tình)
- Token chỉ hiển thị trong dialog, không log ra console

## Testing

### Test hiển thị logo
```bash
flutter run
# Mở màn hình login/register
# Kiểm tra logo hiển thị đúng
```

### Test lấy FCM token
```bash
flutter run
# Đợi FCM khởi tạo (vài giây)
# Nhấn logo 3 lần
# Kiểm tra dialog hiển thị token
# Test nút Copy
```

### Test khi chưa có token
```bash
# Ngay sau khi mở app (trước khi FCM khởi tạo)
# Nhấn logo 3 lần
# Kiểm tra thông báo "Token not available yet"
```

## Screenshots

### Màn hình đăng nhập với logo
```
┌─────────────────────┐
│                     │
│    [LOGO IMAGE]     │
│      PAMELA         │
│      CRUISE         │
│                     │
│  Welcome Back!      │
│  Login to continue  │
│                     │
│  [Email Field]      │
│  [Password Field]   │
│  [Login Button]     │
│                     │
└─────────────────────┘
```

### Dialog FCM Token
```
┌─────────────────────────────┐
│ 🔔 FCM Token               │
│                             │
│ Your Firebase Cloud         │
│ Messaging token:            │
│                             │
│ ┌─────────────────────────┐ │
│ │ eyJhbGciOiJSUzI1NiIs... │ │
│ │ (token text)            │ │
│ └─────────────────────────┘ │
│                             │
│        [Close]  [📋 Copy]   │
└─────────────────────────────┘
```

## Tích hợp với FCM

Logo này hoạt động với FCM service đã có:
- `lib/core/services/fcm_service.dart`
- Token được lấy từ `FCMService().fcmToken`
- Token được lưu vào database khi khởi tạo

## Troubleshooting

### Logo không hiển thị
- Kiểm tra file `assets/images/logo.png` tồn tại
- Kiểm tra `pubspec.yaml` đã khai báo assets

### Token null
- Đợi vài giây sau khi mở app
- Kiểm tra FCM đã được khởi tạo trong `main.dart`
- Kiểm tra quyền notification đã được cấp

### Animation không mượt
- Kiểm tra device performance
- Thử giảm duration của animation

## Các cải tiến có thể thêm

1. **Haptic feedback** khi nhấn logo
2. **Visual indicator** số lần nhấn (1/3, 2/3, 3/3)
3. **QR code** cho FCM token
4. **Share token** qua email/message
5. **Token history** xem các token cũ
6. **Admin mode** với nhiều tính năng debug khác

## Kết luận

Feature này giúp:
- ✅ Dễ dàng lấy FCM token cho testing
- ✅ Không cần log hoặc debug console
- ✅ UI đẹp và professional
- ✅ Bảo mật (cần 3 lần nhấn)
- ✅ Dễ sử dụng (copy token 1 click)
