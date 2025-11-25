# Hướng dẫn Setup Cảnh báo

## Tổng quan

Để có cảnh báo trong app, bạn cần:
1. Có dữ liệu waste_limits (hạn mức)
2. Có dữ liệu waste_entries (nhập liệu)
3. Tạo alerts (tự động hoặc thủ công)

---

## Cách 1: Tự động với Trigger (Khuyến nghị)

### Bước 1: Tạo Function trong Supabase

1. Vào Supabase Dashboard
2. Chọn SQL Editor
3. Copy nội dung file `supabase_functions.sql`
4. Run SQL

### Bước 2: Test

Khi bạn thêm waste_entry mới, trigger sẽ tự động:
- Kiểm tra xem có hạn mức không
- Tính tổng chất thải trong ngày
- Nếu >= 80%, tạo cảnh báo tự động

### Ví dụ:
```sql
-- Giả sử có hạn mức: Rác nhựa tại Vịnh Hạ Long = 100kg/ngày

-- Thêm entry 85kg
INSERT INTO waste_entries (area_id, waste_type_id, quantity, date) 
VALUES (..., ..., 85, CURRENT_DATE);

-- Trigger tự động tạo cảnh báo: "⚠️ CẢNH BÁO: Rác nhựa tại Vịnh Hạ Long đã đạt 85% hạn mức"
```

---

## Cách 2: Thủ công từ App (Để test)

### Bước 1: Vào màn hình Test

1. Mở app
2. Vào **Settings** → **Cảnh báo hạn mức**
3. Nhấn menu (3 chấm) → **Test tạo cảnh báo**

### Bước 2: Tạo cảnh báo

**Option A: Kiểm tra & Tạo tự động**
- Nhấn "Kiểm tra & Tạo Cảnh báo"
- App sẽ:
  - Lấy tất cả waste_limits
  - Tính tổng waste_entries hôm nay
  - Tạo cảnh báo nếu >= 80%

**Option B: Tạo cảnh báo test**
- Nhấn "Tạo Cảnh báo Test"
- App sẽ tạo 1 cảnh báo giả với 150%

**Option C: Xóa tất cả**
- Nhấn "Xóa Tất cả Cảnh báo"
- Xóa để test lại từ đầu

---

## Cách 3: Chạy Function thủ công

### Trong Supabase SQL Editor:

```sql
-- Kiểm tra và tạo cảnh báo cho hôm nay
SELECT * FROM check_waste_limits_today();

-- Kiểm tra cho ngày cụ thể
SELECT * FROM check_waste_limits_today('2025-11-25');
```

---

## Kiểm tra dữ liệu

### 1. Kiểm tra có waste_limits chưa:
```sql
SELECT 
  a.name as area_name,
  wt.name as waste_type,
  wl.daily_limit
FROM waste_limits wl
JOIN areas a ON a.id = wl.area_id
JOIN waste_types wt ON wt.id = wl.waste_type_id;
```

### 2. Kiểm tra waste_entries hôm nay:
```sql
SELECT 
  a.name as area_name,
  wt.name as waste_type,
  SUM(we.quantity) as total_today
FROM waste_entries we
JOIN areas a ON a.id = we.area_id
JOIN waste_types wt ON wt.id = we.waste_type_id
WHERE we.date = CURRENT_DATE
GROUP BY a.name, wt.name;
```

### 3. Kiểm tra alerts:
```sql
SELECT 
  a.name as area_name,
  wt.name as waste_type,
  al.percent,
  al.message,
  al.created_at
FROM alerts al
JOIN areas a ON a.id = al.area_id
JOIN waste_types wt ON wt.id = al.waste_type_id
ORDER BY al.created_at DESC;
```

---

## Troubleshooting

### Không có cảnh báo nào?

**Kiểm tra:**
1. ✅ Có waste_limits chưa?
   ```sql
   SELECT COUNT(*) FROM waste_limits;
   ```

2. ✅ Có waste_entries hôm nay chưa?
   ```sql
   SELECT COUNT(*) FROM waste_entries WHERE date = CURRENT_DATE;
   ```

3. ✅ Có vượt 80% chưa?
   ```sql
   SELECT 
     wl.daily_limit,
     SUM(we.quantity) as total,
     (SUM(we.quantity) / wl.daily_limit * 100) as percent
   FROM waste_limits wl
   LEFT JOIN waste_entries we ON we.area_id = wl.area_id 
     AND we.waste_type_id = wl.waste_type_id 
     AND we.date = CURRENT_DATE
   GROUP BY wl.daily_limit;
   ```

### Trigger không chạy?

**Kiểm tra trigger:**
```sql
-- Xem trigger có tồn tại không
SELECT * FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';

-- Xem function có tồn tại không
SELECT * FROM pg_proc WHERE proname = 'check_waste_limit';
```

**Tạo lại trigger:**
```sql
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
CREATE TRIGGER trigger_check_waste_limit
  AFTER INSERT OR UPDATE ON waste_entries
  FOR EACH ROW 
  EXECUTE FUNCTION check_waste_limit();
```

---

## Tạo dữ liệu test

### Script tạo dữ liệu đầy đủ:

```sql
-- 1. Tạo khu vực
INSERT INTO areas (name) VALUES ('Vịnh Test') RETURNING id;
-- Lưu id: <area_id>

-- 2. Tạo loại chất thải
INSERT INTO waste_types (name, unit) VALUES ('Rác Test', 'kg') RETURNING id;
-- Lưu id: <waste_type_id>

-- 3. Tạo hạn mức 100kg/ngày
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
VALUES ('<area_id>', '<waste_type_id>', 100);

-- 4. Thêm waste entry 85kg (sẽ trigger cảnh báo 85%)
INSERT INTO waste_entries (area_id, waste_type_id, quantity, date) 
VALUES ('<area_id>', '<waste_type_id>', 85, CURRENT_DATE);

-- 5. Kiểm tra cảnh báo
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 1;
```

---

## Cron Job (Tùy chọn)

Để tự động kiểm tra mỗi ngày:

### Supabase Edge Function:

```typescript
// supabase/functions/daily-alert-check/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  // Gọi function kiểm tra
  const { data, error } = await supabase.rpc('check_waste_limits_today')

  return new Response(
    JSON.stringify({ alerts: data, error }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

### Cron Schedule:
```
0 8 * * * // Chạy lúc 8h sáng mỗi ngày
```

---

## Tóm tắt

### Để có cảnh báo:
1. ✅ Tạo waste_limits (Quản lý hạn mức)
2. ✅ Nhập waste_entries (Nhập liệu hàng ngày)
3. ✅ Setup trigger (Cách 1) HOẶC dùng Test page (Cách 2)
4. ✅ Xem cảnh báo trong app

### Flow tự động:
```
Nhập waste_entry → Trigger check → Tính % → Nếu >= 80% → Tạo alert → Hiển thị trong app
```

---

**Cập nhật**: 25/11/2025
