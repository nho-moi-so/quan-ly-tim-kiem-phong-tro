// #include <Wire.h>
// #include <LiquidCrystal_I2C.h>
// #include <Keypad.h>
// #include <ESP32Servo.h>

// ============================Init LCD=========================
// Khởi tạo LCD: 
//LiquidCrystal_I2C lcd(0x27, 16, 2);
//cấu hình LCD
bool isSetupLCD(){
}

// ============================Init keypad========================
//khởi tạo keypad

//====================Init Servo========================
//khởi tạo Servo: tạo đối tượng, gán chân, góc quay ban đầu
//cấu hình Servo
bool isSetupServo(){
}
//========================Init Wifi========================
bool isSetupWifi(){
    bool isConnect = isConnectWifi();
    if(!isConnect){
        connectWifi();
        if(!isConnect){
            //==Kết nối thất bại, yêu cầu nhập lại==
        }
    }
}
//========================Init Room========================
bool isSetupRoom(){
    bool isConnectToRoom = isConnectRoom();
    if(!isConnectToRoom){
        //==Kết nối với phòng==
        bool isConnectRoomSuccess = connectRoom();
        if(!isConnectRoomSuccess){
            //==Kết nối thất bại, yêu cầu nhập lại==
        }
    }

}

//========================Phần các hàm thông dụng====================
//Hàm kiểm tra kết nối Wifi
bool isConnectWifi(){
    //...
}
bool connectWifi(){
    //==Kết nối Wifi==
    string ssid = getInputFromKeypad("Nhap SSID: "); //gọi LCD và Keypad với input là "nhập SSID" => output là string ssid
    string password = getInputFromKeypad("Nhap Mat Khau: "); //gọi LCD và Keypad với input là "nhập mật khẩu" => output là string password
    //...
}
//Hàm kiểm tra thiết bị iot đã kết nối với phòng chưa
bool isConnectRoom(){
    //...
}
bool connectRoom(){
    string roomCode = getInputFromKeypad("Nhap Ma Phong: ");
    // post request đến API để app hiện thông báo yêu cầu kết nối
    callRestAPI("/connect-room", "POST", "{\"roomCode\":\"" + roomCode + "\"}");
    //yêu cầu mã OTP từ phía app gồm 6 số (hiện thị trên LCD)
    getInputFromKeypad("Nhap OTP: ");
    //...
}
// hàm gọi API
void callRestAPI(string endpoint, string method, string? body){
    //...
}


//Hàm lấy dữ liệu từ Keypad
string getInputFromKeypad(string prompt){
    lcd.clear();
    // tạo biến lưu trữ dữ liệu nhập từ keypad
    // hiển thị prompt lên LCD
    // lặp để lấy dữ liệu từ keypad
    // trả về dữ liệu đã nhập
    //...
}


void setup() {
    //==Kiểm tra đã kết nối với Wifi chưa==
    bool isSetupWifiSuccess = isSetupWifi();
    //==Kiểm tra thiết bị iot đã kết nối với phòng chưa==
    bool isSetupRoomSuccess = isSetupRoom();
    //==Khởi tạo LCD==
    bool isSetupLCDSuccess = isSetupLCD();
    //==Khởi tạo Servo==
    bool isSetupServoSuccess = isSetupServo();

}

void loop() {

}
