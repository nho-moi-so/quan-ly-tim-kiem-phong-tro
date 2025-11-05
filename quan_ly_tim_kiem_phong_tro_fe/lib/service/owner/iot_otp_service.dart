import 'package:cloud_firestore/cloud_firestore.dart';


class IOTOtp {
  String ID;
  String otpCode;
  DateTime createdAt;
  String status;
  IOTOtp({
    required this.ID,
    required this.otpCode,
    required this.createdAt,
    required this.status,
  });
}
  //connect to firebase
class IotOtpService {
    //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  
  //getOTPbyId
  Future<IOTOtp> getOTPbyId(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("iot_otps").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return IOTOtp(
      ID: snapshot.id,
      otpCode: data['otpCode'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: data['status'] ?? '',
    );
  }
}