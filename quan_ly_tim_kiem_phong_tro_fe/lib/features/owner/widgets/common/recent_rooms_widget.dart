import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/dashboard_service.dart';

class RecentRoomsWidget extends StatelessWidget {
  final List<RecentRoom> rooms;

  const RecentRoomsWidget({
    super.key,
    required this.rooms,
  });

  @override
  Widget build(BuildContext context) {
    if (rooms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6FFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.apartment_rounded,
                  color: Color(0xFF4C6FFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Phòng gần đây',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...rooms.map((room) => _buildRoomItem(room)),
        ],
      ),
    );
  }

  Widget _buildRoomItem(RecentRoom room) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    Color statusColor;
    String statusText;

    switch (room.status.toLowerCase()) {
      case 'rented':
      case 'đang thuê':
        statusColor = const Color(0xFF10B981);
        statusText = 'Đang thuê';
        break;
      case 'available':
      case 'còn trống':
        statusColor = const Color(0xFF3B82F6);
        statusText = 'Còn trống';
        break;
      case 'maintenance':
      case 'bảo trì':
        statusColor = const Color(0xFFF59E0B);
        statusText = 'Bảo trì';
        break;
      default:
        statusColor = Colors.grey;
        statusText = room.status;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: room.pathImage.isNotEmpty
                ? Image.network(
                    room.pathImage.first,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 60,
                        height: 60,
                        color: Colors.grey[300],
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey[500]),
                      );
                    },
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[300],
                    child: Icon(Icons.apartment, color: Colors.grey[500]),
                  ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.codeApartment,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  room.address,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 11,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${formatter.format(room.dailyRate)} đ/ngày',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4C6FFF),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
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
}
