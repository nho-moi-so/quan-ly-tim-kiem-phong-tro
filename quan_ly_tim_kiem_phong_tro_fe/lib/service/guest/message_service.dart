import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/message.dart';

class MessageService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //=================getAllMessages
  Future<List<Message>> getAllMessages() async {
    List<Message> messages = [];
    QuerySnapshot snapshot = await firestore.collection("message").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      messages.add(Message.fromMap(doc.id, data));
    }
    return messages;
  }

  //=======================getMessageById
  Future<Message> getMessageById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("message").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromMap(snapshot.id, data);
  }

  //===================createMessage
  Future<Message> createMessage(Message message) async {
    DocumentReference docRef = await firestore.collection("message").add(message.toMap());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về Message mới, dùng fromMap (không cần sửa model)
    return Message.fromMap(docRef.id, data);
  }

  //===================updateMessage
  Future<Message> updateMessage(Message message) async {
    await firestore.collection("message").doc(message.messageID).update(message.toMap());
    return message;
  }

  //==========================deleteMessage
  Future<void> deleteMessage(String messageID) async {
    await firestore.collection("message").doc(messageID).delete();
  }

  //==========================getConversation
  Stream<List<Message>> getConversation(String userA, String userB) {
    final controller = StreamController<List<Message>>();
    List<Message> sent = [];
    List<Message> received = [];

    StreamSubscription? sentSub;
    StreamSubscription? receivedSub;

    void emit() {
      final merged = [...sent, ...received]
        ..sort((a, b) => a.sentDate.compareTo(b.sentDate));
      controller.add(merged);
    }

    sentSub = firestore
        .collection('message')
        .where('SenderID', isEqualTo: userA)
        .where('ReceiverID', isEqualTo: userB)
        .orderBy('SentDate')
        .snapshots()
        .listen((snapshot) {
      sent = snapshot.docs
          .map((doc) => Message.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      emit();
    });

    receivedSub = firestore
        .collection('message')
        .where('SenderID', isEqualTo: userB)
        .where('ReceiverID', isEqualTo: userA)
        .orderBy('SentDate')
        .snapshots()
        .listen((snapshot) {
      received = snapshot.docs
          .map((doc) => Message.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      emit();
    });

    controller.onCancel = () {
      sentSub?.cancel();
      receivedSub?.cancel();
    };

    return controller.stream;
  }

  //==========================getSummaryMessagesForUser
  Future<Map<String, Message>> getSummaryMessagesForUser(String userId) async {
    Map<String, Message> summaryMessages = {};

    // Lấy tin nhắn mà user là người gửi (không dùng orderBy để tránh cần index)
    QuerySnapshot sentSnapshot = await firestore
        .collection('message')
        .where('SenderID', isEqualTo: userId)
        .get();

    // Lấy tin nhắn mà user là người nhận
    QuerySnapshot receivedSnapshot = await firestore
        .collection('message')
        .where('ReceiverID', isEqualTo: userId)
        .get();

    // Xử lý tin nhắn đã gửi
    for (var doc in sentSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final message = Message.fromMap(doc.id, data);
      final otherUserId = message.receiverID!;
      
      if (!summaryMessages.containsKey(otherUserId) ||
          message.sentDate.isAfter(summaryMessages[otherUserId]!.sentDate)) {
        summaryMessages[otherUserId] = message;
      }
    }

    // Xử lý tin nhắn đã nhận
    for (var doc in receivedSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final message = Message.fromMap(doc.id, data);
      final otherUserId = message.senderID!;
      
      if (!summaryMessages.containsKey(otherUserId) ||
          message.sentDate.isAfter(summaryMessages[otherUserId]!.sentDate)) {
        summaryMessages[otherUserId] = message;
      }
    }

    return summaryMessages;
  }
  
}