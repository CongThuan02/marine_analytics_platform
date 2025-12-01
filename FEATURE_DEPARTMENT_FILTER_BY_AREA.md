# Tính năng: Lọc Phòng ban theo Khu vực

## 📋 Mô tả
Khi người dùng chọn khu vực trong form thêm/sửa rác thải, dropdown phòng sẽ chỉ hiển thị các phòng thuộc khu vực đã chọn.

## ✅ Đã implement

### 1. Cập nhật FormSelect Widget
**File**: `lib/presentation/widgets/form_slect/form_select.dart`

Thêm 2 tham số mới:
- `filterColumn`: Tên cột để filter (ví dụ: 'area_id')
- `filterValue`: Giá trị để filter (ví dụ: ID của khu vực đã chọn)

```dart
const FormSelect({
  // ... existing parameters
  this.filterColumn,
  this.filterValue,
});
```

### 2. Cập nhật FormSelectEvent
**File**: `lib/presentation/widgets/form_slect/bloc/form_select_event.dart`

Thêm filter parameters vào `GetItemsFormEvent`:
```dart
class GetItemsFormEvent extends FormSelectEvent {
  final String tableName;
  final String? filterColumn;
  final String? filterValue;
  
  const GetItemsFormEvent({
    required this.tableName,
    this.filterColumn,
    this.filterValue,
  });
}
```

### 3. Cập nhật FormSelectBloc
**File**: `lib/presentation/widgets/form_slect/bloc/form_select_bloc.dart`

Truyền filter parameters đến repository:
```dart
on<GetItemsFormEvent>((event, emit) async {
  emit(state.copyWith(status: Status.loading));
  final res = await _formSelectRepository.getAllItems(
    tableName: event.tableName,
    filterColumn: event.filterColumn,
    filterValue: event.filterValue,
  );
  emit(state.copyWith(status: Status.loaded, items: res, selected: state.selected ?? "select"));
});
```

### 4. Cập nhật FormSelectRepository
**File**: `lib/presentation/widgets/form_slect/form_select_repository.dart`

Thêm logic filter vào query:
```dart
Future<List<Map<String, dynamic>>?> getAllItems({
  required String tableName,
  String? filterColumn,
  String? filterValue,
}) async {
  try {
    var query = supabase.from(tableName).select();
    
    // Apply filter if provided
    if (filterColumn != null && filterValue != null && filterValue != 'select') {
      query = query.eq(filterColumn, filterValue);
    }
    
    final res = await query;
    return res;
  } catch (e, st) {
    print('Error fetching data: $e');
    return [];
  }
}
```

### 5. Cập nhật Create Waste Entry Form
**File**: `lib/presentation/views/history/widgets/create_waste_entry_sheet.dart`

- Thêm state variable `_selectedAreaId`
- Thêm `onChange` callback cho area dropdown
- Thêm `filterColumn` và `filterValue` cho department dropdown
- Thêm `key: ValueKey(_selectedAreaId)` để rebuild khi area thay đổi

```dart
class _CreateWasteEntrySheetState extends State<CreateWasteEntrySheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  String? _selectedAreaId;

  // ...

  FormSelect(
    name: 'area_id',
    label: context.l10n.area,
    tableName: 'areas',
    onChange: (value) {
      setState(() {
        _selectedAreaId = value;
        _formKey.currentState?.fields['department_id']?.didChange('select');
      });
    },
    // ...
  ),
  FormSelect(
    key: ValueKey(_selectedAreaId),
    name: 'department_id',
    label: context.l10n.department,
    tableName: 'departments',
    filterColumn: 'area_id',
    filterValue: _selectedAreaId,
    // ...
  ),
}
```

### 6. Cập nhật Edit Waste Entry Form
**File**: `lib/presentation/views/history/widgets/edit_waste_entry_sheet.dart`

Tương tự như create form, nhưng khởi tạo `_selectedAreaId` từ entry hiện tại:
```dart
class _EditWasteEntrySheetState extends State<EditWasteEntrySheet> {
  final _formKey = GlobalKey<FormBuilderState>();
  late String? _selectedAreaId;

  @override
  void initState() {
    super.initState();
    _selectedAreaId = widget.entry.areaId;
    // ...
  }
}
```

## 🎯 Cách hoạt động

1. **Khi form load lần đầu**: Department dropdown hiển thị tất cả phòng (hoặc filtered nếu có area_id)

2. **Khi user chọn khu vực**:
   - `onChange` callback được gọi
   - `_selectedAreaId` được cập nhật
   - Department field được reset về 'select'
   - `setState()` trigger rebuild

3. **Khi department dropdown được mở**:
   - FormSelect gửi `GetItemsFormEvent` với `filterColumn='area_id'` và `filterValue=_selectedAreaId`
   - Repository thực hiện query: `supabase.from('departments').select().eq('area_id', _selectedAreaId)`
   - Chỉ các phòng thuộc khu vực đã chọn được hiển thị

## 📝 Lưu ý

- Filter chỉ áp dụng khi `filterValue != null` và `filterValue != 'select'`
- Khi area thay đổi, department field tự động reset về 'select'
- Sử dụng `ValueKey(_selectedAreaId)` để force rebuild FormSelect khi area thay đổi
- Database phải có foreign key `departments.area_id` references `areas.id`

## 🔄 Các form cần cập nhật thêm (nếu có)

- `create_multiple_waste_entries_sheet.dart`
- `create_multiple_waste_entries_sheet_v2.dart`
- Các form khác có sử dụng area + department

## ✨ Kết quả

Người dùng giờ chỉ thấy các phòng thuộc khu vực đã chọn, giúp:
- Giảm confusion
- Tăng tốc độ nhập liệu
- Tránh chọn sai phòng không thuộc khu vực
