<div align="center">
  <img src="https://raw.githubusercontent.com/viexdigital001/Valorant-Optimizer/main/assets/banner.png" alt="Valorant Optimizer Banner" width="800"/>

  # 🎮 Valorant Optimizer

  *The ultimate one-click system optimization engine for Valorant.*

  ![Version](https://img.shields.io/badge/version-1.1.0-blue.svg)
  ![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)
  ![Platform](https://img.shields.io/badge/platform-Windows%2010%20%7C%2011-lightgrey)
  ![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue.svg?logo=powershell)
  ![Status](https://img.shields.io/badge/status-active-brightgreen.svg)
</div>

---

## 🚀 What's New in v1.1.0

- ⚡ **Balanced Performance Tuning**: Tinh chỉnh hệ thống chuẩn cân bằng hiệu năng — tập trung ổn định 1% Low FPS và frametime consistency trong các tình huống combat dày đặc, loại bỏ hoàn toàn các tinh chỉnh rủi ro hoặc placebo.
- 🛡️ **100% Riot Vanguard & Windows 11 Compliant**: Tự động nhận diện Windows 11 và bảo toàn VBS/HVCI, triệt tiêu nguy cơ phát sinh mã lỗi `VAN9005` hoặc `VAN1067` từ Vanguard.
- 🎧 **Bảo Toàn Thiết Bị Ngoại Vi & Font Chữ**: Duy trì dịch vụ Bluetooth (`bthserv`) trên PC Desktop (bảo vệ chuột, phím, tai nghe, tay cầm không dây); giữ nguyên ClearType Font Smoothing giúp chữ trên Discord, trình duyệt và Windows luôn sắc nét.
- 🌐 **Tối Ưu Network Thể Thao Điện Tử**: Tinh chỉnh riêng biệt card mạng vật lý đang hoạt động (kích hoạt RSS, tắt FlowControl và EEE chống delay gói tin), gỡ bỏ khóa cổ chai `TcpWindowSize` để đạt băng thông tối đa.
- 🔍 **Tính Năng Mới - Latency Diagnostics**: Công cụ đo lường và chẩn đoán độ trễ hệ thống 5 yếu tố cốt lõi (DPC Latency, Input Polling, Memory Standby, MMCSS, Power Throttle) với thang điểm trực quan.
- 💎 **Giới Thiệu VieX Plus 2.0 (VIP Edition)**: Khám phá phiên bản cao cấp tối ưu chuyên sâu cấp độ thi đấu Esports — tinh chỉnh MSI Mode phần cứng, khóa Timer Resolution 0.500ms, tự động giải phóng Standby Memory giữa các round đấu, và hỗ trợ 1-1 từ kỹ sư qua Discord ([https://discord.gg/Xx4pcdvHkw](https://discord.gg/Xx4pcdvHkw)).
- 🔄 **Nâng Cấp Động Cơ Khôi Phục (Restore Engine)**: Tự động sao lưu snapshot trước khi thay đổi, hỗ trợ giải mã nhị phân Mouse Curves, chống tràn số nguyên DWord 0xFFFFFFFF, và phục hồi BCD Dynamic Tick chỉ với 1 nút bấm.

---

## ✨ Features

- **🚀 One-Click Optimization**: Tự động tinh chỉnh toàn diện hệ điều hành và game Valorant chỉ với 1 lần nhấn phím.
- **💻 Hardware & Game Auto-Detection**: Tự động phát hiện CPU, GPU, RAM và quét tìm chính xác thư mục cài đặt `VALORANT-Win64-Shipping.exe` trên mọi ổ đĩa.
- **⚡ Service & Telemetry Management**: Vô hiệu hóa ứng dụng nền không cần thiết và telemetry của Windows mà không ảnh hưởng tính ổn định.
- **🎛️ Dedicated Gaming Modes**: Lựa chọn 3 chế độ cấu hình linh hoạt (*Balanced*, *Competitive*, *Extreme*).
- **🛡️ Safe & 100% Reversible**: Cơ chế Snapshot Backup độc quyền cho phép khôi phục toàn bộ cài đặt gốc bất kỳ lúc nào.
- **🖥️ Retro ASCII Dashboard**: Giao diện TUI nhẹ nhàng, phản hồi tức thì, tiêu tốn 0% tài nguyên CPU khi chơi game.

---

## 📥 Installation & Usage

### Cách 1: Khởi Chạy Nhanh Trực Tuyến (Khuyên Dùng)
Mở cửa sổ **PowerShell với quyền Administrator** (Run as Administrator) và dán lệnh sau:

```powershell
irm "https://raw.githubusercontent.com/viexdigital001/Valorant-Optimizer/main/install.ps1" | iex
```

### Cách 2: Sử Dụng Mã Nguồn Trực Tiếp (Offline / Local)
1. Tải về hoặc clone repository:
   ```powershell
   git clone https://github.com/viexdigital001/Valorant-Optimizer.git
   cd Valorant-Optimizer
   ```
2. Mở PowerShell với quyền **Administrator**.
3. Chạy lệnh sau để mở Dashboard:
   ```powershell
   powershell.exe -ExecutionPolicy Bypass -File .\main.ps1
   ```

---

## 🎮 Hướng Dẫn Sử Dụng Chi Tiết

Sau khi khởi chạy ứng dụng, bạn sử dụng các phím mũi tên **Lên / Xuống** để di chuyển và phím **Enter** để chọn:

1. **Dashboard (Mục 1)**: Xem thông tin phần cứng (CPU, GPU, RAM, OS), trạng thái Game Mode và thiết lập hệ thống.
2. **Optimize Mode (Mục 2)**: Lựa chọn cấp độ tối ưu mong muốn (*Competitive* khuyến nghị cho đấu xếp hạng).
3. **One Click Optimize (Mục 3)**: Tự động tạo snapshot sao lưu an toàn và kích hoạt toàn bộ 22 module tối ưu, sau đó hiển thị bảng tổng kết.
4. **Latency Diagnostics (Mục 4)**: Quét và chấm điểm hệ thống so với tiêu chuẩn thi đấu Esports.
5. **Restore (Mục 5)**: Danh sách các bản sao lưu theo thời gian — hoàn trả cài đặt máy về nguyên trạng ban đầu chỉ trong vài giây.
6. **Log (Mục 6)**: Xem chi tiết nhật ký các tiến trình đã được áp dụng.
7. **[VIP] VieX Plus 2.0 (Mục 7)**: Khám phá các đặc quyền tối ưu phần cứng độc quyền và mở kết nối trực tiếp với đội ngũ kỹ sư.

---

## 🎯 How It Works

Valorant Optimizer can thiệp chuyên sâu vào các cấu hình hiệu năng của Windows:
- **Network**: Tối ưu RSS trên card mạng vật lý, tắt TCP delay (Nagle's Algorithm), gỡ bỏ nghẽn cửa sổ TCP.
- **Process Priority**: Ưu tiên luồng xử lý thời gian thực cho Valorant, khóa tiêu điểm Foreground chống giật màn hình.
- **Visuals & Memory**: Giữ phông chữ ClearType mượt mà, loại bỏ hiệu ứng hoạt họa Windows không cần thiết.
- **MMCSS & Audio**: Đưa tiến trình Games trong Multimedia Scheduler lên mức High, giảm thiểu DPC jitter cho âm thanh footstep.

---

## ⚠️ Disclaimer

Công cụ cung cấp khả năng tự động sao lưu Snapshot trước khi thực hiện bất kỳ thay đổi nào. Bạn luôn có thể dùng tính năng **Restore** để hoàn trả thiết lập ban đầu. Hãy luôn duy trì thói quen chơi game điều độ và bảo vệ sức khỏe!

---

## 📞 Support & Community

Tham gia cộng đồng kỹ thuật và nhận hỗ trợ 1-1 từ đội ngũ phát triển:

[![Discord Support](https://img.shields.io/badge/Discord-Join%20Community-7289DA?logo=discord&logoColor=white)](https://discord.gg/Xx4pcdvHkw)

---

<div align="center">
  <b>Powered by VieX Digital &copy; 2024 - 2026</b>
</div>
