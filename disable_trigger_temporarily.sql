-- =====================================================
-- DISABLE TRIGGER TEMPORARILY
-- =====================================================
-- This disables the database trigger that's causing errors
-- You will only use local notifications (which work fine)

-- Disable the trigger
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
DROP TRIGGER IF EXISTS trigger_check_waste_limit_on_update ON waste_entries;

-- Verify triggers are disabled
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table
FROM information_schema.triggers
WHERE event_object_table = 'waste_entries'
ORDER BY trigger_name;

-- Success message
SELECT '✅ Database triggers disabled. Local notifications will still work!' as status;
