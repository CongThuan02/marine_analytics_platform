# Complete Edit Waste Entry Implementation

## Summary
Đây là tất cả code cần thêm để có chức năng edit waste entry với local notification.

## ✅ Repository Method (Đã có sẵn)
File `lib/data/repositories/waste_entry_repository.dart` đã có method `updateWasteEntry()` với notification check.

## 🔧 Cần thêm

### 1. Thêm UpdateWasteEntry Event

**File**: `lib/presentation/blocs/waste_entry/waste_entry_event.dart`

Thêm vào cuối file (trước dấu `}`):

```dart
class UpdateWasteEntry extends WasteEntryEvent {
  final String id;
  final WasteEntryModel entry;
  
  const UpdateWasteEntry({
    required this.id,
    required this.entry,
  });
  
  @override
  List<Object?> get props => [id, entry];
}
```

### 2. Thêm Handler trong Bloc

**File**: `lib/presentation/blocs/waste_entry/waste_entry_bloc.dart`

**A. Thêm vào constructor:**
```dart
on<UpdateWasteEntry>(_onUpdateWasteEntry);
```

**B. Thêm handler method (trước dấu `}` cuối):**
```dart
Future<void> _onUpdateWasteEntry(
  UpdateWasteEntry event,
  Emitter<WasteEntryState> emit,
) async {
  try {
    emit(state.copyWith(status: Status.loading));
    
    final message = await _repository.updateWasteEntry(
      id: event.id,
      entry: event.entry,
    );
    
    final entries = await _repository.fetchWasteEntries();
    
    emit(state.copyWith(
      status: Status.success,
      message: message,
      entries: entries,
    ));
  } catch (e) {
    emit(state.copyWith(
      status: Status.fail,
      message: e.toString(),
    ));
  }
}
```

### 3. Tạo Edit Bottom Sheet

**File**: `lib/presentation/views/history/widgets/edit_waste_entry_sheet.dart` (FILE MỚI)

Copy toàn bộ code từ `create_waste_entry_sheet.dart` và sửa:

1. Đổi tên class: `CreateWasteEntrySheet` → `EditWasteEntrySheet`
2. Thêm parameter: `final WasteEntryModel entry;`
3. Thêm `initialValue` cho FormBuilder
4. Đổi title: "Record Waste" → "Edit Waste Entry"
5. Đổi button text: "Save" → "Update"
6. Gọi `UpdateWasteEntry` thay vì `CreateWasteEntry`

**Code đầy đủ**: Xem file `IMPLEMENT_EDIT_WASTE_ENTRY.md` section 4.

### 4. Thêm Edit Button vào History Page

**File**: `lib/presentation/views/history_page.dart`

**A. Import edit sheet:**
```dart
import 'package:marine_analytics_platform/presentation/views/history/widgets/edit_waste_entry_sheet.dart';
```

**B. Tìm phần hiển thị waste entry item và thêm edit button:**

Tìm `trailing:` trong ListTile và sửa thành:
```dart
trailing: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    IconButton(
      icon: Icon(Icons.edit, color: AppTheme.primaryGreen),
      onPressed: () => _showEditSheet(context, entry),
    ),
    IconButton(
      icon: Icon(Icons.delete, color: Colors.red),
      onPressed: () => _showDeleteDialog(context, entry),
    ),
  ],
),
```

**C. Thêm method _showEditSheet:**
```dart
void _showEditSheet(BuildContext context, WasteEntryModel entry) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (bottomSheetContext) => BlocProvider.value(
      value: context.read<WasteEntryBloc>(),
      child: EditWasteEntrySheet(entry: entry),
    ),
  );
}
```

### 5. Kiểm tra RLS Policy

Chạy SQL này trong Supabase SQL Editor:

```sql
-- Check existing policies
SELECT policyname, cmd 
FROM pg_policies 
WHERE tablename = 'waste_entries';

-- Add UPDATE policy if not exists
CREATE POLICY "Users can update their own waste entries"
ON waste_entries
FOR UPDATE
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);
```

## 🧪 Testing Steps

1. `flutter run`
2. Vào History page
3. Thấy icon edit (✏️) bên cạnh mỗi entry
4. Tap icon edit
5. Bottom sheet hiện ra với data đã điền sẵn
6. Sửa quantity thành số lớn (vượt limit)
7. Tap "Update"
8. Kiểm tra:
   - Data được update ✅
   - Notification hiển thị ✅
   - Tap notification → Navigate đến Alerts ✅

## 📝 Quick Implementation Checklist

- [ ] Thêm `UpdateWasteEntry` event
- [ ] Thêm `on<UpdateWasteEntry>` trong constructor
- [ ] Thêm `_onUpdateWasteEntry` handler
- [ ] Tạo file `edit_waste_entry_sheet.dart`
- [ ] Import edit sheet vào history_page.dart
- [ ] Thêm edit button vào list item
- [ ] Thêm method `_showEditSheet`
- [ ] Chạy SQL để check/add RLS policy
- [ ] Test

## 🚀 Nếu muốn nhanh

Tôi có thể tạo trực tiếp các file cần thiết. Bạn chỉ cần:
1. Copy code vào đúng vị trí
2. Chạy SQL để add RLS policy
3. Test

Bạn muốn tôi tạo từng file không?
