import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/screens.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với từng tab
  final List<Widget> _screens = [
    const DashboardScreen(), // Hoặc ContractScreen nếu bạn có
    const ApartmentScreen(),
    BookingRequestScreens(),
    const MessageScreen(),
    const PostScreen(),
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
            label: 'Yêu cầu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message),
            label: 'Tin nhắn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.post_add),
            label: 'Bài đăng',
          ),

        ],
      ),
    );
  }
}