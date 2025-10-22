import 'package:cloud_firestore/cloud_firestore.dart';
class Contract {
  final String contractID;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String clause;
  final DateTime createdDate;
  final DateTime updateDate;
  final String pathFileContact;

  Contract({
    required this.contractID,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.clause,
    required this.createdDate,
    required this.updateDate,
    required this.pathFileContact,
  });

  factory Contract.fromMap(String id, Map<String, dynamic> map) => Contract(
        contractID: id,
        startDate: (map['StartDate'] as Timestamp).toDate(),
        endDate: (map['EndDate'] as Timestamp).toDate(),
        status: map['Status'] ?? '',
        clause: map['Clause'] ?? '',
        createdDate: (map['CreatedDate'] as Timestamp).toDate(),
        updateDate: (map['UpdateDate'] as Timestamp).toDate(),
        pathFileContact: map['PathFileContact'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'StartDate': Timestamp.fromDate(startDate),
        'EndDate': Timestamp.fromDate(endDate),
        'Status': status,
        'Clause': clause,
        'CreatedDate': Timestamp.fromDate(createdDate),
        'UpdateDate': Timestamp.fromDate(updateDate),
        'PathFileContact': pathFileContact,
      };
}