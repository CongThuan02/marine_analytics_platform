-- =====================================================
-- Function: Kiểm tra và tạo cảnh báo tự động
-- =====================================================

-- Function để kiểm tra hạn mức và tạo cảnh báo
CREATE OR REPLACE FUNCTION check_waste_limit()
RETURNS TRIGGER AS $$
DECLARE
  v_limit numeric;
  v_total numeric;
  v_percent numeric;
  v_area_name text;
  v_waste_type_name text;
BEGIN
  -- Lấy hạn mức cho khu vực và loại chất thải này
  SELECT wl.daily_limit, a.name, wt.name
  INTO v_limit, v_area_name, v_waste_type_name
  FROM waste_limits wl
  JOIN areas a ON a.id = wl.area_id
  JOIN waste_types wt ON wt.id = wl.waste_type_id
  WHERE wl.area_id = NEW.area_id 
    AND wl.waste_type_id = NEW.waste_type_id;

  -- Nếu có hạn mức được đặt
  IF v_limit IS NOT NULL THEN
    -- Tính tổng chất thải trong ngày
    SELECT COALESCE(SUM(quantity), 0)
    INTO v_total
    FROM waste_entries
    WHERE area_id = NEW.area_id
      AND waste_type_id = NEW.waste_type_id
      AND date = NEW.date;

    -- Tính phần trăm
    v_percent := (v_total / v_limit) * 100;

    -- Nếu vượt 80%, tạo hoặc cập nhật cảnh báo
    IF v_percent >= 80 THEN
      -- Xóa cảnh báo cũ cho cùng khu vực và loại chất thải trong ngày
      DELETE FROM alerts
      WHERE area_id = NEW.area_id
        AND waste_type_id = NEW.waste_type_id
        AND DATE(created_at) = NEW.date;

      -- Tạo cảnh báo mới
      INSERT INTO alerts (
        area_id, 
        waste_type_id, 
        total_today, 
        limit_value, 
        percent, 
        message
      ) VALUES (
        NEW.area_id,
        NEW.waste_type_id,
        v_total,
        v_limit,
        v_percent,
        CASE 
          WHEN v_percent >= 100 THEN 
            format('🔴 VƯỢT HẠN MỨC: %s tại %s đã vượt %.0f%% (%.2f/%.2f kg)', 
                   v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
          ELSE 
            format('⚠️ CẢNH BÁO: %s tại %s đã đạt %.0f%% hạn mức (%.2f/%.2f kg)', 
                   v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
        END
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tạo trigger để tự động kiểm tra sau khi insert/update waste_entries
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
CREATE TRIGGER trigger_check_waste_limit
  AFTER INSERT OR UPDATE ON waste_entries
  FOR EACH ROW 
  EXECUTE FUNCTION check_waste_limit();

-- =====================================================
-- Function: Kiểm tra hạn mức cho một ngày cụ thể
-- =====================================================

CREATE OR REPLACE FUNCTION check_waste_limits_today(check_date date DEFAULT CURRENT_DATE)
RETURNS TABLE (
  id uuid,
  area_id uuid,
  waste_type_id uuid,
  total_today numeric,
  limit_value numeric,
  percent numeric,
  message text,
  created_at timestamptz,
  area_name text,
  waste_type_name text,
  waste_type_unit text
) AS $$
BEGIN
  -- Xóa cảnh báo cũ cho ngày này
  DELETE FROM alerts WHERE DATE(created_at) = check_date;

  -- Tạo cảnh báo mới cho tất cả các khu vực vượt ngưỡng
  INSERT INTO alerts (area_id, waste_type_id, total_today, limit_value, percent, message)
  SELECT 
    wl.area_id,
    wl.waste_type_id,
    COALESCE(SUM(we.quantity), 0) as total,
    wl.daily_limit,
    (COALESCE(SUM(we.quantity), 0) / wl.daily_limit * 100) as pct,
    CASE 
      WHEN (COALESCE(SUM(we.quantity), 0) / wl.daily_limit * 100) >= 100 THEN 
        format('🔴 VƯỢT HẠN MỨC: %s tại %s đã vượt %.0f%%', 
               wt.name, a.name, (COALESCE(SUM(we.quantity), 0) / wl.daily_limit * 100))
      ELSE 
        format('⚠️ CẢNH BÁO: %s tại %s đã đạt %.0f%% hạn mức', 
               wt.name, a.name, (COALESCE(SUM(we.quantity), 0) / wl.daily_limit * 100))
    END
  FROM waste_limits wl
  JOIN areas a ON a.id = wl.area_id
  JOIN waste_types wt ON wt.id = wl.waste_type_id
  LEFT JOIN waste_entries we ON we.area_id = wl.area_id 
    AND we.waste_type_id = wl.waste_type_id 
    AND we.date = check_date
  GROUP BY wl.area_id, wl.waste_type_id, wl.daily_limit, a.name, wt.name
  HAVING (COALESCE(SUM(we.quantity), 0) / wl.daily_limit * 100) >= 80;

  -- Trả về tất cả cảnh báo của ngày
  RETURN QUERY
  SELECT 
    al.id,
    al.area_id,
    al.waste_type_id,
    al.total_today,
    al.limit_value,
    al.percent,
    al.message,
    al.created_at,
    a.name as area_name,
    wt.name as waste_type_name,
    wt.unit as waste_type_unit
  FROM alerts al
  JOIN areas a ON a.id = al.area_id
  JOIN waste_types wt ON wt.id = al.waste_type_id
  WHERE DATE(al.created_at) = check_date
  ORDER BY al.percent DESC, al.created_at DESC;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Cách sử dụng
-- =====================================================

-- 1. Kiểm tra và tạo cảnh báo cho hôm nay:
-- SELECT * FROM check_waste_limits_today();

-- 2. Kiểm tra cho một ngày cụ thể:
-- SELECT * FROM check_waste_limits_today('2025-11-25');

-- 3. Trigger sẽ tự động chạy khi có waste_entry mới

-- =====================================================
-- Test data (Optional)
-- =====================================================

-- Uncomment để tạo dữ liệu test
/*
-- Tạo khu vực test
INSERT INTO areas (name) VALUES ('Khu vực Test') RETURNING id;

-- Tạo loại chất thải test
INSERT INTO waste_types (name, unit) VALUES ('Rác nhựa Test', 'kg') RETURNING id;

-- Tạo hạn mức test (thay <area_id> và <waste_type_id>)
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
VALUES ('<area_id>', '<waste_type_id>', 100);

-- Tạo waste entry vượt ngưỡng (thay các id)
INSERT INTO waste_entries (area_id, waste_type_id, quantity, date) 
VALUES ('<area_id>', '<waste_type_id>', 85, CURRENT_DATE);

-- Kiểm tra cảnh báo
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 5;
*/
