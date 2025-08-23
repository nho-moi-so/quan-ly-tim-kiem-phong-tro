import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/booking_request_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_summary.dart';

import '../../widgets/widgets.dart';

class BookingRequestScreens extends StatefulWidget {
  @override
  State<BookingRequestScreens> createState() => _BookingRequestScreensState();
}

class _BookingRequestScreensState extends State<BookingRequestScreens> {
  String selectedStatus = 'All';
  final BookingRequestController _bookingRequestController = BookingRequestController();

  List<BookingRequestSummary> allRequests = [];

  @override
  void initState() {
    super.initState();
    _loadBookingRequests();
  }

  Future<void> _loadBookingRequests() async {
    final summaries = await _bookingRequestController.getAllBookingRequestsSummaries("dYSjvUDL2vwRrSgqiDHy");
    setState(() {
      allRequests = summaries;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lọc danh sách theo selectedStatus
    final filteredRequests = selectedStatus == 'All'
        ? allRequests
        : allRequests.where((r) => r.status == selectedStatus).toList();

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
                tabs: [
                  'All',
                  ..._bookingRequestController.getStatusList(),
                ],
              ),
              // //search by date
              SearchByDateWidget(),
              SizedBox(height: screenHeight * 0.02),
              //card booking request
              Center(
                child: Column(
                  children: filteredRequests
                      .map(
                        (req) => CardBookingRequestWidget(
                          bookingCode: req.bookingCode ?? '',
                          customerName: req.customerName ?? '',
                          checkinCheckout: req.checkinCheckout ?? '',
                          status: req.status ?? '',
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

