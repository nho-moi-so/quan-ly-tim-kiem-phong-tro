import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final double amount;
  final String? paymentMethod;
  final String? gatewayTransactionId;
  final DateTime paymentDate;
  final String type;
  final String status;
  final String userId;
  final String? invoiceId;

  TransactionModel({
    required this.id,
    required this.amount,
    this.paymentMethod,
    this.gatewayTransactionId,
    required this.paymentDate,
    required this.type,
    required this.status,
    required this.userId,
    this.invoiceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'Amount': amount,
      'PaymentMethod': paymentMethod,
      'GatewayTransactionId': gatewayTransactionId,
      'PaymentDate': Timestamp.fromDate(paymentDate),
      'Type': type,
      'Status': status,
      'UserID': userId,
      'InvoiceID': invoiceId,
    };
  }

  factory TransactionModel.fromMap(String id, Map<String, dynamic> map) {
    final dynamic paymentDateValue = map['PaymentDate'];

    DateTime parsedPaymentDate;
    if (paymentDateValue is Timestamp) {
      parsedPaymentDate = paymentDateValue.toDate();
    } else if (paymentDateValue is DateTime) {
      parsedPaymentDate = paymentDateValue;
    } else {
      parsedPaymentDate = DateTime.now();
    }

    return TransactionModel(
      id: id,
      amount: (map['Amount'] ?? 0).toDouble(),
      paymentMethod: map['PaymentMethod'],
      gatewayTransactionId: map['GatewayTransactionId'],
      paymentDate: parsedPaymentDate,
      type: map['Type'] ?? '',
      status: map['Status'] ?? '',
      userId: map['UserID'] ?? '',
      invoiceId: map['InvoiceID'],
    );
  }
}
