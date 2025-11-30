-- =====================================================
-- UPDATE TRIGGER MESSAGES TO ENGLISH
-- =====================================================
-- This file updates the check_waste_limit() trigger
-- to use English messages instead of Vietnamese

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
      v_body := CASE 
        WHEN v_percent >= 100 THEN 
          format('🔴 LIMIT EXCEEDED: %s at %s has exceeded %.0f%%%% (%.2f/%.2f kg)', 
                 v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
        ELSE 
          format('⚠️ WARNING: %s at %s has reached %.0f%%%% of limit (%.2f/%.2f kg)', 
                 v_waste_type_name, v_area_name, v_percent, v_total, v_limit)
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
            WHEN v_percent >= 100 THEN '🔴 LIMIT EXCEEDED'
            ELSE '⚠️ LIMIT WARNING'
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

-- Recreate trigger
DROP TRIGGER IF EXISTS trigger_check_waste_limit ON waste_entries;
CREATE TRIGGER trigger_check_waste_limit
  AFTER INSERT ON waste_entries
  FOR EACH ROW
  EXECUTE FUNCTION check_waste_limit();

-- Success message
SELECT '✅ Trigger updated to use English messages' as status;
