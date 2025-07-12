import 'package:flutter/material.dart';

class CardRoomWidget extends StatelessWidget {
  const CardRoomWidget({super.key});

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
    return Container(
      width: 130,
      height: 30,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              width: 130,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFF34A853),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          const Positioned(
            left: 32,
            top: 6,
            child: Text(
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
        ],
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
          // Tiêu đề phòng và nút xem chi tiết
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.meeting_room, color: Colors.black, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Phòng 101 - Khu 1',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Container(
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
              )
            ],
          ),

          const SizedBox(height: 8),

          // Người thuê + Hợp đồng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buildInfoRow(Icons.person, 'Phạm Thị Loi', const Color(0xFF15B20A)),
              buildContractButton(),
            ],
          ),

          const SizedBox(height: 8),

          // Giá tiền
          buildInfoRow(Icons.attach_money, '4.000.000đ', const Color(0xFFC70909)),

          const SizedBox(height: 8),

          // Trạng thái
          buildInfoRow(Icons.check_circle, 'Đang ở', Colors.black),

          const SizedBox(height: 16),

          // Nút Xóa và Chỉnh sửa
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0x354285F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4285F4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
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
            ],
          ),
        ],
      ),
    );
  }
}
