#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <string>
#include <ESP32Servo.h>
#include <Keypad.h>
#include <mbedtls/md.h>

//LCD
LiquidCrystal_I2C lcd(0x27, 16, 2); //0x27 hoặc 0x3F

//keypad
const byte ROWS = 4;
const byte COLS = 4;

char keys[ROWS][COLS] = {
  {'1','2','3','A'},
  {'4','5','6','B'},
  {'7','8','9','C'},
  {'*','0','#','D'}
};
byte rowPins[ROWS] = {32, 33, 25, 26}; // R1-R4
byte colPins[COLS] = {27, 14, 12, 13}; // C1-C4
Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// Servo
int currentAngle = 0; //lưu góc quay hiện tại của servo
Servo myServo;
const int servoPin = 18; // Chân kết nối servo

// Thông tin mạng WiFi
const char* ssid = "Là CAFE 24H";       // Tên WiFi
const char* password = "";     // Mật khẩu WiFi

// Thông tin về căn hộ
String roomCode = "";

//thông tin host server
String hostServer = "https://pluvious-shady-joline.ngrok-free.dev";
String blockchainServer = "https://zvpta-115-75-106-79.run.pinggy-free.link";

//Thông tin của thiết bị iot này
String type_iot = "smart_lock";
String device_id = "LOCK001";

// Trạng thái ping từ server
String lastPingCode = "";
unsigned long lastPollTime = 0;
unsigned long lastPasswordPollTime = 0;

//biến lưu mật khẩu
String currentPasswordHash = "";

// Hàm băm SHA-256 ngay trên IoT
String hashPassword(String rawInput) {
    char payload[64];
    rawInput.toCharArray(payload, 64);
    
    byte shaResult[32];
    mbedtls_md_context_t ctx;
    mbedtls_md_type_t md_type = MBEDTLS_MD_SHA256; // Dùng thuật toán SHA-256

    mbedtls_md_init(&ctx);
    mbedtls_md_setup(&ctx, mbedtls_md_info_from_type(md_type), 0);
    mbedtls_md_starts(&ctx);
    mbedtls_md_update(&ctx, (const unsigned char *) payload, strlen(payload));
    mbedtls_md_finish(&ctx, shaResult);
    mbedtls_md_free(&ctx);

    // Chuyển mảng byte thành chuỗi Hex (chữ thường) để dễ so sánh
    String hashHex = "";
    for (int i = 0; i < 32; i++) {
        char str[3];
        sprintf(str, "%02x", (int)shaResult[i]);
        hashHex += str;
    }
    return hashHex;
}

// Poll server lấy PingCode, nếu đổi thì gửi PingReply
void pollPingCode() {
  if (roomCode == "") {
    return; // Chỉ poll khi đã connect thành công
  }

  HTTPClient http;
  String url = hostServer + "/api/iot/devices/" + roomCode + "/ping?deviceId=" + device_id;

  http.begin(url);
  int httpResponseCode = http.GET();

  if (httpResponseCode == 200) {
    String payload = http.getString();

    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, payload);

    if (!error) {
      String currentPingCode = doc["pingCode"] | "";

      // Nếu PingCode mới thì phản hồi lại
      if (currentPingCode.length() > 0 && currentPingCode != lastPingCode) {
        lastPingCode = currentPingCode;
        updatePingReply(currentPingCode);
      }

    }
  }

  http.end();
}

// Gửi PingReply về server để xác nhận online
void updatePingReply(String pingCode) {
  HTTPClient http;
  String url = hostServer + "/api/iot/devices/" + roomCode + "/ping";

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  String postData = "{\"deviceId\":\"" + device_id + "\",\"pingReply\":\"" + pingCode + "\"}";
  int httpResponseCode = http.POST(postData);

  if (httpResponseCode == 200) {

  } else {
    lcd.setCursor(0, 0);
    lcd.println("[IoT] Error sending PingReply: " + String(httpResponseCode));
    delay(1000);
    lcd.clear();
  }

  http.end();
}

void pollPasswordHash();

