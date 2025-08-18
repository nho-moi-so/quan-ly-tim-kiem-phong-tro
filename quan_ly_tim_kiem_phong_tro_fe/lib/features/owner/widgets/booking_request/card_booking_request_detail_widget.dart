//done
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_detail.dart';

class CardBookingRequestDetailWidget extends StatefulWidget {
  const CardBookingRequestDetailWidget({super.key});

  @override
  State<CardBookingRequestDetailWidget> createState() => _CardBookingRequestDetailWidgetState();
}

class _CardBookingRequestDetailWidgetState extends State<CardBookingRequestDetailWidget> {
  bool isEditing = false;

  //================================
  BookingRequestDetail bookingRequestDetail = BookingRequestDetail(
    fullName: 'Mỹ Ngọc',
    roomNumber : '501',
    email: 'abc@gmail',
    phoneNumber: '(123) 456-7890',
    numberOfPeople: 4,
    checkInDate: DateTime(2023, 5, 14),
    checkOutDate: DateTime(2023, 5, 15),
    status: 'Đã Thanh Toán',
    price: '2.400.000',
    codeRoom: '#023135',
    password: '01012457',
  );
  //============================================
  late TextEditingController passwordController;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController(text: bookingRequestDetail.password);
  }

  


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
              title: Text(bookingRequestDetail.fullName),
              subtitle: Text('Phòng số ${bookingRequestDetail.roomNumber} | Người thuê'),
            ),
            const SizedBox(height: 8),
            buildInfoRow('Email', bookingRequestDetail.email),
            buildInfoRow('Số điện thoại', bookingRequestDetail.phoneNumber),
            buildInfoRow('Số người ở', '${bookingRequestDetail.numberOfPeople} Người'),
            buildInfoRow('Checkin - Checkout', '14/05 - 15/05'),
            buildInfoRow('Trạng thái', bookingRequestDetail.status),
            buildInfoRow('Tiền phòng', bookingRequestDetail.price),
            buildInfoRow('Mã đơn phòng', bookingRequestDetail.codeRoom),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Mật khẩu cung cấp:',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: passwordController,
                    enabled: isEditing,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(isEditing ? Icons.check : Icons.edit),
                  onPressed: () {
                    if (isEditing) {
                      // Lưu mật khẩu
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã lưu mật khẩu: ${passwordController.text}')),
                      );
                    }
                    setState(() {
                      isEditing = !isEditing;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Xử lý khi nhấn "Gửi Mật Khẩu"
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Mật khẩu đã được gửi')),
                      );
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 0, 255, 30)),
                    child: const Text('Gửi Mật Khẩu'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    child: const Text('Đóng'),
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
