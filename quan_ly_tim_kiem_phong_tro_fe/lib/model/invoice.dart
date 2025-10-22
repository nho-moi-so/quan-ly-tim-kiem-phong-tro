import 'package:cloud_firestore/cloud_firestore.dart';
class Invoice {
  final String invoiceID;
  final String code;
  final String status;
  final DateTime createdDate;
  final DateTime issueDate;
  final DateTime cancellationDate;
  final double vat;
  final String note;
  final double totalAmount;

  Invoice({
    required this.invoiceID,
    required this.code,
    required this.status,
    required this.createdDate,
    required this.issueDate,
    required this.cancellationDate,
    required this.vat,
    required this.note,
    required this.totalAmount,
  });

  factory Invoice.fromMap(String id, Map<String, dynamic> map) => Invoice(
        invoiceID: id,
        code: map['Code'] ?? '',
        status: map['Status'] ?? '',
        createdDate: (map['CreatedDate'] as Timestamp).toDate(),
        issueDate: (map['IssueDate'] as Timestamp).toDate(),
        cancellationDate: (map['CancellationDate'] as Timestamp).toDate(),
        vat: (map['VAT'] as num).toDouble(),
        note: map['Note'] ?? '',
        totalAmount: (map['TotalAmount'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'Code': code,
        'Status': status,
        'CreatedDate': Timestamp.fromDate(createdDate),
        'IssueDate': Timestamp.fromDate(issueDate),
        'CancellationDate': Timestamp.fromDate(cancellationDate),
        'VAT': vat,
        'Note': note,
        'TotalAmount': totalAmount,
      };
}