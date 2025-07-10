//done
import 'package:flutter/material.dart';

class CardBookingRequestDetailWidget extends StatelessWidget {
  const CardBookingRequestDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFF34A853)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row chứa tiêu đề và nút đóng (dấu x)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Center(
                  child: Text(
                    'Thông tin chi tiết',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: CircleAvatar(backgroundColor: Color(0xFFEFF1F5)),
              title: Text('Mỹ Ngọc'),
              subtitle: Text('Phòng số 501 | Người thuê'),
            ),
            const SizedBox(height: 8),
            buildInfoRow('Email', 'ltmn@example.com'),
            buildInfoRow('Số điện thoại', '(123) 456-7890'),
            buildInfoRow('Số người ở', '4 Người'),
            buildInfoRow('Checkin - Checkout', '14/05 - 15/05'),
            buildInfoRow('Trạng thái', 'Đã Thanh Toán'),
            buildInfoRow('Tiền phòng', '2.400.000'),
            buildInfoRow('Mã đơn phòng', '#023135'),
            buildInfoRow('Mật khẩu cung cấp', '012457'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF369C42)),
                    child: const Text('Gửi Mật Khẩu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('$title:', style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(flex: 5, child: Text(value)),
        ],
      ),
    );
  }
}
