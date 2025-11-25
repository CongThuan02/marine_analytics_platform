-- Test query giống như trong app

SELECT 
  al.id,
  al.area_id,
  al.waste_type_id,
  al.total_today,
  al.limit_value,
  al.percent,
  al.message,
  al.created_at,
  json_build_object('name', a.name) as areas,
  json_build_object('name', wt.name, 'unit', wt.unit) as waste_types
FROM alerts al
LEFT JOIN areas a ON a.id = al.area_id
LEFT JOIN waste_types wt ON wt.id = al.waste_type_id
ORDER BY al.created_at DESC
LIMIT 5;

-- Kiểm tra có alerts nào có area_id hoặc waste_type_id NULL không
SELECT 
  COUNT(*) as total,
  COUNT(area_id) as with_area,
  COUNT(waste_type_id) as with_waste_type
FROM alerts;

-- Xem alerts có foreign key hợp lệ không
SELECT 
  al.id,
  al.area_id,
  al.waste_type_id,
  CASE WHEN a.id IS NULL THEN 'MISSING' ELSE 'OK' END as area_status,
  CASE WHEN wt.id IS NULL THEN 'MISSING' ELSE 'OK' END as waste_type_status
FROM alerts al
LEFT JOIN areas a ON a.id = al.area_id
LEFT JOIN waste_types wt ON wt.id = al.waste_type_id
WHERE a.id IS NULL OR wt.id IS NULL;
