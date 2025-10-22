import 'package:flutter/material.dart';

class ChatItem extends StatefulWidget {
  final String avatarUrl;
  final String name;
  final String message;
  final String status;

  const ChatItem({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.message,
    required this.status,
  });

  @override
  State<ChatItem> createState() => _ChatItemState();
}

class _ChatItemState extends State<ChatItem> {
  late String _status;

  @override
  void initState() {
    super.initState();
    _status = widget.status;
  }

  void toggleStatus() {
    setState(() {
      _status = _status == "Online" ? "Offline" : "Online";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(widget.avatarUrl),
          ),
          const SizedBox(width: 12),

          // Nội dung chính
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tên
                Text(
                  widget.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1B1F),
                  ),
                ),
                const SizedBox(height: 2),

                // Tin nhắn
                Text(
                  widget.message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 2),

                // Trạng thái (Online/Offline)
                GestureDetector(
                  onTap: toggleStatus,
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontSize: 13,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w300,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Icon tuỳ chọn
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
