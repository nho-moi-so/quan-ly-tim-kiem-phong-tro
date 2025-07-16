import 'package:flutter/material.dart';

import '../../viewmodel/room_card_info.dart';
class CardRoomWidget extends StatelessWidget {
  final RoomCardInfo data;

  const CardRoomWidget({super.key, required this.data});

  Widget buildInfoRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontFamily: 'Noto Sans',
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget buildContractButton() {
    return ElevatedButton(
      onPressed: data.onContract,
      style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF34A853),
      minimumSize: const Size(130, 30),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
      elevation: 0,
      ),
      child: const Text(
      'Hợp Đồng',
      style: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontFamily: 'Noto Sans',
        fontWeight: FontWeight.w400,
        height: 1.12,
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xD8756A6A), width: 1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề phòng + nút chi tiết
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.meeting_room, color: Colors.black, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    data.roomName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              InkWell(
                onTap: data.onViewDetail,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9E4F4F),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                  ),
                  onPressed: data.onViewDetail,
                  child: const Text(
                  'Xem Chi Tiết',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'Noto Sans',
                    fontWeight: FontWeight.w400,
                  ),
                  ),
                ),
                ),
              
            ],
          ),

          const SizedBox(height: 8),

          // Người thuê + hợp đồng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildInfoRow(Icons.person, data.tenantName, const Color(0xFF15B20A)),
              buildContractButton(),
            ],
          ),

          const SizedBox(height: 8),

          // Giá
          buildInfoRow(Icons.attach_money, data.price, const Color(0xFFC70909)),

          const SizedBox(height: 8),

          // Trạng thái
          buildInfoRow(Icons.check_circle, data.status, Colors.black),

          const SizedBox(height: 16),

          // Xóa và chỉnh sửa
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: data.onDelete,
                  icon: const Icon(Icons.delete, color: Colors.black, size: 18),
                  label: const Text(
                    'Xóa',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0x354285F4), width: 1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: const Color(0x354285F4),
                  ),
                ),
              ),

              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: data.onEdit,
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text(
                    'Chỉnh Sửa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

            ],
          ),
        ],
      ),
    );
  }
}
