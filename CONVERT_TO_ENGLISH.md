# Convert App to English

## Đã Tạo

File `lib/core/constants/app_strings.dart` chứa tất cả strings tiếng Anh.

## Cách Sử Dụng

### 1. Import AppStrings

Trong mỗi file cần đổi, thêm import:

```dart
import 'package:marine_analytics_platform/core/constants/app_strings.dart';
```

### 2. Thay Thế Text

**Trước:**
```dart
Text('Cảnh báo Hạn mức')
```

**Sau:**
```dart
Text(AppStrings.alertsTitle)
```

## Danh Sách File Cần Thay Đổi

### Priority 1: UI chính

1. **lib/presentation/views/alerts/page.dart**
   - 'Cảnh báo Hạn mức' → AppStrings.alertsTitle
   - 'Không có cảnh báo' → AppStrings.noAlerts
   - 'Xóa cảnh báo cũ' → AppStrings.deleteOldAlerts
   - 'Test tạo cảnh báo' → AppStrings.testCreateAlert

2. **lib/presentation/views/alerts/widgets/alert_card.dart**
   - 'Xóa' → AppStrings.delete
   - 'Bạn có chắc muốn xóa?' → AppStrings.deleteAlertConfirm

3. **lib/presentation/views/waste_limit/page.dart**
   - 'Hạn mức' → AppStrings.wasteLimits
   - 'Thêm hạn mức' → AppStrings.addWasteLimit

4. **lib/presentation/views/reminder/page.dart**
   - 'Nhắc nhở' → AppStrings.reminders
   - 'Thêm nhắc nhở' → AppStrings.addReminder

5. **lib/presentation/views/setting.dart**
   - 'Cài đặt' → AppStrings.settings
   - 'Đăng xuất' → AppStrings.logout
   - 'Bạn có chắc muốn đăng xuất?' → AppStrings.logoutConfirm

6. **lib/presentation/views/home.dart**
   - 'Trang chủ' → AppStrings.home
   - 'Tổng quan' → AppStrings.overview

### Priority 2: Statistics

7. **lib/presentation/views/overviews/widgets/stats_overview_tab.dart**
   - 'Hôm nay' → AppStrings.today
   - 'Tháng này' → AppStrings.thisMonth
   - 'Năm nay' → AppStrings.thisYear
   - 'Tổng khối lượng' → AppStrings.totalQuantity
   - 'Số lần ghi nhận' → AppStrings.entryCount
   - 'Biểu đồ phân bố chất thải' → AppStrings.wasteDistribution
   - 'So sánh khối lượng' → AppStrings.quantityComparison
   - 'Chi tiết theo loại chất thải' → AppStrings.detailsByWasteType

### Priority 3: Forms & Dialogs

8. **lib/presentation/views/waste_type/page.dart**
9. **lib/presentation/views/department/page.dart**
10. **lib/presentation/views/areas/create/page.dart**

### Priority 4: Test Pages

11. **lib/presentation/views/alerts/create_test_alert_page.dart**
12. **lib/test_supabase_connection.dart**

## Ví Dụ Thay Đổi

### Alerts Page

**Trước:**
```dart
appBar: AppBar(
  title: const Text('Cảnh báo Hạn mức'),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        context.read<AlertBloc>().add(LoadAlerts());
      },
    ),
  ],
),
```

**Sau:**
```dart
import 'package:marine_analytics_platform/core/constants/app_strings.dart';

appBar: AppBar(
  title: const Text(AppStrings.alertsTitle),
  actions: [
    IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () {
        context.read<AlertBloc>().add(LoadAlerts());
      },
    ),
  ],
),
```

### Alert Card

**Trước:**
```dart
TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: const Text('Hủy'),
),
TextButton(
  onPressed: () {
    Navigator.of(context).pop();
    context.read<AlertBloc>().add(DeleteAlert(alert.id));
  },
  child: const Text('Xóa'),
),
```

**Sau:**
```dart
TextButton(
  onPressed: () => Navigator.of(context).pop(),
  child: const Text(AppStrings.cancel),
),
TextButton(
  onPressed: () {
    Navigator.of(context).pop();
    context.read<AlertBloc>().add(DeleteAlert(alert.id));
  },
  child: const Text(AppStrings.delete),
),
```

## Tự Động Hóa (Nếu Cần)

Có thể dùng regex để tìm và thay thế:

```bash
# Tìm tất cả Text với tiếng Việt
grep -r "Text('.*[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ].*')" lib/

# Hoặc tìm các string cụ thể
grep -r "Cảnh báo" lib/
grep -r "Hạn mức" lib/
grep -r "Xóa" lib/
```

## Lưu Ý

1. **Không thay đổi**:
   - Comments trong code
   - Debug messages
   - Database field names
   - API endpoints

2. **Cần thay đổi**:
   - UI text (AppBar titles, Button labels, etc.)
   - User-facing messages
   - Error messages
   - Validation messages

3. **Kiểm tra sau khi thay đổi**:
   - Hot reload để xem UI
   - Test tất cả màn hình
   - Kiểm tra dialogs và snackbars

## Thứ Tự Thực Hiện

1. Thay đổi từng file một
2. Hot reload sau mỗi file
3. Test UI để đảm bảo không bị lỗi
4. Commit sau mỗi nhóm file

## Nếu Muốn Hỗ Trợ Đa Ngôn Ngữ

Sau này có thể dùng package `flutter_localizations`:

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0
```

Và tạo file `l10n/app_en.arb` và `l10n/app_vi.arb` để hỗ trợ cả tiếng Anh và tiếng Việt.
