# Hệ thống quản lý chất thải – Database Documentation

## 1. Bảng `areas` – Khu vực
- Lưu thông tin các khu vực phát sinh chất thải (ví dụ: “Bến tàu A”, “Nhà máy B”).
- Là bảng gốc, nhiều bảng khác tham chiếu.
- `created_at`: thời gian tạo khu vực.

## 2. Bảng `departments` – Phòng ban
- Lưu các phòng ban trong công ty/nhà máy.
- Mỗi phòng ban thuộc **1 khu vực** (`area_id`).
- Dùng để phân quyền và thống kê chất thải theo phòng ban.
- `on delete set null` → nếu khu vực bị xóa, phòng ban vẫn tồn tại.

## 3. Bảng `waste_types` – Loại chất thải
- Lưu các loại chất thải: rắn, lỏng, nguy hại…
- `unit` xác định đơn vị đo (kg, L, m³…).
- Phục vụ phân loại, tính toán, báo cáo.

## 4. Bảng `users_profile` – Người dùng
- Lưu thông tin người dùng trong hệ thống, liên kết với Supabase Auth.
- `department_id` xác định phòng ban của người dùng.
- `role` xác định quyền hạn:
    - `admin` → quản lý toàn bộ hệ thống
    - `staff` → nhập liệu
    - `viewer` → chỉ xem báo cáo

## 5. Bảng `waste_entries` – Nhập liệu chất thải
- Lưu từng lần phát sinh chất thải.
- Thông tin gồm: người nhập (`user_id`), phòng ban, khu vực, loại chất thải, số lượng, ngày, QR code (nếu có).
- Dùng để thống kê và xuất báo cáo.

## 6. Bảng `waste_limits` – Hạn mức chất thải
- Lưu hạn mức tối đa chất thải theo khu vực + loại chất thải mỗi ngày.
- Dùng để cảnh báo khi vượt hạn mức.
- `on delete cascade` → nếu khu vực hoặc loại chất thải bị xóa, hạn mức cũng xóa theo.

## 7. Bảng `alerts` – Cảnh báo
- Lưu cảnh báo khi chất thải vượt hoặc gần vượt hạn mức.
- Thông tin gồm: tổng chất thải hôm nay, hạn mức, phần trăm sử dụng, nội dung cảnh báo.
- Dùng để gửi thông báo cho người dùng.

## 8. Bảng `reminders` – Nhắc nhở nhập liệu
- Lưu lịch nhắc nhở nhập dữ liệu chất thải cho phòng ban.
- Thông tin gồm: phòng ban, thời gian trong ngày, tần suất (`daily` / `weekly`), nội dung nhắc nhở, trạng thái bật/tắt.

---

## Tóm tắt nhanh các bảng

| Bảng | Công dụng |
|------|-----------|
| `areas` | Lưu khu vực phát sinh chất thải |
| `departments` | Lưu phòng ban, liên kết khu vực |
| `waste_types` | Lưu loại chất thải và đơn vị đo |
| `users_profile` | Lưu người dùng, quyền hạn, phòng ban |
| `waste_entries` | Lưu các lần phát sinh chất thải |
| `waste_limits` | Lưu hạn mức chất thải theo khu vực/loại/ngày |
| `alerts` | Lưu cảnh báo vượt hạn mức |
| `reminders` | Lưu lịch nhắc nhở nhập liệu |