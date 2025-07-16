import 'package:flutter/material.dart';

class CardBookingRequestWidget extends StatelessWidget {
  const CardBookingRequestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 368,
      height: 228,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Color(0xD8756A6A)),
        color: Colors.white,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mã Đơn
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.receipt_long, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Mã Đơn:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '#023135',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Tên khách
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Tên Khách:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                'Mỹ Ngọc',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Checkin - Checkout
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Checkin - Checkout:',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'Noto Sans',
                      fontWeight: FontWeight.w400,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              Text(
                '14/05 - 15/05',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Trạng Thái
          Row(
            children: const [
              Icon(Icons.circle, color: Color(0xFF34A853), size: 14),
              SizedBox(width: 6),
              Icon(Icons.verified, size: 18, color: Color(0xFF34A853)),
              SizedBox(width: 6),
              Text(
                'Trạng Thái:',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
              Spacer(),
              Text(
                'Đã Thanh Toán',
                style: TextStyle(
                  fontSize: 16,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _actionButton(
                label: 'Xem',
                icon: Icons.visibility,
                bgColor: const Color(0x354285F4),
                textColor: Colors.black,
                onTap: () {
                  // Xử lý khi nhấn "Xem"
                },
              ),
              _actionButton(
                label: 'Xác Nhận',
                icon: Icons.check_circle,
                bgColor: const Color(0xFF4285F4),
                textColor: Colors.white,
                onTap: () {
                  // Xử lý khi nhấn "Xác Nhận"
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Builder(
      builder: (context) => GestureDetector(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Bạn đã nhấn "$label"')),
          );
          onTap();
        },
        child: Container(
          width: 160,
          height: 35,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Noto Sans',
                  fontWeight: FontWeight.w400,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
