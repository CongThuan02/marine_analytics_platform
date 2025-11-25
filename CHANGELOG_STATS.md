# Cập nhật Phần Thống Kê

## Những thay đổi chính

### 1. Biểu đồ trực quan
- **Biểu đồ tròn (Pie Chart)**: Hiển thị tỷ lệ phân bố phần trăm của từng loại chất thải
- **Biểu đồ cột (Bar Chart)**: So sánh trực quan khối lượng giữa các loại chất thải
- Sử dụng màu sắc đa dạng để phân biệt các loại chất thải

### 2. Chuyển đổi đơn vị về kg
Tất cả các đơn vị đã được chuẩn hóa về kilogram (kg):
- **g (gram)** → kg (chia 1000)
- **mg (milligram)** → kg (chia 1,000,000)
- **t/tấn (ton)** → kg (nhân 1000)
- **lb (pound)** → kg (nhân 0.453592)
- **oz (ounce)** → kg (nhân 0.0283495)

### 3. Giao diện cải tiến
- **Summary Cards**: Thiết kế gradient với icon màu sắc nổi bật
- **Breakdown Tiles**: Hiển thị phần trăm, thanh progress bar và khối lượng rõ ràng
- **Responsive**: Tự động điều chỉnh theo kích thước màn hình
- **Shadow effects**: Tạo độ sâu cho các card và biểu đồ

### 4. Tính năng mới
- Tooltip khi hover/tap vào biểu đồ
- Hiển thị phần trăm cho từng loại chất thải
- Sắp xếp theo khối lượng giảm dần
- Pull-to-refresh để cập nhật dữ liệu

## Files đã thay đổi

1. **lib/presentation/views/overviews/widgets/stats_overview_tab.dart**
   - Thêm import `syncfusion_flutter_charts`
   - Thêm widget `_PieChartWidget` và `_BarChartWidget`
   - Cải thiện UI cho `_SummaryCard` và `_BreakdownTile`
   - Thêm hiển thị phần trăm

2. **lib/data/repositories/waste_stats_repository.dart**
   - Thêm hàm `_convertToKg()` để chuyển đổi đơn vị
   - Cập nhật `_buildStats()` để áp dụng chuyển đổi đơn vị
   - Tất cả dữ liệu giờ đều có đơn vị là 'kg'

## Cách sử dụng

Không cần thay đổi gì! Các màn hình thống kê (Ngày/Tháng/Năm) sẽ tự động hiển thị:
- Tổng khối lượng (kg)
- Số lần ghi nhận
- Biểu đồ tròn phân bố
- Biểu đồ cột so sánh
- Chi tiết từng loại chất thải với phần trăm

## Lưu ý
- Đảm bảo package `syncfusion_flutter_charts` đã được cài đặt (đã có trong pubspec.yaml)
- Dữ liệu cũ với đơn vị khác sẽ tự động được chuyển đổi về kg
- Nếu đơn vị không được nhận diện, hệ thống sẽ giả định là kg
