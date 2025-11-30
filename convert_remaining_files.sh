#!/bin/bash

# Script to convert remaining Vietnamese text to English
# Run this after manually reviewing each change

echo "Converting remaining files to English..."

# Note: This is a reference script. 
# Due to complexity, manual conversion is recommended for accuracy.
# Use this as a checklist:

echo "Files to convert:"
echo "1. lib/presentation/views/home.dart"
echo "2. lib/presentation/views/setting.dart"
echo "3. lib/presentation/views/waste_limit/page.dart"
echo "4. lib/presentation/views/reminder/page.dart"
echo "5. lib/presentation/views/waste_type/page.dart"
echo "6. lib/presentation/views/department/page.dart"
echo "7. lib/presentation/views/overviews/widgets/stats_overview_tab.dart"
echo "8. lib/presentation/views/alerts/create_test_alert_page.dart"

echo ""
echo "Common replacements needed:"
echo "- Import: add 'import package:marine_analytics_platform/core/constants/app_strings.dart;'"
echo "- 'Trang chủ' → AppStrings.home"
echo "- 'Cài đặt' → AppStrings.settings"
echo "- 'Đăng xuất' → AppStrings.logout"
echo "- 'Hạn mức' → AppStrings.wasteLimits"
echo "- 'Nhắc nhở' → AppStrings.reminders"
echo "- 'Loại chất thải' → AppStrings.wasteTypes"
echo "- 'Phòng ban' → AppStrings.departments"
echo "- 'Hôm nay' → AppStrings.today"
echo "- 'Tháng này' → AppStrings.thisMonth"
echo "- 'Năm nay' → AppStrings.thisYear"

echo ""
echo "Please convert files manually using AppStrings constants."
echo "Refer to CONVERT_TO_ENGLISH.md for detailed instructions."
