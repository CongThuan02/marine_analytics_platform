#!/bin/bash

echo "🖼️  Background Image Setup"
echo "=========================="
echo ""

# Check if image exists
if [ -f "assets/images/halong_bay.jpg" ]; then
    echo "✅ Image found: assets/images/halong_bay.jpg"
    ls -lh assets/images/halong_bay.jpg
    echo ""
    echo "Running flutter commands..."
    flutter clean
    flutter pub get
    echo ""
    echo "✅ Done! Now run: flutter run"
    echo "   Then press 'R' (capital R) to hot restart"
else
    echo "❌ Image NOT found!"
    echo ""
    echo "Please follow these steps:"
    echo "1. Save your Halong Bay image"
    echo "2. Rename it to: halong_bay.jpg"
    echo "3. Copy it to: assets/images/halong_bay.jpg"
    echo ""
    echo "Current files in assets/images/:"
    ls -la assets/images/
    echo ""
    echo "After adding the image, run this script again:"
    echo "   ./setup_background.sh"
fi
