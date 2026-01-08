/// Model đại diện cho một loại thiết bị IOT trong hệ thống
/// Collection: iot_devices trên Firebase
class IotDevice {
  final String deviceId; // Document ID (smart_lock, sensor_door, ...)
  final String name; // Tên hiển thị (Khóa cửa thông minh, ...)
  final String description; // Mô tả thiết bị
  final String? icon; // Icon name (optional)

  IotDevice({
    required this.deviceId,
    required this.name,
    required this.description,
    this.icon,
  });

  factory IotDevice.fromMap(String id, Map<String, dynamic> map) {
    return IotDevice(
      deviceId: id,
      name: map['Name'] ?? '',
      description: map['Description'] ?? '',
      icon: map['Icon'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'Name': name,
      'Description': description,
      'Icon': icon,
    };
  }
}

/// Model đại diện cho thiết bị IOT đã kết nối với phòng
class ConnectedIotDevice {
  final String connectionId; // ID của kết nối (document ID trong iot_device_in_apartment)
  final String iotDeviceId; // ID loại thiết bị (smart_lock, ...)
  final String apartmentId; // Mã phòng
  final String? status; // Trạng thái kết nối (verified, pending, ...)
  final DateTime? creationDate;
  final IotDevice? deviceInfo; // Thông tin chi tiết của loại thiết bị

  ConnectedIotDevice({
    required this.connectionId,
    required this.iotDeviceId,
    required this.apartmentId,
    this.status,
    this.creationDate,
    this.deviceInfo,
  });

  bool get isConnected => status == 'verified';

  factory ConnectedIotDevice.fromMap(String id, Map<String, dynamic> map, {IotDevice? deviceInfo}) {
    DateTime? creationDate;
    final creationRaw = map['CreationDate'];
    if (creationRaw != null) {
      if (creationRaw is DateTime) {
        creationDate = creationRaw;
      } else if (creationRaw.runtimeType.toString().contains('Timestamp')) {
        creationDate = (creationRaw as dynamic).toDate();
      }
    }

    return ConnectedIotDevice(
      connectionId: id,
      iotDeviceId: map['IoTDeviceID'] ?? '',
      apartmentId: map['ApartmentID'] ?? '',
      status: map['Status'] as String?,
      creationDate: creationDate,
      deviceInfo: deviceInfo,
    );
  }
}
