# Database Schema - Marine Analytics Platform

## Tổng quan

Hệ thống quản lý chất thải biển với 8 bảng chính, sử dụng PostgreSQL trên Supabase.

## Sơ đồ quan hệ

```
areas (Khu vực)
  ├── departments (Phòng ban)
  │     └── users_profile (Người dùng)
  │           └── waste_entries (Nhập liệu)
  ├── waste_entries (Nhập liệu)
  ├── waste_limits (Hạn mức)
  └── alerts (Cảnh báo)

waste_types (Loại chất thải)
  ├── waste_entries (Nhập liệu)
  ├── waste_limits (Hạn mức)
  └── alerts (Cảnh báo)

reminders (Nhắc nhở)
  └── departments (Phòng ban)
```

---

## 1. Bảng `areas` - Khu vực

Quản lý các khu vực địa lý (vùng biển, cảng, bãi biển...)

### Cấu trúc
```sql
create table areas (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
INSERT INTO areas (name) VALUES 
  ('Vịnh Hạ Long'),
  ('Cảng Hải Phòng'),
  ('Bãi biển Đà Nẵng'),
  ('Vùng biển Nha Trang');
```

### Ghi chú
- Mỗi khu vực có thể có nhiều phòng
- Khi xóa khu vực, các phòng liên quan sẽ có `area_id = null`
- Dùng để phân tích thống kê theo vùng địa lý

---

## 2. Bảng `departments` - Phòng ban

Quản lý các phòng/đơn vị thuộc khu vực

### Cấu trúc
```sql
create table departments (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  area_id uuid references areas(id) on delete set null,
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
INSERT INTO departments (name, area_id) VALUES 
  ('Phòng Quản lý Môi trường', '<area_id>'),
  ('Đội Tuần tra Biển', '<area_id>'),
  ('Trạm Quan trắc', '<area_id>');
```

### Ghi chú
- Một phòng thuộc một khu vực
- Có thể tồn tại phòng không thuộc khu vực nào (`area_id = null`)
- Dùng để phân quyền và theo dõi trách nhiệm

---

## 3. Bảng `waste_types` - Loại chất thải

Danh mục các loại chất thải biển

### Cấu trúc
```sql
create table waste_types (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  unit text not null, -- kg, L, m3, tấn, g...
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
INSERT INTO waste_types (name, unit) VALUES 
  ('Rác thải nhựa', 'kg'),
  ('Dầu tràn', 'L'),
  ('Rác thải sinh hoạt', 'kg'),
  ('Kim loại phế liệu', 'kg'),
  ('Chất thải nguy hại', 'kg'),
  ('Rác thải hữu cơ', 'tấn');
```

### Ghi chú
- **Đơn vị được tự động chuyển đổi về kg** trong hệ thống thống kê
- Hỗ trợ các đơn vị: `kg`, `g`, `mg`, `tấn`, `t`, `lb`, `oz`
- Đơn vị thể tích (`L`, `m3`) cần quy đổi thủ công nếu cần

### Quy đổi đơn vị tự động
```dart
// Trong waste_stats_repository.dart
kg → kg (x1)
g → kg (÷1000)
mg → kg (÷1,000,000)
tấn/t → kg (×1000)
lb → kg (×0.453592)
oz → kg (×0.0283495)
```

---

## 4. Bảng `users_profile` - Hồ sơ người dùng

Mở rộng thông tin từ Supabase Auth

### Cấu trúc
```sql
create table users_profile (
  id uuid primary key, -- Map với supabase.auth.users.id
  department_id uuid references departments(id) on delete set null,
  role text check (role in ('admin', 'staff', 'viewer')) default 'staff',
  created_at timestamptz default now()
);
```

### Vai trò (Roles)
- **admin**: Quản trị viên - toàn quyền
- **staff**: Nhân viên - nhập liệu và xem báo cáo
- **viewer**: Người xem - chỉ xem báo cáo

