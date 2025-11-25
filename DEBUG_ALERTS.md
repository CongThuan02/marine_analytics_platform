# Debug: Tại Sao Không Có Cảnh Báo?

## Checklist Nhanh

Chạy file `check_alert_system.sql` trong Supabase SQL Editor để kiểm tra:

### ✅ 1. Có waste_limits không?
```sql
SELECT * FROM waste_limits;
```
- **Nếu rỗng** → Chưa có hạn mức, cần tạo trong app hoặc SQL

### ✅ 2. Có waste_entries hôm nay không?
```sql
SELECT * FROM waste_entries WHERE date = CURRENT_DATE;
```
- **Nếu rỗng** → Chưa nhập dữ liệu hôm nay

### ✅ 3. Tổng có vượt 80% không?
```sql
SELECT 
  SUM(quantity) as total,
  (SELECT daily_limit FROM waste_limits WHERE area_id = we.area_id LIMIT 1) as limit,
  (SUM(quantity) / (SELECT daily_limit FROM waste_limits WHERE area_id = we.area_id LIMIT 1) * 100) as percent
FROM waste_entries we
WHERE date = CURRENT_DATE
GROUP BY area_id;
```
- **Nếu percent < 80** → Chưa đủ để trigger alert

### ✅ 4. Trigger có tồn tại không?
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';
```
- **Nếu rỗng** → Chưa deploy trigger, chạy `supabase_functions.sql`

### ✅ 5. Có alerts trong database không?
```sql
SELECT * FROM alerts WHERE DATE(created_at) = CURRENT_DATE;
```
- **Nếu rỗng** → Trigger chưa chạy hoặc chưa đủ điều kiện

## Giải Pháp Từng Trường Hợp

### Trường Hợp 1: Chưa Có Waste Limits

**Cách 1: Tạo trong App**
1. Vào trang **Waste Limits** (Hạn mức)
2. Click nút **+** để thêm mới
3. Chọn khu vực, loại chất thải, nhập hạn mức (VD: 100 kg/ngày)
4. Lưu

**Cách 2: Tạo bằng SQL**
```sql
-- Xem areas và waste_types có sẵn
SELECT id, name FROM areas;
SELECT id, name, unit FROM waste_types;

-- Tạo waste_limit
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
VALUES (
  '<area_id>',  -- Thay bằng ID từ query trên
  '<waste_type_id>',  -- Thay bằng ID từ query trên
  100.0  -- Hạn mức 100 kg/ngày
);
```

### Trường Hợp 2: Chưa Deploy Trigger

Chạy file SQL trong Supabase Dashboard:
```bash
supabase_functions.sql
```

Kiểm tra lại:
```sql
SELECT * FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';
```

### Trường Hợp 3: Đã Nhập Nhưng Chưa Đủ 80%

Ví dụ:
- Hạn mức: 100 kg
- Đã nhập: 50 kg
- Percent: 50% < 80% → Chưa trigger

**Giải pháp**: Nhập thêm để đạt >= 80 kg

### Trường Hợp 4: Area/WasteType Không Khớp

Waste_entry phải có cùng `area_id` và `waste_type_id` với waste_limit.

Kiểm tra:
```sql
-- Xem waste_entry
SELECT area_id, waste_type_id, quantity FROM waste_entries WHERE date = CURRENT_DATE;

-- Xem waste_limit
SELECT area_id, waste_type_id, daily_limit FROM waste_limits;

-- Phải khớp nhau!
```

### Trường Hợp 5: Trigger Chạy Nhưng Không Tạo Alert

Xem logs trong Supabase Dashboard → Database → Logs

Hoặc test trigger thủ công:
```sql
-- Tạo waste_entry test
INSERT INTO waste_entries (
  user_id,
  department_id,
  area_id,
  waste_type_id,
  quantity,
  date
) VALUES (
  (SELECT id FROM users_profile LIMIT 1),
  (SELECT id FROM departments LIMIT 1),
  (SELECT area_id FROM waste_limits LIMIT 1),
  (SELECT waste_type_id FROM waste_limits LIMIT 1),
  85.0,  -- 85% của 100
  CURRENT_DATE
);

-- Kiểm tra alert
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 1;
```

## Test Nhanh Trong App

Nếu không muốn setup phức tạp:

1. Vào trang **Alerts**
2. Click menu 3 chấm → **"Test tạo cảnh báo"**
3. Click **"Tạo Dữ Liệu Test"** (nếu chưa có)
4. Click **"Tạo Alert Test (85%)"**
5. Quay lại trang Alerts → Sẽ thấy alert mới

## Kiểm Tra App

Trong Flutter app:

1. **Refresh trang Alerts**: Pull down để refresh
2. **Xem logs**: Tìm lỗi trong console
3. **Kiểm tra AlertBloc**: Có load dữ liệu không?

## Vẫn Không Được?

Chạy đầy đủ file `check_alert_system.sql` và gửi kết quả để debug chi tiết.

Hoặc tạo alert thủ công để test:
```sql
INSERT INTO alerts (
  area_id,
  waste_type_id,
  total_today,
  limit_value,
  percent,
  message
) VALUES (
  (SELECT id FROM areas LIMIT 1),
  (SELECT id FROM waste_types LIMIT 1),
  85.0,
  100.0,
  85.0,
  '⚠️ CẢNH BÁO TEST: Đã đạt 85% hạn mức'
);
```

Sau đó refresh app để xem alert hiển thị.
