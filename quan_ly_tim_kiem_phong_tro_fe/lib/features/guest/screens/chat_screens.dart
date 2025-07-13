import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/message/chat.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/message/message_header.dart';


class ChatScreens extends StatelessWidget {
  const ChatScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: Column(
        children: [
          const MessageHeader(),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const Chat()));
            },
            child: const Text("Xem danh sách chat"),
          ),
        ],
      ),
    );
  }
}

