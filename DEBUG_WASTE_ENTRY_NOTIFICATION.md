# Debug: Notification khi thêm Waste Entry

## Vấn đề
- Test button → Notification hiển thị ✅
- Thêm waste entry → Notification KHÔNG hiển thị ❌

## Debug Steps

### Bước 1: Xem Console Logs

Khi thêm waste entry, bạn phải thấy các logs sau:

```
🔍 [WASTE LIMIT CHECK] Starting check...
   Area ID: [uuid]
   Waste Type ID: [uuid]
   Quantity: 50.0
✅ [WASTE LIMIT CHECK] Found area: Kitchen
✅ [WASTE LIMIT CHECK] Found waste type: Plastic
📊 [LIMIT CHECK] Checking waste limit...
   Area: Kitchen ([uuid])
   Waste Type: Plastic ([uuid])
   New Quantity: 50.0
   Date range: 2024-01-01 to 2024-01-31
   Found 2 entries this month
   Entry quantity: 60.0
   Entry quantity: 50.0
   Total quantity this month: 110.0
   Limit: 100.0 (monthly)
   Comparing: 110.0 > 100.0 ?
⚠️ [LIMIT CHECK] EXCEEDED! Showing notification...
✅ [LIMIT CHECK] Notification sent!
   Total: 110.0, Limit: 100.0, Exceeded by: 10.0
```

### Bước 2: Kiểm tra từng trường hợp

#### Case 1: Không thấy log gì
**Nguyên nhân**: Method `_checkWasteLimitAndNotify` không được gọi

**Kiểm tra**:
```dart
// lib/data/repositories/waste_entry_repository.dart
// Phải có dòng này sau insert:
await _checkWasteLimitAndNotify(entry);
```

#### Case 2: Thấy "Area not found" hoặc "Waste type not found"
**Nguyên nhân**: Area ID hoặc Waste Type ID không tồn tại

**Giải pháp**:
```sql
-- Kiểm tra areas
SELECT id, name FROM areas;

-- Kiểm tra waste_types
SELECT id, name FROM waste_types;
```

#### Case 3: Thấy "No limit set for this area and waste type"
**Nguyên nhân**: Chưa tạo waste limit

**Giải pháp**:
1. Vào Waste Limits page
2. Tạo limit mới với ĐÚNG area và waste type
3. Thử lại

**Kiểm tra trong database**:
```sql
SELECT * FROM waste_limits 
WHERE area_id = '[your_area_id]' 
  AND waste_type_id = '[your_waste_type_id]';
```

#### Case 4: Thấy "Within limit"
**Nguyên nhân**: Tổng lượng chưa vượt giới hạn

**Ví dụ**:
```
Total: 80.0, Limit: 100.0, Remaining: 20.0
```

**Giải pháp**: Thêm waste entry với quantity lớn hơn để vượt giới hạn

#### Case 5: Thấy "EXCEEDED! Showing notification..." nhưng không có notification
**Nguyên nhân**: Quyền notification chưa được cấp

**Giải pháp**:
1. Kiểm tra Settings → Apps → Your App → Notifications
2. Đảm bảo "Allow notifications" BẬT
3. Restart app

### Bước 3: Test từng bước

#### Test 1: Tạo waste limit
```
Area: Kitchen
Waste Type: Plastic
Limit: 100
Period: monthly
```

Verify trong database:
```sql
SELECT * FROM waste_limits 
WHERE area_id = (SELECT id FROM areas WHERE name = 'Kitchen')
  AND waste_type_id = (SELECT id FROM waste_types WHERE name = 'Plastic');
```

#### Test 2: Thêm entry đầu tiên (60kg)
```
Area: Kitchen
Waste Type: Plastic
Quantity: 60
Date: Today
```

Console log phải thấy:
```
Total quantity this month: 60.0
Limit: 100.0
✅ Within limit
```

#### Test 3: Thêm entry thứ hai (50kg)
```
Area: Kitchen
Waste Type: Plastic
Quantity: 50
Date: Today
```

Console log phải thấy:
```
Total quantity this month: 110.0
Limit: 100.0
⚠️ EXCEEDED! Showing notification...
✅ Notification sent!
```

### Bước 4: Kiểm tra query tổng lượng

Chạy query thủ công để verify:
```sql
SELECT 
  SUM(quantity) as total,
  COUNT(*) as count
FROM waste_entries
WHERE area_id = '[your_area_id]'
  AND waste_type_id = '[your_waste_type_id]'
  AND date >= DATE_TRUNC('month', CURRENT_DATE)
  AND date <= DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day';
```

## Common Issues

### Issue 1: Date format không khớp

**Triệu chứng**: "Found 0 entries this month" nhưng biết chắc có entries

**Nguyên nhân**: Date format trong database khác với query

**Debug**:
```sql
-- Xem format date trong database
SELECT date, TO_CHAR(date, 'YYYY-MM-DD') as formatted_date 
FROM waste_entries 
LIMIT 5;

-- Xem date range đang query
SELECT 
  DATE_TRUNC('month', CURRENT_DATE) as first_day,
  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month' - INTERVAL '1 day' as last_day;
```

### Issue 2: Area ID hoặc Waste Type ID không khớp

**Triệu chứng**: "No limit set" nhưng đã tạo limit

**Debug**:
```sql
-- Xem tất cả limits
SELECT 
  wl.id,
  a.name as area_name,
  wt.name as waste_type_name,
  wl.limit_value,
  wl.area_id,
  wl.waste_type_id
FROM waste_limits wl
JOIN areas a ON a.id = wl.area_id
JOIN waste_types wt ON wt.id = wl.waste_type_id;

-- Xem waste entry vừa tạo
SELECT 
  we.id,
  a.name as area_name,
  wt.name as waste_type_name,
  we.quantity,
  we.area_id,
  we.waste_type_id
FROM waste_entries we
JOIN areas a ON a.id = we.area_id
JOIN waste_types wt ON wt.id = we.waste_type_id
ORDER BY we.created_at DESC
LIMIT 1;
```

### Issue 3: Notification không hiển thị dù log "Notification sent"

**Nguyên nhân**: Quyền notification hoặc Do Not Disturb

**Giải pháp**:
1. Kiểm tra quyền notification
2. Tắt Do Not Disturb
3. Kiểm tra notification settings cho app
4. Test với test button để confirm notification hoạt động

## Quick Debug Checklist

- [ ] Console log hiển thị "Starting check"
- [ ] Console log hiển thị "Found area" và "Found waste type"
- [ ] Console log hiển thị "Checking waste limit"
- [ ] Console log hiển thị số entries found
- [ ] Console log hiển thị total quantity
- [ ] Console log hiển thị limit value
- [ ] Nếu exceeded: Console log hiển thị "EXCEEDED! Showing notification"
- [ ] Nếu exceeded: Console log hiển thị "Notification sent"
- [ ] Kiểm tra notification tray
- [ ] Test button hoạt động bình thường

## Kết luận

Nếu:
- ✅ Test button hiển thị notification
- ❌ Thêm waste entry không hiển thị notification

Thì vấn đề nằm ở:
1. Waste limit chưa được tạo
2. Area ID hoặc Waste Type ID không khớp
3. Tổng lượng chưa vượt giới hạn
4. Date range query không đúng

Xem console logs để xác định chính xác vấn đề!
