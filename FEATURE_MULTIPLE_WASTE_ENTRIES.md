# ✨ Feature: Thêm nhiều loại rác thải cùng lúc

## 📋 Tổng quan

Đã thêm tính năng **thêm nhiều loại rác thải cùng một lúc** để tiết kiệm thời gian khi ghi nhận nhiều loại rác thải trong cùng một thời điểm.

## 🎯 Tính năng mới

### 1. Dual FAB (Floating Action Buttons)
- **FAB Extended**: "Nhiều loại" - Mở form thêm nhiều loại
- **FAB Normal**: "+" - Mở form thêm 1 loại (như cũ)

### 2. Form thêm nhiều loại rác thải
**Thông tin chung (nhập 1 lần):**
- Khu vực
- Phòng ban
- Ngày ghi nhận

**Danh sách rác thải (có thể thêm nhiều):**
- Loại chất thải
- Số lượng (với đơn vị tự động)
- Nút thêm/xóa loại

### 3. Dynamic Form
- Thêm loại rác thải mới bằng nút "Thêm loại"
- Xóa loại rác thải (nếu có > 1 loại)
- Hiển thị số lượng loại đang thêm
- Auto-fetch đơn vị khi chọn loại rác

### 4. Validation
- Validate thông tin chung
- Validate từng loại rác thải
- Hiển thị lỗi rõ ràng

## 📁 Files đã tạo/sửa

### 1. New Widget
```
lib/presentation/views/history/widgets/
└── create_multiple_waste_entries_sheet.dart  # Form thêm nhiều loại
```

### 2. Modified Files
```
lib/presentation/views/
└── history_page.dart                         # Thêm dual FAB
```

## 🎨 UI/UX Features

### Header Section
- Icon và title rõ ràng
- Badge hiển thị số lượng loại đang thêm
- Drag handle để đóng sheet

### Common Fields Section
- Grouped trong card "Thông tin chung"
- Chỉ cần nhập 1 lần cho tất cả loại rác

### Waste Items List
- Mỗi loại trong 1 card riêng
- Numbered badge (1, 2, 3...)
- Hiển thị tên loại đã chọn
- Delete button (nếu > 1 loại)

### Action Buttons
- "Thêm loại" button ở header của list
- "Lưu X loại rác thải" button ở cuối
- Icon và label rõ ràng

## 🔧 Cách sử dụng

### Thêm 1 loại (như cũ)
1. Tap FAB tròn "+"
2. Điền form
3. Lưu

### Thêm nhiều loại (mới)
1. Tap FAB extended "Nhiều loại"
2. Điền thông tin chung (khu vực, phòng ban, ngày)
3. Chọn loại rác thải đầu tiên và số lượng
4. Tap "Thêm loại" để thêm loại khác
5. Điền thông tin cho các loại tiếp theo
6. Tap "Lưu X loại rác thải"

### Xóa loại rác
- Tap icon delete ở góc phải của card
- Chỉ hiện khi có > 1 loại

## 📊 Ví dụ Use Cases

### Use Case 1: Thu gom hàng ngày
```
Khu vực: Tầng 1
Phòng ban: Văn phòng
Ngày: 27/11/2024

Loại 1: Giấy (5 kg)
Loại 2: Nhựa (3 kg)
Loại 3: Kim loại (2 kg)

→ Lưu 3 entries cùng lúc
```

### Use Case 2: Kiểm tra định kỳ
```
Khu vực: Nhà máy
Phòng ban: Sản xuất
Ngày: 27/11/2024

Loại 1: Chất thải nguy hại (10 kg)
Loại 2: Chất thải công nghiệp (50 kg)
Loại 3: Chất thải sinh hoạt (15 kg)
Loại 4: Chất thải tái chế (20 kg)

→ Lưu 4 entries cùng lúc
```

## 🎯 Benefits

### 1. Tiết kiệm thời gian
- Không cần nhập lại khu vực, phòng ban, ngày
- Thêm nhiều loại trong 1 lần mở form

### 2. Giảm lỗi
- Đảm bảo consistency về thời gian và địa điểm
- Validation tập trung

### 3. UX tốt hơn
- Linh hoạt: Chọn thêm 1 hoặc nhiều loại
- Visual feedback rõ ràng
- Easy to use

