import 'package:flutter/material.dart';

class ChatDetail extends StatelessWidget {
  final String name;
  final String avatar;

  const ChatDetail({super.key, required this.name, required this.avatar});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(name),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: size.width,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: size.width * 0.1,
                  backgroundImage: AssetImage(avatar),
                ),
                const SizedBox(height: 8),
                Text(
                  name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(thickness: 1),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                ChatBubble(message: "Dạ em có thể hỏi 1 vài vấn đề ko ạ", isMe: true),
                ChatBubble(message: "Tôi có thể giúp gì cho bạn?", isMe: false),
                ChatBubble(message: "Dạ Phòng 205-khu A minihouse có cho nuôi chó ko ạ", isMe: true),
                ChatBubble(message: "Dạ khu minihouse có cho nuôi thú cưng ạ", isMe: false),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn……',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isMe;

  const ChatBubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(maxWidth: size * 0.7),
        decoration: BoxDecoration(
          color: isMe ? Colors.pink[50] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message),
      ),
    );
  }
}
