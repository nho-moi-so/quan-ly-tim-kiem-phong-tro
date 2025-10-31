import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/home_page_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/my_booking_screens.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ✅ Icon success
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Tiêu đề
              const Text(
                "Đặt Phòng Thành Công",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 30),

              // ✅ 2 nút điều hướng
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Nút trở về trang chủ
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HomePageScreen()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      "Trở về trang chủ",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Nút đến phòng của tôi
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyBookingScreens()),
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      "Đến phòng của tôi",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
