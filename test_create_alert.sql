-- =====================================================
-- SCRIPT TEST: Tạo Alert Mẫu
-- =====================================================
-- Script này giúp bạn test hệ thống cảnh báo bằng cách
-- tạo dữ liệu mẫu và trigger alert

-- =====================================================
-- Bước 1: Kiểm tra dữ liệu hiện có
-- =====================================================

-- Xem các khu vực
SELECT id, name FROM areas ORDER BY name;

-- Xem các loại chất thải
SELECT id, name, unit FROM waste_types ORDER BY name;

-- Xem các hạn mức đã thiết lập
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

-- Xem các alerts hiện có
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
ORDER BY al.created_at DESC
LIMIT 10;

-- =====================================================
-- Bước 2: Tạo dữ liệu test (nếu chưa có)
-- =====================================================

-- Tạo khu vực test (nếu chưa có)
INSERT INTO areas (name) 
VALUES ('Khu vực Test Alert')
ON CONFLICT DO NOTHING
RETURNING id, name;

-- Tạo loại chất thải test (nếu chưa có)
INSERT INTO waste_types (name, unit) 
VALUES ('Rác nhựa Test', 'kg')
ON CONFLICT DO NOTHING
RETURNING id, name, unit;

-- =====================================================
-- Bước 3: Tạo hạn mức test
-- =====================================================

-- LƯU Ý: Thay <area_id> và <waste_type_id> bằng ID thực tế từ query trên

-- Ví dụ: Tạo hạn mức 100kg/ngày
/*
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
VALUES (
  '<area_id>',  -- Thay bằng ID khu vực
  '<waste_type_id>',  -- Thay bằng ID loại chất thải
  100.0
)
ON CONFLICT (area_id, waste_type_id) 
DO UPDATE SET daily_limit = 100.0
RETURNING *;
*/

-- =====================================================
-- Bước 4: Tạo waste_entry để trigger alert
-- =====================================================

-- LƯU Ý: Thay các ID bằng ID thực tế

-- Ví dụ: Nhập 85kg (vượt 80% của 100kg)
/*
INSERT INTO waste_entries (
  user_id,
  department_id,
  area_id,
  waste_type_id,
  quantity,
  date
) VALUES (
  (SELECT id FROM users_profile LIMIT 1),  -- Lấy user đầu tiên
  (SELECT id FROM departments LIMIT 1),    -- Lấy department đầu tiên
  '<area_id>',  -- Thay bằng ID khu vực
  '<waste_type_id>',  -- Thay bằng ID loại chất thải
  85.0,  -- 85% của 100kg
  CURRENT_DATE
);
*/

-- =====================================================
-- Bước 5: Kiểm tra alert đã được tạo
-- =====================================================

-- Xem alert mới nhất
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
ORDER BY al.created_at DESC
LIMIT 5;

-- =====================================================
-- HƯỚNG DẪN SỬ DỤNG
-- =====================================================

/*
1. Chạy các query ở Bước 1 để xem dữ liệu hiện có

2. Nếu chưa có dữ liệu:
   - Chạy Bước 2 để tạo khu vực và loại chất thải test
   - Copy ID từ kết quả

3. Uncomment và chạy query ở Bước 3:
   - Thay <area_id> và <waste_type_id> bằng ID thực tế
   - Tạo hạn mức 100kg/ngày

4. Uncomment và chạy query ở Bước 4:
   - Thay <area_id> và <waste_type_id> bằng ID thực tế
   - Nhập 85kg để trigger alert (85% > 80%)

5. Chạy Bước 5 để xem alert đã được tạo

6. Mở app Flutter để xem alert hiển thị
*/

-- =====================================================
-- CÁCH NHANH: Tạo alert trực tiếp (không qua trigger)
-- =====================================================

-- Nếu muốn test nhanh, có thể tạo alert trực tiếp:
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
  '⚠️ CẢNH BÁO: Đã đạt 85% hạn mức'
);
*/

-- Sau đó refresh app để xem alert
