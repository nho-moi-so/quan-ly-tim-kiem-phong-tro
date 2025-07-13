import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/logo.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/home_page/search_home_section.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/home_page/apartment_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/bottom_tabbar.dart';

class HomePageMenuScreens extends StatefulWidget {
  const HomePageMenuScreens({super.key});

  @override
  State<HomePageMenuScreens> createState() => _SearchApartmentScreensState();
}

class _SearchApartmentScreensState extends State<HomePageMenuScreens> {
  bool showMenu = false;

  void toggleMenu() {
    setState(() {
      showMenu = !showMenu;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: const Text("Trang chủ"),
            actions: [
              IconButton(icon: const Icon(Icons.menu), onPressed: toggleMenu),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: const [
                Logo(),
                SearchHomeSection(),
                ApartmentCard(),
                BottomTabbar(),
              ],
            ),
          ),
        ),

        /// Menu hiển thị đè lên
        if (showMenu) Positioned(top: 70, right: 16, child: _buildPopupMenu()),
      ],
    );
  }

  Widget _buildPopupMenu() {
    final List<Map<String, dynamic>> menuItems = [
      {'icon': Icons.dashboard, 'label': 'Dashboard'},
      {'icon': Icons.post_add, 'label': 'Bài Đăng Mới'},
      {'icon': Icons.event_note, 'label': 'Lịch Sử Đặt Phòng'},
      {'icon': Icons.meeting_room, 'label': 'Rooms'},
      {'icon': Icons.support_agent, 'label': 'Liên Hệ Chủ Trọ'},
      {'icon': Icons.logout, 'label': 'Logout'},
      {'icon': Icons.settings, 'label': 'Settings'},
    ];

    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 220,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueAccent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 8),
              child: Text(
                'Thông Tin Cá Nhân',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...menuItems.asMap().entries.map((entry) {
              int index = entry.key;
              var item = entry.value;
              bool isActive = index == 2;

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isActive
                      ? const Color(0xFF2563EB)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  child: InkWell(
                    onTap: () {
                      // xử lý điều hướng
                      setState(() => showMenu = false);
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            item['icon'] as IconData,
                            size: 18,
                            color: isActive ? Colors.white : Colors.black,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            item['label']!,
                            style: TextStyle(
                              color: isActive ? Colors.white : Colors.black,
                              fontSize: 13,
                              fontWeight: isActive
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
