import 'package:cloud_firestore/cloud_firestore.dart';


class IOTOtp {
  String Id;
  String IoTDeviceID;
  String ApartmentID;
  String DeviceID;
  String? Otp;
  String? Status;
  DateTime? CreationDate;
  String? PingCode;    // App ghi mã ngẫu nhiên vào đây
  String? PingReply;   // IoT copy mã đó ghi lại vào đây
  
  IOTOtp({
    required this.Id,
    required this.IoTDeviceID,
    required this.ApartmentID,
    required this.DeviceID,
    this.Otp,
    this.Status,
    this.CreationDate,
    this.PingCode,
    this.PingReply,
  });
}
  //connect to firebase
class IotOtpService {
    //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  //getOTPbyId
  Future<IOTOtp> getOTPbyId(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("iot_device_in_apartment").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    final creationRaw = data['CreationDate'];
    DateTime? creationDate;
    if (creationRaw is Timestamp) {
      creationDate = creationRaw.toDate();
    } else if (creationRaw is DateTime) {
      creationDate = creationRaw;
    } else {
      creationDate = null;
    }

    return IOTOtp(
      Id: (data['Id'] as String?) ?? snapshot.id,
      IoTDeviceID: data['IoTDeviceID'] ?? '',
      ApartmentID: data['ApartmentID'] ?? '',
      Otp: data['Otp'] as String?,
      Status: data['Status'] as String?,
      CreationDate: creationDate,
      DeviceID: data['DeviceID'] ?? '',
      PingCode: data['PingCode'] as String?,
      PingReply: data['PingReply'] as String?,
    );
  }
}