# Fix Lỗi FCM Notification trên Android

## Lỗi Đã Fix

1. ✅ **Duplicate FCM token** - Dùng `upsert` với `onConflict`
2. ✅ **NullPointerException khi show notification** - Thêm permissions và receivers trong AndroidManifest
3. ✅ **Crash app khi notification lỗi** - Wrap trong try-catch

## Thay Đổi

### 1. AndroidManifest.xml

Đã thêm:
- Permissions: `POST_NOTIFICATIONS`, `VIBRATE`, `RECEIVE_BOOT_COMPLETED`
- Receivers cho local notifications
- Boot receiver để khôi phục scheduled notifications

### 2. FCMService

Đã cập nhật:
- `_saveFCMToken()` - Dùng `onConflict: 'user_id,token'`
- `_showLocalNotification()` - Wrap trong try-catch để tránh crash

## Rebuild App

Sau khi thay đổi AndroidManifest, cần rebuild:

```bash
flutter clean
flutter run
```

## Test FCM

1. **Kiểm tra token đã lưu**:
   ```sql
   SELECT * FROM user_fcm_tokens;
   ```

2. **Tạo alert test** trong app:
   - Vào trang Alerts → Menu → "Test tạo cảnh báo"
   - Tạo alert mới
   - Kiểm tra notification hiển thị

3. **Test từ Supabase** (sau khi deploy trigger):
   - Tạo waste_entry vượt 80% hạn mức
   - Tất cả users sẽ nhận notification

## Troubleshooting

### Không nhận được notification?

1. Kiểm tra permissions:
   ```
   Settings → Apps → Marine Analytics → Permissions → Notifications
   ```

2. Xem logs:
   ```
   I/flutter: ✅ FCM token saved to database
   I/flutter: 📨 Foreground message: ...
   ```

3. Test notification channel:
   ```dart
   // Trong app, check channel đã được tạo
   ```

### Vẫn bị crash?

- Xóa app và cài lại sau khi rebuild
- Kiểm tra Android version (cần API 33+ cho POST_NOTIFICATIONS)
- Xem full stack trace trong logcat

## Permissions Giải Thích

- `POST_NOTIFICATIONS` - Hiển thị notification (Android 13+)
- `VIBRATE` - Rung khi có notification
- `RECEIVE_BOOT_COMPLETED` - Khôi phục scheduled notifications sau reboot
- `INTERNET` - Nhận FCM messages

## Next Steps

Sau khi app chạy ổn:
1. Deploy `supabase_waste_limit_fcm.sql` để enable auto notification
2. Deploy Edge Function `send-fcm-notification`
3. Cấu hình FCM_SERVER_KEY
4. Test end-to-end flow
