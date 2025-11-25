# Chức năng Hạn mức và Nhắc nhở

## Tổng quan

Đã thêm 2 chức năng mới vào hệ thống:
1. **Quản lý Hạn mức** - Đặt ngưỡng cảnh báo cho chất thải theo khu vực
2. **Quản lý Nhắc nhở** - Tự động nhắc nhở phòng ban nhập liệu

---

## 1. Quản lý Hạn mức (Waste Limits)

### Mục đích
- Đặt hạn mức chất thải hàng ngày cho từng khu vực
- Theo dõi và cảnh báo khi vượt ngưỡng
- Quản lý tập trung các giới hạn

### Tính năng
- ✅ Xem danh sách tất cả hạn mức
- ✅ Thêm hạn mức mới (khu vực + loại chất thải + giới hạn)
- ✅ Xóa hạn mức
- ✅ Hiển thị thông tin chi tiết (khu vực, loại chất thải, đơn vị)

### Cách sử dụng
1. Vào **Settings** → **Quản lý hạn mức**
2. Nhấn nút **+** để thêm hạn mức mới
3. Chọn:
   - Khu vực
   - Loại chất thải
   - Hạn mức hàng ngày (số)
4. Nhấn **Thêm** để lưu

### Ví dụ
```
Khu vực: Vịnh Hạ Long
Loại chất thải: Rác thải nhựa
Hạn mức: 500 kg/ngày
```

### Files liên quan
```
lib/data/models/waste_limit_model.dart
lib/data/repositories/waste_limit_repository.dart
lib/presentation/blocs/waste_limit/
lib/presentation/views/waste_limit/
  ├── page.dart
  └── widgets/
      ├── limit_card.dart
      └── create_limit_dialog.dart
```

---

## 2. Quản lý Nhắc nhở (Reminders)

### Mục đích
- Tự động nhắc nhở phòng ban nhập dữ liệu
- Đặt lịch nhắc nhở theo giờ và tần suất
- Bật/tắt nhắc nhở linh hoạt

### Tính năng
- ✅ Xem danh sách nhắc nhở
- ✅ Thêm nhắc nhở mới
- ✅ Bật/tắt nhắc nhở bằng switch
- ✅ Xóa nhắc nhở
- ✅ Tùy chỉnh thời gian và tần suất

### Cách sử dụng
1. Vào **Settings** → **Quản lý nhắc nhở**
2. Nhấn nút **+** để thêm nhắc nhở mới
3. Chọn:
   - Phòng ban
   - Thời gian (giờ:phút)
   - Tần suất (Hàng ngày / Hàng tuần)
   - Nội dung nhắc nhở (tùy chọn)
4. Nhấn **Thêm** để lưu
5. Dùng switch để bật/tắt nhắc nhở

### Ví dụ
```
Phòng ban: Phòng Quản lý Môi trường
Thời gian: 09:00
Tần suất: Hàng ngày
Nội dung: "Nhắc nhở: Vui lòng nhập dữ liệu chất thải hôm nay"
```

### Files liên quan
```
lib/data/models/reminder_model.dart
lib/data/repositories/reminder_repository.dart
lib/presentation/blocs/reminder/
lib/presentation/views/reminder/
  ├── page.dart
  └── widgets/
      ├── reminder_card.dart
      └── create_reminder_dialog.dart
```

---

## Cấu trúc Database

### Bảng `waste_limits`
```sql
create table waste_limits (
  id uuid primary key default gen_random_uuid(),
  area_id uuid references areas(id) on delete cascade,
  waste_type_id uuid references waste_types(id) on delete cascade,
  daily_limit numeric not null,
  created_at timestamptz default now()
);
```

### Bảng `reminders`
```sql
create table reminders (
  id uuid primary key default gen_random_uuid(),
  department_id uuid references departments(id) on delete cascade,
  time_of_day time not null,
  frequency text check (frequency in ('daily', 'weekly')),
  message text,
  enabled boolean default true,
  created_at timestamptz default now()
);
```

---

## Kiến trúc Code

### Models
- `WasteLimitModel` - Dữ liệu hạn mức
- `ReminderModel` - Dữ liệu nhắc nhở