### Trigger tự động tạo profile
```sql
-- Tự động tạo profile khi user đăng ký
create or replace function public.handle_new_user()
returns trigger as $$
begin
  insert into public.users_profile (id, role)
  values (new.id, 'staff');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();
```

### Ghi chú
- `id` phải khớp với `auth.users.id` của Supabase
- Mỗi user thuộc một phòng
- Dùng để phân quyền và audit trail

---

## 5. Bảng `waste_entries` - Nhập liệu chất thải

Ghi nhận các lần thu gom/phát hiện chất thải

### Cấu trúc
```sql
create table waste_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references users_profile(id) on delete set null,
  department_id uuid references departments(id) on delete set null,
  area_id uuid references areas(id) on delete set null,
  waste_type_id uuid references waste_types(id) on delete set null,
  quantity numeric not null,
  date date not null,
  qr_code text,
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
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
  150.5,
  '2025-11-25'
);
```

### Indexes quan trọng
```sql
-- Tăng tốc truy vấn thống kê
create index idx_waste_entries_date on waste_entries(date);
create index idx_waste_entries_area on waste_entries(area_id);
create index idx_waste_entries_waste_type on waste_entries(waste_type_id);
create index idx_waste_entries_date_area on waste_entries(date, area_id);
```

### Ghi chú
- `quantity` lưu theo đơn vị của `waste_type`
- `qr_code` dùng để tracking túi rác/container
- Dữ liệu này được dùng cho thống kê theo ngày/tháng/năm

---

## 6. Bảng `waste_limits` - Hạn mức chất thải

Thiết lập ngưỡng cảnh báo cho từng khu vực

### Cấu trúc
```sql
create table waste_limits (
  id uuid primary key default gen_random_uuid(),
  area_id uuid references areas(id) on delete cascade,
  waste_type_id uuid references waste_types(id) on delete cascade,
  daily_limit numeric not null,
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
INSERT INTO waste_limits (area_id, waste_type_id, daily_limit) VALUES 
  ('<area_id>', '<plastic_waste_id>', 500.0),  -- 500kg nhựa/ngày
  ('<area_id>', '<oil_spill_id>', 100.0);      -- 100L dầu/ngày
```

### Unique constraint
```sql
-- Mỗi khu vực chỉ có 1 hạn mức cho 1 loại chất thải
alter table waste_limits 
  add constraint unique_area_waste_type 
  unique (area_id, waste_type_id);
```

### Ghi chú
- `daily_limit` tính theo đơn vị của `waste_type`
- Khi xóa khu vực hoặc loại chất thải, hạn mức cũng bị xóa
- Dùng để trigger cảnh báo tự động

---

## 7. Bảng `alerts` - Cảnh báo vượt mức

Lưu lịch sử các lần vượt ngưỡng

### Cấu trúc
```sql
create table alerts (
  id uuid primary key default gen_random_uuid(),
  area_id uuid references areas(id),
  waste_type_id uuid references waste_types(id),
  total_today numeric not null,
  limit_value numeric not null,
  percent numeric not null,
  message text,
  created_at timestamptz default now()
);
```

### Ví dụ dữ liệu
```sql
INSERT INTO alerts (
  area_id, 
  waste_type_id, 
  total_today, 
  limit_value, 
  percent, 
  message
) VALUES (
  '<area_id>',
  '<waste_type_id>',
  650.0,
  500.0,
  130.0,
  'Cảnh báo: Rác thải nhựa vượt 30% hạn mức tại Vịnh Hạ Long'
);
```

