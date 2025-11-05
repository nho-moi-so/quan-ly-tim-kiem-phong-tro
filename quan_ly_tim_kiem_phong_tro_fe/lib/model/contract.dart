import 'package:cloud_firestore/cloud_firestore.dart';

class Contract {
  final String contractID;
  final String userId;
  final String? ApartmentId;
  
  final DateTime startDate;
  final DateTime? endDate; 
  final DateTime createdDate;
  final DateTime updateDate;
  
  final int total; 
  final String status;

  Contract({
    required this.contractID,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.createdDate,
    required this.updateDate,
    required this.total,
    required this.userId,
    this.ApartmentId,
  });

  static DateTime _getDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is String) {
      try {
        return DateTime.parse(value); 
      } catch (_) {
        return DateTime.now(); 
      }
    }
    return DateTime.now(); 
  }


  static int _getTotalAsInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is double) {
    
      return value.toInt();
    }

    return 0; 
  }

  factory Contract.fromMap(String id, Map<String, dynamic> map) {
    return Contract(
      contractID: id,
      startDate: _getDateTime(map['StartDate']),
      endDate: map['EndDate'] != null ? _getDateTime(map['EndDate']) : null, 
      status: map['Status'] ?? 'Unknown',
      createdDate: _getDateTime(map['CreatedDate']),
      updateDate: _getDateTime(map['UpdateDate']),
      
 
      total: _getTotalAsInt(map['Total']), 
      
      userId: map['UserID'] ?? "",
      ApartmentId: map['ApartmentId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'StartDate': Timestamp.fromDate(startDate),
    'EndDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
    'Status': status,
    'CreatedDate': Timestamp.fromDate(createdDate),
    'UpdateDate': Timestamp.fromDate(updateDate),

    'Total': total, 
    
    'UserID': userId,
    if (ApartmentId != null) 'ApartmentId': ApartmentId,
  };
}