### Repositories
- `WasteLimitRepository` - CRUD operations cho hạn mức
- `ReminderRepository` - CRUD operations cho nhắc nhở

### BLoC Pattern
- `WasteLimitBloc` - Quản lý state hạn mức
  - Events: Load, Create, Update, Delete
  - States: Initial, Loading, Loaded, Error

- `ReminderBloc` - Quản lý state nhắc nhở
  - Events: Load, Create, Update, Toggle, Delete
  - States: Initial, Loading, Loaded, Error

### UI Components
- **Pages**: Màn hình chính
- **Widgets**: 
  - Card hiển thị item
  - Dialog thêm mới

---

## Tích hợp với hệ thống

### Routes
Đã thêm vào `app_router.dart`:
```dart
GoRoute(path: '/wasteLimit', name: '/wasteLimit', 
  builder: (context, state) => const WasteLimitPage()),
GoRoute(path: '/reminder', name: '/reminder', 
  builder: (context, state) => const ReminderPage()),
```

### Settings Menu
Đã thêm 2 nút mới trong `SettingsPage`:
- **Quản lý hạn mức**
- **Quản lý nhắc nhở**

---

## Tính năng nâng cao (Tương lai)

### Hạn mức
- [ ] Cảnh báo tự động khi vượt ngưỡng
- [ ] Biểu đồ so sánh thực tế vs hạn mức
- [ ] Hạn mức theo tuần/tháng
- [ ] Export báo cáo vượt hạn mức
- [ ] Push notification khi vượt ngưỡng

### Nhắc nhở
- [ ] Gửi notification thực tế (Firebase Cloud Messaging)
- [ ] Email reminder
- [ ] SMS reminder
- [ ] Lịch sử nhắc nhở đã gửi
- [ ] Tùy chỉnh ngày trong tuần (cho weekly)
- [ ] Snooze reminder

---

## Cách triển khai Notification

### 1. Firebase Cloud Messaging (FCM)
```dart
// Cần thêm package
dependencies:
  firebase_messaging: ^latest

// Setup trong main.dart
await Firebase.initializeApp();
FirebaseMessaging messaging = FirebaseMessaging.instance;

// Request permission
await messaging.requestPermission();

// Get token
String? token = await messaging.getToken();
```

### 2. Supabase Edge Function
Tạo function để gửi notification theo lịch:
```typescript
// supabase/functions/send-reminders/index.ts
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"

serve(async (req) => {
  // Query reminders cần gửi
  // Gửi FCM notification
  // Log lịch sử
})
```

### 3. Cron Job
Setup cron để chạy Edge Function mỗi phút:
```bash
# Supabase Dashboard → Edge Functions → Cron Jobs
# Schedule: */1 * * * * (every minute)
```

---

## Testing

### Test Hạn mức
1. Thêm hạn mức mới
2. Kiểm tra hiển thị đúng thông tin
3. Xóa hạn mức
4. Test với nhiều khu vực khác nhau

### Test Nhắc nhở
1. Thêm nhắc nhở mới
2. Toggle bật/tắt
3. Kiểm tra thời gian hiển thị đúng
4. Xóa nhắc nhở
5. Test với nhiều phòng ban

---

## Troubleshooting

### Lỗi không load được dữ liệu
- Kiểm tra kết nối Supabase
- Xem console log để debug
- Kiểm tra RLS policies trong Supabase

### Lỗi không thêm được
- Kiểm tra validation form
- Đảm bảo đã chọn đủ thông tin
- Kiểm tra foreign key constraints

### Lỗi không xóa được
- Kiểm tra cascade delete trong database
- Xem có dữ liệu liên quan không

---

## Ghi chú quan trọng

1. **Unique Constraint**: Mỗi khu vực chỉ có 1 hạn mức cho 1 loại chất thải
2. **Cascade Delete**: Xóa khu vực/phòng ban sẽ xóa hạn mức/nhắc nhở liên quan
3. **Time Format**: Thời gian lưu dạng HH:mm:ss
4. **Frequency**: Chỉ hỗ trợ 'daily' và 'weekly'
5. **Enabled**: Nhắc nhở có thể tắt mà không cần xóa

---

## Cập nhật lần cuối
25/11/2025
