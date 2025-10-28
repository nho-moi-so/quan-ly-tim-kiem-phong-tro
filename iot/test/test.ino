// #include <Wire.h>
// #include <LiquidCrystal_I2C.h>
// #include <Keypad.h>
// #include <ESP32Servo.h>
// #include <WiFi.h>
// #include <HTTPClient.h>

// // ============================Biến Global=========================
// // LCD
// LiquidCrystal_I2C lcd(0x27, 16, 2);

// // Keypad
// const byte ROWS = 4;
// const byte COLS = 4;

// char keys[ROWS][COLS] = {
//   {'1','2','3','A'},
//   {'4','5','6','B'},
//   {'7','8','9','C'},
//   {'*','0','#','D'}
// };
// byte rowPins[ROWS] = {9, 8, 7, 6};
// byte colPins[COLS] = {5, 4, 3, 2};
// Keypad keypad = Keypad(makeKeymap(keys), rowPins, colPins, ROWS, COLS);

// // Servo
// int currentAngle = 0; //lưu góc quay hiện tại của servo
// Servo myServo;
// const int servoPin = 18; // Chân kết nối servo

// // WiFi
// String ssid = "";
// String password = "";
// bool isWifiConnected = false;

// // // Room
// // String roomCode = "";
// // String otpCode = "";
// // String inputPassword = ""; // Mật khẩu nhập từ keypad
// // bool isRoomConnected = false;

// // // Trạng thái setup
// // bool isLCDReady = false;
// // bool isServoReady = false;
// bool isWifiReady = false;
// // bool isRoomReady = false;


// void setup() {
//   Serial.begin(115200);
  
//   // // ==Khởi tạo LCD==
//   // lcd.begin();
//   // lcd.backlight();
//   // lcd.clear();
//   // lcd.setCursor(0, 0);
//   // lcd.print("Khoi tao...");
//   // delay(1000);
//   // isLCDReady = true;
  
//   // // ==Khởi tạo Servo==
//   // myServo.attach(servoPin);
//   // myServo.write(currentAngle); // Góc ban đầu
//   // isServoReady = true;
  
//   // ==Kiểm tra và kết nối WiFi==
//   if (WiFi.status() != WL_CONNECTED) {
//     // Yêu cầu nhập SSID
//     lcd.clear();
//     lcd.setCursor(0, 0);
//     lcd.print("Nhap SSID (#: Enter, *: Back):");
//     lcd.setCursor(0, 1);
//     ssid = "";
//     while (ssid == "") {
//         char key = keypad.getKey();
//         if (key) {
//         if (key == '#') {
//           break; // Kết thúc nhập
//         } else if (key == '*') {
//             if (ssid.length() > 0) {
//             ssid.remove(ssid.length() - 1); // Xóa ký tự cuối
//             lcd.setCursor(0, 1);
//             lcd.print("                "); // Xóa dòng
//             lcd.setCursor(0, 1);
//             lcd.print(ssid);
//             }
//         } else {
//             ssid += key;
//             lcd.print(key);
//         }
//         }
//     }
    
//     // Yêu cầu nhập Password
//     lcd.clear();
//     lcd.setCursor(0, 0);
//     lcd.print("Nhap Mat Khau:");
//     lcd.setCursor(0, 1);
//     password = "";
//     while (password == "") {
//         char key = keypad.getKey();
//         if (key) {
//         if (key == '#') {
//           break; // Kết thúc nhập
//         } else if (key == '*') {
//             if (password.length() > 0) {
//             password.remove(password.length() - 1); // Xóa ký tự cuối
//             lcd.setCursor(0, 1);
//             lcd.print("                "); // Xóa dòng
//             lcd.setCursor(0, 1);
//             for (int i = 0; i < password.length(); i++) {
//               lcd.print(key);
//             }
//           }
//         } else {
//           password += key;
//           lcd.print(key);
//         }
//       }
//     }
    
//     // Kết nối WiFi
//     lcd.clear();
//     lcd.setCursor(0, 0);
//     lcd.print("Ket noi WiFi...");
//     WiFi.begin(ssid.c_str(), password.c_str());
    
//     int attempts = 0;
//     while (WiFi.status() != WL_CONNECTED && attempts < 20) {
//       delay(500);
//       lcd.print(".");
//       attempts++;
//     }
    
//     if (WiFi.status() == WL_CONNECTED) {
//       isWifiConnected = true;
//       isWifiReady = true;
//       lcd.clear();
//       lcd.setCursor(0, 0);
//       lcd.print("WiFi Ket noi!");
//       lcd.setCursor(0, 1);
//       lcd.print(WiFi.localIP());
//       delay(2000);
//     } else {
//       lcd.clear();
//       lcd.setCursor(0, 0);
//       lcd.print("WiFi That bai!");
//       delay(2000);
//     }
//   } else {
//     isWifiConnected = true;
//     isWifiReady = true;
//   }
  
