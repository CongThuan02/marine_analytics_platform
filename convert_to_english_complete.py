#!/usr/bin/env python3
"""
Complete script to convert ALL Vietnamese text to English in Dart files
"""

import os
import re

# Comprehensive translation map
TRANSLATIONS = {
    # Validation messages
    "Vui lòng chọn khu vực": "Please select an area",
    "Vui lòng chọn phòng ban": "Please select a department",
    "Vui lòng chọn loại chất thải": "Please select a waste type",
    "Vui lòng chọn loại chất thải cho mục": "Please select waste type for item",
    "Vui lòng nhập số lượng": "Please enter quantity",
    "Vui lòng chọn ngày ghi nhận": "Please select entry date",
    "Vui lòng điền đầy đủ thông tin chung": "Please fill in all common information",
    "Vui lòng điền đầy đủ thông tin các loại rác thải": "Please fill in all waste type information",
    "Vui lòng chọn khu vực và loại chất thải": "Please select area and waste type",
    "Vui lòng tạo hạn mức trước": "Please create limits first",
    
    # Success messages
    "Đã thêm": "Added",
    "Đã tạo": "Created",
    "Đã xóa": "Deleted",
    "Thành công": "Success",
    "Đã tạo cảnh báo test thành công": "Test alert created successfully",
    "Đã tạo dữ liệu test thành công": "Test data created successfully",
    "Đã tạo alert test thành công": "Test alert created successfully",
    "Đã xóa cảnh báo cũ": "Old alerts deleted",
    "loại rác thải": "waste types",
    "cảnh báo mới": "new alerts",
    
    # Error messages
    "Đăng ký thất bại": "Registration failed",
    "Đăng nhập thất bại": "Login failed",
    "Số lượng không hợp lệ": "Invalid quantity",
    "Số lượng không hợp lệ ở loại rác thứ": "Invalid quantity for waste type",
    "Số lượng không hợp lệ ở mục": "Invalid quantity for item",
    "Số lượng phải là số": "Quantity must be a number",
    
    # Empty states
    "Chưa có loại chất thải nào": "No waste types yet",
    "Chưa có phòng ban nào": "No departments yet",
    "Chưa có khu vực nào": "No areas yet",
    "Chưa có dữ liệu chất thải cho ngày này": "No waste data for this day",
    "Chưa có dữ liệu chất thải cho tháng này": "No waste data for this month",
    "Chưa có dữ liệu chất thải cho năm này": "No waste data for this year",
    "Chưa có dữ liệu": "No data yet",
    "Chưa có": "None",
    "Không có tên": "No name",
    "Không có khu vực": "No area",
    "Không có hạn mức nào được đặt": "No limits set",
    "Không có khu vực nào vượt ngưỡng": "No areas exceeded threshold",
    
    # Confirmation dialogs
    "Xác nhận xóa": "Confirm Delete",
    "Bạn có chắc muốn xóa": "Are you sure you want to delete",
    "Bạn có chắc muốn xóa hạn mức này": "Are you sure you want to delete this limit",
    "Bạn có chắc muốn xóa nhắc nhở này": "Are you sure you want to delete this reminder",
    
    # Labels and titles
    "Ghi nhận chất thải": "Record Waste",
    "Thêm nhiều loại rác thải": "Add Multiple Waste Types",
    "Thông tin chung": "Common Information",
    "Danh sách rác thải": "Waste List",
    "Thêm loại": "Add Type",
    "Loại rác thải": "Waste Type",
    "Ngày ghi nhận": "Entry Date",
    "Chọn ngày": "Select Date",
    "Đơn vị": "Unit",
    "Ví dụ": "Example",
    
    # Common words
    "Vui lòng": "Please",
    "Không có": "No",
    "Chưa có": "Not yet",
    "Đã": "Already",
    "Thất bại": "Failed",
    "Lỗi": "Error",
}

def convert_file(filepath):
    """Convert Vietnamese text to English in a file"""
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Sort by length (longest first) to avoid partial replacements
        sorted_translations = sorted(TRANSLATIONS.items(), key=lambda x: len(x[0]), reverse=True)
        
        # Apply translations
        for viet, eng in sorted_translations:
            # Replace in single quotes
            content = content.replace(f"'{viet}'", f"'{eng}'")
            # Replace in double quotes
            content = content.replace(f'"{viet}"', f'"{eng}"')
            # Replace in interpolation
            content = re.sub(rf"'([^']*){re.escape(viet)}([^']*)'", rf"'\1{eng}\2'", content)
            content = re.sub(rf'"([^"]*){re.escape(viet)}([^"]*)"', rf'"\1{eng}\2"', content)
        
        # Only write if changed
        if content != original_content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            return True
        return False
    except Exception as e:
        print(f"❌ Error processing {filepath}: {e}")
        return False

def main():
    """Main conversion function"""
    dart_files = []
    
    # Find all dart files in lib/
    for root, dirs, files in os.walk('lib'):
        # Skip test files
        if 'test' in root:
            continue
        for file in files:
            if file.endswith('.dart'):
                dart_files.append(os.path.join(root, file))
    
    print(f"🔍 Found {len(dart_files)} Dart files")
    print("🔄 Converting Vietnamese to English...")
    print()
    
    converted = 0
    for filepath in dart_files:
        if convert_file(filepath):
            converted += 1
            print(f"✅ {filepath}")
    
    print()
    print(f"✨ Converted {converted} files")
    print("🎉 Done! Run 'flutter pub get' and hot reload your app.")

if __name__ == '__main__':
    main()
