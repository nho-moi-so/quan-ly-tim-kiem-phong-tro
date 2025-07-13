import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/logo.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_history_header.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_filter_tabs.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/bottom_tabbar.dart';

class MyBookingScreens extends StatelessWidget {
  const MyBookingScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Logo(),
            BookingHistoryHeader(),
            BookingFilterTabs(),
            BookingCard(),
            BottomTabbar(),
          ],
        ),
      ),
    );
  }
}
