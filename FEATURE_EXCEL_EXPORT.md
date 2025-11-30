# Excel Export Feature

## Overview
Chức năng xuất báo cáo lịch sử waste entries ra file Excel với nhiều tùy chọn thời gian.

## Features

### 1. Export Options
- **Today** - Xuất dữ liệu hôm nay
- **This Week** - Xuất dữ liệu tuần này (từ thứ 2)
- **This Month** - Xuất dữ liệu tháng này
- **This Year** - Xuất dữ liệu năm này
- **Custom Range** - Chọn khoảng thời gian tùy chỉnh

### 2. Excel File Structure

**Headers:**
- Date
- Area
- Department
- Waste Type
- Quantity
- Unit
- QR Code
- Created At

**Summary Section:**
- Total Entries
- Total Quantity
- Period (date range)

### 3. File Naming
Format: `waste_report_{period}_{start_date}_{end_date}.xlsx`

Example: `waste_report_monthly_20241201_20241231.xlsx`

## Usage

### In App

1. Mở **History** page
2. Nhấn icon **Download** (📥) trên app bar
3. Chọn period muốn export:
   - Today
   - This Week
   - This Month
   - This Year
   - Custom Range
4. File Excel sẽ được tạo và share dialog sẽ hiện ra
5. Chọn nơi lưu file (Email, Drive, etc.)

### Programmatically

```dart
import 'package:marine_analytics_platform/core/services/excel_export_service.dart';

// Export data
await ExcelExportService().exportToExcel(
  entries: wasteEntries,
  period: 'monthly',
  startDate: DateTime(2024, 12, 1),
  endDate: DateTime(2024, 12, 31),
);
```

## Technical Details

### Packages Used
- `excel: ^4.0.6` - Create Excel files
- `path_provider: ^2.1.5` - Get temp directory
- `share_plus: ^10.1.3` - Share files

### Service: `ExcelExportService`

Location: `lib/core/services/excel_export_service.dart`

**Methods:**
- `exportToExcel()` - Main export method
- `_formatDate()` - Format date for display
- `_formatDateTime()` - Format datetime for display
- `_formatDateForFile()` - Format date for filename

### Styling
- Header row: Green background (#4CAF50), white text, bold
- Data rows: Default styling
- Summary section: Below data with totals

## Error Handling

### No Data Found
If no entries exist for selected period:
```
Error: No data found for selected period
```

### Export Failed
If Excel generation fails:
```
Error exporting: [error message]
```

## Permissions

### Android
No special permissions needed. Share dialog handles file access.

### iOS
No special permissions needed. Share dialog handles file access.

## Testing

### Test Export
1. Create some waste entries
2. Go to History page
3. Click download icon
4. Select "Today"
5. Verify Excel file is created and shared

### Test Custom Range
1. Click download icon
2. Select "Custom Range"
3. Pick date range
4. Verify correct data is exported

## Future Enhancements

- [ ] Add charts/graphs to Excel
- [ ] Export to PDF
- [ ] Email report directly
- [ ] Schedule automatic reports
- [ ] Add filters (by area, department, waste type)
- [ ] Multiple sheet support (one per area/department)
- [ ] Add company logo to report

## Troubleshooting

### File not opening
- Ensure Excel app is installed
- Try different app (Google Sheets, WPS Office)

### Share dialog not showing
- Check app permissions
- Restart app

### Empty file
- Verify data exists for selected period
- Check date range is correct
