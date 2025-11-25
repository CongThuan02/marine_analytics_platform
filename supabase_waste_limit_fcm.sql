-- =====================================================
-- THÔNG BÁO FCM KHI VƯỢT HẠN MỨC CHẤT THẢI
-- =====================================================
-- File này cập nhật trigger check_waste_limit() để gửi 
-- thông báo FCM cho TẤT CẢ người dùng khi có người nhập 
-- quá giới hạn chất thải

-- =====================================================
-- Bước 1: Đảm bảo bảng user_fcm_tokens tồn tại
-- =====================================================

CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users_profile(id) ON DELETE CASCADE,
  token text NOT NULL,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_updated_at ON user_fcm_tokens(updated_at);

-- =====================================================
-- Bước 2: Cập nhật Function check_waste_limit()
-- =====================================================

CREATE OR REPLACE FUNCTION check_waste_limit()
RETURNS TRIGGER AS $$
DECLARE
  v_limit numeric;
  v_total numeric;
  v_percent numeric;
  v_area_name text;
  v_waste_type_name text;
  v_alert_id uuid;
  v_tokens text[];
  v_title text;
  v_body text;
  v_edge_function_url text;
  v_service_role_key text;
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

      -- Tạo message
      v_body := CASE 
        WHEN v_percent >= 100 THEN 
          format('🔴 VƯỢT HẠN MỨC: %s tại %s đã vượt %.0f%% (%.2f/%.2f kg)', 
                 v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
        ELSE 
          format('⚠️ CẢNH BÁO: %s tại %s đã đạt %.0f%% hạn mức (%.2f/%.2f kg)', 
                 v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
      END;

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
        v_body
      ) RETURNING id INTO v_alert_id;

      -- =====================================================
      -- GỬI THÔNG BÁO FCM CHO TẤT CẢ NGƯỜI DÙNG
      -- =====================================================
      
      BEGIN
        -- Lấy tất cả FCM tokens (active trong 30 ngày)
        SELECT ARRAY_AGG(token) INTO v_tokens
        FROM user_fcm_tokens
        WHERE updated_at > NOW() - INTERVAL '30 days';

        -- Nếu có tokens
        IF v_tokens IS NOT NULL AND ARRAY_LENGTH(v_tokens, 1) > 0 THEN
          -- Tạo title
          v_title := CASE 
            WHEN v_percent >= 100 THEN '🔴 VƯỢT HẠN MỨC'
            ELSE '⚠️ CẢNH BÁO HẠN MỨC'
          END;

          -- Lấy Edge Function URL và Service Role Key từ vault
          -- Nếu không dùng vault, có thể hardcode tạm (không khuyến khích)
          SELECT decrypted_secret INTO v_edge_function_url
          FROM vault.decrypted_secrets
          WHERE name = 'EDGE_FUNCTION_URL'
          LIMIT 1;

          SELECT decrypted_secret INTO v_service_role_key
          FROM vault.decrypted_secrets
          WHERE name = 'SERVICE_ROLE_KEY'
          LIMIT 1;

          -- Gọi Edge Function để gửi FCM notification
          IF v_edge_function_url IS NOT NULL AND v_service_role_key IS NOT NULL THEN
            PERFORM net.http_post(
              url := v_edge_function_url || '/send-fcm-notification',
              headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', 'Bearer ' || v_service_role_key
              ),
              body := jsonb_build_object(
                'tokens', v_tokens,
                'title', v_title,
                'body', v_body,
                'data', jsonb_build_object(
                  'alert_id', v_alert_id,
                  'area_id', NEW.area_id,
                  'waste_type_id', NEW.waste_type_id,
                  'percent', v_percent,
                  'type', 'waste_limit_alert'
                )
              )
            );
            
            RAISE NOTICE 'FCM notification sent to % users', ARRAY_LENGTH(v_tokens, 1);
          ELSE
            RAISE WARNING 'Edge Function URL or Service Role Key not configured in vault';
          END IF;
        ELSE
          RAISE NOTICE 'No FCM tokens found';
        END IF;

      EXCEPTION
        WHEN OTHERS THEN
          -- Log error nhưng không fail transaction
          RAISE WARNING 'Error sending FCM notification: %', SQLERRM;
      END;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- Bước 3: Tạo lại trigger
-- =====================================================

DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
CREATE TRIGGER trigger_check_waste_limit
  AFTER INSERT OR UPDATE ON waste_entries
  FOR EACH ROW 
  EXECUTE FUNCTION check_waste_limit();

-- =====================================================
-- Bước 4: Enable pg_net extension (nếu chưa có)
-- =====================================================

CREATE EXTENSION IF NOT EXISTS pg_net;

-- =====================================================
-- HƯỚNG DẪN CÀI ĐẶT
-- =====================================================

/*
1. Chạy file SQL này trong Supabase SQL Editor

2. Cấu hình Secrets trong Supabase Dashboard:
   - Vào Settings > Vault
   - Thêm 2 secrets:
     + EDGE_FUNCTION_URL: https://your-project.supabase.co/functions/v1
     + SERVICE_ROLE_KEY: your-service-role-key-from-settings

3. Deploy Edge Function send-fcm-notification:
   cd supabase/functions
   supabase functions deploy send-fcm-notification

4. Cấu hình FCM_SERVER_KEY cho Edge Function:
   supabase secrets set FCM_SERVER_KEY=your-fcm-server-key

5. Trong Flutter app, đảm bảo lưu FCM token khi user login:
   - Xem file lib/core/services/fcm_service.dart
   - Token sẽ được lưu vào bảng user_fcm_tokens

6. Test:
   - Tạo waste_limit cho một khu vực
   - Nhập waste_entry vượt 80% hạn mức
   - Tất cả users sẽ nhận được notification
*/

-- =====================================================
-- TEST QUERIES
-- =====================================================

-- Xem FCM tokens hiện có
SELECT 
  uft.id,
  uft.user_id,
  up.role,
  d.name as department_name,
  uft.token,
  uft.updated_at
FROM user_fcm_tokens uft
JOIN users_profile up ON up.id = uft.user_id
LEFT JOIN departments d ON d.id = up.department_id
ORDER BY uft.updated_at DESC;

-- Xem alerts gần đây
SELECT 
  a.id,
  ar.name as area_name,
  wt.name as waste_type_name,
  a.total_today,
  a.limit_value,
  a.percent,
  a.message,
  a.created_at
FROM alerts a
JOIN areas ar ON ar.id = a.area_id
JOIN waste_types wt ON wt.id = a.waste_type_id
ORDER BY a.created_at DESC
LIMIT 10;

-- Xem waste_limits hiện có
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

-- Test tạo waste_entry vượt hạn mức (thay các ID)
/*
INSERT INTO waste_entries (
  user_id,
  department_id,
  area_id,
  waste_type_id,
  quantity,
  date
) VALUES (
  '<user_id>',
  '<department_id>',
  '<area_id>',
  '<waste_type_id>',
  85.0,  -- Vượt 80% của hạn mức 100
  CURRENT_DATE
);
*/
