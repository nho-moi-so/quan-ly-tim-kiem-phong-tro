#include <WiFi.h>
#include <HTTPClient.h>

// Thông tin mạng WiFi
const char* ssid = "POCO M6 Pro";       // Tên WiFi
const char* password = "212804@#*";     // Mật khẩu WiFi

void setup() {
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
  Serial.print("Dia chi IP cua ESP32: ");
  Serial.println(WiFi.localIP());

  // Test POST request sau khi kết nối
  testInternetConnection();
}

void loop() {
  // Kiểm tra lại kết nối mỗi 10 giây
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("Mat ket noi WiFi! Dang thu ket noi lai...");
    WiFi.reconnect();
  } else {
    // Gửi lại request test mỗi 30 giây
    testInternetConnection();
  }

  delay(30000);
}

void testInternetConnection() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    // Dùng API test công khai
    String url = "http://httpbin.org/post";


    http.begin(url);
    http.addHeader("Content-Type", "application/json");

    // Dữ liệu JSON để gửi
    String postData = "{\"device\":\"ESP32\",\"status\":\"connected\"}";

    int httpResponseCode = http.POST(postData);

    if (httpResponseCode > 0) {
      Serial.print("POST thanh cong, ma HTTP: ");
      Serial.println(httpResponseCode);
      String payload = http.getString();
      Serial.println("Phan hoi tu server:");
      Serial.println(payload);
    } else {
      Serial.print("Loi POST: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("Chua ket noi WiFi, khong the POST!");
  }
}
