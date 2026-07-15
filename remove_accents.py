import os
import re
import unicodedata

def remove_accents(input_str):
    # Normalize unicode characters
    nfkd_form = unicodedata.normalize('NFKD', input_str)
    # Keep only ASCII characters
    return u"".join([c for c in nfkd_form if not unicodedata.combining(c)])

def process_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Dictionary of specific translations to make it look better in English
    translations = {
        r"Tối ưu hóa": "Optimizing",
        r"Vô hiệu hóa": "Disabling",
        r"Đã bật": "Enabled",
        r"Đã tắt": "Disabled",
        r"Đang bật": "Enabling",
        r"Đang tắt": "Disabling",
        r"Áp dụng": "Applying",
        r"Hoàn tất": "Completed",
        r"Cấu hình": "Configuring",
        r"LỖI": "ERROR",
        r"Cảnh báo": "WARNING",
        r"Nhật ký": "Log",
        r"Khôi phục": "Restore",
        r"Bản sao lưu": "Backup snapshot",
        r"Đã lưu toàn bộ Snapshot Backup vào thư mục": "Saved Snapshot Backup to directory",
        r"Khởi tạo phiên sao lưu tại": "Initialized backup session at",
        r"Không tìm thấy bản sao lưu": "Backup not found",
        r"Đang khôi phục cài đặt": "Restoring configuration",
        r"Đã tối ưu": "Optimized",
        r"Thành công": "Success",
        r"Không thể": "Cannot",
        r"Đang": "Currently",
        r"Hệ thống": "System",
        r"Máy tính": "Computer",
        r"Tự động": "Automatic",
        r"Chế độ": "Mode",
        r"Khởi động lại máy": "Restart PC",
        r"Nhấn phím bất kỳ để": "Press any key to",
        # Emojis and other non-ascii
        r"✔️": "[V]",
        r"✔": "[V]",
        r"⚠️": "[!]",
        r"❌": "[X]",
        r"🔴": "[X]",
        r"🟢": "[V]",
        r"🟡": "[!]",
        r"⚡": "[*]",
        r"💡": "[i]",
        r"💻": "[PC]",
        r"🎮": "[Game]",
        r"🚀": "[*]",
        r"🎉": "[*]",
        r"🔄": "[~]",
        r"📜": "[Log]",
        r"ℹ": "[i]",
        r"👉": "->",
        r"▶": ">",
        r"◀": "<",
        r"═": "-",
        r"║": "|",
        r"╔": "+",
        r"╗": "+",
        r"╚": "+",
        r"╝": "+",
        r"╠": "+",
        r"╣": "+",
        r"╦": "+",
        r"╩": "+",
        r"╬": "+",
        r"█": "#",
        r"░": "-",
        r"•": "-",
    }

    # Apply specific translations
    for vn, en in translations.items():
        content = re.sub(vn, en, content, flags=re.IGNORECASE)

    # Remove accents for any remaining Vietnamese text
    content = remove_accents(content)

    # Finally, strip any remaining non-ascii characters to guarantee 100% ASCII compliance
    content = re.sub(r'[^\x00-\x7F]', '', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f"Processed: {filepath}")

def main():
    root_dir = r"d:\WorkSpace\Valorant Optimize"
    directories = [
        os.path.join(root_dir, 'core'),
        os.path.join(root_dir, 'modules')
    ]
    
    for directory in directories:
        if not os.path.exists(directory):
            continue
        for filename in os.listdir(directory):
            if filename.endswith(".ps1"):
                filepath = os.path.join(directory, filename)
                process_file(filepath)

if __name__ == "__main__":
    main()
