import 'package:cloud_firestore/cloud_firestore.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ChatItemViewModel> _messages = [];
  List<ChatItemViewModel> _filteredMessages = [];
  List<Map<String, dynamic>> _searchedUsers = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = '';
  
  // Pagination variables
  int _currentPage = 1;
  final int _itemsPerPage = 8;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    final messages = await _messageController.getSummaryMessage(FirebaseAuth.instance.currentUser!.uid);
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    
    // Load actual user names from Firestore
    List<ChatItemViewModel> chatItems = [];
    for (var msg in messages) {
      // Determine which user is the partner (not current user)
      final partnerId = msg.ownerId == currentUserId ? msg.tenantId : msg.ownerId;
      
      // Fetch partner's name from Firestore
      String partnerName = 'Người dùng';
      try {
        final userDoc = await _firestore.collection('users').doc(partnerId).get();
        if (userDoc.exists) {
          final userData = userDoc.data();
          partnerName = userData?['Fullname'] ?? 'Người dùng';
        }
      } catch (e) {
        print('Error fetching user name: $e');
      }
      
      chatItems.add(ChatItemViewModel(
        avatarUrl: msg.avatarUrl,
        name: partnerName,
        message: msg.message,
        status: msg.status,
        ownerId: msg.ownerId,
        tenantId: msg.tenantId,
      ));
    }
    
    setState(() {
      _messages = chatItems;
      _filteredMessages = _messages;
      _isLoading = false;
    });
  }

  bool _isPhoneNumber(String text) {
    // Check if text contains only digits and has 10-11 digits
    return RegExp(r'^[0-9]{10,11}$').hasMatch(text.trim());
  }

  Future<void> _handleSearch(String query) async {
    setState(() {
      _searchQuery = query;
      _isSearching = true;
      _searchedUsers = [];
      _currentPage = 1; // Reset pagination khi tìm kiếm
    });

    if (query.isEmpty) {
      setState(() {
        _filteredMessages = _messages;
        _isSearching = false;
        _searchedUsers = [];
      });
      return;
    }

    // Check if it's a phone number
    if (_isPhoneNumber(query)) {
      // Search for users by phone
      try {
        final currentUserId = FirebaseAuth.instance.currentUser?.uid;
        final QuerySnapshot snapshot = await _firestore
            .collection('users')
            .where('Phone', isEqualTo: query.trim())
            .get();

        final users = snapshot.docs
            .where((doc) => doc.id != currentUserId)
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return {
                'userId': doc.id,
                'fullname': data['Fullname'] ?? 'Không có tên',
                'phone': data['Phone'] ?? '',
                'role': data['Role'] ?? '',
              };
            })
            .toList();

        setState(() {
          _searchedUsers = users;
          _filteredMessages = [];
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _isSearching = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi tìm kiếm: ${e.toString()}'),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } else {
      // Search in messages by name or content
      final filtered = _messages.where((msg) {
        final nameLower = msg.name.toLowerCase();
        final messageLower = msg.message.toLowerCase();
        final queryLower = query.toLowerCase();
        return nameLower.contains(queryLower) || messageLower.contains(queryLower);
      }).toList();

      setState(() {
        _filteredMessages = filtered;
        _searchedUsers = [];
        _isSearching = false;
      });
    }
  }

  void _startChatWithUser(Map<String, dynamic> user) {
    final chatItem = ChatItemViewModel(
      avatarUrl: '',
      name: user['fullname'],
      message: 'Bắt đầu trò chuyện',
      status: 'Trực tuyến',
      ownerId: FirebaseAuth.instance.currentUser!.uid,
      tenantId: user['userId'],
    );
    
    _showChatBottomSheet(context, chatItem);
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

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6FFF), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Text(
                user['fullname'].toString().substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['fullname'],
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 12,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user['phone'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4C6FFF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        _getRoleDisplay(user['role']),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C6FFF),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Chat button
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => _startChatWithUser(user),
              icon: const Icon(
                Icons.chat_bubble_outline,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDisplay(String? role) {
    switch (role?.toLowerCase()) {
      case 'owner':
        return 'Chủ căn hộ';
      case 'guest':
        return 'Khách thuê';
      case 'admin':
        return 'Quản trị viên';
      default:
        return 'Người dùng';
    }
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
              SearchBarWidget(
                controller: _searchController,
                onChanged: _handleSearch,
                onClear: () {
                  setState(() {
                    _searchQuery = '';
                    _filteredMessages = _messages;
                    _searchedUsers = [];
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Show search results for users if found
              if (_searchedUsers.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C6FFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.person_search, 
                        color: Color(0xFF4C6FFF), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Tìm thấy ${_searchedUsers.length} người dùng',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4C6FFF),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ..._searchedUsers.map((user) => _buildUserCard(user)),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 12),
              ],
              
              // Show message results
              _isLoading
                  ? const LoadingWidget(
                      message: 'Đang tải tin nhắn...',
                    )
                  : _isSearching
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            color: Color(0xFF4C6FFF),
                          ),
                        ),
                      )
                    : _searchQuery.isNotEmpty && _filteredMessages.isEmpty && _searchedUsers.isEmpty
                      ? EmptyStateWidget(
                          title: 'Không tìm thấy kết quả',
                          message: _isPhoneNumber(_searchQuery) 
                            ? 'Không tìm thấy người dùng với số điện thoại này'
                            : 'Không tìm thấy tin nhắn phù hợp',
                          icon: Icons.search_off,
                        )
                      : _filteredMessages.isEmpty && _searchQuery.isEmpty
                        ? const EmptyStateWidget(
                            title: 'Chưa có cuộc trò chuyện',
                            message: 'Bạn chưa có tin nhắn nào',
                            icon: Icons.chat_bubble_outline,
                          )
                        : Builder(
                            builder: (context) {
                              final totalCount = _filteredMessages.length;
                              final startIndex = 0;
                              final endIndex = _currentPage * _itemsPerPage;
                              final paginatedMessages = endIndex >= totalCount 
                                ? _filteredMessages 
                                : _filteredMessages.sublist(startIndex, endIndex);
                              final hasMore = paginatedMessages.length < totalCount;
                              
                              return Column(
                                children: [
                                  // Hiển thị số lượng
                                  if (totalCount > 0)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      child: Text(
                                        'Hiển thị ${paginatedMessages.length} / $totalCount cuộc trò chuyện',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF6B7280),
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                    ),
                                  // Danh sách tin nhắn
                                  ...paginatedMessages
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
                                  // Nút xem thêm
                                  if (hasMore)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      child: Container(
                                        width: double.infinity,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFF4C6FFF).withOpacity(0.3),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Material(
                                          color: Colors.transparent,
                                          child: InkWell(
                                            onTap: () {
                                              setState(() {
                                                _currentPage++;
                                              });
                                            },
                                            borderRadius: BorderRadius.circular(12),
                                            child: Center(
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                children: const [
                                                  Text(
                                                    'Xem thêm',
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight: FontWeight.w600,
                                                      color: Colors.white,
                                                      fontFamily: 'Inter',
                                                    ),
                                                  ),
                                                  SizedBox(width: 8),
                                                  Icon(
                                                    Icons.keyboard_arrow_down_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              );
                            },
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
                      // Text(
                      //   widget.chatItem.status,
                      //   style: TextStyle(
                      //     fontSize: 12,
                      //     color: Colors.grey[600],
                      //     fontWeight: FontWeight.w400,
                      //   ),
                      // ),
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