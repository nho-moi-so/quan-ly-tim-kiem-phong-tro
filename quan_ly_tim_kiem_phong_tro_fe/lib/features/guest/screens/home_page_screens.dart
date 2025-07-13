import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/logo.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/home_page/search_home_section.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/home_page/apartment_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/bottom_tabbar.dart';

class HomePageScreen extends StatelessWidget {
  const HomePageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
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
    );
  }
}
