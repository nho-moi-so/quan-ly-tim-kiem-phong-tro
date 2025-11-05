import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/booking_request_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_summary.dart';

import '../../widgets/widgets.dart';

class BookingRequestScreens extends StatefulWidget {
  @override
  State<BookingRequestScreens> createState() => _BookingRequestScreensState();
}

class _BookingRequestScreensState extends State<BookingRequestScreens> {
  String selectedStatus = 'Pending';
  final BookingRequestController _bookingRequestController = BookingRequestController();

  List<BookingRequestSummary> allRequests = [];
  bool _isLoading = true;

  DateTime? filterFrom;
  DateTime? filterTo;

  @override
  void initState() {
    super.initState();
    _loadBookingRequests();
  }

  Future<void> _loadBookingRequests() async {
    setState(() {
      _isLoading = true;
    });
    final summaries = await _bookingRequestController.getAllBookingRequestsSummaries(FirebaseAuth.instance.currentUser!.uid);
    setState(() {
      allRequests = summaries;
      _isLoading = false;
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
              SizedBox(height: screenHeight * 0.02),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TagWithIconWidget(title: "Danh sách đặt phòng"),
              ],
              ),
              //filter status
              FliterStatusWidget(
                onStatusChanged: (status) {
                  setState(() {
                    selectedStatus = status;
                  });
                },
                tabs: [
                  ..._bookingRequestController.getStatusList(),
                ],
              ),
              // //search by date
              SearchByDateWidget(
                onDateRangeChanged: (from, to) async {
                  filterFrom = from;
                  filterTo = to;
                  setState(() {
                    _isLoading = true;
                  });
                  final results = await _bookingRequestController
                      .searchBookingRequestByStartDateAndEndDate(FirebaseAuth.instance.currentUser!.uid, from, to);
                  setState(() {
                    allRequests = results;
                    _isLoading = false;
                  });
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              //card booking request
              _isLoading
                ? const LoadingWidget()
                : filteredRequests.isEmpty
                  ? EmptyStateWidget(
                      title: 'Không có yêu cầu đặt phòng',
                      message: selectedStatus == 'All' 
                        ? 'Chưa có yêu cầu đặt phòng nào'
                        : 'Không tìm thấy yêu cầu với trạng thái "$selectedStatus"',
                    )
                  : Column(
                children: filteredRequests
                    .map((req) => CardBookingRequestWidget(
                          bookingCode: req.bookingCode ?? '',
                          customerName: req.customerName ?? '',
                          checkinCheckout: req.checkinCheckout ?? '',
                          status: req.status ?? '',
                          onConfirm: (action) async {
                              // Show loading dialog
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (ctx) => Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(24),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4285F4)),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Đang xử lý...',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );

                              bool result = false;
                              if (action == BookingAction.approved) {
                                //== Xác nhận
                                result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Approved');
                              } else if (action == BookingAction.canceled) {
                                //== Hủy
                                result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Canceled');
                              } else if (action == BookingAction.pending) {
                                //== Hoàn tác
                                result = await _bookingRequestController
                                    .updateBookingRequestStatus(req.bookingCode ?? '', 'Pending');
                              }

                              // Close loading dialog
                              Navigator.pop(context);

                              if (result) {
                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.check_circle, color: Colors.white),
                                        const SizedBox(width: 12),
                                        const Text('Cập nhật trạng thái thành công'),
                                      ],
                                    ),
                                    backgroundColor: Colors.green,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                // Reload data
                                _loadBookingRequests();
                              } else {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.error_outline, color: Colors.white),
                                        const SizedBox(width: 12),
                                        const Text('Cập nhật thất bại. Vui lòng thử lại'),
                                      ],
                                    ),
                                    backgroundColor: Colors.red,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            },
                          ))
                    .toList(),
              ),
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}

