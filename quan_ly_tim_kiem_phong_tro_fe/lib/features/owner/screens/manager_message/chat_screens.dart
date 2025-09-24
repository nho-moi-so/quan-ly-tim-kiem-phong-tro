import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required ChatItemViewModel chatItem});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [
    {"fromMe": false, "text": "Tôi có thể giúp gì cho bạn?"},
    {"fromMe": true, "text": "Dạ Phòng 203 còn trống ko ạ"},
    {"fromMe": false, "text": "Dạ Phòng 203 vẫn còn trống ạ, bạn muốn xem phòng vào ngày mai ko ạ?"},
    {"fromMe": true, "text": "Dạ em sẽ xem xét và nhắn lại ạ"},
  ];

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    setState(() {
      _messages.add({"fromMe": true, "text": _controller.text.trim()});
      _controller.clear();
    });
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
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildMessage(msg["text"], msg["fromMe"]);
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
                    onPressed: _sendMessage,
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
