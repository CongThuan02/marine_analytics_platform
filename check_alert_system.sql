-- =====================================================
-- KIỂM TRA HỆ THỐNG CẢNH BÁO
-- =====================================================

-- 1. Kiểm tra waste_limits
SELECT 
  wl.id,
  a.name as area_name,
  wt.name as waste_type_name,
  wl.daily_limit,
  wt.unit
FROM waste_limits wl
JOIN areas a ON a.id = wl.area_id
JOIN waste_types wt ON wt.id = wl.waste_type_id
ORDER BY a.name, wt.name;

-- Nếu rỗng → Chưa có hạn mức, cần tạo

-- 2. Kiểm tra waste_entries hôm nay
SELECT 
  we.id,
  a.name as area_name,
  wt.name as waste_type_name,
  we.quantity,
  wt.unit,
  we.date,
  we.created_at
FROM waste_entries we
JOIN areas a ON a.id = we.area_id
JOIN waste_types wt ON wt.id = we.waste_type_id
WHERE we.date = CURRENT_DATE
ORDER BY we.created_at DESC;

-- 3. Tính tổng theo area và waste_type hôm nay
SELECT 
  we.area_id,
  a.name as area_name,
  we.waste_type_id,
  wt.name as waste_type_name,
  SUM(we.quantity) as total_today,
  wl.daily_limit,
  ROUND((SUM(we.quantity) / wl.daily_limit * 100)::numeric, 2) as percent
FROM waste_entries we
JOIN areas a ON a.id = we.area_id
JOIN waste_types wt ON wt.id = we.waste_type_id
LEFT JOIN waste_limits wl ON wl.area_id = we.area_id 
  AND wl.waste_type_id = we.waste_type_id
WHERE we.date = CURRENT_DATE
GROUP BY we.area_id, a.name, we.waste_type_id, wt.name, wl.daily_limit
ORDER BY percent DESC NULLS LAST;

-- 4. Kiểm tra alerts đã được tạo
SELECT 
  al.id,
  a.name as area_name,
  wt.name as waste_type_name,
  al.total_today,
  al.limit_value,
  al.percent,
  al.message,
  al.created_at
FROM alerts al
JOIN areas a ON a.id = al.area_id
JOIN waste_types wt ON wt.id = al.waste_type_id
WHERE DATE(al.created_at) = CURRENT_DATE
ORDER BY al.created_at DESC;

-- 5. Kiểm tra trigger có tồn tại không
SELECT 
  tgname as trigger_name,
  tgenabled as enabled,
  proname as function_name
FROM pg_trigger t
JOIN pg_proc p ON p.oid = t.tgfoid
WHERE tgname = 'trigger_check_waste_limit';

-- 6. Kiểm tra function có tồn tại không
SELECT 
  proname as function_name,
  prosrc as source_code
FROM pg_proc
WHERE proname = 'check_waste_limit';

-- =====================================================
-- HƯỚNG DẪN KHẮC PHỤC
-- =====================================================

/*
Nếu Query 1 (waste_limits) rỗng:
→ Chưa có hạn mức, cần tạo:
   INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
   VALUES ('<area_id>', '<waste_type_id>', 100);

Nếu Query 3 cho thấy percent >= 80 nhưng Query 4 (alerts) rỗng:
→ Trigger chưa chạy hoặc chưa được deploy
→ Chạy file: supabase_functions.sql

Nếu Query 5 (trigger) rỗng:
→ Trigger chưa được tạo
→ Chạy file: supabase_functions.sql

Nếu Query 6 (function) rỗng:
→ Function chưa được tạo
→ Chạy file: supabase_functions.sql

Nếu tất cả đều OK nhưng vẫn không có alert:
→ Thử tạo waste_entry mới để trigger chạy lại
*/

-- =====================================================
-- TEST NHANH: Tạo alert thủ công
-- =====================================================

-- Nếu muốn test nhanh, tạo alert trực tiếp:
/*
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
*/

-- Sau đó refresh app để xem alert
