import 'dart:async';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/message.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/message_service.dart';


//== data test: user: U002, U001
class MessageController {
  final MessageService _messageService = MessageService();

  get firestore => _messageService.firestore;

  //getSummaryMessage - Lấy danh sách tóm tắt tin nhắn
  Future<List<ChatItemViewModel>> getSummaryMessage(String ownerId) async {
    // print("Getting summary messages for owner: $ownerId");
    try {
      // Lấy tất cả tin nhắn tóm tắt cho owner
      Map<String, Message> summaryMessages = await _messageService.getSummaryMessagesForUser(ownerId);
      
      List<ChatItemViewModel> chatItems = [];
      
      // Duyệt qua từng cuộc hội thoại
      for (var entry in summaryMessages.entries) {
        String otherUserId = entry.key;
        Message lastMessage = entry.value;
        
        // Xác định ai là sender và receiver
        bool isOwnerSender = lastMessage.senderID == ownerId;
        String displayMessage = isOwnerSender ? "Bạn: ${lastMessage.content}" : lastMessage.content;
        
        // Tạo ChatItemViewModel
        ChatItemViewModel chatItem = ChatItemViewModel(
          avatarUrl: "", // Có thể lấy từ User service nếu cần
          name: "User $otherUserId", // Có thể lấy tên thật từ User service
          message: displayMessage,
          status: lastMessage.status,
          ownerId: ownerId,
          tenantId: otherUserId,
        );
        
        chatItems.add(chatItem);
      }
      
      // Sắp xếp theo thời gian tin nhắn mới nhất
      chatItems.sort((a, b) {
        DateTime dateA = summaryMessages[a.tenantId]!.sentDate;
        DateTime dateB = summaryMessages[b.tenantId]!.sentDate;
        return dateB.compareTo(dateA);
      });
      
      return chatItems;
    } catch (e) {
      print("Error getting summary messages: $e");
      return [];
    }
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
