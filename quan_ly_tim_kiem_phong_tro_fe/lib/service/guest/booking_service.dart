import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/booking_request.dart';

class BookingRequestService {
  final CollectionReference _bookingCollection = FirebaseFirestore.instance
      .collection('bookingRequest');

  Future<List<BookingRequest>> getBookingRequestsByUser() async {
  final String testUserId = 'Bq4Z9yMPYQzpFP1WkksN'; // Test thủ công

  try {
    final snapshot = await _bookingCollection
        .where('UserId', isEqualTo: testUserId)
        .get();

    print("Đang lấy lịch sử đặt phòng cho UserId: $testUserId");
    print("Tìm thấy ${snapshot.docs.length} kết quả");

    final list = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>; // Ép kiểu ở đây
      return BookingRequest.fromFirestore(doc.id, data);
    }).toList();

    return list;
  } catch (e) {
    print("Lỗi khi lấy booking: $e");
    return [];
  }
}

}
