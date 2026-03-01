#include <WiFi.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <string>
#include <mbedtls/md.h>

// Servo giả lập
int currentAngle = 0; //lưu góc quay hiện tại của servo (giả lập)

// Thông tin mạng WiFi
const char* ssid = "MINH KHANG";       // Tên WiFi
const char* password = "20012016";     // Mật khẩu WiFi

// Thông tin về căn hộ
String roomCode = "";

//thông tin host server
String hostServer = "https://pluvious-shady-joline.ngrok-free.dev";
String blockchainServer = "http://tnbvx-171-252-155-96.a.free.pinggy.link";

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
    Serial.println("[PingReply] Success");
  } else {
    Serial.println("[PingReply] Error: " + String(httpResponseCode));
  }

  http.end();
}

void pollPasswordHash();

void delayWithPoll() {
      //### Kiểm tra và poll PingCode trong khi chờ nhập
  if (millis() - lastPollTime > 2000000) {
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
          Serial.println("[IoT] Da cap nhat passwordHash moi tu /api/get-password");
        }
      }
    }
  } else {
    Serial.println("[IoT] Loi poll /api/get-password: " + String(httpResponseCode));
  }

  http.end();
}

// Đọc 1 ký tự từ Serial (blocking, có poll)
char serialGetKey() {
  while (true) {
    delayWithPoll();
    if (Serial.available()) {
      char ch = Serial.read();
      if (ch == '\r' || ch == '\n') continue; // bỏ qua newline
      return ch;
    }
    delay(50);
  }
}

void setup(){
  Serial.begin(115200);

  delay(1000);
  
  Serial.println("\n\n===== SMART LOCK TEST (Serial thay LCD/Keypad/Servo) =====");
  Serial.println("Khoi dong...");
  delay(1000);
  
  // Hiển thị trạng thái kết nối WiFi
  Serial.println("\nKet noi WiFi...");
  Serial.println("SSID: " + String(ssid));

  WiFi.begin(ssid, password);

  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }

  if (WiFi.status() == WL_CONNECTED) {
    Serial.println("\nWiFi ket noi!");
    Serial.println("IP: " + WiFi.localIP().toString());
    delay(2000);
  } else {
    Serial.println("\nWiFi that bai!");
    delay(2000);
  }

  // Giả lập Servo: góc ban đầu = 0
  currentAngle = 0;
  
  Serial.println("San sang!");
  delay(1000);

  // ================ GỌI API RE-CONNECT ================
  Serial.println("\nKiem tra ket noi...");
  
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
        roomCode = doc["roomCode"].as<String>();
        
        Serial.println("Da ket noi!");
        Serial.println("Phong: " + roomCode);
        delay(2000);
      } else {
        Serial.println("Chua ket noi!");
        Serial.println("Can nhap ma phong");
        delay(2000);
      }
    }
  } else {
    Serial.println("Loi reconnect API");
    delay(1500);
  }
  http.end();
}

