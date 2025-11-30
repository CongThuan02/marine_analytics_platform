# 🎨 App Branding Guide - PAMELA CRUISE

## 📱 Logo & Title trong AppBar

### ✅ Đã implement

**Home Page AppBar** hiện có:
- Logo PAMELA (40x40px)
- Tên app "PAMELA" (bold, green)
- Subtitle "CRUISE" (lighter green)
- Background trắng với shadow nhẹ

### 🎯 Các widget có sẵn

#### 1. AppLogoTitle (Default)
```dart
AppBar(
  title: const AppLogoTitle(),
)
```

**Features:**
- Logo với background nhẹ
- Title "PAMELA" bold
- Subtitle "CRUISE"
- Hero animation support

**Customization:**
```dart
AppLogoTitle(
  logoSize: 40,           // Kích thước logo
  titleFontSize: 20,      // Font size title
  subtitleFontSize: 12,   // Font size subtitle
  showSubtitle: true,     // Hiện/ẩn subtitle
)
```

#### 2. AppLogoTitleHorizontal
```dart
AppBar(
  title: const AppLogoTitleHorizontal(),
)
```

**Features:**
- Layout ngang
- "PAMELA CRUISE" trên cùng 1 dòng
- Compact hơn

**Customization:**
```dart
AppLogoTitleHorizontal(
  logoSize: 36,
  fontSize: 24,
)
```

#### 3. AppLogoTitleCompact
```dart
AppBar(
  title: const AppLogoTitleCompact(),
)
```

**Features:**
- Siêu compact
- Chỉ logo + "PAMELA"
- Dùng cho space nhỏ

**Customization:**
```dart
AppLogoTitleCompact(
  size: 32,  // Kích thước tổng thể
)
```

## 🎨 Color Scheme

### Primary Colors
```dart
AppTheme.primaryGreen        // #2E7D32 - Main green
AppTheme.primaryGreenLight   // Lighter green
AppTheme.secondaryTeal       // Teal accent
```

### Usage in Branding
- **Logo**: Original colors (green clover)
- **Title**: `AppTheme.primaryGreen`
- **Subtitle**: `AppTheme.primaryGreen.withOpacity(0.7-0.8)`
- **Background**: White with subtle shadow

## 📐 Spacing & Sizing

### Logo Sizes
- **AppBar**: 40x40px
- **Splash Screen**: 120x120px (recommended)
- **About Page**: 80x80px
- **Compact**: 32x32px

### Typography
- **Title**: 20-24px, Bold, Letter spacing 1.2-1.5
- **Subtitle**: 12-14px, Medium, Letter spacing 2-2.5

### Spacing
- Logo to Text: 8-12px
- Title to Subtitle: 0-2px (tight)

## 🎯 Usage Examples

### Example 1: Standard AppBar
```dart
AppBar(
  title: const AppLogoTitle(),
  backgroundColor: Colors.white,
  elevation: 2,
  actions: [
    IconButton(
      icon: Icon(Icons.notifications),
      onPressed: () {},
    ),
  ],
)
```

### Example 2: Centered Logo
```dart
AppBar(
  centerTitle: true,
  title: const AppLogoTitle(
    logoSize: 36,
    titleFontSize: 18,
  ),
  backgroundColor: Colors.white,
)
```

### Example 3: Compact for Drawer
```dart
DrawerHeader(
  child: Column(
    children: [
      const AppLogoTitleCompact(size: 48),
      const SizedBox(height: 8),
      Text('Marine Analytics Platform'),
    ],
  ),
)
```

### Example 4: Splash Screen
```dart
Center(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Image.asset(
        'assets/images/logo.png',
        height: 120,
        width: 120,
      ),
      const SizedBox(height: 24),
      Text(
        'PAMELA',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryGreen,
          letterSpacing: 2,
        ),
      ),
      Text(
        'CRUISE',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppTheme.primaryGreen.withOpacity(0.8),
          letterSpacing: 3,
        ),
      ),
    ],
  ),
)
```

## 🔄 Switching Between Styles

### In home.dart
```dart
// Option 1: Default (current)
title: const AppLogoTitle(),

// Option 2: Horizontal
title: const AppLogoTitleHorizontal(),

// Option 3: Compact
title: const AppLogoTitleCompact(),
```

## 🎨 Customization Tips

### 1. Adjust Logo Background
```dart
AppLogoTitle(
  // Trong app_logo_title.dart, sửa:
  decoration: BoxDecoration(
    color: AppTheme.primaryGreenLight.withOpacity(0.1),
    // Thay đổi opacity hoặc color
  ),
)
```

### 2. Change Letter Spacing
```dart
Text(
  'PAMELA',
  style: TextStyle(
    letterSpacing: 1.5,  // Tăng/giảm spacing
  ),
)
```

### 3. Add Gradient
```dart
ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [
      AppTheme.primaryGreen,
      AppTheme.secondaryTeal,
    ],
  ).createShader(bounds),
  child: Text('PAMELA'),
)
```

## 📱 Platform-Specific Adjustments

### iOS
```dart
AppBar(
  title: const AppLogoTitle(
    logoSize: 36,  // Slightly smaller
    titleFontSize: 18,
  ),
)
```

### Android
```dart
AppBar(
  title: const AppLogoTitle(
    logoSize: 40,  // Standard size
    titleFontSize: 20,
  ),
)
```

## ✅ Checklist

- [x] Logo added to AppBar
- [x] Title "PAMELA" displayed
- [x] Subtitle "CRUISE" displayed
- [x] Proper spacing and sizing
- [x] Color scheme matches brand
- [x] Reusable widget created
- [x] Multiple style options available
- [ ] Add to other screens (optional)
- [ ] Create splash screen (optional)
- [ ] Add to about page (optional)

## 🚀 Next Steps

### Optional Enhancements

1. **Animated Logo**
   ```dart
   // Add rotation or scale animation
   AnimatedContainer(...)
   ```

2. **Splash Screen**
   - Create dedicated splash screen
   - Show logo with animation
   - Transition to home

3. **About Page**
   - Large logo display
   - App version
   - Credits

4. **Login/Register**
   - Add logo to auth screens
   - Consistent branding

## 📝 Files Modified

- ✅ `lib/presentation/views/home.dart` - Updated AppBar
- ✅ `lib/presentation/widgets/app_logo_title.dart` - New widget
- ✅ `assets/images/logo.png` - Logo asset

## 🎉 Result

AppBar hiện có:
- 🎨 Logo PAMELA đẹp mắt
- 📝 Tên app rõ ràng
- 🎯 Brand identity mạnh mẽ
- ♻️ Reusable components
- 🔧 Dễ customize

Enjoy your branded app! 🚀
