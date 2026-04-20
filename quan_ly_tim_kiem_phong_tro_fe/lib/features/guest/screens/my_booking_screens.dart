import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/contract.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/booking_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/contract_service.dart'; 
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/my_back_button.dart'; 
class MyBookingScreens extends StatefulWidget {
  const MyBookingScreens({super.key});

  @override
  State<MyBookingScreens> createState() => _MyBookingScreensState();
}

class _MyBookingScreensState extends State<MyBookingScreens> with SingleTickerProviderStateMixin {
  final _bookingService = BookingRequestService();

  final _contractService = ContractService(); 

  late Future<List<BookingRequest>> _futureBookings;
  late Stream<List<Contract>> _contractStream;
  
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    const String currentUserId = "dYSjvUDL2vwRrSgqiDHy"; 


    _futureBookings = _bookingService.getBookingRequestsByUser(); 
    _contractStream = _contractService.getContractsByUserId(currentUserId);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const MyBackButton(), 
        title: const Text("Quản Lý Đặt Phòng & Hợp Đồng"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Lịch Sử Đặt Phòng"),
            Tab(text: "Hợp Đồng Đã Ký"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBookingList(),
          _buildContractList(), 
        ],
      ),
    );
  }

  // Widget hiển thị danh sách Hợp đồng (StreamBuilder)
  Widget _buildContractList() {
    return StreamBuilder<List<Contract>>(
      stream: _contractStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          print('Lỗi tải hợp đồng: ${snapshot.error}');
          return Center(child: Text("Lỗi tải dữ liệu: ${snapshot.error}"));
        }

        final contracts = snapshot.data;

        if (contracts == null || contracts.isEmpty) {
          return const Center(child: Text("Bạn chưa có hợp đồng nào."));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: contracts.length,
          itemBuilder: (context, index) {
            final contract = contracts[index];
            return BookingCard(
              data: contract, // Truyền Contract object
            );
          },
        );
      },
    );
  }

  // Widget hiển thị danh sách Đặt phòng (FutureBuilder)
  Widget _buildBookingList() {
    return FutureBuilder<List<BookingRequest>>(
      future: _futureBookings,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("Không có lịch sử đặt phòng."));
        }

        final bookings = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return BookingCard(data: booking);
          },
        );
      },
    );
  }
}
