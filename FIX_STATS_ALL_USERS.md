# Fix Thống Kê Hiển Thị Tất Cả Người Dùng

## Vấn Đề

Phần tổng quan hiện tại chỉ hiển thị thống kê của 1 người dùng do Row Level Security (RLS) trong Supabase.

## Giải Pháp

Đã tạo SQL function `get_waste_stats_all_users()` với `SECURITY DEFINER` để bypass RLS và lấy dữ liệu của tất cả người dùng.

## Các Bước Thực Hiện

### 1. Deploy SQL Function (BẮT BUỘC)

Mở **Supabase Dashboard** → **SQL Editor** → Chạy file:

```bash
supabase_stats_all_users.sql
```

Function này sẽ:
- Bypass RLS để lấy tất cả waste_entries
- Trả về dữ liệu với waste_type_name và waste_type_unit
- Có thể gọi bởi authenticated users

### 2. Code Đã Được Cập Nhật

File `lib/data/repositories/waste_stats_repository.dart` đã được cập nhật để:
- Dùng `supabase.rpc('get_waste_stats_all_users')` thay vì query trực tiếp
- Xử lý dữ liệu từ RPC function với `_buildStatsFromRpc()`

### 3. Test

Sau khi deploy SQL function:

1. **Hot reload app** (nhấn `r` trong terminal)
2. Vào trang **Tổng quan**
3. Kiểm tra các tab:
   - Hôm nay
   - Tháng này
   - Năm nay
4. Thống kê sẽ hiển thị dữ liệu của **TẤT CẢ người dùng**

## Kiểm Tra RLS

Để xem RLS policies hiện tại:

```sql
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'waste_entries';
```

## Giải Pháp Thay Thế (Không Khuyến Nghị)

Nếu muốn tắt RLS hoàn toàn cho `waste_entries`:

```sql
ALTER TABLE waste_entries DISABLE ROW LEVEL SECURITY;
```

**Lưu ý**: Cách này sẽ cho phép tất cả users xem dữ liệu của nhau trong mọi query, không chỉ thống kê.

## Troubleshooting

### Lỗi: "function get_waste_stats_all_users does not exist"

→ Chưa chạy file `supabase_stats_all_users.sql`

### Lỗi: "permission denied for function"

→ Chạy lại grant permission:
```sql
GRANT EXECUTE ON FUNCTION get_waste_stats_all_users(date, date) TO authenticated;
```

### Vẫn chỉ thấy dữ liệu của 1 người

1. Kiểm tra function đã được tạo:
   ```sql
   SELECT * FROM pg_proc WHERE proname = 'get_waste_stats_all_users';
   ```

2. Test function trực tiếp:
   ```sql
   SELECT * FROM get_waste_stats_all_users(CURRENT_DATE, CURRENT_DATE);
   ```

3. Xem logs trong app để kiểm tra lỗi

## So Sánh

### Trước (chỉ 1 user):
```dart
final response = await supabase
    .from('waste_entries')
    .select('quantity, date, waste_types(name, unit)')
    .gte('date', startDate)
    .lte('date', endDate);
// RLS tự động filter theo user_id
```

### Sau (tất cả users):
```dart
final response = await supabase.rpc(
  'get_waste_stats_all_users',
  params: {
    'start_date': startDate,
    'end_date': endDate,
  },
);
// SECURITY DEFINER bypass RLS
```

## Bảo Mật

Function `get_waste_stats_all_users()` được đánh dấu `SECURITY DEFINER`, nghĩa là:
- Chạy với quyền của người tạo function (thường là admin)
- Bypass RLS policies
- Chỉ authenticated users mới gọi được (do GRANT EXECUTE)

Điều này an toàn cho mục đích thống kê tổng quan.
