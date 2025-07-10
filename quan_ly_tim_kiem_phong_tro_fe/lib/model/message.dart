import 'package:cloud_firestore/cloud_firestore.dart';
class Message {
  final String messageID;
  final String content;
  final String status;
  final DateTime sentDate;
  final DateTime receivedDate;

  Message({
    required this.messageID,
    required this.content,
    required this.status,
    required this.sentDate,
    required this.receivedDate,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) => Message(
        messageID: id,
        content: map['Content'] ?? '',
        status: map['Status'] ?? '',
        sentDate: (map['SentDate'] as Timestamp).toDate(),
        receivedDate: (map['ReceivedDate'] as Timestamp).toDate(),
      );

  Map<String, dynamic> toMap() => {
        'Content': content,
        'Status': status,
        'SentDate': Timestamp.fromDate(sentDate),
        'ReceivedDate': Timestamp.fromDate(receivedDate),
      };
}