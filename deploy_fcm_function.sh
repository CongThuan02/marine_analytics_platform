#!/bin/bash

echo "🚀 DEPLOY FCM EDGE FUNCTION"
echo "================================"
echo ""

echo "📝 Đã sửa Edge Function để hỗ trợ iOS:"
echo "   - Thêm apns payload"
echo "   - Thêm android config"
echo "   - Thêm content-available cho background"
echo ""

echo "🔧 CÁCH DEPLOY:"
echo "================================"
echo ""

echo "Cách 1: Từ Supabase Dashboard (Dễ nhất)"
echo "---"
echo "1. Vào: https://supabase.com/dashboard"
echo "2. Chọn project của bạn"
echo "3. Edge Functions → send-fcm-notification"
echo "4. Click 'Deploy' hoặc 'Update'"
echo "5. Copy nội dung file: supabase/functions/send-fcm-notification/index.ts"
echo "6. Paste vào editor"
echo "7. Click 'Deploy'"
echo ""

echo "Cách 2: Từ Supabase CLI"
echo "---"
echo "# Cài đặt Supabase CLI (nếu chưa có)"
echo "brew install supabase/tap/supabase"
echo ""
echo "# Login"
echo "supabase login"
echo ""
echo "# Link project"
echo "supabase link --project-ref YOUR_PROJECT_REF"
echo ""
echo "# Deploy function"
echo "supabase functions deploy send-fcm-notification"
echo ""

echo "Cách 3: Tạo lại function trong Supabase SQL Editor"
echo "---"
echo "Chạy file: supabase_fcm_setup.sql"
echo ""

echo "================================"
echo "✅ SAU KHI DEPLOY"
echo "================================"
echo ""

echo "1. Test lại notification:"
echo "   - Tạo waste entry vượt hạn mức"
echo "   - Hoặc gọi function trực tiếp từ SQL Editor"
echo ""

echo "2. Kiểm tra logs trong Supabase Dashboard:"
echo "   - Edge Functions → send-fcm-notification → Logs"
echo ""

echo "3. Nếu thành công, iOS sẽ nhận được notification!"
echo ""

echo "📋 TEST NHANH:"
echo "================================"
echo ""
echo "Chạy trong Supabase SQL Editor:"
echo ""
cat << 'EOF'
-- Test gửi notification
SELECT send_fcm_notification(
  'YOUR_FCM_TOKEN_HERE',
  'Test iOS',
  'Test notification với apns payload',
  jsonb_build_object('type', 'test')
);
EOF
echo ""