void delayWithPoll() {
      // Kiểm tra và poll PingCode trong khi chờ nhập
  if (millis() - lastPollTime > 2000) {
    pollPingCode();
    lastPollTime = millis();
  }

  // Poll password hash mỗi 1 phút
  if (millis() - lastPasswordPollTime > 60000) {
    pollPasswordHash();
    lastPasswordPollTime = millis();
  }
}

// Poll password hash từ blockchain server mỗi 5 phút
void pollPasswordHash() {
  if (roomCode == "") {
    return; // Chỉ poll khi đã connect thành công
  }

  HTTPClient http;
  String url = blockchainServer + "/api/get-password";

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  String postData = "{\"roomCode\":\"" + roomCode + "\"}";
  int httpResponseCode = http.POST(postData);

  if (httpResponseCode == 200) {
    String payload = http.getString();

    StaticJsonDocument<256> doc;
    DeserializationError error = deserializeJson(doc, payload);

    if (!error) {
      String status = doc["status"] | "";
      String newPasswordHash = doc["passwordHash"] | "";

      if (status == "success" && newPasswordHash.length() > 0) {
        if (newPasswordHash != currentPasswordHash) {
          currentPasswordHash = newPasswordHash;
          // // ---- THAY THẾ SERIAL BẰNG LCD (THÀNH CÔNG) ----
          // lcd.clear();
          // lcd.setCursor(0, 0);
          // lcd.print(" nhat MK:"); // 12 ký tự
          // lcd.setCursor(0, 1);
          // lcd.print("Thanh cong!"); // 11 ký tự
          // delay(2000); // Dừng 2 giây để người dùng đọc thông báo
          // ----------------------------------------------
        }
      }
    }
  } else {
    // ---- THAY THẾ SERIAL BẰNG LCD (BÁO LỖI SERVER) ----
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Loi tai MK:"); // 11 ký tự
    lcd.setCursor(0, 1);
    lcd.print("Ma: " + String(httpResponseCode)); // Ví dụ: "Ma: -1" hoặc "Ma: 500"
    delay(2000); // Dừng 2 giây để xem mã lỗi
    // ---------------------------------------------------
  }

  http.end();
}

