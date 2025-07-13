import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/message/chat_detail.dart';

class Chat extends StatelessWidget {
  const Chat({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double fontSize = screenWidth * 0.04;

    final List<Map<String, dynamic>> chatList = [
      {
        'name': 'Pamiuoi',
        'message': 'Dạ khu minihouse có cho nuôi thú cưng ạ',
        'avatar': 'assets/images/avt1.png',
        'isOnline': true,
      },
      {
        'name': 'Bành Tiêu Nhiệm',
        'message': 'hỗ trợ lắp đặt máy lạnh',
        'avatar': 'assets/images/avt2.png',
        'isOnline': true,
      },
      {
        'name': 'Chú hề trắng',
        'message': '5tr cho 1 phòng',
        'avatar': 'assets/images/avt3.png',
        'isOnline': false,
      },
      {
        'name': 'Nhỏ Mít Ướt',
        'message': 'Bạn cần thêm thông tin chi tiết ko',
        'avatar': 'assets/images/avt4.png',
        'isOnline': false,
      },
      {
        'name': 'Mặt nạ bóng đêm',
        'message': 'Hỗ trợ chuyển trọ khi em cần',
        'avatar': 'assets/images/avt5.png',
        'isOnline': false,
      },
      {
        'name': 'Tóc đen dài',
        'message': 'khi nào em cần xem phòng',
        'avatar': 'assets/images/avt6.png',
        'isOnline': false,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lịch Sử Trò Chuyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Thanh tìm kiếm
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: Colors.grey),
                  hintText: 'Tìm kiếm cuộc trò chuyện...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          // Danh sách chat
          Expanded(
            child: ListView.separated(
              itemCount: chatList.length,
              separatorBuilder: (_, __) => const Divider(indent: 80, height: 4),
              itemBuilder: (context, index) {
                final item = chatList[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(item['avatar']),
                    radius: 26,
                  ),
                  title: Text(
                    item['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: fontSize,
                    ),
                  ),
                  subtitle: Text(
                    item['message'],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fontSize * 0.9),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            size: 8,
                            color: item['isOnline'] ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item['isOnline'] ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: fontSize * 0.8,
                              color: item['isOnline']
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Icon(Icons.more_vert, size: 18),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatDetail(
                          name: item['name'],
                          avatar: item['avatar'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
