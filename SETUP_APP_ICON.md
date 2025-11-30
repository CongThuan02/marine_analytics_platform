# 🎨 Hướng dẫn thay đổi App Icon

## 📋 Yêu cầu

- Logo image (PNG format, khuyến nghị 1024x1024px)
- Flutter SDK đã cài đặt

## 🚀 Các bước thực hiện

### Bước 1: Chuẩn bị logo

1. **Lưu logo vào project:**
   ```bash
   # Tạo thư mục nếu chưa có
   mkdir -p assets/images
   
   # Copy logo vào thư mục
   # Đặt tên file là logo.png
   cp /path/to/your/logo.png assets/images/logo.png
   ```

2. **Yêu cầu về logo:**
   - Format: PNG
   - Kích thước khuyến nghị: 1024x1024px (hoặc lớn hơn)
   - Nền trong suốt (transparent) cho kết quả tốt nhất
   - Logo nên có padding khoảng 10-15% để tránh bị cắt

### Bước 2: Cài đặt dependencies

```bash
flutter pub get
```

### Bước 3: Generate app icons

```bash
# Generate icons cho cả Android và iOS
dart run flutter_launcher_icons
```

Hoặc nếu lệnh trên không hoạt động:

```bash
flutter pub run flutter_launcher_icons
```

### Bước 4: Verify kết quả

**Android:**
- Kiểm tra: `android/app/src/main/res/mipmap-*/ic_launcher.png`
- Adaptive icon: `android/app/src/main/res/mipmap-*/ic_launcher_foreground.png`

**iOS:**
- Kiểm tra: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Bước 5: Test trên thiết bị

```bash
# Clean build
flutter clean

# Rebuild app
flutter run
```

## 📱 Cấu hình chi tiết

File `flutter_launcher_icons.yaml` đã được tạo với cấu hình:

```yaml
flutter_launcher_icons:
  android: true                              # Generate cho Android
  ios: true                                  # Generate cho iOS
  image_path: "assets/images/logo.png"       # Đường dẫn logo
  
  # Android Adaptive Icon
  adaptive_icon_background: "#FFFFFF"        # Màu nền (trắng)
  adaptive_icon_foreground: "assets/images/logo.png"
  
  # iOS
  remove_alpha_ios: true                     # Xóa alpha channel cho iOS
  
  # Web (optional)
  web:
    generate: true
    image_path: "assets/images/logo.png"
    background_color: "#FFFFFF"
    theme_color: "#2E7D32"                   # Màu xanh lá
```

## 🎨 Tùy chỉnh

### Thay đổi màu nền Android Adaptive Icon

Sửa trong `flutter_launcher_icons.yaml`:

```yaml
adaptive_icon_background: "#2E7D32"  # Màu xanh lá
```

### Sử dụng logo khác cho Android và iOS

```yaml
flutter_launcher_icons:
  android: true
  ios: true
  image_path_android: "assets/images/logo_android.png"
  image_path_ios: "assets/images/logo_ios.png"
```

### Chỉ generate cho một platform

```yaml
# Chỉ Android
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/images/logo.png"
```

## 🔧 Troubleshooting

### Lỗi: "Image not found"

**Giải pháp:**
- Kiểm tra đường dẫn file logo
- Đảm bảo file tồn tại: `assets/images/logo.png`
- Kiểm tra tên file (case-sensitive)

### Lỗi: "Invalid image format"

**Giải pháp:**
- Chuyển đổi sang PNG format
- Đảm bảo image không bị corrupt
- Thử resize về 1024x1024px

### Icon không hiển thị sau khi build

**Giải pháp:**
```bash
# Clean và rebuild
flutter clean
flutter pub get
flutter run
```

### Android: Icon bị cắt

**Giải pháp:**
- Thêm padding vào logo (10-15%)
- Hoặc tạo foreground riêng với padding

### iOS: Icon có nền đen

**Giải pháp:**
- Đảm bảo `remove_alpha_ios: true` trong config
- Hoặc tạo logo với nền trắng

## 📐 Kích thước Icon được generate

### Android
- `mipmap-mdpi`: 48x48px
- `mipmap-hdpi`: 72x72px
- `mipmap-xhdpi`: 96x96px
- `mipmap-xxhdpi`: 144x144px
- `mipmap-xxxhdpi`: 192x192px

### iOS
- `20x20@2x`: 40x40px
- `20x20@3x`: 60x60px
- `29x29@2x`: 58x58px
- `29x29@3x`: 87x87px
- `40x40@2x`: 80x80px
- `40x40@3x`: 120x120px
- `60x60@2x`: 120x120px
- `60x60@3x`: 180x180px
- `1024x1024`: 1024x1024px (App Store)

## 🎯 Best Practices

1. **Logo Design:**
   - Đơn giản, dễ nhận diện
   - Tránh text quá nhỏ
   - Sử dụng màu tương phản cao

2. **File Preparation:**
   - PNG format với nền trong suốt
   - Kích thước 1024x1024px hoặc lớn hơn
   - Padding 10-15% xung quanh logo

3. **Testing:**
   - Test trên nhiều thiết bị khác nhau
   - Kiểm tra cả light và dark mode
   - Verify trên App Store/Play Store preview

## 📝 Checklist

- [ ] Logo đã được lưu vào `assets/images/logo.png`
- [ ] Chạy `flutter pub get`
- [ ] Chạy `dart run flutter_launcher_icons`
- [ ] Verify icons đã được generate
- [ ] Clean và rebuild app
- [ ] Test trên thiết bị thật
- [ ] Kiểm tra icon trên home screen
- [ ] Kiểm tra icon trong app switcher

## 🔗 Resources

- [flutter_launcher_icons package](https://pub.dev/packages/flutter_launcher_icons)
- [Android Icon Guidelines](https://developer.android.com/guide/practices/ui_guidelines/icon_design_adaptive)
- [iOS Icon Guidelines](https://developer.apple.com/design/human-interface-guidelines/app-icons)

## ✅ Kết quả mong đợi

Sau khi hoàn thành, bạn sẽ có:
- ✅ App icon mới trên Android (tất cả densities)
- ✅ App icon mới trên iOS (tất cả sizes)
- ✅ Adaptive icon cho Android 8.0+
- ✅ Web icon (nếu enable)
- ✅ Icon hiển thị đúng trên home screen
- ✅ Icon hiển thị đúng trong app switcher

## 🎉 Done!

App của bạn giờ đã có logo mới! 🚀
