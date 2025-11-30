# Hướng dẫn sửa các lỗi còn lại

## Tổng quan
Còn 14 lỗi compile, chủ yếu là type mismatch giữa Entity và Model trong UI components.

## Các lỗi cần sửa

### 1. Alert Page (3 lỗi)
**File:** `lib/presentation/views/alerts/page.dart`

**Lỗi:**
- Line 120: `List<Alert>` không thể assign cho `List<AlertModel>`
- Line 127: `Alert` không thể assign cho `AlertModel`
- Line 221: Method `DeleteOldAlerts` không tồn tại

**Cách sửa:**
```dart
// Thay đổi từ AlertModel sang Alert trong widget
// Line ~120
final filteredAlerts = state.alerts.where((alert) {
  // alert đã là Alert entity rồi
}).toList();

// Line ~127
return AlertCard(alert: alert); // alert là Alert entity
```

### 2. Alert Card Widget (1 lỗi)
**File:** `lib/presentation/views/alerts/widgets/alert_card.dart`

**Lỗi:** Line 224: Method `DeleteAlert` không tồn tại

**Cách sửa:**
- AlertBloc mới không có DeleteAlert event
- Có thể xóa feature này hoặc thêm use case mới

### 3. Department Page (1 lỗi)
**File:** `lib/presentation/views/department/page.dart`

**Lỗi:** Line 134: `areaModel` không tồn tại trong DepartmentModel

**Cách sửa:**
```dart
// Thay đổi từ
department.areaModel?.name

// Sang
department.area?.name
```

### 4. Waste Entry Sheet (6 lỗi)
**File:** `lib/presentation/views/history/widgets/create_waste_entry_sheet.dart`

**Lỗi:** Line 130-134: Thiếu required parameters và null safety

**Cách sửa:**
```dart
final entry = WasteEntryModel(
  id: '', // Thêm
  userId: supabase.auth.currentUser!.id, // Thêm
  departmentId: _selectedDepartmentId!, // Thêm !
  areaId: _selectedAreaId!, // Thêm !
  wasteTypeId: _selectedWasteTypeId!, // Thêm !
  quantity: double.parse(_quantityController.text),
  date: _selectedDate!, // Thêm !
  createdAt: DateTime.now(), // Thêm
);
```

### 5. Reminder Page (1 lỗi)
**File:** `lib/presentation/views/reminder/page.dart`

**Lỗi:** Line 102: `Reminder` không thể assign cho `ReminderModel`

**Cách sửa:**
```dart
// Widget nên nhận Reminder entity, không phải ReminderModel
// Thay đổi ReminderCard để nhận Reminder
class ReminderCard extends StatelessWidget {
  final Reminder reminder; // Đã đúng rồi
  
  const ReminderCard({required this.reminder});
}
```

### 6. Waste Limit Page (1 lỗi)
**File:** `lib/presentation/views/waste_limit/page.dart`

**Lỗi:** Line 92: `WasteLimit` không thể assign cho `WasteLimitModel`

**Cách sửa:**
```dart
// Widget nên nhận WasteLimit entity
class LimitCard extends StatelessWidget {
  final WasteLimit limit; // Thay đổi từ WasteLimitModel
  
  const LimitCard({required this.limit});
}
```

## Script tự động sửa

Tôi sẽ tạo script để sửa các lỗi này:

```bash
# Chạy script này để sửa tự động
flutter pub run build_runner build --delete-conflicting-outputs
```

## Lưu ý quan trọng

1. **Entities vs Models:**
   - UI components nên sử dụng **Entities** (từ domain layer)
   - Models chỉ dùng trong Data layer để serialize/deserialize

2. **Type Safety:**
   - Entities có required fields không nullable
   - Cần handle null safety khi tạo entities từ form data

3. **BLoC Events:**
   - Các event names đã thay đổi:
     - `CreateReminder` → `CreateReminderEvent`
     - `DeleteReminder` → `DeleteReminderEvent`
     - `ToggleReminder` → `ToggleReminderEvent`
     - `CreateWasteLimit` → `CreateWasteLimitEvent`
     - `DeleteWasteLimit` → `DeleteWasteLimitEvent`

## Ưu tiên sửa

1. ✅ **High Priority:** Alert, Reminder, Waste Limit pages (đã sử dụng)
2. ⚠️ **Medium Priority:** Department page
3. 🔵 **Low Priority:** Waste Entry (có thể sửa sau)
