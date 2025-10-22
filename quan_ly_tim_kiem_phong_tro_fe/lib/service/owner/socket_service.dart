import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../navigation_service.dart';

class SocketService with ChangeNotifier {
  late IO.Socket socket;
  String? _otp;
  String? _roomCode;
  String? _roomName;
  String? _apartmentName;
  String? _connectionStatus;

  String? get otp => _otp;
  String? get roomCode => _roomCode;
  String? get roomName => _roomName;
  String? get apartmentName => _apartmentName;
  String? get connectionStatus => _connectionStatus;

  SocketService() {
    // Khởi tạo và kết nối ngay khi service được tạo
    initSocket();
  }

  void initSocket() {
    try {
      print('🔄 Initializing Socket...');
      
      // Thay đổi URL dựa trên môi trường:
      // - Android Emulator: http://10.0.2.2:3000
      // - iOS Simulator: http://localhost:3000
      // - Device thật (cùng WiFi): http://YOUR_IP:3000
      final serverUrl = 'http://192.168.2.144:3000';
      print('🌐 Connecting to: $serverUrl');
      
      socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionDelay(1000)
            .setReconnectionDelayMax(5000)
            .setReconnectionAttempts(5)
            .build(),
      );
      
      print('✅ Socket instance created');

      // Lắng nghe sự kiện kết nối
      socket.onConnect((_) {
        print('✅ Socket Connected: ${socket.id}');
        _connectionStatus = 'Connected';
        notifyListeners();

        // Join room A101 giống test-socket-client.js
        socket.emit('join_room', 'A101');
        print('📤 Sent join_room event with roomCode: A101');
      });

      // ⚠️ QUAN TRỌNG: Event name phải khớp với server
      // Server emit: 'otp_received' (không có dấu gạch ngang)
      socket.on('otp_received', (data) {
        print('🔑 OTP Received from server: $data');
        
        // Server trả về { otp, roomCode }
        _otp = data['otp']?.toString();  // Đổi từ 'otpCode' thành 'otp'
        _roomCode = data['roomCode']?.toString();
        _roomName = 'Phòng ${data['roomCode']}';  // Tạm thời generate
        _apartmentName = 'Tòa nhà A';  // Tạm thời hardcode
        _connectionStatus = 'OTP Ready';
        
        notifyListeners();
        
        // Tự động navigate đến màn hình OTP bằng named route
        print('🚀 Navigating to /iot-test screen...');
        navigationService.navigatorKey.currentState?.pushNamed('/iot-test');
      });

      // Event khi verify thành công
      socket.on('iot-verified', (data) {
        print('🎉 Verification Success: $data');
        _connectionStatus = 'Verification Successful';
        _otp = null;
        notifyListeners();
      });

      // Lắng nghe khi join room thành công
      socket.on('joined', (data) {
        print('✅ Joined room successfully: $data');
      });

      // Lắng nghe sự kiện ngắt kết nối
      socket.onDisconnect((_) {
        print('❌ Socket Disconnected');
        _connectionStatus = 'Disconnected';
        notifyListeners();
      });

      // Lắng nghe lỗi
      socket.onError((error) {
        print('🚨 Socket Error: $error');
        _connectionStatus = 'Error: $error';
        notifyListeners();
      });

      socket.onConnectError((error) {
        print('🚨 Socket Connect Error: $error');
        _connectionStatus = 'Connect Error: $error';
        notifyListeners();
      });
      
      // Debug: Log tất cả events
      socket.onAny((event, data) {
        print('📨 Event received: $event with data: $data');
      });

      // Bắt đầu kết nối
      print('🔌 Attempting to connect...');
      socket.connect();
    } catch (e) {
      print('❌ Socket Initialization Error: $e');
      _connectionStatus = 'Init Error: $e';
      notifyListeners();
    }
  }

  // Phương thức đóng socket
  void closeSocket() {
    socket.disconnect();
    socket.dispose();
  }

  // Reset OTP sau khi đã hiển thị hoặc verify
  void resetOtp() {
    _otp = null;
    _roomCode = null;
    _roomName = null;
    _apartmentName = null;
    notifyListeners();
  }

  @override
  void dispose() {
    closeSocket();
    super.dispose();
  }
}
