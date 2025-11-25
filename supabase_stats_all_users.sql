-- =====================================================
-- THỐNG KÊ CHO TẤT CẢ NGƯỜI DÙNG
-- =====================================================
-- File này tạo function để lấy thống kê của tất cả người dùng
-- thay vì chỉ người dùng hiện tại

-- =====================================================
-- Function: Lấy thống kê theo khoảng thời gian
-- =====================================================

CREATE OR REPLACE FUNCTION get_waste_stats_all_users(
  start_date date,
  end_date date
)
RETURNS TABLE (
  quantity numeric,
  date date,
  waste_type_name text,
  waste_type_unit text
) 
SECURITY DEFINER -- Bypass RLS
SET search_path = public
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    we.quantity,
    we.date,
    wt.name as waste_type_name,
    wt.unit as waste_type_unit
  FROM waste_entries we
  JOIN waste_types wt ON wt.id = we.waste_type_id
  WHERE we.date >= start_date 
    AND we.date <= end_date
  ORDER BY we.date DESC;
END;
$$;

-- =====================================================
-- Grant permissions
-- =====================================================

-- Cho phép authenticated users gọi function này
GRANT EXECUTE ON FUNCTION get_waste_stats_all_users(date, date) TO authenticated;

-- =====================================================
-- Test function
-- =====================================================

-- Test lấy stats hôm nay
SELECT * FROM get_waste_stats_all_users(CURRENT_DATE, CURRENT_DATE);

-- Test lấy stats tháng này
SELECT * FROM get_waste_stats_all_users(
  DATE_TRUNC('month', CURRENT_DATE)::date,
  (DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month - 1 day')::date
);

-- Test lấy stats năm nay
SELECT * FROM get_waste_stats_all_users(
  DATE_TRUNC('year', CURRENT_DATE)::date,
  (DATE_TRUNC('year', CURRENT_DATE) + INTERVAL '1 year - 1 day')::date
);

-- =====================================================
-- Kiểm tra RLS hiện tại
-- =====================================================

-- Xem các policies hiện có cho waste_entries
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'waste_entries';

-- =====================================================
-- Tắt RLS cho waste_entries (nếu cần)
-- =====================================================

-- CẢNH BÁO: Chỉ làm điều này nếu bạn muốn tất cả users
-- có thể xem dữ liệu của nhau

-- Tắt RLS
-- ALTER TABLE waste_entries DISABLE ROW LEVEL SECURITY;

-- Hoặc tạo policy cho phép đọc tất cả
-- CREATE POLICY "Allow read all waste_entries"
--   ON waste_entries
--   FOR SELECT
--   USING (true);

-- =====================================================
-- HƯỚNG DẪN SỬ DỤNG
-- =====================================================

/*
1. Chạy file SQL này trong Supabase SQL Editor

2. Trong Flutter, cập nhật WasteStatsRepository để dùng function:

   final response = await supabase.rpc(
     'get_waste_stats_all_users',
     params: {
       'start_date': _formatDate(range.start),
       'end_date': _formatDate(range.end),
     },
   );

3. Hoặc nếu muốn đơn giản hơn, tắt RLS cho waste_entries:
   
   ALTER TABLE waste_entries DISABLE ROW LEVEL SECURITY;

4. Test lại app để xem thống kê của tất cả người dùng
*/
