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

  DateTime? filterFrom;
  DateTime? filterTo;

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
    // Lọc theo status và ngày
    var filteredRequests = allRequests.where((r) {
      final statusMatch = selectedStatus == 'All' || r.status == selectedStatus;
      final date = r.checkinDate;
      // Nếu chưa chọn filter ngày thì luôn true
      if (filterFrom == null && filterTo == null) return statusMatch;
      // Nếu có filter ngày thì kiểm tra date
      final dateMatch = (date != null) &&
        (filterFrom == null || date.isAfter(filterFrom!.subtract(const Duration(days: 1)))) &&
        (filterTo == null || date.isBefore(filterTo!.add(const Duration(days: 1))));
      return statusMatch && dateMatch;
    }).toList();

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
              SearchByDateWidget(
                onDateRangeChanged: (from, to) async {
                  filterFrom = from;
                  filterTo = to;
                  final results = await _bookingRequestController
                      .searchBookingRequestByStartDateAndEndDate("dYSjvUDL2vwRrSgqiDHy", from, to);
                  setState(() {
                    allRequests = results; // hoặc filteredRequests = results nếu bạn muốn dùng biến này
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              //card booking request
              Center(
                child: Column(
                  children: filteredRequests
                      .map((req) => CardBookingRequestWidget(
                            bookingCode: req.bookingCode ?? '',
                            customerName: req.customerName ?? '',
                            checkinCheckout: req.checkinCheckout ?? '',
                            status: req.status ?? '',
                            onConfirm: (action) async {
                              if (action == BookingAction.approved) {
                                //== Xác nhận
                                final result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Approved'); // này là bấm xác nhận -> chuyển đến approved
                                if (result) {
                                  // Nếu cập nhật thành công, tải lại danh sách
                                  print('Booking request approved: ${req.bookingCode}');
                                  _loadBookingRequests();
                                }
                              } else if (action == BookingAction.canceled) {
                                //== Hủy
                                final result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Canceled'); // này là bấm hủy -> Chuyển về Hủy
                                if (result) {
                                  // Nếu cập nhật thành công, tải lại danh sách
                                  _loadBookingRequests();
                                }
                              } else if (action == BookingAction.pending) {
                                //== Hoàn tác
                                final result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Pending'); // này là bấm hoàn tác -> chuyển về Pending
                                if (result) {
                                  // Nếu cập nhật thành công, tải lại danh sách
                                  _loadBookingRequests();
                                }
                              }
                            },
                          ))
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

