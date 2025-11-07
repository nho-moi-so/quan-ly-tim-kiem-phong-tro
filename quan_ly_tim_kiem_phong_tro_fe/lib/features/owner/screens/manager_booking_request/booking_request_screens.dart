import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/booking_request_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/screens/manager_contract/contract_detail_screen.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/booking_request_summary.dart';

import '../../widgets/widgets.dart';

class BookingRequestScreens extends StatefulWidget {
  @override
  State<BookingRequestScreens> createState() => _BookingRequestScreensState();
}

class _BookingRequestScreensState extends State<BookingRequestScreens> {
  String selectedStatus = 'Approved';
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
                  'Approved',
                  'Canceled',
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
                          bookingId: req.bookingId ?? '',
                          bookingCode: req.bookingCode ?? '',
                          customerName: req.customerName ?? '',
                          checkinCheckout: req.checkinCheckout ?? '',
                          status: req.status ?? '',
                          checkinDate: req.checkinDate != null
                              ? "${req.checkinDate!.day.toString().padLeft(2, '0')}/${req.checkinDate!.month.toString().padLeft(2, '0')}/${req.checkinDate!.year}"
                              : 'Không có thông tin',
                          checkoutDate: req.checkoutDate != null
                              ? "${req.checkoutDate!.day.toString().padLeft(2, '0')}/${req.checkoutDate!.month.toString().padLeft(2, '0')}/${req.checkoutDate!.year}"
                              : 'Không có thông tin',
                          totalPrice: req.totalPrice,
                          cancelReason: 'Khách hàng đổi ý', //== Lấy từ database
                          isRefunded: false, //== Lấy từ database
                          onConfirm: (action) async {
                              if (action == BookingAction.viewContract) {
                                //== Hiển thị màn hình hợp đồng
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        const Icon(Icons.description, color: Colors.white),
                                        const SizedBox(width: 12),
                                        Text('Xem hợp đồng: ${req.bookingCode}'),
                                      ],
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                                //== Hiển thị màn hình hợp đồng
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContractDetailScreen(contractId: req.bookingId ?? ''),
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

