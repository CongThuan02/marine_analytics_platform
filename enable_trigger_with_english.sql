-- =====================================================
-- ENABLE TRIGGER WITH ENGLISH MESSAGES
-- =====================================================
-- This script:
-- 1. Updates the check_waste_limit() function with English messages
-- 2. Re-enables triggers for both INSERT and UPDATE
-- 3. Verifies the setup

-- =====================================================
-- STEP 1: Update function with English messages
-- =====================================================

CREATE OR REPLACE FUNCTION check_waste_limit()
RETURNS TRIGGER AS $$
DECLARE
  v_limit numeric;
  v_total numeric;
  v_percent numeric;
  v_area_name text;
  v_waste_type_name text;
  v_body text;
  v_alert_id uuid;
  v_tokens text[];
  v_title text;
  v_edge_function_url text;
  v_service_role_key text;
BEGIN
  -- Get limit for this area and waste type
  SELECT wl.daily_limit, a.name, wt.name
  INTO v_limit, v_area_name, v_waste_type_name
  FROM waste_limits wl
  JOIN areas a ON a.id = wl.area_id
  JOIN waste_types wt ON wt.id = wl.waste_type_id
  WHERE wl.area_id = NEW.area_id
    AND wl.waste_type_id = NEW.waste_type_id;

  -- If limit is set
  IF v_limit IS NOT NULL THEN
    -- Calculate total waste for today
    SELECT COALESCE(SUM(quantity), 0)
    INTO v_total
    FROM waste_entries
    WHERE area_id = NEW.area_id
      AND waste_type_id = NEW.waste_type_id
      AND date = NEW.date;

    -- Calculate percentage
    v_percent := (v_total / v_limit) * 100;

    -- If exceeds 80%, create or update alert
    IF v_percent >= 80 THEN
      -- Delete old alert for same area and waste type today
      DELETE FROM alerts
      WHERE area_id = NEW.area_id
        AND waste_type_id = NEW.waste_type_id
        AND DATE(created_at) = NEW.date;

      -- Create message in ENGLISH
      -- Note: In format(), use %I for identifiers, %L for literals, %s for strings
      -- For literal %, we need to escape it differently
      v_body := CASE 
        WHEN v_percent >= 100 THEN 
          v_waste_type_name || ' at ' || v_area_name || 
          ' has exceeded ' || ROUND(v_percent, 0)::text || '% (' || 
          ROUND(v_total, 2)::text || '/' || ROUND(v_limit, 2)::text || ' kg) 🔴'
        ELSE 
          v_waste_type_name || ' at ' || v_area_name || 
          ' has reached ' || ROUND(v_percent, 0)::text || '% of limit (' || 
          ROUND(v_total, 2)::text || '/' || ROUND(v_limit, 2)::text || ' kg) ⚠️'
      END;

      -- Create new alert
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
      -- SEND FCM NOTIFICATION TO ALL USERS
      -- =====================================================
      
      BEGIN
        -- Get all FCM tokens (active in last 30 days)
        SELECT ARRAY_AGG(token) INTO v_tokens
        FROM user_fcm_tokens
        WHERE updated_at > NOW() - INTERVAL '30 days';

        -- If there are tokens
        IF v_tokens IS NOT NULL AND ARRAY_LENGTH(v_tokens, 1) > 0 THEN
          -- Create title in ENGLISH
          v_title := CASE 
            WHEN v_percent >= 100 THEN 'Limit Exceeded 🔴'
            ELSE 'Limit Warning ⚠️'
          END;

          -- Get Edge Function URL and Service Role Key from vault
          SELECT decrypted_secret INTO v_edge_function_url
          FROM vault.decrypted_secrets
          WHERE name = 'EDGE_FUNCTION_URL'
          LIMIT 1;

          SELECT decrypted_secret INTO v_service_role_key
          FROM vault.decrypted_secrets
          WHERE name = 'SERVICE_ROLE_KEY'
          LIMIT 1;

          -- Call Edge Function to send FCM notification
          IF v_edge_function_url IS NOT NULL AND v_service_role_key IS NOT NULL THEN
            PERFORM
              net.http_post(
                url := v_edge_function_url,
                headers := jsonb_build_object(
                  'Content-Type', 'application/json',
                  'Authorization', 'Bearer ' || v_service_role_key
                ),
                body := jsonb_build_object(
                  'tokens', v_tokens,
                  'title', v_title,
                  'body', v_body,
                  'data', jsonb_build_object(
                    'alert_id', v_alert_id::text,
                    'area_id', NEW.area_id::text,
                    'waste_type_id', NEW.waste_type_id::text,
                    'type', 'waste_limit_alert'
                  )
                )
              );
            
            RAISE NOTICE 'FCM notification sent to % users', ARRAY_LENGTH(v_tokens, 1);
          ELSE
            RAISE NOTICE 'Edge Function URL or Service Role Key not configured';
          END IF;
        ELSE
          RAISE NOTICE 'No FCM tokens found';
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE NOTICE 'Error sending FCM notification: %', SQLERRM;
      END;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =====================================================
-- STEP 2: Re-enable triggers for INSERT and UPDATE
-- =====================================================

-- Drop existing triggers if any
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
DROP TRIGGER IF EXISTS trigger_check_waste_limit_on_update ON waste_entries;

-- Create trigger for INSERT
CREATE TRIGGER trigger_check_waste_limit
  AFTER INSERT ON waste_entries
  FOR EACH ROW
  EXECUTE FUNCTION check_waste_limit();

-- Create trigger for UPDATE
CREATE TRIGGER trigger_check_waste_limit_on_update
  AFTER UPDATE ON waste_entries
  FOR EACH ROW
  EXECUTE FUNCTION check_waste_limit();

-- =====================================================
-- STEP 3: Verify setup
-- =====================================================

-- Check triggers
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
SELECT '✅ Triggers re-enabled with English messages!' as status;
SELECT '✅ Both INSERT and UPDATE triggers are active' as info;
