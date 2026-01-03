import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/message_controller.dart';
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
    final messages = await _messageController.getSummaryMessage(FirebaseAuth.instance.currentUser!.uid);
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

  void _showChatBottomSheet(BuildContext context, ChatItemViewModel chatItem) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: _MessengerChatWidget(chatItem: chatItem),
      ),
    );
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
                TagWithIconWidget(title: "Quản lý liên hệ"),
                // ButtonAddWidget(title: "Thêm bài đăng mới", screen: DetailPostScreen(postId: "new"),),
              ],
              ),
              // SizedBox(height: screenHeight * 0.02),
              // FliterStatusWidget(),
              SizedBox(height: screenHeight * 0.02),
              Center(child: LabelTitleWidget(title: "Lịch sử trò chuyện")),
              SizedBox(height: screenHeight * 0.01),
              SearchBarWidget(),
              SizedBox(height: screenHeight * 0.02),
                _isLoading
                  ? const LoadingWidget(
                      message: 'Đang tải tin nhắn...',
                    )
                  : _messages.isEmpty
                    ? const EmptyStateWidget(
                        title: 'Chưa có cuộc trò chuyện',
                        message: 'Bạn chưa có tin nhắn nào',
                        icon: Icons.chat_bubble_outline,
                      )
                    : Column(
                    children: _messages
                      .map((msg) => ChatItem(
                          avatarUrl: msg.avatarUrl,
                          name: msg.name,
                          message: msg.message,
                          status: msg.status,
                          onTap: () {
                            _showChatBottomSheet(context, msg);
                          },
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

// Messenger-style Chat Widget
class _MessengerChatWidget extends StatefulWidget {
  final ChatItemViewModel chatItem;

  const _MessengerChatWidget({required this.chatItem});

  @override
  State<_MessengerChatWidget> createState() => _MessengerChatWidgetState();
}

class _MessengerChatWidgetState extends State<_MessengerChatWidget> {
  final TextEditingController _controller = TextEditingController();
  final MessageController _messageController = MessageController();
  final ScrollController _scrollController = ScrollController();

  String get _currentUserId => widget.chatItem.ownerId;
  String get _partnerId => widget.chatItem.tenantId;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

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
      // Scroll to bottom after sending
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gửi tin nhắn thất bại'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildMessage(String text, bool fromMe, DateTime? timestamp) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!fromMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.chatItem.avatarUrl.isNotEmpty 
                    ? NetworkImage(widget.chatItem.avatarUrl)
                    : null,
                  child: widget.chatItem.avatarUrl.isEmpty 
                    ? Icon(Icons.person, size: 16, color: Colors.grey[600])
                    : null,
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: fromMe 
                      ? const LinearGradient(
                          colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                    color: fromMe ? null : const Color(0xFFE4E6EB),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: fromMe ? const Radius.circular(18) : Radius.zero,
                      bottomRight: fromMe ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: fromMe ? Colors.white : Colors.black87,
                      height: 1.4,
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (timestamp != null)
            Padding(
              padding: EdgeInsets.only(
                top: 4,
                left: fromMe ? 0 : 38,
                right: fromMe ? 8 : 0,
              ),
              child: Text(
                _formatTime(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return 'Vừa xong';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes} phút';
    } else if (difference.inDays < 1) {
      return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    } else {
      return '${time.day}/${time.month} ${time.hour}:${time.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header - Messenger style
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  color: const Color(0xFF0084FF),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: widget.chatItem.avatarUrl.isNotEmpty 
                    ? NetworkImage(widget.chatItem.avatarUrl)
                    : null,
                  child: widget.chatItem.avatarUrl.isEmpty 
                    ? Icon(Icons.person, size: 24, color: Colors.grey[600])
                    : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.chatItem.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF050505),
                        ),
                      ),
                      Text(
                        widget.chatItem.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Video call action
                  },
                  icon: const Icon(Icons.videocam_outlined),
                  color: const Color(0xFF0084FF),
                ),
                IconButton(
                  onPressed: () {
                    // Phone call action
                  },
                  icon: const Icon(Icons.call_outlined),
                  color: const Color(0xFF0084FF),
                ),
              ],
            ),
          ),

          // Messages area
          Expanded(
            child: Container(
              color: Colors.white,
              child: StreamBuilder<List<dynamic>>(
                stream: _messageController.getConversation(_currentUserId, _partnerId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF0084FF),
                      ),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'Không thể tải tin nhắn',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ),
                    );
                  }

                  final messages = snapshot.data ?? [];
                  
                  if (messages.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0084FF).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.chat_bubble_outline,
                              size: 48,
                              color: Color(0xFF0084FF),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Bắt đầu cuộc trò chuyện',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Gửi tin nhắn đầu tiên của bạn',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Auto-scroll to bottom when new messages arrive
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final fromMe = msg.senderID == _currentUserId;
                      return _buildMessage(
                        msg.content,
                        fromMe,
                        msg.sentDate,
                      );
                    },
                  );
                },
              ),
            ),
          ),

          // Input area - Messenger style
          Container(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Emoji/Plus button
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0084FF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Show emoji picker or attachments
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    color: const Color(0xFF0084FF),
                  ),
                ),
                const SizedBox(width: 8),
                
                // Text input
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _controller,
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Aa",
                        hintStyle: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF8A8D91),
                          fontWeight: FontWeight.w400,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 8),
                
                // Send button
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF0084FF), Color(0xFF0066CC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, size: 18),
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}