void loop(){
  // Poll PingCode + PasswordHash
  delayWithPoll();

  //neu roomCode rong thi ket noi iot voi app
  if(roomCode == ""){
    //===================================goi /api/iot/connect-room============================
    
    Serial.println("\nNhap Ma Phong:");
    Serial.println("#:OK *:Xoa");
    delay(1500);
    
    Serial.print("Ma Phong: ");
    
    String roomCodeData = "";
    bool inputComplete = false;
    
    while (!inputComplete) {
      delayWithPoll();
      
      char key = serialGetKey();
      if (key) {
        if (key == '#') {
          if (roomCodeData.length() > 0) {
            inputComplete = true;
            Serial.println();
          }
        } else if (key == '*') {
          if (roomCodeData.length() > 0) {
            roomCodeData.remove(roomCodeData.length() - 1);
            Serial.print("\r");
            Serial.print("Ma Phong: " + roomCodeData + "  ");
            Serial.print("\r");
            Serial.print("Ma Phong: " + roomCodeData);
          }
        } else {
          if (roomCodeData.length() < 16) {
            roomCodeData += key;
            Serial.print(key);
          }
        }
      }
    }
    
    Serial.println("Dang ket noi...");
    Serial.println("Ma phong: " + roomCodeData);
    
    HTTPClient http;
    String url = hostServer + "/api/iot/connect-room";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");

    String postData = "{\"roomCode\":\"" + roomCodeData + "\",\"type_iot\":\"" + type_iot + "\",\"deviceId\":\"" + device_id + "\"}";
    int httpResponseCode = http.POST(postData);
    
    if (httpResponseCode > 0) {
      String payload = http.getString();

      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      String status = doc["status"];
      bool access = doc["access"] | false;
      String message = doc["message"];

      if (status == "success") {
        Serial.println("Thanh cong!");
      } else {
        Serial.println("That bai!");
      }
      Serial.println(message.substring(0, 16));
      delay(2000);
      
      if(status == "success"){
        //===================================================goi /api/iot/verify-otp
        
        Serial.println("\nNhap OTP (6 so):");
        Serial.println("#:OK *:Xoa");
        delay(1500);
        
        Serial.print("OTP: ");
        
        String passwordData = "";
        inputComplete = false;
        
        while (!inputComplete) {
          delayWithPoll();
          
          char key = serialGetKey();
          if (key) {
            if (key == '#') {
              if (passwordData.length() == 6) {
                inputComplete = true;
                Serial.println();
              } else {
                Serial.println("\nOTP phai 6 so!");
                delay(1000);
                Serial.print("OTP: " + passwordData);
              }
            } else if (key == '*') {
              if (passwordData.length() > 0) {
                passwordData.remove(passwordData.length() - 1);
                Serial.print("\r");
                Serial.print("OTP: " + passwordData + "  ");
                Serial.print("\r");
                Serial.print("OTP: " + passwordData);
              }
            } else if (key >= '0' && key <= '9') {
              if (passwordData.length() < 6) {
                passwordData += key;
                Serial.print(key);
              }
            }
          }
        }
        
        Serial.println("Xac thuc OTP...");
        
        url = hostServer + "/api/iot/verify-otp";
        http.begin(url);
        http.addHeader("Content-Type", "application/json");

        // Dữ liệu JSON để gửi
        postData = "{\"otpCode\":\"" +passwordData+ "\",\"roomCode\":\""+roomCodeData+"\",\"deviceId\":\"" + device_id + "\"}";
        Serial.println("POST: " + postData);
        httpResponseCode = http.POST(postData);
        
        if (httpResponseCode > 0) {
          payload = http.getString();
          Serial.println("Response: " + payload);
          //  --- Phân tích JSON ---
          StaticJsonDocument<200> docVerifyOTP;
          DeserializationError error = deserializeJson(docVerifyOTP, payload);
          
          // Lấy giá trị "status" và "message"
          String status = docVerifyOTP["status"];
          String message = docVerifyOTP["message"];

          // Hiển thị kết quả OTP trên LCD
          // lcd.clear();
          // lcd.setCursor(0, 0);
          if (status == "success") {
            // lcd.print("OTP dung!");
            Serial.println("OTP dung!");
            roomCode = roomCodeData; // Lưu roomCode
            // lcd.setCursor(0, 1);
            // lcd.print("Da ket noi!");
            Serial.println("Da ket noi!");
          } else {
            // lcd.print("OTP sai!");
            // lcd.setCursor(0, 1);
            // lcd.print(message.substring(0, 16));
            Serial.println("OTP sai!");
            Serial.println("Message: " + message);
          }
          delay(2000);

          if (error) {
            Serial.println("Loi JSON!");
            delay(1500);
            return;
          }
        } else {
          Serial.println("Loi POST OTP:");
          Serial.println(http.errorToString(httpResponseCode));
          delay(2000);
        }
      }
      
      if (error) {
        Serial.println("Loi JSON!");
        delay(1500);
        return;
      }    
    }
    else {
        Serial.println("Loi ket noi!");
        Serial.println(http.errorToString(httpResponseCode));
        delay(2000);
    }
    http.end();
  }
  else{
    // Hiển thị mã phòng + hướng dẫn, chờ nhấn '#' để vào nhập mật khẩu
    String line1 = "Ma phong:" + roomCode;
    if (line1.length() > 16) line1 = line1.substring(0, 16);
    Serial.println("\n" + line1);
    Serial.println("Nhan # de nhap MK");

    // Chờ '#'
    while (true) {
      delayWithPoll();
      
      char k = serialGetKey();
      if (k == '#') break;
      delay(50);
    }

    // Màn hình nhập mật khẩu
    Serial.println("\nNhap mat khau:");
    Serial.println("#:OK *:Xoa");
    delay(1500);
    Serial.print("Mat khau: ");
    String inputPassword = "";
    bool inputComplete = false;
    while (!inputComplete) {
      delayWithPoll();
      
      char key = serialGetKey();
      if (key) {
        if (key == '#') {
          if (inputPassword.length() > 0) {
            inputComplete = true;
            Serial.println();
          }
        } else if (key == '*') {
          if (inputPassword.length() > 0) {
            inputPassword.remove(inputPassword.length() - 1);
            Serial.print("\r");
            Serial.print("Mat khau: " + inputPassword + "  ");
            Serial.print("\r");
            Serial.print("Mat khau: " + inputPassword);
          }
        } else {
          if (inputPassword.length() < 16) {
            inputPassword += key;
            Serial.print(key);
          }
        }
      }
    }

    // Xác thực offline: chỉ hash và so sánh với currentPasswordHash đã lưu
    if (currentPasswordHash.length() == 0) {
      Serial.println("Chua co du lieu");
      Serial.println("hash mat khau");
      delay(2000);
    } else {
      String inputPasswordHash = hashPassword(inputPassword);

      if (inputPasswordHash == currentPasswordHash) {
        if (currentAngle != 90) {
          Serial.println("Mo cua...");
          currentAngle = 90; // giả lập servo xoay 90°
          delay(500);
          Serial.println("Cua da mo!");
        } else {
          Serial.println("Da mo roi!");
        }
      } else {
        Serial.println("Sai mat khau!");
      }
      Serial.println("Offline compare");
      delay(2000);
    }
  }

  // =================================================================================
  // LOGIC MỚI: XỬ LÝ ĐÓNG/MỞ CỬA
  // =================================================================================

  // 1. Hiển thị màn hình chờ dựa trên trạng thái cửa
  if (currentAngle == 90) {
    Serial.println("\nCua dang MO");
    Serial.println("Nhan # de DONG");
  } else {
    String line1 = "Ma phong:" + roomCode;
    if (line1.length() > 16) line1 = line1.substring(0, 16);
    Serial.println("\n" + line1);
    Serial.println("Nhan # de nhap MK");
  }

  // 2. Vòng lặp chờ nhấn nút
  bool startLoginProcess = false;

  while (true) {
    delayWithPoll();

    char k = serialGetKey();

    if (k == '#') {
      if (currentAngle == 90) {
        // --- TRƯỜNG HỢP CỬA ĐANG MỞ -> ĐÓNG CỬA ---
        Serial.println("Dang dong cua...");
        currentAngle = 0; // giả lập servo quay về 0°
        delay(1000);
        Serial.println("Cua da dong!");
        delay(1000);
        break;
      } else {
        // --- TRƯỜNG HỢP CỬA ĐANG ĐÓNG -> NHẬP MẬT KHẨU ---
        startLoginProcess = true;
        break;
      }
    }
    delay(50);
  }

  // 3. Chỉ thực hiện nhập mật khẩu nếu cờ startLoginProcess được bật
  if (startLoginProcess) {

    Serial.println("\nNhap mat khau:");
    Serial.println("#:OK *:Xoa");
    delay(1500);
    Serial.print("Mat khau: ");
    String inputPassword = "";
    bool inputComplete = false;

    while (!inputComplete) {
      delayWithPoll();
      char key = serialGetKey();
      if (key) {
        if (key == '#') {
          if (inputPassword.length() > 0) {
            inputComplete = true;
            Serial.println();
          }
        } else if (key == '*') {
          if (inputPassword.length() > 0) {
            inputPassword.remove(inputPassword.length() - 1);
            Serial.print("\r");
            Serial.print("Mat khau: " + inputPassword + "  ");
            Serial.print("\r");
            Serial.print("Mat khau: " + inputPassword);
          }
        } else {
          if (inputPassword.length() < 16) {
            inputPassword += key;
            Serial.print(key);
          }
        }
      }
    }

    // Xác thực offline: chỉ hash và so sánh với currentPasswordHash đã lưu
    if (currentPasswordHash.length() == 0) {
      Serial.println("Chua co du lieu");
      Serial.println("hash mat khau");
      delay(2000);
    } else {
      String inputPasswordHash = hashPassword(inputPassword);

      if (inputPasswordHash == currentPasswordHash) {
          Serial.println("Mo cua...");
          currentAngle = 90; // giả lập servo xoay 90°
          delay(500);
          Serial.println("Cua da mo!");
      } else {
        Serial.println("Sai mat khau!");
      }
      Serial.println("Offline compare");
      delay(2000);
    }
  }
}
