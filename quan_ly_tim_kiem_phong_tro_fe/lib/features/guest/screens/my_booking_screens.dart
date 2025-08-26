import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_detail_dialog.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_history_header.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/booking_request.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/guest/booking_service.dart';

class MyBookingScreens extends StatefulWidget {
  const MyBookingScreens({super.key});

  @override
  State<MyBookingScreens> createState() => _MyBookingScreensState();
}

class _MyBookingScreensState extends State<MyBookingScreens> {
  final _bookingService = BookingRequestService();
  late Future<List<BookingRequest>> _futureBookings;

  @override
  void initState() {
    super.initState();

    // Gán cứng userId để test
    // const String fakeUserId =
    //     'Bq4Z9yMPYQzpFP1WkksN'; // ví dụ userId lấy từ Firestore

    _futureBookings = _bookingService.getBookingRequestsByUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Lịch sử đặt phòng")),
      body: FutureBuilder<List<BookingRequest>>(
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
              return BookingCard(booking: booking);
            },
          );
        },
      ),
    );
  }
}
