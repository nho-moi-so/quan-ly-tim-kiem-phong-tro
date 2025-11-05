import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/socket_room_helper.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/socket_service.dart';

class OwnerMainScreen extends StatefulWidget {
  final int initialIndex;

  const OwnerMainScreen({super.key, this.initialIndex = 0});

  @override
  State<OwnerMainScreen> createState() => _OwnerMainScreenState();
}

class _OwnerMainScreenState extends State<OwnerMainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    // Join tất cả rooms của user khi app khởi động
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final socketService = Provider.of<SocketService>(context, listen: false);
      
      // Lấy userId từ Firebase Auth currentUser
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (currentUser != null) {
        final userId = currentUser.uid;
        print('🔄 MainScreen: Đang join rooms cho user $userId...');
        await SocketRoomHelper.joinUserRooms(socketService, userId);
        print('✅ MainScreen: Đã join rooms thành công');
      } else {
        print('⚠️ MainScreen: Không tìm thấy user đang đăng nhập');
      }
    });
  }

  // Danh sách các màn hình tương ứng với từng tab
  final List<Widget> _screens = [
    const DashboardScreen(), // Hoặc ContractScreen nếu bạn có
    const ApartmentScreen(),
    BookingRequestScreens(),
    const PostScreen(),
    const MessageScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF4285F4),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.apartment),
            label: 'Căn hộ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pending_actions),
            label: 'Đặt phòng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Bài đăng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Liên hệ',
          ),

        ],
      ),
    );
  }
}