-- =====================================================
-- FIX HOÀN TOÀN RLS CHO ALERTS
-- =====================================================

-- 1. Xem RLS status hiện tại
SELECT 
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'alerts';

-- 2. Xem tất cả policies
SELECT 
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'alerts';

-- 3. XÓA TẤT CẢ POLICIES
DO $$ 
DECLARE
    r RECORD;
BEGIN
    FOR r IN (SELECT policyname FROM pg_policies WHERE tablename = 'alerts')
    LOOP
        EXECUTE 'DROP POLICY IF EXISTS ' || quote_ident(r.policyname) || ' ON alerts';
    END LOOP;
END $$;

-- 4. TẮT RLS
ALTER TABLE alerts DISABLE ROW LEVEL SECURITY;

-- 5. GRANT permissions
GRANT ALL ON alerts TO authenticated;
GRANT ALL ON alerts TO anon;

-- 6. Kiểm tra lại
SELECT 
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE tablename = 'alerts';

-- 7. Test query
SELECT COUNT(*) as total_alerts FROM alerts;

SELECT 
  id,
  area_id,
  waste_type_id,
  percent,
  message,
  created_at
FROM alerts
ORDER BY created_at DESC
LIMIT 5;
