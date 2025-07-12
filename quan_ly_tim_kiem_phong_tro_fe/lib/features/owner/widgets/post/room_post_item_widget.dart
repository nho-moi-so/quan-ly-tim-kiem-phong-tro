import 'package:flutter/material.dart';

class RoomPostItemWidget extends StatelessWidget {
  final String roomName;
  final String postDate;
  final String status;
  final String imageUrl;

  const RoomPostItemWidget({
    Key? key,
    required this.roomName,
    required this.postDate,
    required this.status,
    required this.imageUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ảnh đại diện phòng
          Container(
            width: 80,
            height: 60,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 12),

          // Thông tin phòng
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  roomName,
                  style: const TextStyle(
                    color: Color(0xFF1C1B1F),
                    fontSize: 16,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ngày đăng: $postDate\nTrạng thái: $status',
                  style: const TextStyle(
                    color: Color(0xFFA09CAB),
                    fontSize: 14,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    height: 1.43,
                  ),
                ),
              ],
            ),
          ),

          // Icon menu
          const SizedBox(width: 8),
          Icon(Icons.more_vert, color: Colors.grey[600], size: 20),
        ],
      ),
    );
  }
}
