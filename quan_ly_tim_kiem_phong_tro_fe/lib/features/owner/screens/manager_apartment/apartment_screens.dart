import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/apartment_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/user_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_card_info.dart';

import '../../widgets/common/filter_chip_widget.dart';
import '../../widgets/widgets.dart';

enum RoomFilter { rented, available }

class ApartmentScreen extends StatefulWidget {
  const ApartmentScreen({super.key});
  
  @override
  State<ApartmentScreen> createState() => _MainApartmentScreenState();
}

class _MainApartmentScreenState extends State<ApartmentScreen> {
  
  //get all list card infor
  Future<List<RoomCardInfo>> roomCards = ApartmentController().getSummaryRoom( FirebaseAuth.instance.currentUser!.uid);
  RoomFilter currentFilter = RoomFilter.rented;

  // Method để refresh danh sách phòng
  void _refreshRoomList() {
    setState(() {
      roomCards = ApartmentController().getSummaryRoom(FirebaseAuth.instance.currentUser!.uid);
    });
  }

  List<RoomCardInfo> _filterRooms(List<RoomCardInfo> rooms) {
    switch (currentFilter) {
      case RoomFilter.rented:
        // Lọc phòng đang ở (có khách thuê)
        return rooms.where((room) => 
          room.tenantName != "Chưa có khách thuê" && 
          (room.status == 'Rented' || room.status.contains('Rented'))
        ).toList();
      case RoomFilter.available:
        // Lọc phòng còn trống (chưa có khách thuê hoặc status là đang trống)
        return rooms.where((room) => 
          room.tenantName == "Chưa có khách thuê" || 
          (room.status == 'Available' || room.status.contains('Available'))
        ).toList();
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
        message = "Bạn cần được Admin phê duyệt quyền chủ nhà trước khi đăng bài.\n\nGửi yêu cầu ngay?";
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
                // Icon Header
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
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 20),
                // Title
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
                // Message
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
                // Action Buttons
                Row(
                  children: [
                    // Close Button
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
                      // Request Button
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
              //wiget trong đây
              SizedBox( 
              height: screenHeight * 0.05,
              ),
              Center(child: LogoWidget()),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagWithIconWidget(title: "Quảng lý căn hộ"),
                ButtonAddWidget(
                  title: "Thêm căn hộ mới", 
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser!.uid;
                    final result = await UserController().checkOwnerPermission(uid);
                    
                    if (result['canPost'] == true) {
                      // TODO: Navigator.push sang DetailApartmentScreen
                      Navigator.push(context, MaterialPageRoute(builder: (context) => DetailApartmentScreen()));
                    } else {
                      _showKYCRequestDialog(result['status'] ?? 'ACTIVE');
                    }
                  },
                ),
              ],
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              FilterChipWidget<RoomFilter>(
                currentFilter: currentFilter,
                options: [
                  FilterOption(
                    label: 'Đang Ở',
                    icon: Icons.home_rounded,
                    color: const Color(0xFFEF4444),
                    value: RoomFilter.rented,
                  ),
                  FilterOption(
                    label: 'Đang Trống',
                    icon: Icons.door_front_door_rounded,
                    color: const Color(0xFF10B981),
                    value: RoomFilter.available,
                  ),
                ],
                onFilterChanged: (filter) {
                  setState(() {
                    currentFilter = filter;
                  });
                },
              ),
              SizedBox(
              height: screenHeight * 0.01,
              ),
              // LabelTitleWidget(title:"Chung Cư Nam Long", header:"50, Trịnh Hoài Đức, Phường Vĩnh Thanh Vân TP. Rạch Giá"),
              
              // ===========List of room cards
              FutureBuilder<List<RoomCardInfo>>(
                future: roomCards,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LoadingWidget(
                      message: 'Đang tải danh sách phòng...',
                    );
                  } else if (snapshot.hasError) {
                    return EmptyStateWidget(
                      title: 'Có lỗi xảy ra',
                      message: 'Không thể tải danh sách phòng\n${snapshot.error}',
                      icon: Icons.error_outline,
                    );
                  } else if (snapshot.hasData) {
                    final filteredRooms = _filterRooms(snapshot.data!);
                    if (filteredRooms.isEmpty) {
                      String message = currentFilter == RoomFilter.rented
                        ? 'Chưa có phòng nào đang được thuê'
                        : 'Chưa có phòng trống';
                      return EmptyStateWidget(
                        title: 'Không có phòng',
                        message: message,
                        icon: Icons.home_outlined,
                      );
                    }
                    return Column(
                      children: filteredRooms.map((card) => CardRoomWidget(data: card,)).toList(),
                    );
                  }
                  return const SizedBox.shrink();
                })
            ],
            
            ),
          ),
          ),
          
        );
        }
      }

