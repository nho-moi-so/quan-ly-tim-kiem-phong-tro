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
    return InkWell(
      onTap: data.onContract,
      child: Container(
        width: 130,
        height: 30,
        decoration: BoxDecoration(
          color: const Color(0xFF34A853),
          borderRadius: BorderRadius.circular(6),
        ),
        alignment: Alignment.center,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9E4F4F),
                    borderRadius: BorderRadius.circular(6),
                  ),
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
              )
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
                child: InkWell(
                  onTap: data.onDelete,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x354285F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, color: Colors.black, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Xóa',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: data.onEdit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, color: Colors.white, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Chỉnh Sửa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
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
