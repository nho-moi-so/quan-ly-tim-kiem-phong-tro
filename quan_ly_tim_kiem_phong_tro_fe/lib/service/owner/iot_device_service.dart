import 'package:cloud_firestore/cloud_firestore.dart';
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
  /// Document ID = roomCode (mã phòng)
  Future<List<ConnectedIotDevice>> getConnectedDevicesForRoom(String roomCode) async {
    try {
      List<ConnectedIotDevice> connectedDevices = [];

      // Cách 1: Lấy document có ID = roomCode (1 phòng - 1 thiết bị chính)
      final doc = await _firestore.collection('iot_device_in_apartment').doc(roomCode).get();
      
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
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

      // Cách 2: Query thêm các thiết bị có field RoomCode = roomCode (nếu có)
      // Dùng cho trường hợp 1 phòng có nhiều thiết bị
      try {
        final snapshot = await _firestore
            .collection('iot_device_in_apartment')
            .where('RoomCode', isEqualTo: roomCode)
            .get();

        for (var extraDoc in snapshot.docs) {
          // Tránh trùng với document đã lấy ở trên
          if (extraDoc.id != roomCode) {
            final data = extraDoc.data();
            final iotDeviceId = data['IoTDeviceID'] as String?;
            
            IotDevice? deviceInfo;
            if (iotDeviceId != null && iotDeviceId.isNotEmpty) {
              deviceInfo = await getDeviceById(iotDeviceId);
            }

            connectedDevices.add(
              ConnectedIotDevice.fromMap(extraDoc.id, data, deviceInfo: deviceInfo),
            );
          }
        }
      } catch (_) {
        // Bỏ qua nếu không có field RoomCode
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
}
