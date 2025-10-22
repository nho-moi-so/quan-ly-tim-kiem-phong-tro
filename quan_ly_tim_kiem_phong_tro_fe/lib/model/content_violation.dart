import 'package:cloud_firestore/cloud_firestore.dart';
class ContentViolation {
  final String contentViolationID;
  final String decription;
  final String type;
  final DateTime reportedDate;
  final String status;

  ContentViolation({
    required this.contentViolationID,
    required this.decription,
    required this.type,
    required this.reportedDate,
    required this.status,
  });

  factory ContentViolation.fromMap(String id, Map<String, dynamic> map) => ContentViolation(
        contentViolationID: id,
        decription: map['Decription'] ?? '',
        type: map['Type'] ?? '',
        reportedDate: (map['ReportedDate'] as Timestamp).toDate(),
        status: map['Status'] ?? '',
      );

  Map<String, dynamic> toMap() => {
        'Decription': decription,
        'Type': type,
        'ReportedDate': Timestamp.fromDate(reportedDate),
        'Status': status,
      };
}
