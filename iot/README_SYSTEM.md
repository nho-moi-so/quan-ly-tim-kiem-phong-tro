# 🏠 HỆ THỐNG IOT QUẢN LÝ PHÒNG TRỌ

Hệ thống điều khiển cửa thông minh dựa trên ESP32, tích hợp LCD, Keypad và Servo Motor.

## 📁 Cấu Trúc Thư Mục

```
iot/
├── test/
│   ├── main.ino          # Code chính của hệ thống
│   └── test.ino          # Code test các module riêng lẻ
├── CIRCUIT_DIAGRAM.md    # Sơ đồ mạch chi tiết
├── README.md            # Thông tin API Backend
└── README_SYSTEM.md     # File này - Hướng dẫn hệ thống
```

## 🎯 Tính Năng

### 1. **Kết nối WiFi**
- Tự động kết nối WiFi khi khởi động
- Hiển thị trạng thái kết nối trên LCD
- Hiển thị địa chỉ IP khi kết nối thành công

### 2. **Kết nối với Phòng (Room)**
- Nhập mã phòng qua Keypad
- Gửi yêu cầu kết nối đến server
- Xác thực OTP (6 số) từ ứng dụng mobile
- Lưu trữ thông tin phòng sau khi kết nối thành công

### 3. **Mở Cửa Bằng Mật Khẩu**
- Nhập mật khẩu qua Keypad
- Gửi request xác thực đến server
- Điều khiển Servo mở/đóng cửa khi xác thực thành công

### 4. **Hiển Thị LCD**
- Hiển thị trạng thái hệ thống
- Hướng dẫn người dùng nhập liệu
- Thông báo lỗi và kết quả xử lý

## 🔧 Linh Kiện Cần Thiết

| Linh kiện | Số lượng | Ghi chú |
|-----------|----------|---------|
| ESP32 DevKit V1 | 1 | Vi điều khiển chính |
| LCD I2C 16x2 | 1 | Địa chỉ 0x27 hoặc 0x3F |
| Keypad 4x4 | 1 | Ma trận phím |
| Servo SG90 | 1 | Điều khiển cửa |
| Adapter 5V/2A | 1 | Nguồn cho Servo (khuyến nghị) |
| Dây nối Dupont | 1 set | Kết nối các module |
| Breadboard | 1 | Test mạch |

## 📡 Kết Nối GPIO

### LCD I2C
- **SDA** → GPIO 21
- **SCL** → GPIO 22
- **VCC** → 3.3V/5V
- **GND** → GND

### Keypad 4x4
**Hàng (Rows):**
- R1 → GPIO 32
- R2 → GPIO 33
- R3 → GPIO 25
- R4 → GPIO 26

**Cột (Columns):**
- C1 → GPIO 27
- C2 → GPIO 14
- C3 → GPIO 12
- C4 → GPIO 13

### Servo Motor
- **Signal** → GPIO 18
- **VCC** → 5V (nguồn ngoài khuyến nghị)
- **GND** → GND

> 📖 **Chi tiết:** Xem file [CIRCUIT_DIAGRAM.md](./CIRCUIT_DIAGRAM.md) để có sơ đồ mạch đầy đủ.

## 🛠️ Cài Đặt

