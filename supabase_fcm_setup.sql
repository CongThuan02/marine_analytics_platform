-- =====================================================
-- Bảng lưu FCM tokens của users
-- =====================================================

CREATE TABLE IF NOT EXISTS user_fcm_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid REFERENCES users_profile(id) ON DELETE CASCADE,
  token text NOT NULL,
  updated_at timestamptz DEFAULT now(),
  UNIQUE(user_id, token)
);

-- Index
CREATE INDEX IF NOT EXISTS idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);

-- =====================================================
-- Function: Gửi notification khi tạo alert
-- =====================================================

CREATE OR REPLACE FUNCTION send_alert_notification()
RETURNS TRIGGER AS $$
DECLARE
  v_tokens text[];
  v_title text;
  v_body text;
BEGIN
  -- Tạo title và body cho notification
  IF NEW.percent >= 100 THEN
    v_title := '🔴 VƯỢT HẠN MỨC';
  ELSE
    v_title := '⚠️ CẢNH BÁO HẠN MỨC';
  END IF;
  
  v_body := NEW.message;

  -- Lấy tất cả FCM tokens của users
  SELECT ARRAY_AGG(token) INTO v_tokens
  FROM user_fcm_tokens
  WHERE updated_at > NOW() - INTERVAL '30 days'; -- Chỉ lấy token còn active

  -- Log để debug
  RAISE NOTICE 'Sending notification to % tokens: %', ARRAY_LENGTH(v_tokens, 1), v_title;

  -- Gọi Edge Function để gửi notification
  -- (Cần tạo Edge Function riêng vì Supabase không thể gọi FCM trực tiếp)
  PERFORM net.http_post(
    url := current_setting('app.settings.edge_function_url') || '/send-fcm-notification',
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'Authorization', 'Bearer ' || current_setting('app.settings.service_role_key')
    ),
    body := jsonb_build_object(
      'tokens', v_tokens,
      'title', v_title,
      'body', v_body,
      'data', jsonb_build_object(
        'alert_id', NEW.id,
        'area_id', NEW.area_id,
        'waste_type_id', NEW.waste_type_id,
        'percent', NEW.percent
      )
    )
  );

  RETURN NEW;
EXCEPTION
  WHEN OTHERS THEN
    -- Log error nhưng không fail transaction
    RAISE WARNING 'Error sending notification: %', SQLERRM;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Tạo trigger
DROP TRIGGER IF EXISTS trigger_send_alert_notification ON alerts;
CREATE TRIGGER trigger_send_alert_notification
  AFTER INSERT ON alerts
  FOR EACH ROW
  EXECUTE FUNCTION send_alert_notification();

-- =====================================================
-- Cách sử dụng
-- =====================================================

-- 1. Khi user login, app sẽ tự động lưu FCM token vào bảng user_fcm_tokens
-- 2. Khi có alert mới được tạo, trigger sẽ tự động gửi notification
-- 3. Tất cả users sẽ nhận được notification

-- =====================================================
-- Test
-- =====================================================

-- Xem FCM tokens
SELECT * FROM user_fcm_tokens;

-- Xem alerts
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 5;
