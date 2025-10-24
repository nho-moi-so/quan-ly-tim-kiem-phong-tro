#include <Wire.h>
#include <LiquidCrystal_I2C.h>
#include <WiFi.h>
#include <ArduinoJson.h>
#include <HTTPClient.h>
#include <string>

// Thông tin mạng WiFi
const char* ssid = "MINH KHANG";       // Tên WiFi
const char* password = "20012016";     // Mật khẩu WiFi

// Thông tin về căn hộ
String roomCode = "";

void setup(){
  Serial.begin(115200);
  delay(1000);
  Serial.println();
  Serial.println("Dang ket noi WiFi...");

  WiFi.begin(ssid, password);

  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }

  Serial.println("");
  Serial.println("Da ket noi WiFi!");
  

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
    HTTPClient http;
    String url = "http://192.168.2.144:3000/api/iot/connect-room";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");

    // Chờ người dùng nhập
    Serial.println("Nhap gia tri cho 'roomCode' va nhan Enter:");
    while (!Serial.available());  // Dừng cho đến khi có dữ liệu    
    String roomCodeData = Serial.readStringUntil('\n'); // Đọc chuỗi nhập
    roomCodeData.trim();  // Xóa ký tự xuống dòng, khoảng trắng thừa

    // Dữ liệu JSON để gửi
    String postData = "{\"roomCode\":\"" + roomCodeData + "\"}";
    int httpResponseCode = http.POST(postData);
    if (httpResponseCode > 0) {
      Serial.println(httpResponseCode);
      String payload = http.getString();

      // --- Phân tích JSON ---
      StaticJsonDocument<200> doc;
      DeserializationError error = deserializeJson(doc, payload);

      // Lấy giá trị "status" và "message"
      String status = doc["status"];
      String message = doc["message"];

      Serial.println("Status cua connect-room: " + status); //done 
      Serial.println("Message cua connect-room: " + message); //done
      if(status == "success"){
        //===================================================goi /api/iot/verify-otp
        url = "http://192.168.2.144:3000/api/iot/verify-otp";
        http.begin(url);
        http.addHeader("Content-Type", "application/json");
        // Chờ người dùng nhập
        Serial.println("Nhap gia tri cho 'passwordData' va nhan Enter:");
        while (!Serial.available());  // Dừng cho đến khi có dữ liệu      
        String passwordData = Serial.readStringUntil('\n'); // Đọc chuỗi nhập
        passwordData.trim();  // Xóa ký tự xuống dòng, khoảng trắng thừa

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

          Serial.println("Status cua verify-otp" + status);
          Serial.println("Message cua verify-otp" + message);
          if(status == "success"){
            roomCode = roomCodeData;
          }

          if (error) {
            Serial.print("Loi parse JSON1: ");
            Serial.println(error.c_str());
            return;
          }
        }
      }
      

      if (error) {
        Serial.print("Loi parse JSON:");
        Serial.println(error.c_str());
        return;
      }    
    }
    else {
        Serial.print("Loi POST: ");
        Serial.println(httpResponseCode);
    }
    http.end();
  }
  else{
    Serial.println("Da ket noi IOT voi App voi roomCode la:" + roomCode);
  }

 
}