//   // // ==Kiểm tra và kết nối Room==
//   // if (isWifiConnected && !isRoomConnected) {
//   //   // Yêu cầu nhập mã phòng
//   //   lcd.clear();
//   //   lcd.setCursor(0, 0);
//   //   lcd.print("Nhap Ma Phong:");
//   //   lcd.setCursor(0, 1);
//   //   roomCode = "";
//   //   while (roomCode == "") {
//   //     char key = keypad.getKey();
//   //     if (key) {
//   //       if (key == '#') {
//   //         break; // Kết thúc nhập
//   //       } else if (key == '*') {
//   //         if (roomCode.length() > 0) {
//   //           roomCode.remove(roomCode.length() - 1); // Xóa ký tự cuối
//   //           lcd.setCursor(0, 1);
//   //           lcd.print("                "); // Xóa dòng
//   //           lcd.setCursor(0, 1);
//   //           lcd.print(roomCode);
//   //         }
//   //       } else {
//   //         roomCode += key;
//   //         lcd.print(key);
//   //       }
//   //     }
//   //   }
    
//     // // Gọi API kết nối phòng
//     // if (roomCode != "") {
//     //   HTTPClient http;
//     //   http.begin("http://your-api-server.com/api/iot/connect-room");
//     //   http.addHeader("Content-Type", "application/json");
//     //   String requestBody = "{\"roomCode\":\"" + roomCode + "\"}";
//     //   int httpResponseCode = http.POST(requestBody);
      
//     //   if (httpResponseCode == 200) {
//     //     // Yêu cầu nhập OTP
//     //     lcd.clear();
//     //     lcd.setCursor(0, 0);
//     //     lcd.print("Nhap OTP:");
//     //     lcd.setCursor(0, 1);
//     //     otpCode = "";
//     //     while (otpCode.length() < 6) {
//     //       char key = keypad.getKey();
//     //       if (key) {
//     //         if (key >= '0' && key <= '9') {
//     //           otpCode += key;
//     //           lcd.print(key);
//     //         } else if (key == '*' && otpCode.length() > 0) {
//     //           otpCode.remove(otpCode.length() - 1); // Xóa ký tự cuối
//     //           lcd.setCursor(0, 1);
//     //           lcd.print("                "); // Xóa dòng
//     //           lcd.setCursor(0, 1);
//     //           lcd.print(otpCode);
//     //         }
//     //       }
//     //     }
        
//   //       // Xác thực OTP (giả lập thành công)
//   //       // POST API xác thực OTP
//   //       HTTPClient http;
//   //       http.begin("http://your-api-server.com/api/iot/verify-otp");
//   //       http.addHeader("Content-Type", "application/json");
//   //       String requestBody = "{\"otpCode\":\"" + otpCode + "\"}";
//   //       int httpResponseCode = http.POST(requestBody);

//   //       if (httpResponseCode == 200) {
//   //           //lấy thông tin trong response
//   //           String response = http.getString();
//   //           // giả lập trong body response có chứa "success": true
//   //           if (response.indexOf("\"success\":true") != -1) {
//   //             isRoomConnected = true;
//   //             isRoomReady = true;
//   //             lcd.clear();
//   //             lcd.setCursor(0, 0);
//   //             lcd.print("Ket noi thanh");
//   //           }
//   //           else {
//   //             lcd.clear();
//   //             lcd.setCursor(0, 0);
//   //             lcd.print("OTP sai!");
//   //             delay(2000);
//   //           }
//   //       } else {
//   //           lcd.clear();
//   //           lcd.setCursor(0, 0);
//   //           lcd.print("Loi ket noi!");
//   //           delay(2000);
//   //       }
//   //       lcd.setCursor(0, 1);
//   //       lcd.print("cong!");
//   //       delay(2000);
//   //     }
//   //     http.end();
//   //   }
//   // }
  
//   // // Hiển thị trạng thái hoàn thành setup
//   // lcd.clear();
//   // lcd.setCursor(0, 0);
//   // lcd.print("San sang!");
// }

// void loop() {
//   // char key = keypad.getKey();
//   // if (key) {
//   //   lcd.clear();
//   //   lcd.setCursor(0, 0);
//   //   lcd.print("Phim da nhan:");
//   //   lcd.setCursor(0, 1);
//   //   lcd.print(key);
    
