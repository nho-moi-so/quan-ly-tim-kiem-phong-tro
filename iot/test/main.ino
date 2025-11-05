#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <string>
#include <ESP32Servo.h>
#include <Keypad.h>

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
const char* ssid = "abcxyz";       // Tên WiFi
const char* password = "12345678";     // Mật khẩu WiFi

// Thông tin về căn hộ
String roomCode = "";

//thông tin host server
String hostServer = "http://10.54.183.42:3000";

void setup(){
  Serial.begin(115200);
  delay(1000);
  
  // Khởi tạo LCD
  lcd.init();
  lcd.backlight();
  lcd.clear();
  lcd.setCursor(0, 0);
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
}
void loop(){
    // Kiểm tra lại kết nối mỗi 10 giây
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Mat ket noi WiFi! Dang thu ket noi lai...");
    WiFi.reconnect();
  }

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
    String postData = "{\"roomCode\":\"" + roomCodeData + "\"}";
    int httpResponseCode = http.POST(postData);
    
    if (httpResponseCode > 0) {
      String payload = http.getString();

      // --- Phân tích JSON ---
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      // Lấy giá trị "status" và "message"
      String status = doc["status"];
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
        http.addHeader("Content-Type", "application/json");

        // Dữ liệu JSON để gửi
        postData = "{\"otpCode\":\"" +passwordData+ "\",\"roomCode\":\""+roomCodeData+"\"}";
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

    // Gửi mật khẩu kiểm tra
    HTTPClient http;
    String url = hostServer + "/api/iot/verify-password";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    String postData = "{\"password\":\"" + inputPassword + "\",\"roomCode\":\"" + roomCode + "\"}";
    int httpResponseCode = http.POST(postData);

    if (httpResponseCode > 0) {
      String payload = http.getString();
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);
      String status = doc["status"];
      String message = doc["message"];
      
      lcd.clear();
      lcd.setCursor(0, 0);
      if (status == "success") {
        if (currentAngle != 180) {
          lcd.print("Mo cua...");
          myServo.write(180);      // xoay đến 180° và giữ
          currentAngle = 180;
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
      lcd.print(message.substring(0, 16));
      delay(2000);

      if (error) {
        lcd.clear();
        lcd.setCursor(0, 0);
        lcd.print("Loi JSON!");
        delay(1500);
        http.end();
        return;
      }
    } else {
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("Loi ket noi!");
      lcd.setCursor(0, 1);
      lcd.print(http.errorToString(httpResponseCode));
      delay(2000);
    }
    http.end();
  }

 
}