# Hướng dẫn chuẩn bị file Excel để Import

## ⚠️ Vấn đề thường gặp
**Excel hiểu nhầm số thành ngày tháng** - Đây là vấn đề phổ biến khi Excel tự động format cột số lượng thành ngày.

## 🔧 Cách khắc phục

### Phương pháp 1: Sử dụng file mẫu từ ứng dụng (Khuyến nghị)
1. Trong ứng dụng, chọn **"Tải file Excel mẫu"**
2. File mẫu đã được format đúng định dạng
3. Điền dữ liệu vào file mẫu này
4. Lưu và import

### Phương pháp 2: Tự tạo file Excel
1. **Tạo file Excel mới**
2. **Nhập header** (dòng đầu tiên):
   ```
   A1: Loại chất thải
   B1: Số lượng  
   C1: Đơn vị
   D1: Phòng ban
   E1: Khu vực
   F1: Ngày (dd/mm/yyyy)
   G1: Mã QR (tùy chọn)
   H1: Ghi chú (tùy chọn)
   ```

3. **Format cột số lượng (cột B)**:
   - Chọn toàn bộ cột B
   - Chuột phải → **Format Cells**
   - Chọn **"Number"** hoặc **"General"**
   - Đặt số chữ số thập phân: 1-2
   - Nhấn **OK**

4. **Nhập dữ liệu**:
   - Cột A: Tên loại chất thải (VD: Nhựa, Giấy, Kim loại)
   - Cột B: **Chỉ nhập số** (VD: 10.5, 5.2, 8.0)
   - Các cột khác: Nhập bình thường

### Phương pháp 3: Sửa file Excel bị lỗi
Nếu file Excel đã hiểu nhầm số thành ngày:

1. **Mở file Excel**
2. **Chọn cột số lượng** (cột B)
3. **Chuột phải → Format Cells**
4. **Chọn "Number"** (không phải Date)
5. **Nhập lại các số** trong cột B
6. **Lưu file**

## ✅ Kiểm tra trước khi Import

### Cột số lượng phải:
- ✅ Chứa **chỉ số** (VD: 10, 10.5, 5.2)
- ✅ **Không có text** (VD: "10 kg" → sai, "10.5" → đúng)
- ✅ **Không có ngày tháng** (VD: 10/01/1900 → sai)
- ✅ **Số dương** (> 0)

### Các cột khác:
- ✅ **Loại chất thải**: Không được trống
- ✅ **Ngày**: Định dạng dd/mm/yyyy (VD: 15/12/2024)
- ✅ **Đơn vị**: Có thể để trống (mặc định: kg)

## 🚨 Dấu hiệu file Excel bị lỗi

### Trong Excel:
- Cột số lượng hiển thị như: `10-Jan-00`, `05-Feb-00`
- Khi click vào cell, thanh công thức hiển thị ngày thay vì số

### Trong ứng dụng:
- Lỗi: "Số lượng phải là số dương hợp lệ"
- Debug log hiển thị: `DateCellValue`

## 💡 Mẹo hay

1. **Luôn dùng file mẫu** từ ứng dụng để tránh lỗi format
2. **Nhập số trực tiếp** vào Excel, không copy-paste từ nguồn khác
3. **Kiểm tra preview** trong ứng dụng trước khi import
4. **Lưu file .xlsx** (không phải .xls cũ)

## 📞 Hỗ trợ
Nếu vẫn gặp vấn đề, vui lòng liên hệ bộ phận hỗ trợ kỹ thuật với thông tin:
- File Excel gốc
- Screenshot lỗi trong ứng dụng
- Phiên bản Excel đang sử dụng