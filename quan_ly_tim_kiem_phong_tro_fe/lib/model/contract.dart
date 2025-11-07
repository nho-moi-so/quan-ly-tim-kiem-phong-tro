import 'package:cloud_firestore/cloud_firestore.dart';
class Contract {
  String contractID;
  String apartmentId;
  DateTime createdDate;
  DateTime endDate;
  DateTime startDate;
  String status;
  double total;
  DateTime updateDate;
  String userId; //nay la id cua nguoi thue

  Contract({
    this.contractID = '',
    this.apartmentId = '',
    required this.createdDate,
    required this.endDate,
    required this.startDate,
    this.status = '',
    this.total = 0.0,
    required this.updateDate,
    this.userId = '',
  });

  factory Contract.fromMap(String id, Map<String, dynamic> map) => Contract(
        contractID: id,
        apartmentId: map['ApartmentId'] ?? '',
        createdDate: _parseDate(map['CreatedDate']),
        endDate: _parseDate(map['EndDate']),
        startDate: _parseDate(map['StartDate']),
        status: map['Status'] ?? '',
        total: (map['Total'] as num?)?.toDouble() ?? 0.0,
        updateDate: _parseDate(map['UpdateDate']),
        userId: map['UserID'] ?? '',
      );

  static DateTime _parseDate(dynamic value) {
    if (value == null) {
      return DateTime.now();
    }
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('Error parsing date string: $value, error: $e');
        return DateTime.now();
      }
    }
    print('Unexpected date type: ${value.runtimeType}');
    return DateTime.now();
  }

  Map<String, dynamic> toMap() => {
        'ApartmentId': apartmentId,
        'CreatedDate': Timestamp.fromDate(createdDate),
        'EndDate': Timestamp.fromDate(endDate),
        'StartDate': Timestamp.fromDate(startDate),
        'Status': status,
        'Total': total,
        'UpdateDate': Timestamp.fromDate(updateDate),
        'UserID': userId,
      };
}