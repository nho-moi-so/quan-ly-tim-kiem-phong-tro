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

  factory BookingRequest.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {

    return BookingRequest(

      id: id,

      userId:
          data['UserID'] ?? '',

      apartmentId:
          data['ApartmentID'] ?? '',

      status:
          data['Status'] ?? '',

      checkinDate:
          data['CheckinDate'] != null
              ? (data['CheckinDate']
                      as Timestamp)
                  .toDate()
              : DateTime.now(),

      checkoutDate:
          data['CheckoutDate'] != null
              ? (data['CheckoutDate']
                      as Timestamp)
                  .toDate()
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {

    return {

      'UserID': userId,

      'ApartmentID': apartmentId,

      'CheckinDate':
          Timestamp.fromDate(
              checkinDate),

      'CheckoutDate':
          Timestamp.fromDate(
              checkoutDate),

      'Status': status,
    };
  }
}