### 1. Cài đặt Arduino IDE
- Tải Arduino IDE từ [arduino.cc](https://www.arduino.cc/en/software)
- Cài đặt ESP32 Board Manager:
  - File → Preferences
  - Thêm URL: `https://dl.espressif.com/dl/package_esp32_index.json`
  - Tools → Board → Boards Manager → Tìm "ESP32" và cài đặt

### 2. Cài đặt Thư viện
Mở **Library Manager** (Tools → Manage Libraries) và cài đặt:

- `LiquidCrystal I2C` by Frank de Brabander
- `Keypad` by Mark Stanley, Alexander Brevig
- `ESP32Servo` by Kevin Harrington
- `ArduinoJson` by Benoit Blanchon
- `WiFi` (Built-in)
- `HTTPClient` (Built-in)

### 3. Cấu hình Code

Mở file `test/main.ino` và cập nhật:

```cpp
// Thông tin WiFi
const char* ssid = "TEN_WIFI_CUA_BAN";
const char* password = "MAT_KHAU_WIFI";

// Địa chỉ server
String hostServer = "http://IP_SERVER:PORT";

// Địa chỉ LCD (kiểm tra bằng I2C Scanner nếu cần)
LiquidCrystal_I2C lcd(0x27, 16, 2); // hoặc 0x3F
```

### 4. Upload Code

1. Chọn Board: **ESP32 Dev Module**
2. Chọn Port: COM port tương ứng
3. Nhấn Upload (Ctrl+U)

## 🚀 Hướng Dẫn Sử Dụng

### Lần Đầu Khởi Động

1. **Kết nối WiFi:**
   - LCD hiển thị "Ket noi WiFi..."
   - Chờ hiển thị IP address

2. **Kết nối Phòng:**
   - LCD hiển thị "Nhap Ma Phong:"
   - Nhập mã phòng bằng Keypad
   - Nhấn `#` để xác nhận
   - Nhập OTP (6 số) từ app
   - Nhấn `#` để xác nhận OTP

### Sử Dụng Hàng Ngày

1. **Mở Cửa:**
   - LCD hiển thị "Nhap mat khau:"
   - Nhập mật khẩu bằng Keypad
   - Nhấn `#` để mở cửa
   - Servo quay 180° (mở cửa)
   - Sau 2 giây tự động đóng (quay về 0°)

### Phím Chức Năng

- **Phím số 0-9, A-D:** Nhập ký tự
- **Phím `#`:** Xác nhận/Enter
- **Phím `*`:** Xóa ký tự cuối (Backspace)

## 🔍 Kiểm Tra Lỗi

### LCD không hiển thị
```bash
# Chạy I2C Scanner để kiểm tra địa chỉ
# Code trong CIRCUIT_DIAGRAM.md
```

### Keypad không phản hồi
- Kiểm tra lại kết nối GPIO
- Đảm bảo đúng thứ tự Rows và Cols

### Servo rung giật
- Dùng nguồn ngoài 5V/2A riêng cho servo
- Nối chung GND

### WiFi không kết nối
- Kiểm tra SSID và password
- Đảm bảo dùng WiFi 2.4GHz (ESP32 không hỗ trợ 5GHz)

### HTTP POST lỗi -1
- Kiểm tra server đang chạy
- Ping thử IP server từ máy tính
- Kiểm tra URL đúng format

## 📊 API Endpoints

Hệ thống giao tiếp với 3 API:

### 1. Kết nối phòng
```
POST /api/iot/connect-room
Body: {"roomCode": "00001"}
Response: {"status": "success", "message": "..."}
```

### 2. Xác thực OTP
```
POST /api/iot/verify-otp
Body: {"otpCode": "123456", "roomCode": "00001"}
Response: {"status": "success", "message": "..."}
```

### 3. Xác thực mật khẩu
```
POST /api/iot/verify-password
Body: {"password": "123456", "roomCode": "00001"}
Response: {"status": "success", "message": "..."}
```

> 📖 **Chi tiết API:** Xem file [README.md](./README.md) để biết yêu cầu chi tiết về API Backend.

## 🎥 Demo

### Luồng hoạt động:
```
[Khởi động] 
    ↓
[Kết nối WiFi] → Hiển thị IP
    ↓
[Nhập Mã Phòng] → POST connect-room
    ↓
[Nhập OTP] → POST verify-otp
    ↓
[Lưu roomCode]
    ↓
[Nhập Mật Khẩu] → POST verify-password
    ↓
[Mở Cửa] → Servo 0° → 180° → 0°
```

## ⚙️ Tham Số Cấu Hình

### Servo
```cpp
myServo.setPeriodHertz(50);           // 50Hz PWM
myServo.attach(servoPin, 500, 2400);  // Pulse width 500-2400µs
```

### Keypad
```cpp
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);
// Debounce time mặc định: 10ms
```

### LCD
```cpp
lcd.init();        // Khởi tạo
lcd.backlight();   // Bật đèn nền
lcd.clear();       // Xóa màn hình
lcd.setCursor(x, y); // Di chuyển con trỏ
lcd.print("Text"); // In text
```

## 🔐 Bảo Mật

- Mật khẩu không được lưu cục bộ
- Tất cả xác thực qua server
- OTP có thời gian sống ngắn
- Kết nối WiFi WPA2

## 🧪 Test Riêng Lẻ Từng Module

File `test/test.ino` chứa code test riêng:
- Test LCD
- Test Keypad
- Test Servo
- Test HTTP Request

## 📝 Changelog

### Version 1.0 (Current)
- ✅ Kết nối WiFi
- ✅ Kết nối phòng với OTP
- ✅ Mở cửa bằng mật khẩu
- ✅ Hiển thị LCD đầy đủ
- ✅ GPIO đã test và hoạt động ổn định
- ✅ Servo với cấu hình PWM tối ưu

### Tính năng dự kiến
- [ ] RFID/NFC reader
- [ ] Lưu log hoạt động
- [ ] Deep sleep mode
- [ ] OTA update

## 🤝 Đóng Góp

Nếu bạn muốn đóng góp:
1. Fork repository
2. Tạo branch mới (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📞 Liên Hệ & Hỗ Trợ

- **Repository:** [quan-ly-tim-kiem-phong-tro](https://github.com/nho-moi-so/quan-ly-tim-kiem-phong-tro)
- **Branch:** feature/owner
- **Issues:** Báo lỗi qua GitHub Issues

## 📄 License

MIT License - Xem file LICENSE để biết thêm chi tiết.

---

**Chúc bạn thành công! 🎉**

> 💡 **Tip:** Luôn test từng module riêng biệt trước khi kết hợp tất cả lại!
