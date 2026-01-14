import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/common/screens/login_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/profile_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/auth_service.dart';

import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
                children: [
                  const Expanded(
                    flex: 3,
                    child: TagWithIconWidget(title: "Trang chủ"),
                  ),
                  const SizedBox(width: 6),
                  // Button "Chủ căn hộ"
                  Expanded(
                    flex: 2,
                    child: Container(
                      height: 44,
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
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ProfileScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.person_rounded, size: 18, color: Colors.white),
                                SizedBox(width: 6),
                                Text(
                                  'Hồ sơ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    fontFamily: 'Inter',
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Button Đăng xuất
                  InkWell(
                    onTap: () => _handleLogout(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFEF4444),
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.logout_rounded,
                        color: Color(0xFFEF4444),
                        size: 20,
                      ),
                    ),
                  ),
                ],
                ),
              SizedBox(height: screenHeight * 0.02),
              RoomStatusRatioWidget(
                rentedCount: 12,        // Số phòng đang thuê
                availableCount: 8,      // Số phòng còn trống
                totalRooms: 20,         // Tổng số phòng
              ),
              SizedBox(height: screenHeight * 0.02),
              MonthlyIncomeChartWidget(
                incomeData: {
                  'Tháng 1': [
                    12.0, 14.5, 13.8, 16.2, 18.0, 17.3, 15.0, 19.5, 22.0, 21.0,
                    20.5, 18.9, 17.2, 16.0, 15.8, 18.3, 20.0, 21.5, 19.0, 22.3,
                    23.5, 24.0, 25.1, 26.5, 24.3, 22.8, 20.0, 18.5, 19.2, 21.0
                  ],
                  'Tháng 2': [
                    14.0, 16.5, 18.0, 19.2, 20.0, 22.5, 23.1, 25.0, 26.3, 27.5,
                    28.0, 26.2, 24.8, 23.0, 22.1, 24.0, 25.3, 27.0, 26.8, 28.5,
                    29.0, 28.2, 26.5, 25.0, 23.3, 22.5, 21.0, 20.8, 21.5, 22.0
                  ],
                  'Tháng 3': [
                    18.0, 19.5, 21.0, 22.8, 23.5, 25.0, 26.2, 28.0, 27.3, 29.0,
                    30.0, 28.5, 26.8, 25.0, 24.5, 26.0, 27.2, 28.5, 29.8, 31.0,
                    30.2, 28.0, 27.0, 25.5, 24.0, 23.8, 22.5, 21.5, 22.0, 23.0
                  ],
                },
                months: ['Tháng 1', 'Tháng 2', 'Tháng 3'],
              )

            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _handleLogout(BuildContext context) async {
    // Hiển thị dialog xác nhận
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.logout_rounded, color: Color(0xFFEF4444)),
              SizedBox(width: 12),
              Text(
                'Xác nhận đăng xuất',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất khỏi tài khoản không?',
            style: TextStyle(fontSize: 15),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                'Hủy',
                style: TextStyle(
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    // Nếu user xác nhận đăng xuất
    if (shouldLogout == true) {
      try {
        // Hiển thị loading
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext dialogContext) {
            return const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6FFF)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Đang đăng xuất...',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );

        // Gọi service đăng xuất
        final authService = AuthService();
        await authService.logoutUser();

        // Đóng loading dialog
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Navigate về màn hình login và xóa tất cả màn hình trước đó
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LoginScreens()),
            (route) => false,
          );

          // Hiển thị thông báo thành công
          Future.delayed(const Duration(milliseconds: 300), () {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: const [
                      Icon(Icons.check_circle_outline, color: Colors.white),
                      SizedBox(width: 12),
                      Text('Đăng xuất thành công!'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF10B981),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          });
        }
      } catch (e) {
        // Đóng loading dialog nếu có lỗi
        if (context.mounted) {
          Navigator.of(context).pop();
        }

        // Hiển thị lỗi
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(child: Text('Đăng xuất thất bại. Vui lòng thử lại.')),
                ],
              ),
              backgroundColor: const Color(0xFFEF4444),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
        
        debugPrint('Logout error: $e');
      }
    }
  }
}