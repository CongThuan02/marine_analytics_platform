-- =====================================================
-- TẮT RLS CHO TẤT CẢ CÁC BẢNG
-- =====================================================

-- Tắt RLS cho tất cả bảng chính
ALTER TABLE areas DISABLE ROW LEVEL SECURITY;
ALTER TABLE departments DISABLE ROW LEVEL SECURITY;
ALTER TABLE waste_types DISABLE ROW LEVEL SECURITY;
ALTER TABLE users_profile DISABLE ROW LEVEL SECURITY;
ALTER TABLE waste_entries DISABLE ROW LEVEL SECURITY;
ALTER TABLE waste_limits DISABLE ROW LEVEL SECURITY;
ALTER TABLE alerts DISABLE ROW LEVEL SECURITY;
ALTER TABLE reminders DISABLE ROW LEVEL SECURITY;
ALTER TABLE user_fcm_tokens DISABLE ROW LEVEL SECURITY;

-- Grant permissions cho authenticated users
GRANT ALL ON areas TO authenticated;
GRANT ALL ON departments TO authenticated;
GRANT ALL ON waste_types TO authenticated;
GRANT ALL ON users_profile TO authenticated;
GRANT ALL ON waste_entries TO authenticated;
GRANT ALL ON waste_limits TO authenticated;
GRANT ALL ON alerts TO authenticated;
GRANT ALL ON reminders TO authenticated;
GRANT ALL ON user_fcm_tokens TO authenticated;

-- Kiểm tra RLS status
SELECT 
  tablename,
  rowsecurity as rls_enabled
FROM pg_tables
WHERE schemaname = 'public'
  AND tablename IN (
    'areas', 'departments', 'waste_types', 'users_profile',
    'waste_entries', 'waste_limits', 'alerts', 'reminders', 'user_fcm_tokens'
  )
ORDER BY tablename;

-- Test queries
SELECT COUNT(*) as total_areas FROM areas;
SELECT COUNT(*) as total_waste_types FROM waste_types;
SELECT COUNT(*) as total_waste_limits FROM waste_limits;
SELECT COUNT(*) as total_alerts FROM alerts;

-- Test query alerts với join
SELECT 
  al.id,
  al.percent,
  al.message,
  a.name as area_name,
  wt.name as waste_type_name
FROM alerts al
LEFT JOIN areas a ON a.id = al.area_id
LEFT JOIN waste_types wt ON wt.id = al.waste_type_id
ORDER BY al.created_at DESC
LIMIT 5;
