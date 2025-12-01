# Tính năng: Phòng ban không bắt buộc thuộc Khu vực

## 📋 Mô tả
Cho phép tạo và quản lý phòng không thuộc khu vực cụ thể nào (area_id = null). Điều này hữu ích cho các phòng chung hoặc phòng cấp công ty.

## ✅ Đã implement

### 1. Cập nhật Create Department Form
**File**: `lib/presentation/views/department/widget/create.dart`

- Thêm label "(tùy chọn)" cho dropdown khu vực
- Thêm option đặc biệt: "(Không thuộc khu vực nào)" với id = 'null'
- Convert 'null' string thành actual null khi lưu vào database

```dart
FormSelect(
  tableName: 'areas',
  name: 'area_id',
  label: 'Khu vực (tùy chọn)',
  iniItems: const [
    {
      'id': 'null',
      'name': '(Không thuộc khu vực nào)',
    }
  ],
  onChange: (value) {
    // Convert 'null' string to actual null for database
    final areaId = value == 'null' || value == 'select' ? null : value;
    bloc.add(
      UpdateFieldDepartmentEvent(
        key: 'area_id',
        value: areaId,
      ),
    );
  },
),
```

### 2. Cập nhật Edit Department Dialog
**File**: `lib/presentation/views/department/page.dart`

Tạo StatefulWidget mới `_EditDepartmentDialog` với:
- TextField cho tên phòng
- FormSelect cho khu vực (tùy chọn)
- Xử lý convert 'null' string thành actual null
- Loading state khi đang lưu

```dart
class _EditDepartmentDialog extends StatefulWidget {
  final String id;
  final String currentName;
  final String? currentAreaId;  // Nullable
  final VoidCallback onSave;
  
  // ...
}
```

**Tính năng chính**:
- Hiển thị khu vực hiện tại (nếu có)
- Cho phép chọn "(Không thuộc khu vực nào)"
- Cho phép thay đổi từ có khu vực sang không có khu vực và ngược lại
- Loading indicator khi đang lưu
- Error handling với SnackBar

### 3. Cập nhật FormSelect Repository
**File**: `lib/presentation/widgets/form_slect/form_select_repository.dart`

Filter đã được cập nhật để bao gồm cả records có area_id = null:

```dart
// Include items where filterColumn = filterValue OR filterColumn is null
if (filterColumn != null && filterValue != null && filterValue != 'select') {
  query = query.or('$filterColumn.eq.$filterValue,$filterColumn.is.null');
}
```

## 🎯 Cách hoạt động

### Tạo phòng mới:
1. User mở form tạo phòng
2. Nhập tên phòng
3. Có 3 lựa chọn cho khu vực:
   - "Chọn" (mặc định - sẽ lưu null)
   - "(Không thuộc khu vực nào)" - sẽ lưu null
   - Chọn một khu vực cụ thể - sẽ lưu area_id
4. Nhấn "Lưu"

### Sửa phòng:
1. User nhấn nút edit trên phòng
2. Dialog hiển thị:
   - Tên hiện tại
   - Khu vực hiện tại (hoặc "Không thuộc khu vực nào" nếu null)
3. User có thể:
   - Đổi tên
   - Đổi khu vực
   - Chọn "Không thuộc khu vực nào" để remove area_id
4. Nhấn "Cập nhật"

### Khi chọn phòng trong form waste entry:
- Nếu đã chọn khu vực A: Hiển thị phòng thuộc khu vực A + phòng không thuộc khu vực nào
- Nếu chưa chọn khu vực: Hiển thị tất cả phòng

## 📊 Database Schema

Bảng `departments`:
```sql
CREATE TABLE departments (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  area_id UUID REFERENCES areas(id),  -- Nullable!
  created_at TIMESTAMP DEFAULT NOW()
);
```

## 💡 Use Cases

**Phòng ban không thuộc khu vực** phù hợp cho:
- Phòng Nhân sự (HR) - phục vụ toàn công ty
- Phòng IT - phục vụ toàn công ty
- Phòng Kế toán - phục vụ toàn công ty
- Ban Giám đốc
- Các phòng hỗ trợ chung

**Phòng ban thuộc khu vực** phù hợp cho:
- Phòng Sản xuất Khu A
- Phòng Kho Khu B
- Phòng Bảo trì Khu C
- Các phòng hoạt động tại địa điểm cụ thể

## ✨ Kết quả

- ✅ Linh hoạt hơn trong quản lý cấu trúc tổ chức
- ✅ Phù hợp với thực tế doanh nghiệp
- ✅ Không bắt buộc phải tạo khu vực trước khi tạo phòng
- ✅ Phòng ban chung có thể được chọn từ bất kỳ khu vực nào
- ✅ UI rõ ràng với label "(tùy chọn)" và option "(Không thuộc khu vực nào)"
