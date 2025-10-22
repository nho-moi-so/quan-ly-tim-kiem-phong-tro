import 'package:cloud_firestore/cloud_firestore.dart';
class BookingRequest {
  final String apartmentID;
  final String userId;
  final String bookingRequestID;
  final DateTime requestedDate;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  String status;

  BookingRequest({
    required this.bookingRequestID,
    required this.apartmentID,
    required this.userId,
    required this.requestedDate,
    required this.checkinDate,
    required this.checkoutDate,
    required this.status,
  });

  factory BookingRequest.fromMap(String id, Map<String, dynamic> map) => BookingRequest(
        bookingRequestID: id,
        apartmentID: map['ApartmentID'] ?? '',
        userId: map['UserID'] ?? '',
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