## 🔄 Data Flow

```
User taps "Nhiều loại" FAB
    ↓
Open CreateMultipleWasteEntriesSheet
    ↓
User fills common fields
    ↓
User adds waste items (1 or more)
    ↓
For each item: Select type → Auto-fetch unit
    ↓
User taps "Lưu X loại"
    ↓
Validate all fields
    ↓
Loop through items
    ↓
For each: Create WasteEntryModel
    ↓
Dispatch CreateWasteEntry event
    ↓
Save to database
    ↓
Show success message
    ↓
Close sheet & refresh list
```

## 📈 Technical Details

### WasteItem Model
```dart
class WasteItem {
  String? wasteTypeId;
  String? wasteTypeName;
  String? unit;
  double? quantity;
}
```

### Form Structure
```dart
// Common form (1 FormBuilder)
FormBuilder(
  key: _formKey,
  child: Column(
    children: [
      // Common fields
      FormSelect(name: 'area_id'),
      FormSelect(name: 'department_id'),
      DateField(name: 'date'),
      
      // Waste items (multiple FormBuilders)
      ...List.generate(items.length, (i) =>
        FormBuilder(
          key: _itemFormKeys[i],
          child: Column(
            children: [
              FormSelect(name: 'waste_type_id_$i'),
              TextField(name: 'quantity_$i'),
            ],
          ),
        ),
      ),
    ],
  ),
)
```

### Validation Strategy
1. Validate common form first
2. Loop through all item forms
3. If any fails → Show error
4. If all pass → Create entries

### Auto-fetch Unit
```dart
onChange: (wasteTypeId) {
  // Fetch from Supabase
  final response = await supabase
    .from('waste_types')
    .select('name, unit')
    .eq('id', wasteTypeId)
    .single();
  
  // Update state
  setState(() {
    wasteItem.unit = response['unit'];
    wasteItem.name = response['name'];
  });
}
```

## 🎨 Design Decisions

### Why Dual FAB?
- Không làm phức tạp UI
- User có thể chọn nhanh
- Backward compatible (FAB cũ vẫn hoạt động)

### Why Separate Forms?
- Mỗi waste item có form riêng
- Dễ validate từng item
- Dễ add/remove items

### Why Show Unit in Label?
- User biết ngay đơn vị cần nhập
- Giảm confusion
- Better UX

## 🚀 Performance

### Optimization
- Lazy loading waste types
- Form validation on demand
- Efficient state management

### Scalability
- Có thể thêm unlimited items
- Scroll support cho nhiều items
- Memory efficient

## ✅ Testing

### Test Cases
1. ✅ Thêm 1 loại rác thải
2. ✅ Thêm nhiều loại (2-5 loại)
3. ✅ Xóa loại rác thải
4. ✅ Validation thông tin chung
5. ✅ Validation từng loại rác
6. ✅ Auto-fetch unit
7. ✅ Submit và save
8. ✅ Error handling

### Manual Testing
```bash
# 1. Run app
flutter run

# 2. Navigate to History page
# 3. Tap "Nhiều loại" FAB
# 4. Fill common fields
# 5. Add multiple waste types
# 6. Test validation
# 7. Submit and verify
```

## 📝 Future Enhancements

### Có thể thêm sau:
1. **Template/Preset**
   - Lưu combination thường dùng
   - Quick select preset

2. **Bulk Import**
   - Import từ Excel/CSV
   - Scan multiple QR codes

3. **Smart Suggestions**
   - Suggest based on history
   - Auto-complete waste types

4. **Duplicate Detection**
   - Warn if same type added twice
   - Auto-merge duplicates

5. **Photo Attachment**
   - Attach photos for each type
   - Visual documentation

## 🎉 Kết luận

Feature **Thêm nhiều loại rác thải** đã hoàn thành với:
- ✅ Dual FAB cho flexibility
- ✅ Dynamic form với add/remove
- ✅ Auto-fetch unit
- ✅ Comprehensive validation
- ✅ Professional UI/UX
- ✅ Efficient data flow

User giờ có thể tiết kiệm thời gian khi ghi nhận nhiều loại rác thải cùng lúc!
