import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/detail_apartment_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_apartment/new_customer_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_contract/contract_detail_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_post/detail_post_screens.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/room_detail.dart';

import '../../viewmodel/room_card_info.dart';
class CardRoomWidget extends StatelessWidget {
  final RoomCardInfo data;

  const CardRoomWidget({super.key, required this.data});

  String _getStatusInVietnamese(String status) {
    if (status.contains('Available')) {
      return 'Còn trống';
    } else if (status.contains('Rented')) {
      return 'Đã thuê';
    }
    return status;
  }

  Color _getStatusColor(String status) {
    if (status.contains('Còn trống') || status.contains('Available')) {
      return const Color(0xFF10B981);
    } else if (status.contains('Đã thuê') || status.contains('Rented')) {
      return const Color(0xFFEF4444);
    }
    return const Color(0xFF6B7280);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(data.status);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAFBFF),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [statusColor.withOpacity(0.1), statusColor.withOpacity(0.05)],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color(0xFF4C6FFF), const Color(0xFF4C6FFF).withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C6FFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.meeting_room_rounded, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phòng',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          data.roomName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.85)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusInVietnamese(data.status),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Tenant info
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: 'Người Thuê',
                  value: data.tenantName,
                ),
                const SizedBox(height: 12),

                // Price
                _buildInfoRow(
                  icon: Icons.attach_money_rounded,
                  iconColor: const Color(0xFFEF4444),
                  label: 'Giá Thuê',
                  value: data.price,
                  valueStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                // First row: View Detail and Contract/Post
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Chi Tiết',
                        icon: Icons.visibility_rounded,
                        bgColor: const Color(0xFF4C6FFF),
                        textColor: Colors.white,
                        onTap: () async {
                          RoomDetail roomDetail = await data.onViewDetail();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailApartmentScreen(roomDetail: roomDetail),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: data.tenantName == "Chưa có khách thuê"
                          ? _actionButton(
                              label: 'Đăng Bài',
                              icon: Icons.post_add_rounded,
                              bgColor: const Color(0xFF10B981),
                              textColor: Colors.white,
                              onTap: () async {
                                RoomDetail roomDetail = await data.onViewDetail();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailPostScreen(
                                      postId: "new",
                                      apartmentId: roomDetail.roomId,
                                    ),
                                  ),
                                );
                              },
                            )
                          : _actionButton(
                              label: 'Hợp Đồng',
                              icon: Icons.description_rounded,
                              bgColor: const Color(0xFF10B981),
                              textColor: Colors.white,
                              onTap: () async {
                                String contractId = await data.onContract();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContractDetailScreen(contractId: contractId),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Second row: Delete and Edit/Add Customer
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Xóa',
                        icon: Icons.delete_rounded,
                        bgColor: const Color(0xFFEF4444),
                        textColor: Colors.white,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: const [
                                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Text('Xoá thành công'),
                                ],
                              ),
                              backgroundColor: const Color(0xFFEF4444),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _actionButton(
                        label: data.tenantName == "Chưa có khách thuê" ? 'Thêm Khách' : 'Chỉnh Sửa',
                        icon: data.tenantName == "Chưa có khách thuê" 
                            ? Icons.person_add_rounded 
                            : Icons.edit_rounded,
                        bgColor: const Color(0xFF8B5CF6),
                        textColor: Colors.white,
                        onTap: () async {
                          if (data.tenantName == "Chưa có khách thuê") {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => NewCustomerScreen()),
                            );
                          } else {
                            RoomDetail roomDetail = await data.onViewDetail();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailApartmentScreen(roomDetail: roomDetail),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [iconColor.withOpacity(0.15), iconColor.withOpacity(0.05)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bgColor, bgColor.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: textColor),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
