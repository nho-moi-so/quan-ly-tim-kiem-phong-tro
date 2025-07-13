import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_contact.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_map.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/images.dart';

class ViewApartmentScreens extends StatelessWidget {
  const ViewApartmentScreens({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: const [
            Images(),
            ApartmentDetail(),
            ApartmentDetailCard(),
            ApartmentAmenities(),
            ApartmentMap(),
            ApartmentDetailContact(),
          ],
        ),
      ),
    );
  }
}
