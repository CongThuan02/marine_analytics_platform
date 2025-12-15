# Feature: Biểu đồ cột chồng so sánh loại rác thải

## Tổng quan
Thêm biểu đồ cột chồng (stacked bar chart) vào tab "Xu hướng" để so sánh số lượng của các loại rác thải qua các tháng/năm, giống như biểu đồ đường xu hướng.

## Các file đã tạo/sửa đổi

### 1. File mới: `lib/presentation/views/overviews/widgets/stacked_waste_bar_chart.dart`
Widget biểu đồ cột chồng sử dụng Syncfusion Charts để hiển thị:
- Biểu đồ cột chồng với màu sắc khác nhau cho mỗi loại rác
- Hiển thị dữ liệu qua nhiều kỳ (12 tháng hoặc 5 năm)
- Tooltip hiển thị kỳ, tên loại rác và số lượng
- Legend phía dưới để phân biệt các loại rác
- Xử lý trường hợp không có dữ liệu

**Tính năng:**
- Sử dụng `SfCartesianChart` với `StackedColumnSeries`
- Tự động gán màu cho mỗi loại rác (15 màu khác nhau)
- Mỗi cột đại diện cho 1 kỳ (tháng/năm)
- Các loại rác chồng lên nhau trong cùng 1 cột
- Xoay label trục X -45° để dễ đọc
- Responsive height: 400px

### 2. Cập nhật: `lib/data/repositories/waste_stats_repository.dart`
Thêm method mới:
```dart
Future<StackedWasteData> fetchStackedWasteTypeData({
  required TrendPeriod trendPeriod,
  required DateTime endDate,
  int periodsCount = 12,
})
```

Thêm các class mới:
```dart
class StackedWasteData {
  final List<String> periods;
  final List<WasteTypeSeries> series;
}

class WasteTypeSeries {
  final String name;
  final List<double> data;
}
```

**Chức năng:**
- Lấy dữ liệu thống kê qua nhiều kỳ (12 tháng hoặc 5 năm)
- Tổ chức dữ liệu theo loại rác, mỗi loại có array số lượng theo từng kỳ
- Tự động điền 0 cho các kỳ không có dữ liệu
- Xử lý unit null (mặc định 'kg')

### 3. Cập nhật: `lib/presentation/views/overviews/widgets/trend_comparison_tab.dart`
Thêm biểu đồ cột chồng vào tab xu hướng:
- Import `stacked_waste_bar_chart.dart`
- Thêm state `_stackedWasteData`
- Load dữ liệu stacked trong `_loadTrendData()`
- Hiển thị biểu đồ giữa trend chart và statistics table

**Vị trí hiển thị:**
```
1. Period selector (Hàng tháng/Hàng năm)
2. Summary cards (Tổng, Trung bình, Cao nhất, Thấp nhất)
3. Trend line chart (Xu hướng tổng theo thời gian)
4. ✨ Stacked bar chart (MỚI - So sánh từng loại rác qua các kỳ)
5. Statistics table (Bảng thống kê chi tiết)
```

## Cách sử dụng

### Xem biểu đồ
1. Mở app → Tab "Tổng quan" → Tab "Xu hướng"
2. Chọn kỳ: "Hàng tháng" hoặc "Hàng năm"
3. Biểu đồ cột chồng hiển thị so sánh các loại rác thải qua các kỳ:
   - **Hàng tháng**: 12 tháng gần nhất
   - **Hàng năm**: 5 năm gần nhất

### Tương tác
- **Tap vào cột**: Hiển thị tooltip với kỳ, loại rác và số lượng chính xác
- **Pull to refresh**: Kéo xuống để tải lại dữ liệu
- **Legend**: Click vào legend để ẩn/hiện loại rác cụ thể

### Đọc biểu đồ
- Mỗi cột = 1 kỳ (tháng/năm)
- Các màu khác nhau = các loại rác khác nhau
- Chiều cao mỗi phần = số lượng loại rác đó trong kỳ
- Tổng chiều cao cột = tổng rác thải trong kỳ

## Màu sắc

Biểu đồ sử dụng 15 màu khác nhau theo thứ tự:
1. 🟢 Primary Green (AppTheme.primaryGreen)
2. 🔵 Secondary Teal (AppTheme.secondaryTeal)
3. 🟠 Orange
4. 🔵 Blue
5. 🟣 Purple
6. 🩷 Pink
7. 🟡 Amber
8. 🔷 Cyan
9. 🟦 Indigo
10. 🟢 Lime
11. 🔷 Teal
12. 🟠 Deep Orange
13. 🔵 Light Blue
14. 🟣 Deep Purple
15. 🟢 Light Green

Nếu có > 15 loại rác, màu sẽ lặp lại từ đầu.

## Ví dụ dữ liệu

```dart
StackedWasteData(
  periods: ['01/2024', '02/2024', '03/2024'],
  series: [
    WasteTypeSeries(name: 'Nhựa', data: [150.5, 120.0, 180.3]),
    WasteTypeSeries(name: 'Giấy', data: [89.2, 95.5, 78.0]),
    WasteTypeSeries(name: 'Kim loại', data: [45.0, 50.2, 42.8]),
  ],
)
```

