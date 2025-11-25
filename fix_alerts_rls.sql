-- =====================================================
-- FIX: Alerts không hiển thị do RLS
-- =====================================================

-- 1. Kiểm tra RLS policies cho alerts
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd
FROM pg_policies
WHERE tablename = 'alerts';

-- 2. Tắt RLS cho alerts (để tất cả users có thể xem)
ALTER TABLE alerts DISABLE ROW LEVEL SECURITY;

-- HOẶC tạo policy cho phép đọc tất cả
-- ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
-- DROP POLICY IF EXISTS "Allow read all alerts" ON alerts;
-- CREATE POLICY "Allow read all alerts"
--   ON alerts
--   FOR SELECT
--   USING (true);

-- 3. Test query từ app
SELECT 
  al.*,
  a.name as area_name,
  wt.name as waste_type_name,
  wt.unit as waste_type_unit
FROM alerts al
JOIN areas a ON a.id = al.area_id
JOIN waste_types wt ON wt.id = al.waste_type_id
ORDER BY al.created_at DESC
LIMIT 10;

-- 4. Kiểm tra lại
SELECT COUNT(*) as total_alerts FROM alerts;
