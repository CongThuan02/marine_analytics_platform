# Setup Thông Báo FCM Khi Vượt Hạn Mức - Tóm Tắt

## Đã Hoàn Thành

### 1. File SQL
- ✅ `supabase_waste_limit_fcm.sql` - Trigger tự động gửi FCM khi vượt 80% hạn mức

### 2. Edge Function
- ✅ `supabase/functions/send-fcm-notification/index.ts` - Đã có sẵn

### 3. Flutter Service
- ✅ `lib/core/services/fcm_service.dart` - Đã tự động lưu FCM token

### 4. Dependencies
- ✅ Đã fix conflict và cập nhật:
  - `firebase_messaging: ^16.0.4`
  - Xóa `firebase_storage` và `cloud_firestore` (không dùng)

## Các Bước Tiếp Theo

### 1. Deploy SQL (5 phút)
```sql
-- Chạy trong Supabase SQL Editor
-- File: supabase_waste_limit_fcm.sql
```

### 2. Cấu hình Secrets (5 phút)
Trong Supabase Dashboard → Settings → Vault:
```
EDGE_FUNCTION_URL = https://your-project.supabase.co/functions/v1
SERVICE_ROLE_KEY = your-service-role-key
```

### 3. Deploy Edge Function (2 phút)
```bash
supabase functions deploy send-fcm-notification
supabase secrets set FCM_SERVER_KEY=your-fcm-server-key
```

### 4. Test
```sql
-- Tạo waste_entry vượt 80% hạn mức
-- Tất cả users sẽ nhận notification
```

## Tài Liệu Chi Tiết

Xem file: `HUONG_DAN_THONG_BAO_VUOT_HAN_MUC.md`