//   //   if (key == '#') {
//   //     // Xác thực mật khẩu => POST API chứa mật khẩu lên để server kiểm tra
//   //     HTTPClient http;
//   //     http.begin("http://your-api-server.com/api/iot/room/verify-password");
//   //     http.addHeader("Content-Type", "application/json");
//   //     String requestBody = "{\"password\":\"" + inputPassword + "\",\"roomId\":\"" + roomCode + "\"}";
//   //     int httpResponseCode = http.POST(requestBody);

//   //     if (httpResponseCode == 200) {
//   //       //lấy thông tin trong response
//   //       String response = http.getString();
//   //       // giả lập trong body response có chứa "status": success
//   //       if (response.indexOf("\"status\":\"success\"") != -1) {
//   //         // Mở cửa - xoay servo 180 độ
//   //         lcd.clear();
//   //         lcd.setCursor(0, 0);
//   //         lcd.print("Mo cua...");
//   //         myServo.write(180);
//   //         delay(2000);
        
//   //         lcd.clear();
//   //         lcd.setCursor(0, 0);
//   //         lcd.print("Cua da mo!");
//   //         delay(2000);
//   //       }
//   //       else {
//   //         lcd.clear();
//   //         lcd.setCursor(0, 0);
//   //         lcd.print("Sai mat khau!");
//   //         delay(2000);
//   //       }

//   //   }
//   //   else{
//   //     lcd.println(key);
//   //     inputPassword += key;
//   //   }
    
//   //   // Delay ngắn để tránh đọc phím liên tục
//   //   delay(200);
//   // }

// }


// =============================================================
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
// //=============================================================================================
// // #include <Wire.h>
// // #include <LiquidCrystal_I2C.h>
// // #include <WiFi.h>
// // #include <ArduinoJson.h>
// // #include <HTTPClient.h>

// // // Thông tin mạng WiFi
// // const char* ssid = "POCO M6 Pro";       // Tên WiFi
// // const char* password = "212804@#*";     // Mật khẩu WiFi

// // // Khởi tạo LCD với địa chỉ 0x27, kích thước 16x2
// // LiquidCrystal_I2C lcd(0x27, 16, 2);

// // void setup() {
// //   Serial.begin(115200);
// //   delay(1000);
// //   Serial.println();
// //   Serial.println("Dang ket noi WiFi...");
// //   lcd.init();           // Khởi tạo LCD
// //   lcd.backlight();      // Bật đèn nền
// //   lcd.setCursor(0, 0);  // Đặt con trỏ tại dòng đầu
// //   lcd.print("Xin chao ESP32"); // In thông điệp
  
// //     WiFi.begin(ssid, password);

// //     while (WiFi.status() != WL_CONNECTED) {
// //       delay(500);
// //       Serial.print(".");
// //     }

// //     if (WiFi.status() == WL_CONNECTED) {
// //     HTTPClient http;

// //         // Dùng API test công khai
// //     String url = "https://quan-ly-tim-kiem-phong-tro-admin.vercel.app/api/iot/verify-password";

// //     http.begin(url);
// //     http.addHeader("Content-Type", "application/json");

// //         // Dữ liệu JSON để gửi
// //     String postData = "{\"password\":\"123456\",\"roomCode\":\"00001\"}";

// //     int httpResponseCode = http.POST(postData);

// //     if (httpResponseCode > 0) {
// //       Serial.print("POST thanh cong, ma HTTP: ");
// //       Serial.println(httpResponseCode);
// //       String payload = http.getString();
// //       Serial.println("Phan hoi tu server:");
// //       Serial.println(payload);

// //       // --- Phân tích JSON ---
// //       StaticJsonDocument<200> doc;
// //       DeserializationError error = deserializeJson(doc, payload);

// //       if (error) {
// //         Serial.print("Loi parse JSON: ");
// //         Serial.println(error.c_str());
// //         return;
// //       }

// //       // Lấy giá trị "status" và "message"
// //       const char* status = doc["status"];
// //       const char* message = doc["message"];

// //       // --- In ra LCD ---
// //       lcd.clear();
// //       lcd.setCursor(0, 0);
// //       lcd.print("status: ");
// //       lcd.print(status);

// //       lcd.setCursor(0, 1);
// //       lcd.print("data: ");
// //       lcd.print(message);

// //       // --- In ra Serial để kiểm tra ---
// //       Serial.print("Status: ");
// //       Serial.println(status);
// //       Serial.print("Data: ");
// //       Serial.println(message);
// //       } else {
// //         Serial.print("Loi POST: ");
// //         Serial.println(httpResponseCode);
// //       }

// //       http.end();
// //     } else {
// //       Serial.println("Chua ket noi WiFi, khong the POST!");
// //     }

// // }

// // void loop() {
// //   // Có thể cập nhật nội dung LCD tại đây nếu cần
// // }
