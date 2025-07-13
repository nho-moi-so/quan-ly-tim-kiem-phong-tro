import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_form.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_password.dart';

class ViewContractScreens extends StatelessWidget {
  const ViewContractScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            ApartmentBookingForm(),
            ApartmentBookingDetail(),
            ApartmentBookingPassword(password: '012457'),
           
          ],
        ),
      ),
    );
  }
}
