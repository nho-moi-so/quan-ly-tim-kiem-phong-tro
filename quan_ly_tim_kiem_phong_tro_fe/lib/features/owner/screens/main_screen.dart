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
  List<Widget> get _screens => [
    DashboardScreen(onSwitchTab: _onItemTapped),
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
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFF4C6FFF),
          unselectedItemColor: const Color(0xFF6B7280),
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            fontFamily: 'Noto Sans',
            letterSpacing: 0.2,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            fontFamily: 'Noto Sans',
          ),
          selectedIconTheme: const IconThemeData(
            size: 26,
          ),
          unselectedIconTheme: const IconThemeData(
            size: 24,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Trang chủ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.apartment_rounded),
              label: 'Căn hộ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pending_actions_rounded),
              label: 'Đặt phòng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.post_add_rounded),
              label: 'Bài đăng',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message_rounded),
              label: 'Liên hệ',
            ),
          ],
        ),
      ),
    );
  }
}