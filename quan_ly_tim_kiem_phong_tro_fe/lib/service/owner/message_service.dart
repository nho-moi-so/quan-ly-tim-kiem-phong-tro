import 'package:quan_ly_tim_kiem_phong_tro_fe/model/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class MessageService {
  //connect to firebase
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  //=================getAllMessages
  Future<List<Message>> getAllMessages() async {
    List<Message> messages = [];
    QuerySnapshot snapshot = await firestore.collection("messages").get();
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      messages.add(Message.fromMap(doc.id, data));
    }
    return messages;
  }

  //=======================getMessageById
  Future<Message> getMessageById(String id) async {
    DocumentSnapshot snapshot = await firestore.collection("messages").doc(id).get();
    final data = snapshot.data() as Map<String, dynamic>;
    return Message.fromMap(snapshot.id, data);
  }

  //===================createMessage
  Future<Message> createMessage(Message message) async {
    DocumentReference docRef = await firestore.collection("messages").add(message.toMap());

    // Lấy lại dữ liệu vừa add từ Firestore
    DocumentSnapshot snapshot = await docRef.get();
    final data = snapshot.data() as Map<String, dynamic>;

    // Trả về Message mới, dùng fromMap (không cần sửa model)
    return Message.fromMap(docRef.id, data);
  }

  //===================updateMessage
  Future<Message> updateMessage(Message message) async {
    await firestore.collection("messages").doc(message.messageID).update(message.toMap());
    return message;
  }

  //==========================deleteMessage
  Future<void> deleteMessage(String messageID) async {
    await firestore.collection("messages").doc(messageID).delete();
  }
}