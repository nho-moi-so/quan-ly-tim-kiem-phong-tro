import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/socket_room_helper.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/socket_service.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    
    // Join tất cả rooms của user khi app khởi động
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final socketService = Provider.of<SocketService>(context, listen: false);
      
      //== Hardcode userId tạm thời để test
      const userId = "dYSjvUDL2vwRrSgqiDHy";
      
      print('🔄 MainScreen: Đang join rooms cho user $userId...');
      await SocketRoomHelper.joinUserRooms(socketService, userId);
      print('✅ MainScreen: Đã join rooms thành công');
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