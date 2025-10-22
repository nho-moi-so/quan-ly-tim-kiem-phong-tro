import 'package:cloud_firestore/cloud_firestore.dart';
class Message {
  final String messageID;
  final String content;
  final String status;
  final DateTime sentDate;
  final DateTime? receivedDate;
  final String? senderID;
  final String? receiverID;

  Message({
    required this.messageID,
    required this.content,
    required this.status,
    required this.sentDate,
    this.receivedDate,
    this.senderID,
    this.receiverID,
  });

  factory Message.fromMap(String id, Map<String, dynamic> map) => Message(
        messageID: id,
        content: map['Content'] ?? '',
        status: map['Status'] ?? '',
        sentDate: (map['SentDate'] as Timestamp).toDate(),
        receivedDate: map['ReceivedDate'] != null
            ? (map['ReceivedDate'] as Timestamp).toDate()
            : null,
        senderID: map['SenderID'],
        receiverID: map['ReceiverID'],
      );

  Map<String, dynamic> toMap() => {
        'Content': content,
        'Status': status,
        'SentDate': Timestamp.fromDate(sentDate),
        if (receivedDate != null) 'ReceivedDate': Timestamp.fromDate(receivedDate!),
        'SenderID': senderID,
        'ReceiverID': receiverID,
      };
}