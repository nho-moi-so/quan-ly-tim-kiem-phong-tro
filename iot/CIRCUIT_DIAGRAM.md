# SƠ ĐỒ MẠCH HỆ THỐNG QUẢN LÝ PHÒNG TRỌ IOT

## 📋 DANH SÁCH LINH KIỆN

### Vi điều khiển
- **ESP32 DevKit V1** (hoặc tương tự)
  - WiFi tích hợp
  - 30 GPIO pins

### Thiết bị ngoại vi
1. **LCD I2C 16x2**
   - Module LCD với giao tiếp I2C
   - Địa chỉ: 0x27
   
2. **Keypad 4x4**
   - Ma trận phím 4 hàng x 4 cột
   - 16 phím (0-9, A-D, *, #)

3. **Servo Motor SG90** (hoặc tương tự)
   - Góc quay: 0-180°
   - Điện áp: 5V

---

## 🔌 Sơ ĐỒ KẾT NỐI CHI TIẾT

### 1️⃣ LCD I2C 16x2 ↔ ESP32

| LCD I2C Pin | ESP32 Pin | Mô tả |
|-------------|-----------|-------|
| VCC | 5V hoặc 3.3V | Nguồn dương |
| GND | GND | Nguồn âm (mass) |
| SDA | GPIO 21 | Dữ liệu I2C |
| SCL | GPIO 22 | Xung nhịp I2C |

**Lưu ý:**
- Hầu hết module LCD I2C hoạt động tốt với 3.3V và 5V
- SDA/SCL là các chân I2C mặc định của ESP32

---

### 2️⃣ Keypad 4x4 ↔ ESP32

#### Cấu hình trong code:
```cpp
byte rowPins[ROWS] = {32, 33, 25, 26}; // R1-R4
byte colPins[COLS] = {27, 14, 12, 13}; // C1-C4
```

#### Bảng kết nối:

**HÀNG (ROWS):**
| Keypad Pin | ESP32 GPIO | Mô tả |
|------------|------------|-------|
| R1 | GPIO 32 | Hàng 1 (1, 2, 3, A) |
| R2 | GPIO 33 | Hàng 2 (4, 5, 6, B) |
| R3 | GPIO 25 | Hàng 3 (7, 8, 9, C) |
| R4 | GPIO 26 | Hàng 4 (*, 0, #, D) |

**CỘT (COLUMNS):**
| Keypad Pin | ESP32 GPIO | Mô tả |
|------------|------------|-------|
| C1 | GPIO 27 | Cột 1 (1, 4, 7, *) |
| C2 | GPIO 14 | Cột 2 (2, 5, 8, 0) |
| C3 | GPIO 12 | Cột 3 (3, 6, 9, #) |
| C4 | GPIO 13 | Cột 4 (A, B, C, D) |

#### Ma trận phím:
```
┌───┬───┬───┬───┐
│ 1 │ 2 │ 3 │ A │  ← Row 1 (GPIO 32)
├───┼───┼───┼───┤
│ 4 │ 5 │ 6 │ B │  ← Row 2 (GPIO 33)
├───┼───┼───┼───┤
│ 7 │ 8 │ 9 │ C │  ← Row 3 (GPIO 25)
├───┼───┼───┼───┤
│ * │ 0 │ # │ D │  ← Row 4 (GPIO 26)
└───┴───┴───┴───┘
  ↑   ↑   ↑   ↑
 C1  C2  C3  C4
GPIO GPIO GPIO GPIO
 27  14  12  13
```

**Lưu ý:**
- Keypad không cần điện riêng, ESP32 cấp nguồn qua GPIO
- Thư viện Keypad sử dụng pull-up nội bộ
- Các GPIO này đã được test và hoạt động ổn định với ESP32

---

### 3️⃣ Servo Motor ↔ ESP32

| Servo Pin | ESP32 Pin | Mô tả |
|-----------|-----------|-------|
| VCC (Red) | 5V | Nguồn dương |
| GND (Brown/Black) | GND | Nguồn âm |
| Signal (Orange/Yellow) | GPIO 18 | Tín hiệu PWM |

**Cấu hình trong code:**
```cpp
const int servoPin = 18;

// Trong setup():
myServo.setPeriodHertz(50);           // Tần số PWM 50Hz
myServo.attach(servoPin, 500, 2400);  // Min/Max pulse width
myServo.write(0);                     // Góc ban đầu
```

**Lưu ý quan trọng:**
- ⚠️ **Servo tiêu thụ nhiều dòng!** Nếu servo rung giật hoặc ESP32 reset:
  - Dùng nguồn ngoài 5V riêng cho servo (adapter 5V/2A)
  - Nối chung GND giữa nguồn ngoài và ESP32
  - Chỉ nối Signal vào GPIO 18
- **Cấu hình PWM:** 
  - Pulse width: 500-2400 µs (tùy loại servo)
  - Tần số: 50Hz (chu kỳ 20ms)
- **Góc quay:**
  - 0° = Cửa đóng
  - 90° = Vị trí giữa (mặc định)
  - 180° = Cửa mở

---

## 🔋 SƠ ĐỒ NGUỒN

### Tùy chọn 1: Nguồn đơn giản (Test)
```
USB (5V) → ESP32
            ├→ LCD (3.3V hoặc 5V)
            ├→ Keypad (GPIO power)
            └→ Servo (5V) ⚠️ Có thể không ổn định
```

### Tùy chọn 2: Nguồn ổn định (Khuyến nghị)
```
USB (5V) → ESP32 → LCD + Keypad

Adapter 5V/2A → Servo VCC
                └→ GND nối chung với ESP32 GND
```

---

## 📐 SƠ ĐỒ TỔNG QUAN

```
                    ╔═══════════════════════════╗
                    ║       ESP32 DevKit        ║
                    ║                           ║
   LCD I2C          ║  GPIO 21 (SDA) ←──────┐  ║
   ┌─────────┐      ║  GPIO 22 (SCL) ←──────┤  ║
   │  VCC────┼──────║  3.3V/5V              │  ║
   │  GND────┼──────║  GND                  │  ║
   │  SDA────┼──────║                       │  ║
   │  SCL────┼──────║                       │  ║
   └─────────┘      ║                       │  ║
                    ║                       │  ║
   Keypad 4x4       ║                       │  ║
   ┌─────────┐      ║  GPIO 32 ←── R1      │  ║
   │ R1──────┼──────║  GPIO 33 ←── R2      │  ║
   │ R2──────┼──────║  GPIO 25 ←── R3      │  ║
   │ R3──────┼──────║  GPIO 26 ←── R4      │  ║
   │ R4──────┼──────║  GPIO 27 ←── C1      │  ║
   │ C1──────┼──────║  GPIO 14 ←── C2      │  ║
   │ C2──────┼──────║  GPIO 12 ←── C3      │  ║
   │ C3──────┼──────║  GPIO 13 ←── C4      │  ║
   │ C4──────┼──────║                       │  ║
   └─────────┘      ║                       │  ║
                    ║                       │  ║
   Servo SG90       ║  GPIO 18 ←── Signal   │  ║
   ┌─────────┐      ║  5V      ←── VCC     │  ║
   │ Signal──┼──────║  GND     ←── GND     │  ║
   │ VCC─────┼──────║                       │  ║
   │ GND─────┼──────║                       │  ║
   └─────────┘      ╚═══════════════════════════╝
```

---

## 🛠️ THƯ VIỆN CẦN CÀI ĐẶT

Trong Arduino IDE, cài đặt các thư viện sau qua **Tools → Manage Libraries**:

1. **LiquidCrystal I2C** - by Frank de Brabander
2. **Keypad** - by Mark Stanley, Alexander Brevig
3. **ESP32Servo** - by Kevin Harrington
4. **ArduinoJson** - by Benoit Blanchon
5. **WiFi** - Built-in với ESP32 board
6. **HTTPClient** - Built-in với ESP32 board

---

## ✅ CHECKLIST TRƯỚC KHI CHẠY

- [ ] Tất cả thư viện đã được cài đặt
- [ ] Chọn đúng board: **ESP32 Dev Module** trong Arduino IDE
- [ ] Chọn đúng Port COM
- [ ] Kiểm tra lại tất cả kết nối dây
- [ ] Đảm bảo nguồn đủ mạnh (5V/2A nếu dùng servo)
- [ ] Cập nhật SSID và password WiFi trong code
- [ ] Cập nhật địa chỉ hostServer
- [ ] Kiểm tra địa chỉ I2C của LCD (0x27 hoặc 0x3F)

---

## 🔍 KIỂM TRA ĐỊA CHỈ I2C LCD

Nếu LCD không hiển thị, chạy I2C Scanner:

```cpp
#include <Wire.h>

void setup() {
  Wire.begin();
  Serial.begin(115200);
  Serial.println("\nI2C Scanner");
}

void loop() {
  byte error, address;
  int nDevices;
  Serial.println("Scanning...");
  nDevices = 0;
  for(address = 1; address < 127; address++ ) {
    Wire.beginTransmission(address);
    error = Wire.endTransmission();
    if (error == 0) {
      Serial.print("I2C device found at address 0x");
      if (address<16) Serial.print("0");
      Serial.println(address,HEX);
      nDevices++;
    }
  }
  if (nDevices == 0) Serial.println("No I2C devices found\n");
  else Serial.println("done\n");
  delay(5000);
}
```

Địa chỉ phổ biến: **0x27** hoặc **0x3F**

---

## 🎯 LUỒNG HOẠT ĐỘNG

1. **Khởi động** → LCD hiển thị "Khoi dong..."
2. **Kết nối WiFi** → LCD hiển thị IP address
3. **Nhập mã phòng** → Keypad (nhấn # để OK)
4. **Server gửi OTP** → Ứng dụng mobile nhận
5. **Nhập OTP** → Keypad (6 số, nhấn # để OK)
6. **Xác thực thành công** → Lưu roomCode
7. **Nhập mật khẩu** → Keypad (nhấn # để mở cửa)
8. **Servo quay 180°** → Cửa mở
9. **Servo quay về 0°** → Cửa đóng

---

## ⚠️ LƯU Ý QUAN TRỌNG

1. **GPIO Đã Test và Hoạt Động:**
   - **Keypad Rows:** GPIO 32, 33, 25, 26
   - **Keypad Cols:** GPIO 27, 14, 12, 13
   - **Servo Signal:** GPIO 18
   - **LCD I2C:** GPIO 21 (SDA), GPIO 22 (SCL)
   - ⚠️ **Tránh GPIO:** 0, 2, 15 (có thể gây lỗi boot)

2. **Servo Power:**
   - Servo SG90 tiêu thụ 100-300mA khi quay
   - ESP32 USB chỉ cung cấp ~500mA → Dễ bị sụt áp
   - **Khuyến nghị:** Dùng nguồn ngoài 5V/2A cho servo

3. **Servo Configuration:**
   - Sử dụng `setPeriodHertz(50)` để set tần số 50Hz
   - Sử dụng `attach(pin, 500, 2400)` với pulse width phù hợp
   - Test góc quay: 0° → 90° → 180°

4. **Keypad Debouncing:**
   - Thư viện Keypad đã xử lý debounce
   - Nếu phím bị nhảy → Thêm delay(50) sau getKey()

5. **LCD Contrast:**
   - Nếu LCD hiển thị mờ → Xoay biến trở trên module I2C
   - Sử dụng `lcd.init()` thay vì `lcd.begin()` với một số module

---

## 🔧 TROUBLESHOOTING

| Vấn đề | Nguyên nhân | Giải pháp |
|--------|-------------|-----------|
| LCD không sáng | Sai kết nối hoặc sai địa chỉ I2C | Kiểm tra SDA/SCL, chạy I2C Scanner |
| Keypad không phản hồi | Sai rowPins/colPins | Kiểm tra lại kết nối theo code |
| Servo rung giật | Nguồn yếu | Dùng nguồn ngoài 5V/2A |
| ESP32 reset liên tục | Servo kéo dòng quá mạnh | Tách nguồn servo |
| WiFi không kết nối | Sai SSID/password hoặc WiFi 5GHz | Dùng WiFi 2.4GHz, kiểm tra thông tin |
| HTTP POST lỗi -1 | Server không khả dụng hoặc sai URL | Kiểm tra hostServer, ping thử |

---

## 📸 HÌNH ẢNH THAM KHẢO

### Pinout ESP32:
```
                       ┌─────────────┐
                       │   USB Port  │
                       └─────────────┘
        ┌───────────────────────────────────────┐
        │  3V3                            GND   │
        │  EN                             GPIO23│
        │  GPIO36 (VP)                    GPIO22│ ← SCL (LCD)
        │  GPIO39 (VN)                    GPIO1 │
        │  GPIO34                         GPIO3 │
        │  GPIO35                         GPIO21│ ← SDA (LCD)
        │  GPIO32 ← Keypad R1             GND   │
        │  GPIO33 ← Keypad R2             GPIO19│
        │  GPIO25 ← Keypad R3             GPIO18│ ← Servo Signal
        │  GPIO26 ← Keypad R4             GPIO5 │
        │  GPIO27 ← Keypad C1             GPIO17│
        │  GPIO14 ← Keypad C2             GPIO16│
        │  GPIO12 ← Keypad C3             GPIO4 │
        │  GND                            GPIO0 │
        │  GPIO13 ← Keypad C4             GPIO2 │
        │  GPIO9                          GPIO15│
        │  GPIO10                         GPIO8 │
        │  GPIO11                         GPIO7 │
        │  5V                             GPIO6 │
        └───────────────────────────────────────┘
```

---

## 📞 HỖ TRỢ

Nếu gặp vấn đề:
1. Kiểm tra Serial Monitor (115200 baud)
2. Đảm bảo tất cả dây nối chắc chắn
3. Test từng module riêng biệt trước khi kết hợp
4. Kiểm tra nguồn điện đủ mạnh

---

**Chúc bạn thành công! 🎉**
