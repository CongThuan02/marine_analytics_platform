# Hướng dẫn Import dữ liệu từ Excel

## Tổng quan
Chức năng import Excel cho phép bạn nhập dữ liệu chất thải hàng loạt từ file Excel thay vì nhập từng bản ghi một cách thủ công.

## Cách sử dụng

### 1. Truy cập chức năng Import
- Vào màn hình **Lịch sử chất thải**
- Nhấn vào biểu tượng **⋮** (ba chấm dọc) ở góc trên bên phải
- Chọn **Import Excel**

### 2. Tải file Excel mẫu
- Trong dialog Import, nhấn **"Tải file Excel mẫu"**
- File mẫu sẽ được tạo và chia sẻ qua ứng dụng khác
- Lưu file mẫu vào thiết bị của bạn

### 3. Chuẩn bị dữ liệu
Mở file Excel mẫu và điền dữ liệu theo các cột:

| Cột | Tên | Bắt buộc | Mô tả |
|-----|-----|----------|-------|
| A | Loại chất thải | ✅ | Tên loại chất thải (VD: Nhựa, Giấy, Kim loại) |
| B | Số lượng | ✅ | Số lượng chất thải (số dương) |
| C | Đơn vị | ❌ | Đơn vị đo (VD: kg, tấn). Mặc định: kg |
| D | Phòng ban | ❌ | Tên phòng ban |
| E | Khu vực | ❌ | Tên khu vực |
| F | Ngày | ❌ | Ngày theo định dạng dd/mm/yyyy. Mặc định: hôm nay |
| G | Mã QR | ❌ | Mã QR (nếu có) |
| H | Ghi chú | ❌ | Ghi chú bổ sung |

**Lưu ý quan trọng:**
- Không xóa dòng header (dòng đầu tiên)
- Các trường bắt buộc phải có giá trị
- Định dạng ngày: dd/mm/yyyy (VD: 15/12/2024)
- Số lượng phải là số dương

### 4. Import dữ liệu
- Nhấn **"Chọn file Excel để import"**
- Chọn file Excel đã chuẩn bị
- Hệ thống sẽ kiểm tra và hiển thị:
  - Tổng số dòng
  - Số dòng hợp lệ
  - Danh sách lỗi (nếu có)
  - Danh sách cảnh báo (nếu có)
  - Preview 5 bản ghi đầu tiên

### 5. Xác nhận Import
- Kiểm tra thông tin preview
- Nếu có lỗi, sửa file Excel và chọn lại
- Nhấn **"Import X bản ghi"** để xác nhận

## Xử lý tự động

### Tạo dữ liệu mới
Hệ thống sẽ tự động tạo mới nếu chưa tồn tại:
- **Loại chất thải**: Tạo mới với tên và đơn vị từ Excel
- **Phòng ban**: Tạo mới với tên từ Excel
- **Khu vực**: Tạo mới với tên từ Excel

### Validation
Hệ thống kiểm tra:
- ✅ Các trường bắt buộc không được trống
- ✅ Số lượng phải lớn hơn 0
- ✅ Định dạng ngày hợp lệ
- ⚠️ Cảnh báo nếu ngày trong tương lai

## Ví dụ dữ liệu mẫu

```
Loại chất thải | Số lượng | Đơn vị | Phòng ban      | Khu vực | Ngày       | Mã QR | Ghi chú
Nhựa          | 10.5     | kg     | Phòng Kỹ thuật | Khu A   | 15/12/2024 | QR001 | Mẫu 1
Giấy          | 5.2      | kg     | Phòng Hành chính| Khu B   | 15/12/2024 | QR002 | Mẫu 2
Kim loại      | 8.0      | kg     | Phòng Sản xuất | Khu C   | 15/12/2024 |       | Mẫu 3
```

## Xử lý lỗi thường gặp

### Lỗi "Loại chất thải không được để trống"
- **Nguyên nhân**: Cột A trống
- **Giải pháp**: Điền tên loại chất thải

### Lỗi "Số lượng phải là số dương hợp lệ"
- **Nguyên nhân**: Cột B trống hoặc không phải số dương
- **Giải pháp**: Điền số dương (VD: 10, 5.5)

### Lỗi "Định dạng ngày không hợp lệ"
- **Nguyên nhân**: Định dạng ngày sai
- **Giải pháp**: Sử dụng định dạng dd/mm/yyyy (VD: 15/12/2024)

### Lỗi "Không thể đọc file"
- **Nguyên nhân**: File Excel bị lỗi hoặc không đúng định dạng
- **Giải pháp**: Kiểm tra file Excel, đảm bảo định dạng .xlsx hoặc .xls

## Tips và Tricks

1. **Sao chép dữ liệu từ nguồn khác**: Có thể copy-paste từ Google Sheets, CSV, hoặc Excel khác
2. **Import từng phần**: Nếu có nhiều dữ liệu, chia thành nhiều file nhỏ để dễ quản lý
3. **Kiểm tra trước khi import**: Luôn xem preview để đảm bảo dữ liệu chính xác
4. **Backup dữ liệu**: Xuất dữ liệu hiện tại trước khi import để phòng trường hợp cần khôi phục

## Hỗ trợ
Nếu gặp vấn đề, vui lòng liên hệ bộ phận hỗ trợ kỹ thuật.