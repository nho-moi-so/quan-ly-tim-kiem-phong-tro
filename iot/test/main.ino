// #include <WiFi.h>
// #include <HTTPClient.h>

// // Thông tin mạng WiFi
// const char* ssid = "POCO M6 Pro";       // Tên WiFi
// const char* password = "212804@#*";     // Mật khẩu WiFi

// void setup() {
//   Serial.begin(115200);
//   delay(1000);
//   Serial.println();
//   Serial.println("Dang ket noi WiFi...");

//   WiFi.begin(ssid, password);

//   while (WiFi.status() != WL_CONNECTED) {
//     delay(500);
//     Serial.print(".");
//   }

//   Serial.println("");
//   Serial.println("Da ket noi WiFi!");
//   Serial.print("Dia chi IP cua ESP32: ");
//   Serial.println(WiFi.localIP());

//   // Test POST request sau khi kết nối
//   testInternetConnection();
// }

// void loop() {
//   // Kiểm tra lại kết nối mỗi 10 giây
//   if (WiFi.status() != WL_CONNECTED) {
//     Serial.println("Mat ket noi WiFi! Dang thu ket noi lai...");
//     WiFi.reconnect();
//   } else {
//     // Gửi lại request test mỗi 30 giây
//     testInternetConnection();
//   }

//   delay(30000);
// }

// void testInternetConnection() {
//   if (WiFi.status() == WL_CONNECTED) {
//     HTTPClient http;

//     // Dùng API test công khai
//     String url = "http://httpbin.org/post";


//     http.begin(url);
//     http.addHeader("Content-Type", "application/json");

//     // Dữ liệu JSON để gửi
//     String postData = "{\"device\":\"ESP32\",\"status\":\"connected\"}";

//     int httpResponseCode = http.POST(postData);

//     if (httpResponseCode > 0) {
//       Serial.print("POST thanh cong, ma HTTP: ");
//       Serial.println(httpResponseCode);
//       String payload = http.getString();
//       Serial.println("Phan hoi tu server:");
//       Serial.println(payload);
//     } else {
//       Serial.print("Loi POST: ");
//       Serial.println(httpResponseCode);
//     }

//     http.end();
//   } else {
//     Serial.println("Chua ket noi WiFi, khong the POST!");
//   }
// }

#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>

// Thông tin mạng WiFi
const char* ssid = "POCO M6 Pro";       // Tên WiFi
const char* password = "212804@#*";     // Mật khẩu WiFi

// Khởi tạo LCD với địa chỉ 0x27, kích thước 16x2
LiquidCrystal_I2C lcd(0x27, 16, 2);

void setup() {
  Serial.begin(115200);
  delay(1000);
  Serial.println();
  Serial.println("Dang ket noi WiFi...");
  lcd.init();           // Khởi tạo LCD
  lcd.backlight();      // Bật đèn nền
  lcd.setCursor(0, 0);  // Đặt con trỏ tại dòng đầu
  lcd.print("Xin chao ESP32"); // In thông điệp
  
    WiFi.begin(ssid, password);

    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      Serial.print(".");
    }

    if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

        // Dùng API test công khai
    String url = "https://quan-ly-tim-kiem-phong-tro-admin.vercel.app/api/iot/verify-password";

    http.begin(url);
    http.addHeader("Content-Type", "application/json");

        // Dữ liệu JSON để gửi
    String postData = "{\"password\":\"123456\",\"roomCode\":\"00001\"}";

    int httpResponseCode = http.POST(postData);

    if (httpResponseCode > 0) {
      Serial.print("POST thanh cong, ma HTTP: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println("Phan hoi tu server:");
      Serial.println(payload);

      // --- Phân tích JSON ---
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      if (error) {
        Serial.print("Loi parse JSON: ");
        Serial.println(error.c_str());
        return;
      }

      // Lấy giá trị "status" và "message"
      const char* status = doc["status"];
      const char* message = doc["message"];

      // --- In ra LCD ---
      lcd.clear();
      lcd.setCursor(0, 0);
      lcd.print("status: ");
      lcd.print(status);

      lcd.setCursor(0, 1);
      lcd.print("data: ");
      lcd.print(message);

      // --- In ra Serial để kiểm tra ---
      Serial.print("Status: ");
      Serial.println(status);
      Serial.print("Data: ");
      Serial.println(message);
      } else {
        Serial.print("Loi POST: ");
        Serial.println(httpResponseCode);
      }

      http.end();
    } else {
      Serial.println("Chua ket noi WiFi, khong the POST!");
    }

}

void loop() {
  // Có thể cập nhật nội dung LCD tại đây nếu cần
}

