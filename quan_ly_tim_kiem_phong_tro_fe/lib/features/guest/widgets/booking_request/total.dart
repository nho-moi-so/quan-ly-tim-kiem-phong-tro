import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/booking_success_screen.dart';

class Total extends StatefulWidget {
  final Apartment apartment;
  final SearchCriteria? criteria;
  final int? soNgayO;
  final double? tongTien;
  final double totalAmount;

  const Total({
    super.key,
    required this.apartment,
    this.criteria,
    this.soNgayO,
    this.tongTien,
    required this.totalAmount,
  });

  @override
  State<Total> createState() => _TotalState();
}

class _TotalState extends State<Total> {
  bool _isPolicyAccepted = false;

  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Chính sách thuê phòng"),
        content: const SingleChildScrollView(
          child: Text(
            """• Khách hàng vui lòng cung cấp CMND/CCCD khi nhận phòng.
• Thời gian nhận phòng: 14h, trả phòng: 12h ngày hôm sau.
• Hủy phòng trước 24h được hoàn tiền 100%.
• Không hút thuốc, không nuôi thú cưng trong phòng.
• Mọi thiệt hại tài sản sẽ được bồi thường theo quy định.""",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Đóng"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isPolicyAccepted = true;
              });
              Navigator.pop(context);
            },
            child: const Text("Tôi đồng ý"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    // 🔹 Lấy ngày Check-in / Check-out thật
    final checkIn = widget.criteria?.checkIn;
    final checkOut = widget.criteria?.checkOut;

    // 🔹 Tính số ngày ở
    int soNgayO =
        widget.soNgayO ??
        ((checkIn != null && checkOut != null)
            ? checkOut.difference(checkIn).inDays
            : 1);
    if (soNgayO <= 0) soNgayO = 1;

    // 🔹 Tính tổng tiền
    double tongTien =
        widget.tongTien ?? ((widget.apartment.DailyRate ?? 0) * soNgayO);

    return Container(
      width: width,
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Chi tiết đặt phòng",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // 🔹 Hiển thị Check-in / Check-out
          _buildRow(
            "Ngày nhận phòng:",
            checkIn != null ? _formatDate(checkIn) : "Chưa chọn",
          ),
          _buildRow(
            "Ngày trả phòng:",
            checkOut != null ? _formatDate(checkOut) : "Chưa chọn",
          ),

          const SizedBox(height: 8),
          _buildRow("Số ngày ở:", "$soNgayO ngày"),
          _buildRow("Giá mỗi ngày:", "${widget.apartment.DailyRate ?? 0} đ"),
          const Divider(),
          _buildRow(
            "Tổng cộng:",
            "${tongTien.toStringAsFixed(0)} đ",
            isBold: true,
            valueColor: Colors.red,
          ),
          const SizedBox(height: 16),

          // 🔹 Chính sách
          Row(
            children: [
              Checkbox(
                value: _isPolicyAccepted,
                onChanged: (value) {
                  setState(() {
                    _isPolicyAccepted = value ?? false;
                  });
                },
              ),
              Expanded(
                child: Row(
                  children: [
                    const Text("Tôi đã đọc và đồng ý "),
                    GestureDetector(
                      onTap: _showPolicyDialog,
                      child: const Text(
                        "chính sách thuê phòng",
                        style: TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 🔹 Nút đặt phòng
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPolicyAccepted
                  ? () {
                      // Chuyển sang trang thành công
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const BookingSuccessScreen(),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPolicyAccepted
                    ? Colors.blue
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text("Đặt phòng"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String label,
    String value, {
    bool isBold = false,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Hàm định dạng ngày cho đẹp hơn
  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