### Function tự động tạo cảnh báo
```sql
create or replace function check_waste_limit()
returns trigger as $$
declare
  v_limit numeric;
  v_total numeric;
  v_percent numeric;
begin
  -- Lấy hạn mức
  select daily_limit into v_limit
  from waste_limits
  where area_id = new.area_id 
    and waste_type_id = new.waste_type_id;

  if v_limit is not null then
    -- Tính tổng trong ngày
    select coalesce(sum(quantity), 0) into v_total
    from waste_entries
    where area_id = new.area_id
      and waste_type_id = new.waste_type_id
      and date = new.date;

    v_percent := (v_total / v_limit) * 100;

    -- Nếu vượt 80%, tạo cảnh báo
    if v_percent >= 80 then
      insert into alerts (
        area_id, 
        waste_type_id, 
        total_today, 
        limit_value, 
        percent, 
        message
      ) values (
        new.area_id,
        new.waste_type_id,
        v_total,
        v_limit,
        v_percent,
        format('Cảnh báo: Đã đạt %.0f%% hạn mức', v_percent)
      );
    end if;
  end if;

  return new;
end;
$$ language plpgsql;

create trigger trigger_check_waste_limit
  after insert or update on waste_entries
  for each row execute function check_waste_limit();
```

### Ghi chú
- Tự động tạo khi vượt 80% hạn mức
- `percent` = (total_today / limit_value) × 100
- Có thể gửi notification qua email/push

---

## 8. Bảng `reminders` - Nhắc nhở nhập liệu

Cấu hình nhắc nhở cho phòng

### Cấu trúc
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

### Ví dụ dữ liệu
```sql
INSERT INTO reminders (
  department_id, 
  time_of_day, 
  frequency, 
  message, 
  enabled
) VALUES (
  '<department_id>',
  '09:00:00',
  'daily',
  'Nhắc nhở: Vui lòng nhập dữ liệu chất thải hôm nay',
  true
);
```

### Ghi chú
- `time_of_day`: Giờ gửi nhắc nhở (HH:MM:SS)
- `frequency`: 
  - `daily` - Mỗi ngày
  - `weekly` - Mỗi tuần (thứ 2)
- Cần cron job hoặc Supabase Edge Function để gửi

---

## Queries thường dùng

### 1. Thống kê theo ngày
```sql
select 
  wt.name as waste_type,
  wt.unit,
  sum(we.quantity) as total_quantity,
  count(*) as entry_count
from waste_entries we
join waste_types wt on we.waste_type_id = wt.id
where we.date = current_date
group by wt.id, wt.name, wt.unit
order by total_quantity desc;
```

### 2. Thống kê theo tháng
```sql
select 
  wt.name as waste_type,
  wt.unit,
  sum(we.quantity) as total_quantity,
  count(*) as entry_count
from waste_entries we
join waste_types wt on we.waste_type_id = wt.id
where date_trunc('month', we.date) = date_trunc('month', current_date)
group by wt.id, wt.name, wt.unit
order by total_quantity desc;
```

### 3. Thống kê theo năm
```sql
select 
  wt.name as waste_type,
  wt.unit,
  sum(we.quantity) as total_quantity,
  count(*) as entry_count
from waste_entries we
join waste_types wt on we.waste_type_id = wt.id
where date_trunc('year', we.date) = date_trunc('year', current_date)
group by wt.id, wt.name, wt.unit
order by total_quantity desc;
```

### 4. Top khu vực có nhiều chất thải nhất
```sql
select 
  a.name as area_name,
  sum(we.quantity) as total_waste,
  count(*) as entry_count
from waste_entries we
join areas a on we.area_id = a.id
where we.date >= current_date - interval '30 days'
group by a.id, a.name
order by total_waste desc
limit 10;
```

### 5. Kiểm tra khu vực vượt hạn mức
```sql
select 
  a.name as area_name,
  wt.name as waste_type,
  sum(we.quantity) as total_today,
  wl.daily_limit,
  round((sum(we.quantity) / wl.daily_limit * 100)::numeric, 2) as percent
from waste_entries we
join areas a on we.area_id = a.id
join waste_types wt on we.waste_type_id = wt.id
join waste_limits wl on wl.area_id = we.area_id 
  and wl.waste_type_id = we.waste_type_id
where we.date = current_date
group by a.name, wt.name, wl.daily_limit
having sum(we.quantity) > wl.daily_limit
order by percent desc;
```

