# ✨ Feature: Trend Comparison Chart

## 📊 Tổng quan

Đã thêm tính năng **so sánh xu hướng rác thải** theo thời gian để phân tích sự thay đổi về số lượng rác thải giữa các tháng hoặc các năm.

## 🎯 Tính năng mới

### 1. Tab "Trend" mới trong Home Page
- Thêm tab thứ 4 với icon trending_up
- Hiển thị biểu đồ so sánh xu hướng

### 2. Biểu đồ Line Chart
- **Monthly Trend**: So sánh 12 tháng gần nhất
- **Yearly Trend**: So sánh 5 năm gần nhất
- Line chart với gradient area fill
- Data labels hiển thị số lượng
- Zoom và pan support

### 3. Thống kê tổng hợp
**Summary Cards:**
- Total: Tổng số rác thải trong khoảng thời gian
- Average: Trung bình mỗi kỳ
- Highest: Kỳ có số lượng cao nhất
- Lowest: Kỳ có số lượng thấp nhất

**Statistics Table:**
- Bảng chi tiết theo từng kỳ
- Hiển thị: Period, Quantity (kg), Entry count

### 4. Period Selector
- Segmented button để chọn Monthly/Yearly
- Tự động reload data khi thay đổi

## 📁 Files đã tạo

### 1. Widget Components
```
lib/presentation/views/overviews/widgets/
├── trend_chart_widget.dart          # Line chart component
└── trend_comparison_tab.dart        # Main trend tab
```

### 2. Page
```
lib/presentation/views/overviews/
└── trend.dart                       # Trend overview page
```

### 3. Repository Enhancement
```
lib/data/repositories/
└── waste_stats_repository.dart      # Added fetchTrendData method
```

## 🔧 Cách sử dụng

### Xem Trend Comparison
1. Mở app → Home page
2. Chọn tab **"Trend"** (icon trending_up)
3. Chọn period: **Monthly** hoặc **Yearly**
4. Xem biểu đồ và thống kê

### Monthly Trend
- Hiển thị 12 tháng gần nhất
- Format: MM/YYYY (ví dụ: 01/2024)
- So sánh số lượng rác thải giữa các tháng

### Yearly Trend
- Hiển thị 5 năm gần nhất
- Format: YYYY (ví dụ: 2024)
- So sánh số lượng rác thải giữa các năm

## 📊 Ví dụ Use Cases

### 1. Phân tích xu hướng tăng/giảm
```
Tháng 1: 150 kg
Tháng 2: 180 kg (+20%)
Tháng 3: 160 kg (-11%)
→ Nhận biết được tháng nào tăng đột biến
```

### 2. So sánh theo mùa
```
Q1 (Jan-Mar): 500 kg
Q2 (Apr-Jun): 650 kg
Q3 (Jul-Sep): 720 kg
Q4 (Oct-Dec): 580 kg
→ Xác định mùa nào có nhiều rác nhất
```

### 3. Đánh giá hiệu quả giảm thiểu
```
2020: 2,500 kg
2021: 2,300 kg (-8%)
2022: 2,100 kg (-9%)
2023: 1,900 kg (-10%)
→ Theo dõi tiến độ giảm rác qua các năm
```

## 🎨 UI Features

### Chart Interactions
- **Zoom**: Pinch to zoom in/out
- **Pan**: Drag to move chart
- **Tooltip**: Tap data point to see details
- **Data Labels**: Hiển thị số lượng trên mỗi điểm

### Visual Design
- Gradient area fill (green theme)
- Circular markers on data points
- Responsive layout
- Card-based design

### Color Scheme
- Primary: AppTheme.primaryGreen
- Secondary: AppTheme.secondaryTeal
- Accent: Orange (highest), Blue (lowest)

## 🔄 Data Flow

```
User selects period
    ↓
TrendComparisonTab._loadTrendData()
    ↓
WasteStatsRepository.fetchTrendData()
    ↓
Loop through periods (12 months or 5 years)
    ↓
For each period: fetchStats()
    ↓
Aggregate TrendDataPoint[]
    ↓
Display in TrendChartWidget
```

## 📈 Technical Details

### TrendDataPoint Model
```dart
class TrendDataPoint {
  final String period;      // "01/2024" or "2024"
  final double quantity;    // Total kg
  final DateTime date;      // Reference date
  final int entryCount;     // Number of entries
}
```

### TrendPeriod Enum
```dart
enum TrendPeriod {
  monthly,  // Compare months
  yearly,   // Compare years
}
```

### Repository Method
```dart
Future<List<TrendDataPoint>> fetchTrendData({
  required TrendPeriod trendPeriod,
  required DateTime endDate,
  int periodsCount = 12,
})
```

## 🚀 Performance

### Optimization
- Lazy loading: Chỉ load khi user chọn tab
- Caching: Data được cache trong state
- Efficient queries: Reuse existing fetchStats method

### Loading States
- Loading indicator khi fetch data
- Error handling với retry option
- Pull-to-refresh support

## 🎯 Benefits

### 1. Phân tích xu hướng
- Nhận biết pattern tăng/giảm
- Dự đoán xu hướng tương lai
- Xác định anomalies

### 2. So sánh hiệu quả
- Đánh giá các biện pháp giảm thiểu
- So sánh giữa các kỳ
- Tracking KPIs

### 3. Báo cáo trực quan
- Dễ hiểu cho management
- Export-ready charts
- Professional presentation

## 📝 Future Enhancements

### Có thể thêm sau:
1. **Export to PDF/Excel**
   - Export chart và statistics
   - Generate reports

2. **Custom Date Range**
   - Cho phép user chọn range tùy ý
   - Compare any two periods

3. **Multiple Metrics**
   - So sánh nhiều loại rác cùng lúc
   - Stacked line chart

4. **Forecast**
   - Dự đoán xu hướng tương lai
   - ML-based predictions

5. **Comparison Mode**
   - So sánh 2 khoảng thời gian
   - Year-over-year comparison

## ✅ Testing

### Test Cases
1. ✅ Monthly trend hiển thị 12 tháng
2. ✅ Yearly trend hiển thị 5 năm
3. ✅ Switch giữa monthly/yearly
4. ✅ Pull to refresh
5. ✅ Chart interactions (zoom, pan)
6. ✅ Empty state handling
7. ✅ Error state handling

### Manual Testing
```bash
# 1. Run app
flutter run

# 2. Navigate to Home → Trend tab
# 3. Test monthly view
# 4. Switch to yearly view
# 5. Test zoom/pan
# 6. Pull to refresh
```

## 🎉 Kết luận

Feature **Trend Comparison** đã hoàn thành với:
- ✅ Line chart với gradient
- ✅ Monthly và Yearly comparison
- ✅ Summary statistics
- ✅ Interactive chart
- ✅ Professional UI/UX

User giờ có thể dễ dàng phân tích xu hướng rác thải và đưa ra quyết định dựa trên data!
