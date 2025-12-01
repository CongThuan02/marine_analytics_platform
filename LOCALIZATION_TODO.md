# Danh sách các file cần chuyển sang đa ngôn ngữ

## ✅ Đã hoàn thành
- lib/main.dart - Đã thêm localization delegates
- lib/routes/app_router.dart - Bottom navigation
- lib/presentation/views/home.dart - Tab labels
- lib/presentation/views/setting.dart - Settings page
- lib/presentation/views/login/page.dart - Login form
- lib/presentation/views/register/page.dart - Register form
- lib/presentation/views/alerts/page.dart - Alerts page
- lib/presentation/views/alerts/widgets/alert_card.dart - Alert card
- lib/presentation/views/overviews/*.dart - Overview pages
- lib/presentation/views/history_page.dart - History page (partial)
- lib/presentation/views/history/widgets/create_waste_entry_sheet.dart - Create form (partial)

## 🔄 Cần hoàn thiện

### High Priority (Người dùng thường xuyên thấy)

1. **lib/presentation/views/waste_type/page.dart**
   - "Manage Waste Types" → context.l10n.manageWasteTypes
   - "Edit Waste Type" → "Chỉnh sửa loại chất thải"
   - "Confirm Delete" → context.l10n.confirmDelete
   - "Cannot Delete" → "Không thể xóa"
   - Buttons: Cancel, Update, Delete, OK

2. **lib/presentation/views/department/page.dart**
   - "Manage Departments" → context.l10n.manageDepartments
   - "Edit Department" → context.l10n.editDepartment
   - "Confirm Delete" → context.l10n.confirmDelete
   - Buttons: Cancel, Update, Delete

3. **lib/presentation/views/history/widgets/edit_waste_entry_sheet.dart**
   - "Update" button → context.l10n.update
   - Form labels: Area, Department, Quantity
   - Validation messages

4. **lib/presentation/views/history/widgets/create_multiple_waste_entries_sheet.dart**
   - "Add Type" → context.l10n.addType
   - "Save X waste types" → Sử dụng template string
   - Form labels

5. **lib/presentation/views/waste_limit/widgets/limit_card.dart**
   - "Confirm Delete" → context.l10n.confirmDelete
   - "Are you sure..." → context.l10n.areYouSureDelete
   - "Limit deleted" → "Đã xóa hạn mức"

6. **lib/presentation/views/reminder/widgets/reminder_card.dart**
   - "Confirm Delete" → context.l10n.confirmDelete
   - "Are you sure..." → context.l10n.areYouSureDelete
   - "Reminder deleted" → "Đã xóa nhắc nhở"

7. **lib/presentation/views/overviews/widgets/stats_overview_tab.dart**
   - "Select month and year" → "Chọn tháng và năm"
   - "Select year" → "Chọn năm"
   - "Change" → "Thay đổi"
   - "Select", "Cancel" buttons

8. **lib/presentation/views/overviews/widgets/trend_comparison_tab.dart**
   - "Monthly" → "Hàng tháng"
   - "Yearly" → "Hàng năm"

### Medium Priority

9. **lib/presentation/views/waste_type/widgets/create.dart**
   - "Name" label → context.l10n.name
   - "Save" button → context.l10n.save

10. **lib/presentation/views/department/widget/create.dart**
    - "Name" label → context.l10n.name
    - "Save" button → context.l10n.save

11. **lib/presentation/views/alerts/test_alerts_page.dart**
    - "Test Create Alert" → "Test tạo cảnh báo"
    - "Create Test Alert" → "Tạo cảnh báo test"
    - "Delete All Alerts" → "Xóa tất cả cảnh báo"
    - "Confirm" → context.l10n.confirm

12. **lib/presentation/views/alerts/create_test_alert_page.dart**
    - "Create Test Data" → "Tạo dữ liệu test"
    - "Create Test Alert (85%)" → "Tạo cảnh báo test (85%)"
    - "Delete All Alerts" → "Xóa tất cả cảnh báo"

### Low Priority (Debug/Test pages)

13. **lib/presentation/views/clickable_logo.dart**
    - "Close" button → context.l10n.close

14. **lib/presentation/views/overviews/widgets/LineChartModel.dart**
    - "Weekly Values" → "Giá trị hàng tuần"

## Cách sử dụng

### 1. Thêm import vào file
```dart
import 'package:marine_analytics_platform/core/localization/localization_extension.dart';
```

### 2. Thay thế hardcoded text
```dart
// Trước:
Text("Save")

// Sau:
Text(context.l10n.save)
```

### 3. Nếu chuỗi chưa có trong AppStringsVi
Thêm vào `lib/core/constants/app_strings_vi.dart` và `lib/core/localization/app_localizations.dart`

## Các chuỗi đã có sẵn trong AppStringsVi

- Common: ok, cancel, save, update, delete, edit, add, search, filter, select, loading, error, success, warning, confirm, close
- Auth: login, logout, register, email, password
- Navigation: home, ships, history, settings, alerts, reminders, limits, statistics
- Waste: wasteEntry, wasteType, wasteLimit, area, department, quantity, date, qrCode
- Time: daily, weekly, monthly, yearly, today, thisWeek, thisMonth, thisYear
- Actions: refresh, apply, reset, clear, back, next, previous, submit
- Messages: noDataFound, noDataForPeriod, deleteConfirm, etc.

Xem đầy đủ trong `lib/core/constants/app_strings_vi.dart`
