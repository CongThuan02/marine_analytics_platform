# Hướng Dẫn Thiết Lập Thông Báo FCM Khi Vượt Hạn Mức

## Tổng Quan

Hệ thống sẽ tự động gửi thông báo Firebase Cloud Messaging (FCM) cho **TẤT CẢ người dùng** khi có người nhập chất thải vượt quá 80% hạn mức đã đặt.

### Luồng Hoạt Động

```
User nhập waste_entry
    ↓
Trigger check_waste_limit() được kích hoạt
    ↓
Kiểm tra tổng chất thải trong ngày
    ↓
Nếu ≥ 80% hạn mức:
    ├─ Tạo alert trong database
    ├─ Lấy tất cả FCM tokens
    └─ Gọi Edge Function gửi notification
        ↓
    Tất cả users nhận thông báo trên điện thoại
```

---

## Bước 1: Cài Đặt Database

### 1.1. Chạy SQL Script

Mở **Supabase Dashboard** → **SQL Editor** → Chạy file:

```bash
supabase_waste_limit_fcm.sql
```

Script này sẽ:
- Tạo bảng `user_fcm_tokens` (nếu chưa có)
- Cập nhật function `check_waste_limit()` với logic gửi FCM
- Tạo trigger tự động
- Enable extension `pg_net`

### 1.2. Kiểm Tra Cài Đặt

```sql
-- Kiểm tra trigger đã được tạo
SELECT * FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';

-- Kiểm tra function
SELECT proname FROM pg_proc WHERE proname = 'check_waste_limit';

-- Kiểm tra extension
SELECT * FROM pg_extension WHERE extname = 'pg_net';
```

---

## Bước 2: Cấu Hình Supabase Secrets

### 2.1. Lấy Thông Tin Cần Thiết

1. **Edge Function URL**:
   - Format: `https://your-project-id.supabase.co/functions/v1`
   - Tìm trong: Supabase Dashboard → Settings → API

2. **Service Role Key**:
   - Tìm trong: Supabase Dashboard → Settings → API → `service_role` key
   - ⚠️ **Cẩn thận**: Key này có quyền admin, không được public

### 2.2. Thêm Secrets vào Vault

**Cách 1: Qua Dashboard** (Khuyến nghị)

1. Vào **Supabase Dashboard** → **Settings** → **Vault**
2. Click **New Secret**
3. Thêm 2 secrets:

```
Name: EDGE_FUNCTION_URL
Secret: https://your-project-id.supabase.co/functions/v1

Name: SERVICE_ROLE_KEY
Secret: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Cách 2: Qua SQL** (Nếu không có Vault UI)

```sql
-- Thêm secrets
SELECT vault.create_secret('https://your-project-id.supabase.co/functions/v1', 'EDGE_FUNCTION_URL');
SELECT vault.create_secret('your-service-role-key', 'SERVICE_ROLE_KEY');

-- Kiểm tra
SELECT name FROM vault.decrypted_secrets;
```

---

## Bước 3: Deploy Edge Function

### 3.1. Cài Đặt Supabase CLI

```bash
# macOS
brew install supabase/tap/supabase

# Hoặc npm
npm install -g supabase
```

### 3.2. Login và Link Project

```bash
# Login
supabase login

# Link với project
supabase link --project-ref your-project-id
```

### 3.3. Deploy Function

```bash
# Deploy function send-fcm-notification
supabase functions deploy send-fcm-notification

# Kiểm tra deployment
supabase functions list
```

### 3.4. Cấu Hình FCM Server Key

Lấy **FCM Server Key** từ Firebase Console:
1. Vào **Firebase Console** → **Project Settings** → **Cloud Messaging**
2. Copy **Server Key** (hoặc tạo mới nếu chưa có)

```bash
# Set secret cho Edge Function
supabase secrets set FCM_SERVER_KEY=your-fcm-server-key-here

# Kiểm tra
supabase secrets list
```

---

## Bước 4: Cấu Hình Flutter App

### 4.1. Đảm Bảo FCM Service Hoạt Động

File `lib/core/services/fcm_service.dart` đã có sẵn, đảm bảo nó được khởi tạo trong `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Firebase
  await Firebase.initializeApp();
  
  // Khởi tạo FCM Service
  final fcmService = FCMService();
  await fcmService.initialize();
  
  runApp(MyApp());
}
```

### 4.2. Lưu FCM Token Khi Login

Trong file xử lý login (cần tìm và cập nhật):

```dart
// Sau khi login thành công
final user = await supabase.auth.signIn(...);

