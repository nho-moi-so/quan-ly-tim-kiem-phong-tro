import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_form.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_password.dart';

class ViewContractScreens extends StatelessWidget {
  final String apartmentId;

  const ViewContractScreens({Key? key, required this.apartmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hợp Đồng')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('apartment') // hoặc 'apartments'
            .doc(apartmentId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Không tìm thấy căn hộ'));
          }

          final apartment = Apartment.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            child: ApartmentBookingForm(apartment: apartment),
          );
        },
      ),
    );
  }
}
