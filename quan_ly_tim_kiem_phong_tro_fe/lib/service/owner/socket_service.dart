import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  // Singleton pattern
  static final SocketService _instance = SocketService._internal();

  factory SocketService() {
    return _instance;
  }

  SocketService._internal() {
    // Khởi tạo và kết nối ngay khi service được tạo
    initSocket();
  }

  void initSocket() {
    try {
      print('🔄 Initializing Socket...');
      final serverUrl = dotenv.env['HOST_SERVER'];
      if(serverUrl == null) {
        throw Exception('HOST_SERVER is not defined in .env file');
      }
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

        //== Join rooms sẽ được gọi từ bên ngoài sau khi lấy danh sách phòng
        // Không join ngay ở đây nữa
      });

      // ⚠️ QUAN TRỌNG: Event name phải khớp với server
      // Server emit: 'otp_received' (không có dấu gạch ngang)
      socket.on('otp_received', (data) {
        print('🔑 OTP Received from server: $data');
        
        bool isAlreadyReady = _connectionStatus == 'OTP Ready';

        // Server trả về { otp, roomCode }
        _otp = data['otp']?.toString();  // Đổi từ 'otpCode' thành 'otp'
        _roomCode = data['roomCode']?.toString();
        _roomName = '${data['roomCode']}';  // Tạm thời generate
        // _apartmentName = 'Tòa nhà A';  // Tạm thời hardcode
        _connectionStatus = 'OTP Ready';
        
        notifyListeners();
        
        if (!isAlreadyReady) {
          // Tự động navigate đến màn hình OTP bằng named route
          print('🚀 Navigating to /iot-test screen...');
          navigationService.navigatorKey.currentState?.pushNamed('/iot-test');
        }
      });

      // Event khi verify thành công
      socket.on('iot-verified', (data) {
        print('🎉 Verification Success: $data');
        _connectionStatus = 'Verification Successful';
        
        // Reset OTP
        _otp = null;
        _roomCode = null;
        _roomName = null;
        _apartmentName = null;
        
        notifyListeners();
        
        // Tự động đóng màn hình OTP (pop back)
        print('🚪 Closing OTP screen...');
        navigationService.navigatorKey.currentState?.pop();
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

  // Join nhiều rooms cùng lúc
  void joinRooms(List<String> roomCodes) {
    if (!socket.connected) {
      print('⚠️ Socket chưa kết nối, không thể join rooms');
      return;
    }

    print('📤 Joining ${roomCodes.length} rooms: ${roomCodes.join(", ")}');
    
    for (String roomCode in roomCodes) {
      socket.emit('join_room', roomCode);
      print('  ✅ Joined room: $roomCode');
    }
  }

  // Join một room đơn lẻ
  void joinRoom(String roomCode) {
    if (!socket.connected) {
      print('⚠️ Socket chưa kết nối, không thể join room');
      return;
    }

    socket.emit('join_room', roomCode);
    print('📤 Joined room: $roomCode');
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
