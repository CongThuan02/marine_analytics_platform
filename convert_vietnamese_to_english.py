#!/usr/bin/env python3
"""
Script to convert all Vietnamese text to English in Dart files
"""

import os
import re

# Translation map
TRANSLATIONS = {
    # Settings
    "Cài đặt": "Settings",
    "Quản lý hệ thống": "System Management",
    "Quản lý khu vực": "Manage Areas",
    "Quản lý phòng": "Manage Departments",
    "Quản lý loại chất thải": "Manage Waste Types",
    "Giám sát & Cảnh báo": "Monitoring & Alerts",
    "Cảnh báo hạn mức": "Limit Alerts",
    "Quản lý hạn mức": "Manage Limits",
    "Quản lý nhắc nhở": "Manage Reminders",
    "Tài khoản": "Account",
    "Đăng xuất": "Logout",
    "Người dùng": "User",
    "Đã đăng nhập": "Logged in",
    
    # Common actions
    "Thêm": "Add",
    "Sửa": "Edit",
    "Xóa": "Delete",
    "Hủy": "Cancel",
    "Lưu": "Save",
    "Đóng": "Close",
    "Xác nhận": "Confirm",
    "Thử lại": "Retry",
    "Làm mới": "Refresh",
    
    # Areas/Locations
    "Khu vực": "Area",
    "khu vực": "area",
    "Thêm, sửa, xóa khu vực": "Add, edit, delete areas",
    "Chọn khu vực": "Select area",
    
    # Departments
    "Phòng ban": "Department",
    "phòng": "department",
    "Thêm, sửa, xóa phòng": "Add, edit, delete departments",
    "Chọn phòng": "Select department",
    "Vui lòng chọn phòng": "Please select a department",
    
    # Waste Types
    "Loại chất thải": "Waste Type",
    "loại chất thải": "waste type",
    "Thêm, sửa, xóa loại chất thải": "Add, edit, delete waste types",
    "Chọn loại chất thải": "Select waste type",
    
    # Waste Limits
    "Hạn mức": "Limit",
    "hạn mức": "limit",
    "Đặt ngưỡng cảnh báo chất thải": "Set waste alert thresholds",
    "Hạn mức hàng ngày": "Daily limit",
    
    # Reminders
    "Nhắc nhở": "Reminder",
    "nhắc nhở": "reminder",
    "Cấu hình nhắc nhở nhập liệu": "Configure data entry reminders",
    
    # Alerts
    "Cảnh báo": "Alert",
    "cảnh báo": "alert",
    "Xem cảnh báo vượt ngưỡng": "View threshold alerts",
    "Không có cảnh báo": "No alerts",
    "Xóa cảnh báo cũ": "Delete old alerts",
    "Đóng cảnh báo": "Close alert",
    "Bạn có muốn đóng cảnh báo này?": "Do you want to close this alert?",
    "Bạn có muốn xóa tất cả cảnh báo trước hôm nay?": "Delete all alerts before today?",
    "Đã xóa cảnh báo cũ": "Old alerts deleted",
    "Test tạo cảnh báo": "Test Create Alert",
    
    # Time periods
    "Hôm nay": "Today",
    "hôm nay": "today",
    "Tháng này": "This Month",
    "Năm nay": "This Year",
    "Tháng": "Month",
    "Năm": "Year",
    "Ngày": "Day",
    
    # Statistics
    "Tổng khối lượng": "Total Quantity",
    "Số lần ghi nhận": "Entry Count",
    "Biểu đồ phân bố chất thải": "Waste Distribution Chart",
    "So sánh khối lượng": "Quantity Comparison",
    "Chi tiết theo loại chất thải": "Details by Waste Type",
    "Tỷ lệ phân bố": "Distribution Ratio",
    "Khối lượng theo loại": "Quantity by Type",
    "Khối lượng": "Quantity",
    "Tổng": "Total",
    "Không có dữ liệu": "No data",
    
    # Messages
    "Vui lòng": "Please",
    "Bạn có chắc": "Are you sure",
    "Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?": "Are you sure you want to logout?",
    "Đã đăng xuất thành công": "Logged out successfully",
    "Lỗi đăng xuất": "Logout error",
    "Lỗi": "Error",
    "Thành công": "Success",
    
    # Validation
    "Vui lòng nhập": "Please enter",
    "Vui lòng chọn": "Please select",
    "không hợp lệ": "invalid",
    "Tối thiểu": "Minimum",
    "ký tự": "characters",
    
    # Roles
    "Vai trò": "Role",
    "Quản trị": "Admin",
    "Nhân viên": "Staff",
    "Quan sát": "Viewer",
    "Vui lòng chọn vai trò": "Please select a role",
    
    # Common
    "Chọn": "Select",
    "chon": "select",
    "Tất cả": "All",
    "Đang tải": "Loading",
    "Không có": "No",
    "Xác nhận đăng xuất": "Confirm Logout",
}

def convert_file(filepath):
    """Convert Vietnamese text to English in a file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Apply translations
        for viet, eng in TRANSLATIONS.items():
            content = content.replace(f"'{viet}'", f"'{eng}'")
            content = content.replace(f'"{viet}"', f'"{eng}"')
        
        # Only write if changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    """Main conversion function"""
    dart_files = []
    
    # Find all dart files in lib/presentation
    for root, dirs, files in os.walk('lib/presentation'):
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"Found {len(dart_files)} Dart files")
    print("Converting...")
    
    converted = 0
    for filepath in dart_files:
        if convert_file(filepath):
            converted += 1
            print(f"✅ {filepath}")
    
    print(f"\n✨ Converted {converted} files")
    print("🎉 Done! Run 'flutter pub get' and hot reload your app.")

if __name__ == '__main__':
    main()
