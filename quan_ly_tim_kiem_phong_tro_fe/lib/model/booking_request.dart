import 'package:cloud_firestore/cloud_firestore.dart';

class BookingRequest {
  final String id;
  final String userId;
  final String apartmentId;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final String status;

  BookingRequest({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
  });

  factory BookingRequest.fromFirestore(String id, Map<String, dynamic> data) {
    return BookingRequest(
      id: id,
      userId: data['UserId'] ?? '', // an toàn nếu null
      apartmentId: data['ApartmentId'] ?? '',
      status: data['Status'] ?? '',
      checkinDate: data['checkinDate'] != null
          ? (data['checkinDate'] as Timestamp).toDate()
          : DateTime.now(),
      checkoutDate: data['checkoutDate'] != null
          ? (data['checkoutDate'] as Timestamp).toDate()
          : DateTime.now(),
      // thêm các field khác tương tự
    );
  }
}
