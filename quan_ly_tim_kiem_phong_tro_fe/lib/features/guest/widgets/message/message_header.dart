import 'package:flutter/material.dart';

class MessageHeader extends StatelessWidget {
  const MessageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double iconSize = screenWidth * 0.055;
    final double smallFontSize = screenWidth * 0.032;
    final double bigFontSize = screenWidth * 0.05;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: menu + breadcrumb
          Row(
            children: [
              Icon(Icons.menu, size: iconSize),
              const SizedBox(width: 8),
              Icon(Icons.home, size: iconSize * 0.9),
              const SizedBox(width: 4),
              Text(
                'Liên Hệ Chủ Phòng',
                style: TextStyle(
                  fontSize: smallFontSize,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Title
          Text(
            'Lịch Sử Trò Chuyện',
            style: TextStyle(
              fontSize: bigFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
