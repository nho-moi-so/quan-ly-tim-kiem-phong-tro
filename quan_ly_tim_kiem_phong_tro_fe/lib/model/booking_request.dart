import 'package:cloud_firestore/cloud_firestore.dart';
class BookingRequest {
  final String bookingRequestID;
  final DateTime requestedDate;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final String status;

  BookingRequest({
    required this.bookingRequestID,
    required this.requestedDate,
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
  });

  factory BookingRequest.fromMap(String id, Map<String, dynamic> map) => BookingRequest(
        bookingRequestID: id,
        requestedDate: (map['RequestedDate'] as Timestamp).toDate(),
        checkinDate: (map['CheckinDate'] as Timestamp).toDate(),
        checkoutDate: (map['CheckoutDate'] as Timestamp).toDate(),
        status: map['Status'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'RequestedDate': Timestamp.fromDate(requestedDate),
        'CheckinDate': Timestamp.fromDate(checkinDate),
        'CheckoutDate': Timestamp.fromDate(checkoutDate),
        'Status': status,
      };
}
