import 'dart:async';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/message.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/message_service.dart';


//== data test: user: U002, U001
class MessageController {
  final MessageService _messageService = MessageService();

  get firestore => _messageService.firestore;

  //getSummaryMessage - //== fake data - done 
  List<ChatItemViewModel> getSummaryMessage(String ownerId) {
    return [
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Pamiuoi",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Online",
        ownerId: "U001",
        tenantId: "U002",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van A",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Offline",
        ownerId: "U002",
        tenantId: "U003",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van B",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Online",
        ownerId: "U002",
        tenantId: "U004",
      ),
      ChatItemViewModel(
        avatarUrl: "https://placehold.co/36x45",
        name: "Nguyen Van C",
        message: "Dạ Phòng 203 còn trống ko ạ",
        status: "Offline",
        ownerId: "U002",
        tenantId: "U005",
      ),
    ];
  }

  //getConversation(String senderId, String receiverId) => List<Message> - done
  Stream<List<Message>> getConversation(String senderId, String receiverId) {
    
    return _messageService.getConversation(senderId, receiverId);
  }

  //== chưa hoàn thiện
  bool sendMessage({required String content, required String senderID, required String receiverID}) {
    try {
      Message message = Message(
        messageID: "", // Firestore sẽ tự tạo ID
        senderID: senderID,
        receiverID: receiverID,
        content: content,
        sentDate: DateTime.now(),
        status: "sent",
      );
    _messageService.createMessage(message);
      return true;
    } catch (e) {
      print("Error sending message: $e");
      return false;
    }

  }

}
