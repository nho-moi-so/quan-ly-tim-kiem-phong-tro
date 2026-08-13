import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/screens/booking_success_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/vnpay_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/momo_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/wallet_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/controller/booking_controller.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum PaymentMethod { wallet, vnpay, momo, cash }

class Total extends StatefulWidget {
  final Apartment apartment;
  final SearchCriteria? criteria;
  final int? soNgayO;
  final double? tongTien;
  final double totalAmount;
  final String? bookingId;

  const Total({
    super.key,
    required this.apartment,
    this.criteria,
    this.soNgayO,
    this.tongTien,
    required this.totalAmount,
    this.bookingId,
  });

  @override
  State<Total> createState() => _TotalState();
}

class _TotalState extends State<Total> {
  PaymentMethod _selectedPayment = PaymentMethod.wallet;

  double walletBalance = 0;
  bool _isPolicyAccepted = false;
  @override
  void initState() {
    super.initState();
    loadWalletBalance();
  }

  Future<void> loadWalletBalance() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data();

      setState(() {
        walletBalance = (data?['Balance'] as num?)?.toDouble() ?? 0;
      });

      print("Wallet Balance = $walletBalance");
    }
  }

  //PaymentMethod _selectedPayment = PaymentMethod.vnpay;

  void _showPolicyDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
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

  Future<void> _handleBooking() async {
    print("Payment Method = $_selectedPayment");

    try {
      if (!_isPolicyAccepted) return;

      // ================= WALLET =================
      if (_selectedPayment == PaymentMethod.wallet) {
        final result = await BookingController().createBooking(
          apartmentId: widget.apartment.ApartmentID!,
          startDate: widget.criteria!.checkIn!,
          endDate: widget.criteria!.checkOut!,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );

        print(result);

        if (!result['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );

        return;
      }

      // ================= VNPAY =================
      if (_selectedPayment == PaymentMethod.vnpay) {
        final success = await VNPayService().pay(
          bookingId:
              widget.bookingId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          amount: widget.totalAmount.toInt(),
          orderInfo: 'Thanh toán căn hộ ${widget.apartment.ApartmentID}',
        );

        if (!success) return;

        final result = await BookingController().createBooking(
          apartmentId: widget.apartment.ApartmentID!,
          startDate: widget.criteria!.checkIn!,
          endDate: widget.criteria!.checkOut!,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );

        if (!result['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );

        return;
      }

      // ================= MOMO =================
      if (_selectedPayment == PaymentMethod.momo) {
        final success = await MoMoService().pay(
          bookingId:
              widget.bookingId ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          amount: widget.totalAmount.toInt(),
          orderInfo: 'Thanh toán căn hộ ${widget.apartment.ApartmentID}',
        );

        if (!success) return;

        final result = await BookingController().createBooking(
          apartmentId: widget.apartment.ApartmentID!,
          startDate: widget.criteria!.checkIn!,
          endDate: widget.criteria!.checkOut!,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );

        if (!result['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );

        return;
      }

      // ================= CASH =================
      if (_selectedPayment == PaymentMethod.cash) {
        final result = await BookingController().createBooking(
          apartmentId: widget.apartment.ApartmentID!,
          startDate: widget.criteria!.checkIn!,
          endDate: widget.criteria!.checkOut!,
          userId: FirebaseAuth.instance.currentUser!.uid,
        );

        if (!result['success']) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(result['message'])));
          return;
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookingSuccessScreen()),
        );

        return;
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi khi đặt phòng: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    final checkIn = widget.criteria?.checkIn;
    final checkOut = widget.criteria?.checkOut;
    print(widget.criteria);
    print(widget.criteria?.checkIn);
    print(widget.criteria?.checkOut);

    int soNgayO =
        widget.soNgayO ??
        ((checkIn != null && checkOut != null)
            ? checkOut.difference(checkIn).inDays
            : 1);

    if (soNgayO <= 0) soNgayO = 1;

    final tongTien =
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

          /// ================= POLICY =================
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
                child: Wrap(
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

          const SizedBox(height: 16),

          /// ================= PAYMENT METHOD =================
          const Text(
            "Phương thức thanh toán",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          // Ví nội bộ
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.wallet,
            groupValue: _selectedPayment,
            onChanged: (value) {
              setState(() {
                _selectedPayment = value!;
              });
            },
            title: const Text(
              "Ví Tiền Của Tôi",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("Số dư: 0đ");
                }

                final data = snapshot.data!.data() as Map<String, dynamic>?;

                final rawBalance = data?['Balance'];

                double balance = 0;

                if (rawBalance is num) {
                  final value = rawBalance.toDouble();

                  if (value.isFinite) {
                    balance = value;
                  }
                }

                return Text("Số dư: ${formatVND(balance.toInt())}");
              },
            ),
          ),

          RadioListTile<PaymentMethod>(
            value: PaymentMethod.vnpay,
            groupValue: _selectedPayment,
            onChanged: (value) {
              setState(() {
                _selectedPayment = value!;
              });
            },
            title: const Text("Thanh toán VNPay"),
            secondary: Image.asset('assets/images/vnpay.jpg', width: 40),
          ),

          RadioListTile<PaymentMethod>(
            value: PaymentMethod.momo,
            groupValue: _selectedPayment,
            onChanged: (value) {
              setState(() {
                _selectedPayment = value!;
              });
            },
            title: const Text("Thanh toán Ví MoMo"),
            secondary: Image.asset('assets/images/MoMo.png', width: 40),
          ),

          RadioListTile<PaymentMethod>(
            value: PaymentMethod.cash,
            groupValue: _selectedPayment,
            onChanged: (value) {
              setState(() {
                _selectedPayment = value!;
              });
            },
            title: const Text("Phương thức thanh toán khác"),
            secondary: const Icon(Icons.money, color: Colors.green),
          ),

          const SizedBox(height: 20),

          /// ================= BUTTON =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isPolicyAccepted ? _handleBooking : null,

              style: ElevatedButton.styleFrom(
                backgroundColor: _isPolicyAccepted
                    ? Colors.blue
                    : Colors.grey.shade400,

                padding: const EdgeInsets.symmetric(vertical: 14),
              ),

              child: Text(
                _selectedPayment == PaymentMethod.vnpay
                    ? 'Thanh toán VNPay'
                    : _selectedPayment == PaymentMethod.momo
                    ? 'Thanh toán Ví MoMo'
                    : 'Đặt phòng',

                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
