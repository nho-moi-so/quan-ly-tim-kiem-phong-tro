import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/iot_device.dart';

class IotDeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Lấy danh sách tất cả các loại thiết bị IOT mà hệ thống hỗ trợ
  /// Collection: iot_devices
  Future<List<IotDevice>> getAllSupportedDevices() async {
    try {
      final snapshot = await _firestore.collection('iot_devices').get();
      return snapshot.docs.map((doc) {
        return IotDevice.fromMap(doc.id, doc.data());
      }).toList();
    } catch (e) {
      print('❌ Error fetching IOT devices: $e');
      return [];
    }
  }

  /// Lấy thông tin một loại thiết bị theo ID
  Future<IotDevice?> getDeviceById(String deviceId) async {
    try {
      final doc = await _firestore.collection('iot_devices').doc(deviceId).get();
      if (doc.exists && doc.data() != null) {
        return IotDevice.fromMap(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('❌ Error fetching IOT device $deviceId: $e');
      return null;
    }
  }

  /// Lấy danh sách thiết bị IOT đã kết nối với một phòng
  /// Collection: iot_device_in_apartment 
  /// Document ID format: {roomCode}_{deviceId}
  /// Một phòng có thể có nhiều thiết bị
  Future<List<ConnectedIotDevice>> getConnectedDevicesForRoom(String roomCode) async {
    try {
      List<ConnectedIotDevice> connectedDevices = [];

      // Query documents có ID bắt đầu với roomCode_
      // Sử dụng orderBy và startAt/endAt để filter theo document ID
      final snapshot = await _firestore
          .collection('iot_device_in_apartment')
          .orderBy(FieldPath.documentId)
          .startAt(['${roomCode}_'])
          .endAt(['${roomCode}_\uf8ff']) // \uf8ff là ký tự Unicode cao nhất
          .get();

      print('🔍 Found ${snapshot.docs.length} devices for room $roomCode');

      for (var doc in snapshot.docs) {
        print('📱 Device doc ID: ${doc.id}');
        final data = doc.data();
        final iotDeviceId = data['IoTDeviceID'] as String?;
        
        // Lấy thông tin chi tiết của loại thiết bị
        IotDevice? deviceInfo;
        if (iotDeviceId != null && iotDeviceId.isNotEmpty) {
          deviceInfo = await getDeviceById(iotDeviceId);
        }

        connectedDevices.add(
          ConnectedIotDevice.fromMap(doc.id, data, deviceInfo: deviceInfo),
        );
      }

      return connectedDevices;
    } catch (e) {
      print('❌ Error fetching connected devices for room $roomCode: $e');
      return [];
    }
  }

  /// Kiểm tra xem có thiết bị IOT nào đã kết nối với phòng không
  Future<bool> hasConnectedDevices(String roomCode) async {
    try {
      // Document ID = roomCode
      final doc = await _firestore.collection('iot_device_in_apartment').doc(roomCode).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['Status'] == 'verified';
      }
      return false;
    } catch (e) {
      print('❌ Error checking connected devices: $e');
      return false;
    }
  }

  /// Kiểm tra kết nối của một thiết bị cụ thể
  Future<bool> checkDeviceConnection(String connectionId) async {
    try {
      final doc = await _firestore.collection('iot_device_in_apartment').doc(connectionId).get();
      if (doc.exists && doc.data() != null) {
        return doc.data()!['Status'] == 'verified';
      }
      return false;
    } catch (e) {
      print('❌ Error checking device connection: $e');
      return false;
    }
  }

  /// Lấy thông tin một thiết bị IOT cụ thể của phòng
  /// Document ID format: {roomCode}_{deviceId}
  Future<ConnectedIotDevice?> getConnectedDeviceByRoomAndDeviceId(String roomCode, String deviceId) async {
    try {
      final docId = '${roomCode}_$deviceId';
      final doc = await _firestore.collection('iot_device_in_apartment').doc(docId).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final iotDeviceId = data['IoTDeviceID'] as String?;
        
        // Lấy thông tin chi tiết của loại thiết bị
        IotDevice? deviceInfo;
        if (iotDeviceId != null && iotDeviceId.isNotEmpty) {
          deviceInfo = await getDeviceById(iotDeviceId);
        }

        return ConnectedIotDevice.fromMap(doc.id, data, deviceInfo: deviceInfo);
      }
      
      return null;
    } catch (e) {
      print('❌ Error fetching device $roomCode\_$deviceId: $e');
      return null;
    }
  }

  /// Kiểm tra trạng thái online/offline của thiết bị IOT qua API
  /// Public method để widget có thể gọi
  Future<String> callAPICheckIOTDevice(String deviceId) async {
      //POST /api/iot/devices/:roomCode/check
      //body: {deviceId: string}
      // respond:  status: online ? "success" : "fail",
            // message: online ? "Thiết bị đang trực tuyến" : "Thiết bị không phản hồi sau 5 giây",
            // roomCode,
            // deviceId,
            // online,

      //deviceId: 101_LOCK001
      String roomCode = deviceId.split('_')[0];
      String idOnly = deviceId.substring(roomCode.length + 1);

      final String? serverDomain = dotenv.env['HOST_SERVER'];
      if(serverDomain == null) {
        throw Exception('HOST_SERVER is not defined in .env file');
      }
      var uri = Uri.parse('$serverDomain/api/iot/devices/$roomCode/check');

      Map<String, String> body = {
        'deviceId': idOnly,
      };

      var response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body));
      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] == 'success') {
          return "online";
        } else {
          return "offline";
        }
      } else if (response.statusCode == 400) {
        var jsonResponse = jsonDecode(response.body);
        return "error: ${jsonResponse['message']}";
      }else {
        throw Exception('Failed to ping IOT device: ${response.body}');
      }
  }
}
