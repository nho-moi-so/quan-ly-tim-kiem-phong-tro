import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/apartment_booking_form.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_map.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/booking_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/total.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/thanhtoan_vnpay.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';

class ViewContractScreens extends StatelessWidget {
  final String apartmentId;
  final SearchCriteria? criteria;

  const ViewContractScreens({
    Key? key,
    required this.apartmentId,
    this.criteria,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hóa Đơn Đặt Phòng')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('apartment')
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

          int soNgayO = 1;
          if (criteria?.checkIn != null && criteria?.checkOut != null) {
            soNgayO = criteria!.checkOut!.difference(criteria!.checkIn!).inDays;
            if (soNgayO <= 0) soNgayO = 1;
          }

          double tongTien = (apartment.DailyRate ?? 0) * soNgayO;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ApartmentBookingForm(apartment: apartment),
                const SizedBox(height: 16),
                ApartmentMap(apartment: apartment),
                const SizedBox(height: 16),
                ApartmentAmenities(apartment: apartment),
                const SizedBox(height: 16),
                Total(
                  apartment: apartment,
                  criteria: criteria,
                  totalAmount: tongTien,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
