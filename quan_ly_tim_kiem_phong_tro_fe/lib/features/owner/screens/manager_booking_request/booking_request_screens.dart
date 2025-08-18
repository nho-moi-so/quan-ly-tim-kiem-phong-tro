import 'package:flutter/material.dart';

import '../../widgets/widgets.dart';

class BookingRequestScreens extends StatefulWidget {
  @override
  State<BookingRequestScreens> createState() => _BookingRequestScreensState();
}

class _BookingRequestScreensState extends State<BookingRequestScreens> {
  String selectedStatus = 'Tất Cả';

  // Ví dụ danh sách booking request mẫu
  final List<Map<String, String>> allRequests = [
    {
      'bookingCode': '123456',
      'customerName': 'Nguyễn Văn A',
      'checkinCheckout': '01/01 - 02/01',
      'status': 'Đã Hủy',
    },
    {
      'bookingCode': '654321',
      'customerName': 'Trần Văn B',
      'checkinCheckout': '03/01 - 04/01',
      'status': 'Đã Thanh Toán',
    },
    // ... thêm dữ liệu khác
  ];

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo selectedStatus
    final filteredRequests = selectedStatus == 'Tất Cả'
        ? allRequests
        : allRequests.where((r) => r['status'] == selectedStatus).toList();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //wiget trong đây
              //widget trong đây
              SizedBox(height: screenHeight * 0.05),
              //logo
              Center(
                child: LogoWidget(),
              ),
              // TagWithIconWidget(),
              SizedBox(height: screenHeight * 0.02),
              //label title
              LabelTitleWidget(
                title: "Danh Sách Yêu Cầu Đặt Phòng",
              ),
              //filter status
              FliterStatusWidget(
                onStatusChanged: (status) {
                  setState(() {
                    selectedStatus = status;
                  });
                },
              ),
              // //search by date
              // SearchByDateWidget(),
              SizedBox(height: screenHeight * 0.02),
              //card booking request
              Center(
                child: Column(
                  children: filteredRequests
                      .map(
                        (req) => CardBookingRequestWidget(
                          bookingCode: req['bookingCode'] ?? '',
                          customerName: req['customerName'] ?? '',
                          checkinCheckout: req['checkinCheckout'] ?? '',
                          status: req['status'] ?? '',
                        ),
                      )
                      .toList(),
                ),
              ),
              
            ],
          ),
        ),
      ),
    );
  }
}