void setup(){
  Serial.begin(115200);

  delay(1000);
  
  // Khởi tạo LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.print("Khoi dong...");
  delay(1000);
  
  // Hiển thị trạng thái kết nối WiFi
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Ket noi WiFi...");
  lcd.setCursor(0, 1);
  lcd.print(ssid);

  WiFi.begin(ssid, password);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    lcd.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("WiFi ket noi!");
    lcd.setCursor(0, 1);
    lcd.print(WiFi.localIP());
    delay(2000);
  } else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("WiFi that bai!");
    delay(2000);
  }

  // Khởi tạo Servo
  myServo.setPeriodHertz(50);
  myServo.attach(servoPin, 500, 2400);
  myServo.write(currentAngle); // Góc ban đầu
  
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("San sang!");
  delay(1000);

  // ================ GỌI API RE-CONNECT ================
  // Kiểm tra xem device đã được kết nối với phòng nào chưa
  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print("Kiem tra ket noi");
  lcd.setCursor(0, 1);
  lcd.print("...");
  
  HTTPClient http;
  String url = hostServer + "/api/iot/re-connect";
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  
  String postData = "{\"deviceId\":\"" + device_id + "\"}";
  int httpResponseCode = http.POST(postData);
  
  if (httpResponseCode > 0) {
    String payload = http.getString();
    StaticJsonDocument<200> doc;
    DeserializationError error = deserializeJson(doc, payload);
    
    if (!error) {
      String status = doc["status"];
      
      if (status == "success") {
        // Device đã được kết nối trước đó
        roomCode = doc["roomCode"].as<String>();
        
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Da ket noi!");
        lcd.setCursor(0, 1);
        lcd.print("Phong: " + roomCode);
        delay(2000);
      } else {
        // Device chưa được kết nối
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Chua ket noi!");
        lcd.setCursor(0, 1);
        lcd.print("Can nhap ma phong");
        delay(2000);
      }
    }
  } else {
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Loi reconnect API");
    delay(1500);
  }
  http.end();
}
void loop(){
  // Poll PingCode mỗi 500ms để cập nhật PingReply
  delayWithPoll();

  //neu roomCode rong thi ket noi iot voi app
  if(roomCode == ""){
    //===================================goi /api/iot/connect-room============================
    
    // Nhập roomCode từ Keypad
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Nhap Ma Phong:");
    lcd.setCursor(0, 1);
    lcd.print("#:OK *:Xoa");
    delay(1500);
    
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Ma Phong:");
    lcd.setCursor(0, 1);
    
    String roomCodeData = "";
    bool inputComplete = false;
    
    while (!inputComplete) {
      // Kiểm tra và poll PingCode trong khi chờ nhập
      delayWithPoll();
      
      char key = keypad.getKey();
      if (key) {
        if (key == '#') {
          if (roomCodeData.length() > 0) {
            inputComplete = true; // Kết thúc nhập
          }
        } else if (key == '*') {
          if (roomCodeData.length() > 0) {
            roomCodeData.remove(roomCodeData.length() - 1); // Xóa ký tự cuối
            lcd.setCursor(0, 1);
            lcd.print("                "); // Xóa dòng
            lcd.setCursor(0, 1);
            lcd.print(roomCodeData);
          }
        } else {
          if (roomCodeData.length() < 16) { // Giới hạn độ dài
            roomCodeData += key;
            lcd.print(key);
          }
        }
      }
    }
    
    // Hiển thị đang kết nối
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Dang ket noi...");
    lcd.setCursor(0, 1);
    lcd.print(roomCodeData);
    
    HTTPClient http;
    String url = hostServer + "/api/iot/connect-room";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");

    // Dữ liệu JSON để gửi
    String postData = "{\"roomCode\":\"" + roomCodeData + "\",\"type_iot\":\"" + type_iot + "\",\"deviceId\":\"" + device_id + "\"}";
    int httpResponseCode = http.POST(postData);
    
    if (httpResponseCode > 0) {
      String payload = http.getString();

      // --- Phân tích JSON ---
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      // Lấy giá trị "status" và "message"
      String status = doc["status"];
      bool access = doc["access"] | false;
      String message = doc["message"];

      // Hiển thị kết quả trên LCD
      lcd.clear();
      lcd.setCursor(0, 0);
      if (status == "success") {
        lcd.print("Thanh cong!");
      } else {
        lcd.print("That bai!");
      }
      lcd.setCursor(0, 1);
      lcd.print(message.substring(0, 16)); // Giới hạn 16 ký tự
      delay(2000);
      
      if(status == "success"){
        // roomCodeData = roomCodeData + "_" + device_id; // luu roomCodeData voi deviceId
        //===================================================goi /api/iot/verify-otp
        
        // Nhập OTP từ Keypad
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Nhap OTP (6 so):");
        lcd.setCursor(0, 1);
        lcd.print("#:OK *:Xoa");
        delay(1500);
        
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("OTP:");
        lcd.setCursor(0, 1);
        
        String passwordData = "";
        inputComplete = false;
        
        while (!inputComplete) {
          // Kiểm tra và poll PingCode trong khi chờ nhập
          delayWithPoll();
          
          char key = keypad.getKey();
          if (key) {
            if (key == '#') {
              if (passwordData.length() == 6) {
                inputComplete = true; // OTP phải đủ 6 số
              } else {
                lcd.setCursor(0, 0);
                lcd.print("OTP phai 6 so!  ");
                delay(1000);
                lcd.setCursor(0, 0);
                lcd.print("OTP:            ");
              }
            } else if (key == '*') {
              if (passwordData.length() > 0) {
                passwordData.remove(passwordData.length() - 1);
                lcd.setCursor(0, 1);
                lcd.print("                ");
                lcd.setCursor(0, 1);
                lcd.print(passwordData);
              }
            } else if (key >= '0' && key <= '9') {
              if (passwordData.length() < 6) {
                passwordData += key;
                lcd.print(key);
              }
            }
          }
        }
        
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Xac thuc OTP...");
        
        url = hostServer + "/api/iot/verify-otp";
        http.begin(url);
        // TĂNG THỜI GIAN CHỜ LÊN 15 GIÂY (15000ms)
        http.setTimeout(15000);
        http.addHeader("Content-Type", "application/json");

        // Dữ liệu JSON để gửi
        postData = "{\"otpCode\":\"" +passwordData+ "\",\"roomCode\":\""+roomCodeData+"\",\"deviceId\":\"" + device_id + "\"}";
        httpResponseCode = http.POST(postData);
        
        if (httpResponseCode > 0) {
          payload = http.getString();
          //  --- Phân tích JSON ---
          StaticJsonDocument<200> docVerifyOTP;
          DeserializationError error = deserializeJson(docVerifyOTP, payload);
          
          // Lấy giá trị "status" và "message"
          String status = docVerifyOTP["status"];
          String message = docVerifyOTP["message"];

          // Hiển thị kết quả OTP trên LCD
          lcd.clear();
          lcd.setCursor(0, 0);
          if (status == "success") {
            lcd.print("OTP dung!");
            roomCode = roomCodeData; // Lưu roomCode
            lcd.setCursor(0, 1);
            lcd.print("Da ket noi!");
            pollPasswordHash();
          } else {
            lcd.print("OTP sai!");
            lcd.setCursor(0, 1);
            lcd.print(message.substring(0, 16));
          }
          delay(2000);

          if (error) {
            lcd.clear();
            lcd.setCursor(0, 0);
            lcd.print("Loi JSON!");
            delay(1500);
            return;
          }
        } else {
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Loi POST OTP:");
          lcd.setCursor(0, 1);
          lcd.print(http.errorToString(httpResponseCode));
          delay(2000);
        }
      }
      

      if (error) {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Loi JSON!");
        delay(1500);
        return;
      }    
    }
    else {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Loi ket noi!");
        lcd.setCursor(0, 1);
        lcd.print(http.errorToString(httpResponseCode));
        delay(2000);
    }
    http.end();
  }
  else{
    // Hiển thị mã phòng + hướng dẫn, chờ nhấn '#' để vào nhập mật khẩu
    lcd.clear();
    lcd.setCursor(0, 0);
    String line1 = "Ma phong:" + roomCode;
    if (line1.length() > 16) line1 = line1.substring(0, 16);
    lcd.print(line1);
    lcd.setCursor(0, 1);
    lcd.print("Nhan # de nhap MK");

    // Chờ '#'
    while (true) {
      // Kiểm tra và poll PingCode trong khi chờ nhập
      delayWithPoll();
      
      char k = keypad.getKey();
      if (k == '#') break;
      delay(50);
    }

    // Màn hình nhập mật khẩu
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Nhap mat khau:");
    String inputPassword = "";
    lcd.setCursor(0, 1);
    lcd.print("#:OK *:Xoa");
    delay(1500);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Mat khau:");
    lcd.setCursor(0, 1);
    inputPassword = "";
    bool inputComplete = false;
    while (!inputComplete) {
      // Kiểm tra và poll PingCode trong khi chờ nhập
      delayWithPoll();
      
      char key = keypad.getKey();
      if (key) {
        if (key == '#') {
          if (inputPassword.length() > 0) inputComplete = true;
        } else if (key == '*') {
          if (inputPassword.length() > 0) {
            inputPassword.remove(inputPassword.length() - 1);
            lcd.setCursor(0, 1);
            lcd.print("                ");
            lcd.setCursor(0, 1);
            lcd.print(inputPassword);
          }
        } else {
          if (inputPassword.length() < 16) {
            inputPassword += key;
            lcd.print(key);
          }
        }
      }
    }

    // Xác thực offline: chỉ hash và so sánh với currentPasswordHash đã lưu
    lcd.clear();
    lcd.setCursor(0, 0);

    if (currentPasswordHash.length() == 0) {
      lcd.print("Chua co du lieu");
      lcd.setCursor(0, 1);
      lcd.print("hash mat khau");
      delay(2000);
    } else {
      String inputPasswordHash = hashPassword(inputPassword);

      if (inputPasswordHash == currentPasswordHash) {
        if (currentAngle != 90) {
          lcd.print("Mo cua...");
          myServo.write(90);      // xoay đến 90° và giữ
          currentAngle = 90;
          delay(500);
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Cua da mo!");
        } else {
          lcd.print("Da mo roi!");
        }
      } else {
        lcd.print("Sai mat khau!");
      }
      lcd.setCursor(0, 1);
      lcd.print("Offline compare");
      delay(2000);
    }
  }

  // =================================================================================
  // LOGIC MỚI: XỬ LÝ ĐÓNG/MỞ CỬA
  // =================================================================================

  // 1. Hiển thị màn hình chờ dựa trên trạng thái cửa
  lcd.clear();
  lcd.setCursor(0, 0);

  if (currentAngle == 90) {
    // Cửa đang MỞ
    lcd.print("Cua dang MO");
    lcd.setCursor(0, 1);
    lcd.print("Nhan # de DONG");
  } else {
    // Cửa đang ĐÓNG
    String line1 = "Ma phong:" + roomCode;
    if (line1.length() > 16) line1 = line1.substring(0, 16);
    lcd.print(line1);
    lcd.setCursor(0, 1);
    lcd.print("Nhan # de nhap MK");
  }

  // 2. Vòng lặp chờ nhấn nút
  bool startLoginProcess = false; // Biến cờ để biết có vào nhập mật khẩu không

  while (true) {
    // Kiểm tra và poll PingCode trong khi chờ nhập
    delayWithPoll();

    char k = keypad.getKey();

    if (k == '#') {
      if (currentAngle == 90) {
        // --- TRƯỜNG HỢP CỬA ĐANG MỞ -> ĐÓNG CỬA ---
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Dang dong cua...");

        myServo.write(0);      // Quay servo về 0 độ
        currentAngle = 0;      // Cập nhật trạng thái
        delay(1000);

        lcd.clear();
        lcd.print("Cua da dong!");
        delay(1000);
        break; // Thoát vòng lặp chờ, quay lại đầu loop() để hiện trạng thái "Đã đóng"
      } else {
        // --- TRƯỜNG HỢP CỬA ĐANG ĐÓNG -> NHẬP MẬT KHẨU ---
        startLoginProcess = true; // Bật cờ để chạy đoạn code nhập pass bên dưới
        break;
      }
    }
    delay(50);
  }

  // 3. Chỉ thực hiện nhập mật khẩu nếu cờ startLoginProcess được bật
  if (startLoginProcess) {

    // Màn hình nhập mật khẩu (Code cũ giữ nguyên)
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Nhap mat khau:");
    String inputPassword = "";
    lcd.setCursor(0, 1);
    lcd.print("#:OK *:Xoa");
    delay(1500);
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print("Mat khau:");
    lcd.setCursor(0, 1);
    inputPassword = "";
    bool inputComplete = false;

    while (!inputComplete) {
      delayWithPoll();
      char key = keypad.getKey();
      if (key) {
        if (key == '#') {
          if (inputPassword.length() > 0) inputComplete = true;
        } else if (key == '*') {
          if (inputPassword.length() > 0) {
            inputPassword.remove(inputPassword.length() - 1);
            lcd.setCursor(0, 1);
            lcd.print("                ");
            lcd.setCursor(0, 1);
            lcd.print(inputPassword);
          }
        } else {
          if (inputPassword.length() < 16) {
            inputPassword += key;
            lcd.print(key);
          }
        }
      }
    }

    // Xác thực offline: chỉ hash và so sánh với currentPasswordHash đã lưu
    lcd.clear();
    lcd.setCursor(0, 0);

    if (currentPasswordHash.length() == 0) {
      lcd.print("Chua co du lieu");
      lcd.setCursor(0, 1);
      lcd.print("hash mat khau");
      delay(2000);
    } else {
      String inputPasswordHash = hashPassword(inputPassword);

      if (inputPasswordHash == currentPasswordHash) {
          lcd.print("Mo cua...");
          myServo.write(90);      // xoay đến 90°
          currentAngle = 90;      // Lưu trạng thái mở
          delay(500);
          lcd.clear();
          lcd.setCursor(0, 0);
          lcd.print("Cua da mo!");
      } else {
        lcd.print("Sai mat khau!");
      }
      lcd.setCursor(0, 1);
      lcd.print("Offline compare");
      delay(2000);
    }
  }
}