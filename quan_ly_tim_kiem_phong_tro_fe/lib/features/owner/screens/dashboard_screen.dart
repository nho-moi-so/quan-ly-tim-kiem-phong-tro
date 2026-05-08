import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:quan_ly_tim_kiem_phong_tro_fe/features/common/screens/login_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/user_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/profile_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/auth_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/dashboard_service.dart';

import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onSwitchTab;

  const DashboardScreen({super.key, this.onSwitchTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  
  bool _isLoading = true;
  
  // Data variables
  RoomStatistics? _roomStats;
  Map<String, List<double>> _incomeData = {};
  List<String> _months = [];

  List<RecentRoom> _recentRooms = [];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load all data in parallel
      final results = await Future.wait([
        _dashboardService.getRoomStatistics(),
        _dashboardService.getMonthlyIncome(),
        _dashboardService.getRecentRooms(),
      ]);

      setState(() {
        _roomStats = results[0] as RoomStatistics;
        _incomeData = results[1] as Map<String, List<double>>;
        _months = _incomeData.keys.toList();
        _recentRooms = results[2] as List<RecentRoom>;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard data: $e');
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text('Không thể tải dữ liệu. Vui lòng thử lại.')),
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
    }
  }

  void _showKYCRequestDialog(String currentStatus) {
    String title = "Yêu cầu xác minh";
    String message = "";
    bool canRequest = false;
    IconData icon = Icons.verified_user_rounded;
    Color iconColor = const Color(0xFF4C6FFF);

    switch (currentStatus.toUpperCase()) {
      case 'ACTIVE':
        message = "Bạn cần được Admin phê duyệt quyền chủ nhà trước khi thêm phòng.\n\nGửi yêu cầu ngay?";
        canRequest = true;
        icon = Icons.verified_user_rounded;
        iconColor = const Color(0xFF4C6FFF);
        break;
      case 'PENDING':
        title = "Đang chờ duyệt";
        message = "Yêu cầu của bạn đang được Admin xét duyệt. Vui lòng chờ!";
        icon = Icons.schedule_rounded;
        iconColor = const Color(0xFFF59E0B);
        break;
      case 'REJECTED':
        title = "Yêu cầu bị từ chối";
        message = "Yêu cầu của bạn đã bị từ chối. Vui lòng liên hệ Admin để biết thêm chi tiết.";
        icon = Icons.cancel_rounded;
        iconColor = const Color(0xFFEF4444);
        break;
      case 'LOCKED':
        title = "Tài khoản bị khóa";
        message = "Tài khoản của bạn đã bị khóa. Vui lòng liên hệ Admin.";
        icon = Icons.lock_rounded;
        iconColor = const Color(0xFFEF4444);
        break;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFAFBFF),
                Color(0xFFFFFFFF),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE0E7FF),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [iconColor, iconColor.withOpacity(0.85)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 20),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF1F2937),
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF6B7280),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFE5E7EB),
                            width: 1,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            borderRadius: BorderRadius.circular(12),
                            child: const Center(
                              child: Text(
                                "Đóng",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'Inter',
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (canRequest) ...[
                      const SizedBox(width: 12),
                      Expanded(
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
                              onTap: () async {
                                final uid = FirebaseAuth.instance.currentUser!.uid;
                                final success = await UserController().requestOwnerPermission(uid);
                                Navigator.pop(context);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.check_circle_rounded, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text("Đã gửi yêu cầu thành công!"),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Row(
                                        children: [
                                          Icon(Icons.error_rounded, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text("Có lỗi xảy ra. Vui lòng thử lại!"),
                                        ],
                                      ),
                                      backgroundColor: const Color(0xFFEF4444),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: const Center(
                                child: Text(
                                  "Gửi Yêu Cầu",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Inter',
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;


    return Scaffold(
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4C6FFF)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: const Color(0xFF4C6FFF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
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
                          // Button "Hồ sơ"
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
                      
                      // Quick Actions
                      QuickActionsWidget(
                        onAddRoom: () async {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid == null) return;
                          final result = await UserController().checkOwnerPermission(uid);
                          if (!mounted) return;
                          if (result['canPost'] == true) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const DetailApartmentScreen()),
                            );
                          } else {
                            _showKYCRequestDialog(result['status'] ?? 'ACTIVE');
                          }
                        },
                        onViewBookings: () {
                          widget.onSwitchTab?.call(2);
                        },
                        onViewPosts: () {
                          widget.onSwitchTab?.call(3);
                        },
                        onViewContact: () {
                          widget.onSwitchTab?.call(4);
                        },
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Room Status
                      if (_roomStats != null)
                        RoomStatusRatioWidget(
                          rentedCount: _roomStats!.rentedCount,
                          availableCount: _roomStats!.availableCount,
                          totalRooms: _roomStats!.totalRooms,
                        ),
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Monthly Income Chart
                      if (_incomeData.isNotEmpty && _months.isNotEmpty)
                        MonthlyIncomeChartWidget(
                          incomeData: _incomeData,
                          months: _months,
                        ),
                      SizedBox(height: screenHeight * 0.02),
                      
                      // Recent Rooms
                      RecentRoomsWidget(rooms: _recentRooms),
                      SizedBox(height: screenHeight * 0.03),
                    ],
                  ),
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
                  color: Color(0xFF000000),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4C6FFF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                'Đăng xuất',
                style: TextStyle(
                  color: Color(0xFF000000),
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