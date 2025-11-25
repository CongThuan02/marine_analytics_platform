# Chức năng Đăng xuất

## Tổng quan

Đã thêm chức năng đăng xuất vào trang Settings với giao diện được cải thiện hoàn toàn.

---

## Tính năng mới

### 1. **Giao diện Settings được thiết kế lại**

#### User Section
- Hiển thị thông tin người dùng hiện tại
- Email và trạng thái đăng nhập
- Icon avatar với màu theme

#### Phân nhóm chức năng
**Quản lý hệ thống:**
- Quản lý khu vực
- Quản lý phòng ban
- Quản lý loại chất thải

**Giám sát & Cảnh báo:**
- Quản lý hạn mức
- Quản lý nhắc nhở

**Tài khoản:**
- Đăng xuất

#### Card Design
- Icon màu xanh môi trường
- Title và subtitle rõ ràng
- Chevron right indicator
- Hover effect khi tap

---

## 2. **Chức năng Đăng xuất**

### Đặc điểm
- ✅ Card màu đỏ nổi bật
- ✅ Dialog xác nhận trước khi đăng xuất
- ✅ Loading indicator trong quá trình đăng xuất
- ✅ Tự động chuyển về màn hình login
- ✅ Thông báo thành công/lỗi
- ✅ Xử lý lỗi an toàn

### Flow đăng xuất
```
1. User tap "Đăng xuất"
   ↓
2. Hiển thị dialog xác nhận
   ↓
3. User xác nhận
   ↓
4. Hiển thị loading
   ↓
5. Gọi supabase.auth.signOut()
   ↓
6. Đóng loading
   ↓
7. Chuyển về /login
   ↓
8. Hiển thị snackbar thành công
```

---

## Code Implementation

### Logout Function
```dart
Future<void> _logout(BuildContext context) async {
  try {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    // Sign out from Supabase
    await supabase.auth.signOut();

    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Navigate to login
    if (context.mounted) {
      context.go('/login');
    }

    // Show success message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đăng xuất thành công'),
          backgroundColor: AppTheme.success,
        ),
      );
    }
  } catch (e) {
    // Error handling
  }
}
```

### Confirmation Dialog
```dart
void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.logout, color: Colors.red),
          SizedBox(width: 12),
          Text('Xác nhận đăng xuất'),
        ],
      ),
      content: const Text(
        'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.pop(dialogContext);
            await _logout(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Đăng xuất'),
        ),
      ],
    ),
  );
}
```

---

## UI Components

### User Info Card
```dart
Container(
  padding: const EdgeInsets.all(16),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        AppTheme.primaryGreen.withOpacity(0.1),
        AppTheme.primaryGreenLight.withOpacity(0.05),
      ],
    ),
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppTheme.primaryGreen.withOpacity(0.3),
    ),
  ),
  child: Row(
    children: [
      // Avatar icon
      // User email
      // Status
    ],
  ),
)
```

### Setting Card
```dart
Card(
  child: InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Icon with background
          // Title & Subtitle
          // Chevron right
        ],
      ),
    ),
  ),
)
```

### Logout Card
```dart
Card(
  color: Colors.red.shade50,
  shape: RoundedRectangleBorder(
    side: BorderSide(color: Colors.red.shade200),
  ),
  child: InkWell(
    onTap: () => _showLogoutDialog(context),
    child: // Similar to setting card but red theme
  ),
)
```

---

## Security & Best Practices

### 1. **Context Safety**
```dart
// Always check if context is mounted
if (context.mounted) {
  Navigator.pop(context);
}
```

### 2. **Error Handling**
```dart
try {
  await supabase.auth.signOut();
} catch (e) {
  // Show error message
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Lỗi: $e')),
  );
}
```

### 3. **Loading State**
- Hiển thị loading khi đang xử lý
- Disable user interaction với `barrierDismissible: false`
- Đóng loading sau khi hoàn thành

### 4. **Navigation**
- Sử dụng `context.go('/login')` để clear navigation stack
- Không dùng `push` để tránh user quay lại

---

## Router Configuration

Router đã được cấu hình để tự động redirect:

```dart
final appRouter = GoRouter(
  redirect: (context, state) {
    final currentSession = supabase.auth.currentSession;
    final isLoggingIn = state.matchedLocation == '/login';

    // Nếu chưa đăng nhập và không ở trang login
    if (currentSession == null) {
      if (!isLoggingIn) {
        return '/login';
      }
    }

    // Nếu đã đăng nhập và đang ở trang login
    if (isLoggingIn && currentSession != null) {
      return '/';
    }

    return null;
  },
  // ...
);
```

Khi `signOut()` được gọi:
1. `currentSession` trở thành `null`
2. Router tự động redirect về `/login`
3. User không thể quay lại trang cũ

---

## Testing

### Test Cases

1. **Đăng xuất thành công**
   - Tap "Đăng xuất"
   - Xác nhận trong dialog
   - Kiểm tra chuyển về login
   - Kiểm tra snackbar hiển thị

2. **Hủy đăng xuất**
   - Tap "Đăng xuất"
   - Tap "Hủy" trong dialog
   - Kiểm tra vẫn ở trang settings

3. **Xử lý lỗi**
   - Mô phỏng lỗi network
   - Kiểm tra error message hiển thị
   - Kiểm tra user vẫn đăng nhập

4. **Session expired**
   - Session hết hạn
   - Tap bất kỳ action nào
   - Kiểm tra tự động redirect về login

---

## User Experience

### Improvements

1. **Visual Hierarchy**
   - Phân nhóm rõ ràng
   - Section titles nổi bật
   - Spacing hợp lý

2. **Feedback**
   - Loading indicator
   - Success/error messages
   - Confirmation dialog

3. **Accessibility**
   - Clear labels
   - Sufficient touch targets
   - Color contrast

4. **Consistency**
   - Sử dụng theme colors
   - Icon style thống nhất
   - Card design đồng bộ

---

## Future Enhancements

### Có thể thêm

- [ ] Đăng xuất khỏi tất cả thiết bị
- [ ] Xem lịch sử đăng nhập
- [ ] Thay đổi mật khẩu
- [ ] Cài đặt bảo mật 2FA
- [ ] Quản lý sessions
- [ ] Dark mode toggle
- [ ] Ngôn ngữ (Language selector)
- [ ] Thông báo push settings
- [ ] Về ứng dụng (About)
- [ ] Điều khoản & Chính sách

---

## Files Changed

```
lib/presentation/views/setting.dart
  - Redesigned UI
  - Added user info section
  - Added logout functionality
  - Improved card design
  - Added section grouping
```

---

## Dependencies

Sử dụng các package có sẵn:
- `supabase_flutter` - Authentication
- `go_router` - Navigation
- `flutter/material.dart` - UI components

Không cần thêm package mới.

---

## Ghi chú

1. **Session Management**: Supabase tự động quản lý session
2. **Token Cleanup**: `signOut()` tự động xóa tokens
3. **State Reset**: Router redirect đảm bảo state được reset
4. **Security**: Không lưu credentials locally sau logout

---

**Cập nhật lần cuối**: 25/11/2025