Hiển thị:
- **Cột 1 (01/2024)**: Tổng 284.7 kg
  - Nhựa: 150.5 kg (màu xanh lá)
  - Giấy: 89.2 kg (màu xanh dương)
  - Kim loại: 45.0 kg (màu cam)
- **Cột 2 (02/2024)**: Tổng 265.7 kg
  - Nhựa: 120.0 kg
  - Giấy: 95.5 kg
  - Kim loại: 50.2 kg
- **Cột 3 (03/2024)**: Tổng 301.1 kg
  - Nhựa: 180.3 kg
  - Giấy: 78.0 kg
  - Kim loại: 42.8 kg

## Format số

Syncfusion tự động format số trong tooltip và trục Y:
- Hiển thị số thập phân khi cần
- Tự động scale cho số lớn
- Tooltip format: "Kỳ - Loại rác: Số lượng kg"

## Xử lý edge cases

### Không có dữ liệu
Hiển thị card với icon và text "Không có dữ liệu"

### 1 loại rác
Hiển thị cột đơn sắc qua các kỳ

### Nhiều loại rác (> 15)
- Màu sắc lặp lại từ đầu
- Legend có thể wrap xuống dòng
- Có thể scroll legend nếu quá nhiều

### Một số kỳ không có dữ liệu
- Hiển thị giá trị 0 cho kỳ đó
- Cột vẫn hiển thị nhưng không có phần của loại rác đó

### Tên kỳ dài
- Label xoay -45° để tránh chồng lấn
- Font size nhỏ (10px) để vừa

## Dependencies

Sử dụng package có sẵn:
- ✅ `syncfusion_flutter_charts: ^31.2.12` (đã có trong pubspec.yaml)

Không cần thêm dependency mới!

## Testing

### Test thủ công
1. **Có dữ liệu đầy đủ**: Tạo waste entries với nhiều loại rác qua nhiều tháng
2. **Không có dữ liệu**: Xóa hết entries trong 12 tháng gần nhất
3. **1 loại rác**: Chỉ tạo 1 loại qua nhiều tháng
4. **Nhiều loại rác**: Tạo > 15 loại để test màu sắc
5. **Dữ liệu không đều**: Một số tháng có, một số tháng không
6. **Switch period**: Chuyển đổi giữa "Hàng tháng" (12 tháng) và "Hàng năm" (5 năm)
7. **Pull to refresh**: Kéo xuống để reload
8. **Legend interaction**: Click vào legend để ẩn/hiện loại rác

### Expected behavior
- Biểu đồ load cùng lúc với trend chart
- Màu sắc nhất quán giữa các lần load
- Tooltip hiển thị đúng kỳ, loại rác và số lượng
- Legend khớp với biểu đồ
- Cột chồng đúng thứ tự
- Tổng chiều cao cột = tổng trong trend chart
- Responsive trên các kích thước màn hình

## Lưu ý

1. **Performance**: Biểu đồ load dữ liệu 12 tháng (hoặc 5 năm), mỗi kỳ 1 query → tổng 12 queries
2. **Unit conversion**: Tất cả đơn vị đã được convert sang kg trong repository
3. **Data structure**: Dữ liệu được tổ chức theo loại rác, mỗi loại có array số lượng theo kỳ
4. **Caching**: Không có cache, mỗi lần load sẽ query database
5. **Zero values**: Các kỳ không có dữ liệu sẽ có giá trị 0 (không hiển thị phần đó trong cột)

## Cải tiến tương lai

- [ ] Thêm filter theo khu vực/phòng ban
- [ ] Export biểu đồ thành hình ảnh
- [ ] Animation khi load dữ liệu
- [ ] Zoom/pan cho biểu đồ
- [ ] Thêm percentage trên mỗi phần của cột
- [ ] Grouped bar chart (so sánh 2 năm cạnh nhau)
- [ ] Cache dữ liệu để giảm số lần query
- [ ] Lazy loading cho dữ liệu cũ hơn
- [ ] Thêm tùy chọn xem theo % thay vì số lượng tuyệt đối

## Hoàn thành ✅

- ✅ Tạo widget `StackedWasteBarChart`
- ✅ Thêm method `fetchStackedWasteTypeData` vào repository
- ✅ Thêm classes `StackedWasteData` và `WasteTypeSeries`
- ✅ Tích hợp vào `TrendComparisonTab`
- ✅ Xử lý empty state
- ✅ Thêm tooltip và legend
- ✅ Stacked column series với nhiều màu
- ✅ Hiển thị dữ liệu qua 12 tháng hoặc 5 năm
- ✅ Responsive design
- ✅ Fix tất cả lỗi compile

## So sánh với biểu đồ đường

| Tính năng | Biểu đồ đường | Biểu đồ cột chồng |
|-----------|---------------|-------------------|
| Hiển thị | Tổng rác thải theo kỳ | Chi tiết từng loại rác theo kỳ |
| Xu hướng | Dễ thấy xu hướng tăng/giảm | Dễ so sánh tỷ lệ các loại |
| Chi tiết | Chỉ tổng | Breakdown theo loại |
| Màu sắc | 1 màu (đường) | Nhiều màu (mỗi loại) |
| Tương tác | Tooltip đơn giản | Tooltip chi tiết + legend |

→ Hai biểu đồ bổ sung cho nhau: Đường cho xu hướng tổng thể, Cột chồng cho phân tích chi tiết.
