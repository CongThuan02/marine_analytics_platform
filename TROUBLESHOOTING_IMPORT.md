# Khắc phục sự cố Import Excel

## Lỗi "MissingPluginException" hoặc "Method not found"

### Nguyên nhân
Lỗi này xảy ra khi plugin `file_picker` chưa được đăng ký đúng cách trong ứng dụng.

### Cách khắc phục

#### Phương pháp 1: Restart ứng dụng (Khuyến nghị)
1. **Đóng hoàn toàn ứng dụng** (không chỉ minimize)
2. **Mở lại ứng dụng** từ icon
3. **Thử lại chức năng import**

#### Phương pháp 2: Restart thiết bị (Nếu phương pháp 1 không hiệu quả)
1. **Tắt nguồn thiết bị** hoàn toàn
2. **Bật lại thiết bị**
3. **Mở ứng dụng và thử lại**

#### Phương pháp 3: Cài đặt lại ứng dụng (Cuối cùng)
1. **Gỡ cài đặt ứng dụng**
2. **Cài đặt lại từ App Store/Play Store**
3. **Đăng nhập và thử lại**

### Lưu ý quan trọng
- Lỗi này chỉ xảy ra **lần đầu tiên** sau khi cập nhật ứng dụng
- Sau khi khắc phục, chức năng sẽ hoạt động bình thường
- **Không mất dữ liệu** khi restart ứng dụng

### Liên hệ hỗ trợ
Nếu vẫn gặp vấn đề sau khi thử các phương pháp trên, vui lòng liên hệ bộ phận hỗ trợ kỹ thuật.

## Các lỗi khác thường gặp

### "Không thể đọc file"
- **Nguyên nhân**: File Excel bị hỏng hoặc định dạng không đúng
- **Giải pháp**: Kiểm tra file Excel, đảm bảo định dạng .xlsx hoặc .xls

### "Định dạng ngày không hợp lệ"
- **Nguyên nhân**: Định dạng ngày trong Excel không đúng
- **Giải pháp**: Sử dụng định dạng dd/mm/yyyy (VD: 15/12/2024)

### "Số lượng phải là số dương hợp lệ"
- **Nguyên nhân**: Cột số lượng chứa text, số âm, hoặc Excel hiểu nhầm thành ngày tháng
- **Giải pháp**: 
  - Đảm bảo cột số lượng chỉ chứa số dương
  - Trong Excel, chọn cột số lượng → Format Cells → Number (không phải Date)
  - Nếu vẫn lỗi, thử nhập lại số trong Excel và lưu file mới

### "Excel hiểu nhầm số thành ngày tháng"
- **Nguyên nhân**: Excel tự động format số thành ngày (VD: 10 thành 10/01/1900)
- **Giải pháp**:
  1. Mở file Excel
  2. Chọn cột số lượng (cột B)
  3. Chuột phải → Format Cells
  4. Chọn "Number" hoặc "General"
  5. Lưu file và thử import lại