# Test Nhanh Hệ Thống Cảnh Báo

## Tại sao không thấy cảnh báo?

Bạn không thấy cảnh báo vì **chưa có dữ liệu alerts trong database**. Có 2 cách để tạo alerts:

### Cách 1: Test Trong App (Nhanh nhất) ⚡

1. Mở app trên emulator/device
2. Vào trang **Alerts** (Cảnh báo)
3. Click menu 3 chấm ở góc phải → **"Test tạo cảnh báo"**
4. Trong trang test:
   - Nếu chưa có dữ liệu → Click **"Tạo Dữ Liệu Test"**
   - Chọn khu vực và loại chất thải
   - Click **"Tạo Alert Test (85%)"**
5. Quay lại trang Alerts → Sẽ thấy cảnh báo mới

### Cách 2: Qua Supabase SQL Editor

1. Mở **Supabase Dashboard** → **SQL Editor**
2. Chạy file `test_create_alert.sql`
3. Làm theo hướng dẫn trong file:
   - Kiểm tra dữ liệu hiện có
   - Tạo khu vực và loại chất thải (nếu chưa có)
   - Tạo hạn mức
   - Nhập waste_entry để trigger alert
4. Refresh app để xem alert

## Kiểm Tra Hệ Thống FCM

Sau khi có alerts trong database, để test FCM notification:

### 1. Kiểm tra FCM Token đã được lưu

```sql
-- Trong Supabase SQL Editor
SELECT * FROM user_fcm_tokens;
```

Nếu rỗng → FCM token chưa được lưu khi login

### 2. Deploy Trigger SQL

```sql
-- Chạy file: supabase_waste_limit_fcm.sql
-- Trigger này sẽ tự động gửi FCM khi có alert mới
```

### 3. Cấu hình Secrets

Trong Supabase Dashboard → Settings → Vault:
```
EDGE_FUNCTION_URL = https://your-project.supabase.co/functions/v1
SERVICE_ROLE_KEY = your-service-role-key
```

### 4. Deploy Edge Function

```bash
supabase functions deploy send-fcm-notification
supabase secrets set FCM_SERVER_KEY=your-fcm-server-key
```

### 5. Test FCM

Sau khi setup xong:
1. Tạo alert mới (qua app hoặc SQL)
2. Tất cả users sẽ nhận notification trên điện thoại

## Troubleshooting

### Không thấy alerts trong app?

- Kiểm tra database có alerts không:
  ```sql
  SELECT * FROM alerts ORDER BY created_at DESC LIMIT 5;
  ```
- Nếu có alerts nhưng app không hiển thị → Kiểm tra AlertBloc

### FCM token không được lưu?

- Kiểm tra FCMService đã được khởi tạo trong main.dart
- Kiểm tra user đã login chưa
- Xem logs: `I/flutter: FCM token saved to database`

### Không nhận được notification?

1. Kiểm tra trigger đã được deploy:
   ```sql
   SELECT * FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';
   ```

2. Kiểm tra Edge Function:
   ```bash
   supabase functions list
   ```

3. Xem logs:
   ```bash
   supabase functions logs send-fcm-notification
   ```

## Tài Liệu Chi Tiết

- `HUONG_DAN_THONG_BAO_VUOT_HAN_MUC.md` - Hướng dẫn đầy đủ
- `SETUP_FCM_WASTE_LIMIT.md` - Tóm tắt setup
- `test_create_alert.sql` - Script SQL test
