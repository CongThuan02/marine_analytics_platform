# Setup Background Image - Step by Step

## ⚠️ IMPORTANT: You need to save the image file first!

### Step 1: Save the Halong Bay image
1. Save your Halong Bay image (the one you showed me) to your computer
2. Rename it to: `halong_bay.jpg`
3. Copy it to this folder in your project:
   ```
   assets/images/halong_bay.jpg
   ```

### Step 2: Verify the file exists
Run this command to check:
```bash
ls -la assets/images/
```

You should see:
```
appIcon.png
logo.png
halong_bay.jpg  <-- This should be here!
```

### Step 3: Update pubspec.yaml (if needed)
Check if assets are declared in `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
```

### Step 4: Clean and rebuild
```bash
flutter clean
flutter pub get
flutter run
```

### Step 5: Hot restart (not hot reload)
Press `R` in the terminal (capital R for full restart)

## Troubleshooting

### If you see error: "Unable to load asset"
- Make sure the file is named exactly: `halong_bay.jpg`
- Make sure it's in the correct folder: `assets/images/`
- Run `flutter clean` and `flutter pub get`
- Do a full restart (not hot reload)

### If background is too bright/dark
Edit `lib/presentation/views/home.dart` and change:
```dart
Colors.white.withOpacity(0.85)  // Change 0.85 to adjust brightness
// 0.0 = fully transparent (dark)
// 1.0 = fully white (bright)
```

### Alternative: Use a different image
If you want to use a different image:
1. Save it as `assets/images/background.jpg`
2. Update the code in `lib/presentation/views/home.dart`:
   ```dart
   image: AssetImage('assets/images/background.jpg'),
   ```

## Current Status
✅ Code is ready in `lib/presentation/views/home.dart`
❌ Image file needs to be added to `assets/images/halong_bay.jpg`
