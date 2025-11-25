# Theme Thân Thiện Môi Trường

## Bảng màu chính

### Màu Primary (Xanh lá cây)
- `AppTheme.primaryGreen` - #2E7D32 - Xanh lá đậm (màu chính)
- `AppTheme.primaryGreenLight` - #66BB6A - Xanh lá sáng
- `AppTheme.primaryGreenDark` - #1B5E20 - Xanh lá rất đậm

### Màu Secondary (Xanh ngọc)
- `AppTheme.secondaryTeal` - #00796B - Xanh ngọc
- `AppTheme.secondaryTealLight` - #26A69A - Xanh ngọc nhạt
- `AppTheme.secondaryTealDark` - #004D40 - Xanh ngọc đậm

### Màu Accent
- `AppTheme.accentBlue` - #0288D1 - Xanh biển
- `AppTheme.accentBrown` - #8D6E63 - Nâu đất
- `AppTheme.accentOlive` - #7CB342 - Xanh olive

### Màu trạng thái
- `AppTheme.success` - #66BB6A - Thành công
- `AppTheme.warning` - #FFB74D - Cảnh báo
- `AppTheme.error` - #E57373 - Lỗi
- `AppTheme.info` - #42A5F5 - Thông tin

### Màu nền
- `AppTheme.backgroundLight` - #F1F8E9 - Nền sáng
- `AppTheme.surfaceLight` - #FFFFFF - Bề mặt
- `AppTheme.cardBackground` - #F5F5F5 - Nền card

### Màu text
- `AppTheme.textPrimary` - #212121 - Text chính
- `AppTheme.textSecondary` - #757575 - Text phụ
- `AppTheme.textHint` - #BDBDBD - Text gợi ý

## Cách sử dụng

### 1. Sử dụng màu trực tiếp
```dart
Container(
  color: AppTheme.primaryGreen,
  child: Text(
    'Hello',
    style: TextStyle(color: AppTheme.textPrimary),
  ),
)
```

### 2. Sử dụng từ Theme context
```dart
Container(
  color: Theme.of(context).colorScheme.primary, // AppTheme.primaryGreen
  child: Text(
    'Hello',
    style: Theme.of(context).textTheme.titleLarge,
  ),
)
```

### 3. Buttons tự động áp dụng theme
```dart
ElevatedButton(
  onPressed: () {},
  child: Text('Button'), // Tự động có màu xanh lá
)

TextButton(
  onPressed: () {},
  child: Text('Text Button'), // Tự động có màu xanh lá
)
```

### 4. Input fields tự động áp dụng theme
```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Nhập dữ liệu',
    // Tự động có border xanh lá khi focus
  ),
)
```

## Triết lý thiết kế

Theme này lấy cảm hứng từ thiên nhiên và môi trường biển:
- **Xanh lá cây**: Tượng trưng cho sự sống, tái tạo và bảo vệ môi trường
- **Xanh ngọc/biển**: Đại diện cho đại dương và hệ sinh thái biển
- **Nâu đất**: Kết nối với đất đai và tự nhiên
- **Màu sắc nhẹ nhàng**: Tạo cảm giác thư giãn, gần gũi với thiên nhiên

## Áp dụng cho toàn bộ app

Theme đã được áp dụng tự động cho:
- ✅ AppBar
- ✅ Buttons (Elevated, Text, Outlined)
- ✅ Cards
- ✅ Input fields
- ✅ Progress indicators
- ✅ Dialogs
- ✅ Bottom navigation
- ✅ Tabs
- ✅ Snackbars
- ✅ FAB (Floating Action Button)
- ✅ Chips

Không cần thay đổi code, tất cả widgets sẽ tự động sử dụng màu mới!
