# Fix Alerts Page Issues

## Vấn đề 1: Không thấy alert trong Waste Limit Alerts page

**Nguyên nhân**: Local notification không tạo record trong database `alerts` table.

**Giải pháp**: Thêm code tạo alert record vào `local_notification_service.dart`

Tìm dòng:
```dart
if (totalQuantity > limitValue) {
  print('⚠️ [LIMIT CHECK] EXCEEDED! Showing notification...');
  
  final exceededBy = totalQuantity - limitValue;
  final percentage = ((totalQuantity / limitValue) * 100).toStringAsFixed(1);
```

Thêm NGAY SAU `final percentage = ...`:
```dart
// Create alert record in database
try {
  await supabase.from('alerts').insert({
    'area_id': areaId,
    'waste_type_id': wasteTypeId,
    'total_today': totalQuantity,
    'limit_value': limitValue,
    'percent': (totalQuantity / limitValue) * 100,
    'message': '$areaName - $wasteTypeName: ${totalQuantity.toStringAsFixed(1)} kg / ${limitValue.toStringAsFixed(1)} kg ($percentage%)',
  });
  print('✅ Alert record created in database');
} catch (e) {
  print('⚠️ Error creating alert: $e');
}
```

## Vấn đề 2: Không có nút quay lại trong Alerts page

**File**: `lib/presentation/views/alerts/page.dart`

Tìm `AppBar` và thêm `leading`:
```dart
AppBar(
  title: const Text("Limit Alerts"),
  leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.of(context).pop(),
  ),
)
```

## Quick Test

1. Thêm waste entry vượt giới hạn
2. Kiểm tra:
   - Local notification hiển thị ✅
   - Vào Alerts page → Thấy alert mới ✅
   - Có nút back ✅
