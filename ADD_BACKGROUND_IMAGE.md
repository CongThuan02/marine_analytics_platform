# Add Background Image to Home Page

## Step 1: Save the image
Save your Halong Bay image to:
```
assets/images/halong_bay.jpg
```

## Step 2: Update pubspec.yaml
The assets folder is already configured in pubspec.yaml, so no changes needed.

## Step 3: Code has been updated
The home page now includes the background image with:
- Semi-transparent overlay for better readability
- Proper image positioning
- Fallback color if image fails to load

## Step 4: Test
```bash
flutter pub get
flutter run
```

The background will show behind all tabs with a subtle overlay.
