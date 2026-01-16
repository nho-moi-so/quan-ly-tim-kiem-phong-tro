import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/common/screens/login_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/profile_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/auth_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/dashboard_service.dart';

import '../widgets/widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
  double _currentMonthRevenue = 0.0;
  int _expiringContracts = 0;
  int _pendingBookings = 0;
  int _newTenants = 0;
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
        _dashboardService.getCurrentMonthRevenue(),
        _dashboardService.getExpiringContractsCount(),
        _dashboardService.getPendingBookingRequestsCount(),
        _dashboardService.getNewTenantsThisMonth(),
        _dashboardService.getRecentRooms(),
      ]);

      setState(() {
        _roomStats = results[0] as RoomStatistics;
        _incomeData = results[1] as Map<String, List<double>>;
        _months = _incomeData.keys.toList();
        _currentMonthRevenue = results[2] as double;
        _expiringContracts = results[3] as int;
        _pendingBookings = results[4] as int;
        _newTenants = results[5] as int;
        _recentRooms = results[6] as List<RecentRoom>;
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final formatter = NumberFormat('#,###', 'vi_VN');

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
                      
                      // Statistics Cards Grid
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCardWidget(
                              title: 'Doanh thu tháng',
                              value: '${formatter.format(_currentMonthRevenue / 1000000)}M',
                              icon: Icons.attach_money_rounded,
                              color: const Color(0xFF10B981),
                              backgroundColor: const Color(0xFF10B981).withOpacity(0.05),
                              subtitle: 'VNĐ',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCardWidget(
                              title: 'Khách mới',
                              value: '$_newTenants',
                              icon: Icons.person_add_rounded,
                              color: const Color(0xFF3B82F6),
                              backgroundColor: const Color(0xFF3B82F6).withOpacity(0.05),
                              subtitle: 'Trong tháng',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: StatisticCardWidget(
                              title: 'HĐ sắp hết hạn',
                              value: '$_expiringContracts',
                              icon: Icons.event_busy_rounded,
                              color: const Color(0xFFF59E0B),
                              backgroundColor: const Color(0xFFF59E0B).withOpacity(0.05),
                              subtitle: 'Trong 30 ngày',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: StatisticCardWidget(
                              title: 'Yêu cầu chờ',
                              value: '$_pendingBookings',
                              icon: Icons.pending_actions_rounded,
                              color: const Color(0xFFEF4444),
                              backgroundColor: const Color(0xFFEF4444).withOpacity(0.05),
                              subtitle: 'Cần xử lý',
                            ),
                          ),
                        ],
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
                      
                      // Quick Actions
                      QuickActionsWidget(
                        onAddRoom: () {
                          // TODO: Navigate to add room screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đang phát triển')),
                          );
                        },
                        onViewBookings: () {
                          // TODO: Navigate to bookings screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đang phát triển')),
                          );
                        },
                        onViewContracts: () {
                          // TODO: Navigate to contracts screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đang phát triển')),
                          );
                        },
                        onViewReports: () {
                          // TODO: Navigate to reports screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Chức năng đang phát triển')),
                          );
                        },
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