if (user != null) {
  // Lấy FCM token
  final fcmToken = await FirebaseMessaging.instance.getToken();
  
  if (fcmToken != null) {
    // Lưu vào database
    await supabase.from('user_fcm_tokens').upsert({
      'user_id': user.id,
      'token': fcmToken,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}
```

### 4.3. Xử Lý Notification Khi Nhận

Trong `FCMService`:

```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print('Nhận notification: ${message.notification?.title}');
  
  // Hiển thị local notification
  if (message.notification != null) {
    _showLocalNotification(
      title: message.notification!.title ?? '',
      body: message.notification!.body ?? '',
    );
  }
  
  // Xử lý data
  if (message.data['type'] == 'waste_limit_alert') {
    // Navigate đến trang alerts hoặc refresh data
    _handleWasteLimitAlert(message.data);
  }
});
```

---

## Bước 5: Test Hệ Thống

### 5.1. Chuẩn Bị Dữ Liệu Test

```sql
-- 1. Tạo khu vực test
INSERT INTO areas (name) VALUES ('Khu vực Test') RETURNING id;
-- Giả sử id = 'area-123'

-- 2. Tạo loại chất thải test
INSERT INTO waste_types (name, unit) VALUES ('Rác nhựa Test', 'kg') RETURNING id;
-- Giả sử id = 'waste-456'

-- 3. Tạo hạn mức 100kg/ngày
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) 
VALUES ('area-123', 'waste-456', 100);

-- 4. Kiểm tra FCM tokens
SELECT COUNT(*) FROM user_fcm_tokens WHERE updated_at > NOW() - INTERVAL '30 days';
-- Phải có ít nhất 1 token
```

### 5.2. Test Nhập Liệu Vượt Hạn Mức

```sql
-- Nhập 85kg (vượt 80% của 100kg)
INSERT INTO waste_entries (
  user_id,
  department_id,
  area_id,
  waste_type_id,
  quantity,
  date
) VALUES (
  'your-user-id',
  'your-department-id',
  'area-123',
  'waste-456',
  85.0,
  CURRENT_DATE
);
```

### 5.3. Kiểm Tra Kết Quả

```sql
-- 1. Kiểm tra alert đã được tạo
SELECT * FROM alerts ORDER BY created_at DESC LIMIT 1;

-- 2. Xem logs (nếu có)
-- Trong Supabase Dashboard → Database → Logs

-- 3. Kiểm tra Edge Function logs
-- Trong Supabase Dashboard → Edge Functions → send-fcm-notification → Logs
```

### 5.4. Kiểm Tra Trên Điện Thoại

- Mở app trên điện thoại
- Đảm bảo đã login và có FCM token
- Sau khi chạy SQL insert ở trên
- Điện thoại sẽ nhận notification trong vài giây

---

## Troubleshooting

### Lỗi 1: Không Nhận Được Notification

**Nguyên nhân có thể:**

1. **Không có FCM token trong database**
   ```sql
   SELECT * FROM user_fcm_tokens;
   ```
   → Nếu rỗng: Kiểm tra logic lưu token khi login

2. **Edge Function URL hoặc Service Role Key sai**
   ```sql
   SELECT name FROM vault.decrypted_secrets;
   ```
   → Phải có 2 secrets: `EDGE_FUNCTION_URL` và `SERVICE_ROLE_KEY`

3. **FCM Server Key chưa được set**
   ```bash
   supabase secrets list
   ```
   → Phải có `FCM_SERVER_KEY`

4. **Edge Function chưa được deploy**
   ```bash
   supabase functions list
   ```
   → Phải thấy `send-fcm-notification`

### Lỗi 2: Alert Được Tạo Nhưng Không Gửi Notification

**Kiểm tra logs:**

```sql
-- Xem warnings trong database logs
-- Supabase Dashboard → Database → Logs

-- Tìm message: "Error sending FCM notification"
```

**Kiểm tra Edge Function:**

```bash
# Xem logs của Edge Function
supabase functions logs send-fcm-notification
```

### Lỗi 3: Trigger Không Chạy

```sql
-- Kiểm tra trigger có enabled không
SELECT tgname, tgenabled FROM pg_trigger WHERE tgname = 'trigger_check_waste_limit';

-- Nếu disabled, enable lại
ALTER TABLE waste_entries ENABLE TRIGGER trigger_check_waste_limit;
```

### Lỗi 4: Extension pg_net Không Có

```sql
-- Enable extension
CREATE EXTENSION IF NOT EXISTS pg_net;