### 6. Lịch sử nhập liệu của user
```sql
select 
  we.date,
  a.name as area_name,
  d.name as department_name,
  wt.name as waste_type,
  we.quantity,
  wt.unit,
  we.created_at
from waste_entries we
join areas a on we.area_id = a.id
join departments d on we.department_id = d.id
join waste_types wt on we.waste_type_id = wt.id
where we.user_id = '<user_id>'
order by we.date desc, we.created_at desc
limit 50;
```

---

## Row Level Security (RLS)

### Enable RLS cho tất cả bảng
```sql
alter table areas enable row level security;
alter table departments enable row level security;
alter table waste_types enable row level security;
alter table users_profile enable row level security;
alter table waste_entries enable row level security;
alter table waste_limits enable row level security;
alter table alerts enable row level security;
alter table reminders enable row level security;
```

### Policies mẫu

#### 1. Users có thể xem profile của mình
```sql
create policy "Users can view own profile"
  on users_profile for select
  using (auth.uid() = id);
```

#### 2. Admin có thể làm mọi thứ
```sql
create policy "Admins can do everything"
  on waste_entries for all
  using (
    exists (
      select 1 from users_profile
      where id = auth.uid() and role = 'admin'
    )
  );
```

#### 3. Staff chỉ xem dữ liệu phòng mình
```sql
create policy "Staff can view own department data"
  on waste_entries for select
  using (
    department_id in (
      select department_id from users_profile
      where id = auth.uid()
    )
  );
```

#### 4. Viewer chỉ được xem
```sql
create policy "Viewers can only read"
  on waste_entries for select
  using (
    exists (
      select 1 from users_profile
      where id = auth.uid() and role in ('viewer', 'staff', 'admin')
    )
  );
```

---

## Backup & Maintenance

### Backup định kỳ
```bash
# Backup toàn bộ database
pg_dump -h <host> -U <user> -d <database> > backup_$(date +%Y%m%d).sql

# Backup chỉ schema
pg_dump -h <host> -U <user> -d <database> --schema-only > schema.sql

# Backup chỉ data
pg_dump -h <host> -U <user> -d <database> --data-only > data.sql
```

### Vacuum & Analyze
```sql
-- Dọn dẹp và tối ưu
vacuum analyze waste_entries;
vacuum analyze alerts;

-- Xem thống kê bảng
select 
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) as size
from pg_tables
where schemaname = 'public'
order by pg_total_relation_size(schemaname||'.'||tablename) desc;
```

---

## Migration Scripts

### Thêm cột mới
```sql
-- Thêm cột description vào waste_types
alter table waste_types add column description text;

-- Thêm cột image_url vào waste_entries
alter table waste_entries add column image_url text;
```

### Thêm index
```sql
-- Index cho tìm kiếm full-text
create index idx_waste_types_name_trgm 
  on waste_types using gin(name gin_trgm_ops);

-- Index cho range query
create index idx_waste_entries_date_range 
  on waste_entries using brin(date);
```

---

## Lưu ý quan trọng

### 1. Đơn vị đo lường
- Tất cả đơn vị khối lượng được tự động chuyển về **kg** trong thống kê
- Đơn vị thể tích (L, m3) cần xử lý riêng nếu cần quy đổi

### 2. Timezone
- Tất cả `timestamptz` lưu theo UTC
- Client cần convert sang timezone địa phương

### 3. Soft Delete
- Hiện tại dùng `on delete set null` hoặc `on delete cascade`
- Có thể thêm cột `deleted_at` nếu cần soft delete

### 4. Performance
- Thêm index cho các cột thường query
- Partition bảng `waste_entries` theo tháng nếu data lớn
- Sử dụng materialized view cho báo cáo phức tạp

### 5. Security
- Luôn enable RLS
- Không expose API key trong code
- Sử dụng service role key chỉ ở backend

---

## Liên hệ & Hỗ trợ

- **Database**: PostgreSQL 15+ trên Supabase
- **ORM**: Supabase Client (Dart)
- **Migration**: Supabase CLI hoặc SQL Editor

**Cập nhật lần cuối**: 25/11/2025
