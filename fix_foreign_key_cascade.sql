-- Fix foreign key constraints to allow cascade delete
-- This will automatically delete related records when parent is deleted

-- 1. Drop existing foreign key constraint on alerts table
ALTER TABLE alerts 
DROP CONSTRAINT IF EXISTS alerts_waste_type_id_fkey;

-- 2. Add new foreign key with CASCADE delete
ALTER TABLE alerts 
ADD CONSTRAINT alerts_waste_type_id_fkey 
FOREIGN KEY (waste_type_id) 
REFERENCES waste_types(id) 
ON DELETE CASCADE;

-- 3. Also fix area_id foreign key
ALTER TABLE alerts 
DROP CONSTRAINT IF EXISTS alerts_area_id_fkey;

ALTER TABLE alerts 
ADD CONSTRAINT alerts_area_id_fkey 
FOREIGN KEY (area_id) 
REFERENCES areas(id) 
ON DELETE CASCADE;

-- 4. Fix other tables that might have similar issues

-- waste_entries
ALTER TABLE waste_entries 
DROP CONSTRAINT IF EXISTS waste_entries_waste_type_id_fkey;

ALTER TABLE waste_entries 
ADD CONSTRAINT waste_entries_waste_type_id_fkey 
FOREIGN KEY (waste_type_id) 
REFERENCES waste_types(id) 
ON DELETE RESTRICT; -- Don't allow delete if entries exist

ALTER TABLE waste_entries 
DROP CONSTRAINT IF EXISTS waste_entries_area_id_fkey;

ALTER TABLE waste_entries 
ADD CONSTRAINT waste_entries_area_id_fkey 
FOREIGN KEY (area_id) 
REFERENCES areas(id) 
ON DELETE RESTRICT;

-- waste_limits
ALTER TABLE waste_limits 
DROP CONSTRAINT IF EXISTS waste_limits_waste_type_id_fkey;

ALTER TABLE waste_limits 
ADD CONSTRAINT waste_limits_waste_type_id_fkey 
FOREIGN KEY (waste_type_id) 
REFERENCES waste_types(id) 
ON DELETE CASCADE;

ALTER TABLE waste_limits 
DROP CONSTRAINT IF EXISTS waste_limits_area_id_fkey;

ALTER TABLE waste_limits 
ADD CONSTRAINT waste_limits_area_id_fkey 
FOREIGN KEY (area_id) 
REFERENCES areas(id) 
ON DELETE CASCADE;

-- departments
ALTER TABLE departments 
DROP CONSTRAINT IF EXISTS departments_area_id_fkey;

ALTER TABLE departments 
ADD CONSTRAINT departments_area_id_fkey 
FOREIGN KEY (area_id) 
REFERENCES areas(id) 
ON DELETE SET NULL; -- Set to NULL instead of blocking delete