-- Kiểm tra
SELECT * FROM pg_extension WHERE extname = 'pg_net';
```

---

## Tùy Chỉnh

### Thay Đổi Ngưỡng Cảnh Báo

Mặc định: 80%. Để thay đổi, sửa trong function:

```sql
-- Thay đổi từ 80% thành 90%
IF v_percent >= 90 THEN
  -- ...
END IF;
```

### Thay Đổi Thời Gian Token Hợp Lệ

Mặc định: 30 ngày. Để thay đổi:

```sql
-- Thay đổi thành 60 ngày
WHERE updated_at > NOW() - INTERVAL '60 days';
```

### Gửi Notification Cho Một Nhóm Cụ Thể

Thay vì gửi cho tất cả, có thể lọc theo role hoặc department:

```sql
-- Chỉ gửi cho admin
SELECT ARRAY_AGG(uft.token) INTO v_tokens
FROM user_fcm_tokens uft
JOIN users_profile up ON up.id = uft.user_id
WHERE up.role = 'admin'
  AND uft.updated_at > NOW() - INTERVAL '30 days';

-- Hoặc gửi cho department cụ thể
SELECT ARRAY_AGG(uft.token) INTO v_tokens
FROM user_fcm_tokens uft
JOIN users_profile up ON up.id = uft.user_id
WHERE up.department_id = NEW.department_id
  AND uft.updated_at > NOW() - INTERVAL '30 days';
```

---

## Monitoring & Maintenance

### Xem Thống Kê Notification

```sql
-- Số lượng alerts theo ngày
SELECT 
  DATE(created_at) as date,
  COUNT(*) as alert_count,
  AVG(percent) as avg_percent
FROM alerts
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Top khu vực có nhiều cảnh báo nhất
SELECT 
  a.name as area_name,
  COUNT(*) as alert_count
FROM alerts al
JOIN areas a ON a.id = al.area_id
WHERE al.created_at >= NOW() - INTERVAL '30 days'
GROUP BY a.name
ORDER BY alert_count DESC;
```

### Dọn Dẹp FCM Tokens Cũ

```sql
-- Xóa tokens không active trong 90 ngày
DELETE FROM user_fcm_tokens
WHERE updated_at < NOW() - INTERVAL '90 days';

-- Hoặc tạo cron job tự động
-- Supabase Dashboard → Database → Cron Jobs
```

### Backup Alerts

```sql
-- Export alerts sang bảng archive
CREATE TABLE IF NOT EXISTS alerts_archive AS
SELECT * FROM alerts WHERE created_at < NOW() - INTERVAL '1 year';

-- Xóa alerts cũ
DELETE FROM alerts WHERE created_at < NOW() - INTERVAL '1 year';
```

---

## Câu Hỏi Thường Gặp

### Q1: Notification có gửi được khi app đang tắt không?

**A:** Có, FCM sẽ gửi notification ngay cả khi app đang tắt. User sẽ thấy notification trong notification tray.

### Q2: Có giới hạn số lượng notification không?

**A:** FCM free tier cho phép unlimited messages. Tuy nhiên, nên tránh spam bằng cách:
- Chỉ gửi khi vượt ngưỡng quan trọng (80%, 100%)
- Không gửi lại nếu đã gửi trong cùng ngày cho cùng alert

### Q3: Làm sao để test notification trên iOS?

**A:** 
1. Cần Apple Developer Account
2. Cấu hình APNs trong Firebase Console
3. Test trên thiết bị thật (không được trên simulator)

### Q4: Token FCM có hết hạn không?

**A:** Có, token có thể hết hạn hoặc thay đổi khi:
- User xóa và cài lại app
- User xóa app data
- Token tự động refresh

→ Nên cập nhật token mỗi lần app khởi động:

```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  // Cập nhật token mới vào database
  supabase.from('user_fcm_tokens').upsert({
    'user_id': currentUserId,
    'token': newToken,
    'updated_at': DateTime.now().toIso8601String(),
  });
});
```

---

## Tài Liệu Tham Khảo

- [Firebase Cloud Messaging](https://firebase.google.com/docs/cloud-messaging)
- [Supabase Edge Functions](https://supabase.com/docs/guides/functions)
- [Supabase Vault](https://supabase.com/docs/guides/database/vault)
- [PostgreSQL Triggers](https://www.postgresql.org/docs/current/sql-createtrigger.html)

---

**Cập nhật lần cuối:** 25/11/2025
**Phiên bản:** 1.0
