import '/model/booking_request.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //=================getAllBookingRequest
  Future<List<BookingRequest>> getAllBookingRequest() async {
    List<BookingRequest> bookingRequests = [];
    QuerySnapshot snapshot = await firestore.collection("bookingRequest").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      bookingRequests.add(BookingRequest.fromMap(doc.id, data));
    }
    return bookingRequests;
  }

  //=======================getBookingRequestById
  Future<BookingRequest> getBookingRequestById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("bookingRequest").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return BookingRequest.fromMap(snapshot.id, data);
  }

  //========================getBookingRequestByApartmentId
  Future<List<BookingRequest>> getBookingRequestByApartmentId(String apartmentId) async {
    List<BookingRequest> bookingRequests = [];
    QuerySnapshot snapshot = await firestore
        .collection("bookingRequest")
        .where('ApartmentId', isEqualTo: apartmentId)
        .get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      bookingRequests.add(BookingRequest.fromMap(doc.id, data));
    }
    return bookingRequests;
  }

  //===================createBookingRequest
  Future<BookingRequest> createBookingRequest(BookingRequest bookingRequest) async {
    DocumentReference docRef = await firestore.collection("bookingRequest").add(bookingRequest.toMap());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về BookingRequest mới, dùng fromMap (không cần sửa model)
    return BookingRequest.fromMap(docRef.id, data);
  }

  //===================updateBookingRequest
  Future<BookingRequest> updateBookingRequest(BookingRequest bookingRequest) async {
    await firestore.collection("bookingRequest").doc(bookingRequest.bookingRequestID).update(bookingRequest.toMap());
    return bookingRequest;
  }

  //==========================deleteBookingRequest
  Future<void> deleteBookingRequest(String bookingRequestID) async {
    await firestore.collection("bookingRequest").doc(bookingRequestID).delete();
  }

  // Future<List<BookingRequest>> getAllBookingRequest({
  //   String? ownerId,
  //   String? status,
  //   DateTime? startDate,
  //   DateTime? endDate,
  // }) async {
  //   // Dữ liệu mẫu
  //   final sampleData = [
  //     BookingRequest(
  //       bookingRequestID: '1',
  //       requestedDate: DateTime.now(),
  //       checkinDate: DateTime.now().add(Duration(days: 1)),
  //       checkoutDate: DateTime.now().add(Duration(days: 2)),
  //       status: 'Đã Xác Nhận',
  //     ),
      
  //   ];

  //   // Có thể thêm logic lọc ở đây nếu cần

  //   return sampleData;
  // }
}