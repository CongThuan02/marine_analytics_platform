-- =====================================================
-- ADD UPDATE TRIGGER FOR WASTE LIMIT NOTIFICATION
-- =====================================================
-- This adds a trigger to check waste limit when updating waste entries
-- Currently only INSERT trigger exists, this adds UPDATE trigger

-- The function check_waste_limit() already exists and works for both INSERT and UPDATE
-- We just need to add a trigger for UPDATE events

-- Drop existing trigger if any
DROP TRIGGER IF EXISTS trigger_check_waste_limit_on_update ON waste_entries;

-- Create trigger for UPDATE
CREATE TRIGGER trigger_check_waste_limit_on_update
  AFTER UPDATE ON waste_entries
  FOR EACH ROW
  EXECUTE FUNCTION check_waste_limit();

-- Verify triggers
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_statement
FROM information_schema.triggers
WHERE event_object_table = 'waste_entries'
  AND trigger_name LIKE '%check_waste_limit%'
ORDER BY trigger_name;

-- Success message
SELECT '✅ UPDATE trigger added for waste limit notifications' as status;
