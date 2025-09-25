import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/message_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/message.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  final ChatItemViewModel chatItem;

  const ChatScreen({super.key, required this.chatItem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final MessageController _messageController = MessageController();

  String get _currentUserId => widget.chatItem.ownerId;   // id chủ trọ
  String get _partnerId => widget.chatItem.tenantId;       // id khách thuê

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final isSent = await _messageController.sendMessage(
      content: text,
      senderID: _currentUserId,
      receiverID: _partnerId,
    );

    if (isSent) {
      _controller.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi tin nhắn thất bại. Vui lòng thử lại.'),
        ),
      );
    }
  }

  Widget _buildMessage(String text, bool fromMe) {
    return Align(
      alignment: fromMe ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 250),
        decoration: BoxDecoration(
          color: fromMe ? Colors.grey.withOpacity(0.3) : const Color(0xFFF3ECEC),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(8),
            topRight: const Radius.circular(8),
            bottomLeft: fromMe ? Radius.zero : const Radius.circular(8),
            bottomRight: fromMe ? const Radius.circular(8) : Radius.zero,
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w300,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.blue,
                      size: 24,
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage("https://placehold.co/60x75"),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Pamiuoi",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1C1B1F),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.black.withOpacity(0.6)),

            // Tin nhắn
            Expanded(
              child: StreamBuilder<List<Message>>(
                stream: _messageController.getConversation(_currentUserId, _partnerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Lỗi tải tin nhắn'));
                  }

                  final messages = snapshot.data ?? [];
                  if (messages.isEmpty) {
                    return const Center(child: Text('Chưa có tin nhắn'));
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final fromMe = msg.senderID == _currentUserId;
                      return _buildMessage(msg.content, fromMe);
                    },
                  );
                },
              ),
            ),

            // Input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Nhập tin nhắn...",
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w300,
                          color: Color(0xFF4B5563),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: Color(0xFFCECFD1)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () => _sendMessage(),
                    icon: const Icon(Icons.send, size: 16, color: Colors.white),
                    label: const Text(
                      "Gửi",
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
