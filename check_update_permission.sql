-- Check if user can update waste_entries

-- 1. Check RLS policies for waste_entries
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
WHERE tablename = 'waste_entries'
ORDER BY cmd, policyname;

-- 2. Try a test update (will show if RLS blocks it)
-- Replace with actual entry ID
-- UPDATE waste_entries 
-- SET quantity = quantity 
-- WHERE id = 'your-entry-id';
