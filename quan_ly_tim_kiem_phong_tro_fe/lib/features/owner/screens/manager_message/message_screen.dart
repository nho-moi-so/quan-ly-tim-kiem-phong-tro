import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/message_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_message/chat_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/chat_item_viewmodel.dart';

import '../../widgets/widgets.dart';

class MessageScreen extends StatefulWidget {
  const MessageScreen({super.key});

  @override
  State<MessageScreen> createState() => _MessageScreenState();
}

class _MessageScreenState extends State<MessageScreen> {
  final MessageController _messageController = MessageController();
  List<ChatItemViewModel> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    //== Thay "ownerId" bằng id thực tế nếu có
    final messages = await _messageController.getSummaryMessage("dYSjvUDL2vwRrSgqiDHy");
    setState(() {
      _messages = messages
          .map((msg) => ChatItemViewModel(
                avatarUrl: msg.avatarUrl,
                name: msg.name,
                message: msg.message,
                status: msg.status,
                ownerId: msg.ownerId,
                tenantId: msg.tenantId,
              ))
          .toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(child: LogoWidget()),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagWithIconWidget(title: "Quản lý liên hệ khách hàng"),
                // ButtonAddWidget(title: "Thêm bài đăng mới", screen: DetailPostScreen(postId: "new"),),
              ],
              ),
              // SizedBox(height: screenHeight * 0.02),
              // FliterStatusWidget(),
              SizedBox(height: screenHeight * 0.02),
              LabelTitleWidget(title: "Lịch sử trò chuyện"),
              SearchBarWidget(),
              SizedBox(height: screenHeight * 0.02),
                _isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Column(
                    children: _messages
                      .map((msg) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatScreen(
                            chatItem: msg,
                            ),
                          ),
                          );
                        },
                        child: ChatItem(
                          avatarUrl: msg.avatarUrl,
                          name: msg.name,
                          message: msg.message,
                          status: msg.status,
                        ),
                        ))
                      .toList(),
                  ),
                
            ],
          ),
        ),
      ),
    );
  }
}