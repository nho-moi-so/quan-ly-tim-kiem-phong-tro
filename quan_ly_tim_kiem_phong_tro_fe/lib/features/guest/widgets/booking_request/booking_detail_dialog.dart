// file: booking_detail_dialog.dart

import 'package:flutter/material.dart';

class BookingDetailDialog extends StatelessWidget {
  const BookingDetailDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.035;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close),
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Thông tin chi tiết',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),

              // Dữ liệu hiển thị tĩnh mẫu
              Row(
                children: [
                  const CircleAvatar(radius: 18),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Mỹ Ngọc", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Phòng số 501 | Người thuê"),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              _infoText("Địa chỉ:", "45 Nguyễn Văn Cừ, An Bình, Cần Thơ", fontSize),
              _infoText("SĐT chủ căn hộ:", "(123) 456-7890", fontSize),
              _infoText("Số người ở:", "4 Người", fontSize),
              _infoText("Checkin:", "14h, 14/05", fontSize),
              _infoText("Checkout:", "12h, 15/05", fontSize),
              _infoText("Trạng thái:", "Đã Thực Hiện", fontSize),
              _infoText("Tiền Phòng:", "4.500.000đ", fontSize),
              _infoText("Số Phòng:", "501, Tầng 5", fontSize),
              _infoText("Mật khẩu phòng:", "012457", fontSize),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.green)),
                      child: const Text("Trở Về", style: TextStyle(color: Colors.green)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Xóa"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoText(String label, String value, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: TextStyle(fontSize: fontSize))),
          Expanded(child: Text(value, style: TextStyle(fontWeight: FontWeight.w500, fontSize: fontSize))),
        ],
      ),
    );
  }
}
