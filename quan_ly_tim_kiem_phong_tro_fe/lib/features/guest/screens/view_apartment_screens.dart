import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_contact.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_map.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/images.dart';

class ViewApartmentScreens extends StatelessWidget {
  const ViewApartmentScreens({super.key});

  Future<Apartment> fetchApartment() async {
    final data = await FirebaseFirestore.instance
        .collection('apartment')
        .doc('4wqOPjLk65V4GcSpw7c4') 
        .get();

    return Apartment.fromFirestore(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Trang chủ")),
      body: FutureBuilder<Apartment>(
        future: fetchApartment(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          }

          final apartment = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Images(),
                ApartmentDetail(),
                ApartmentDetailCard(),
                ApartmentAmenities(),
                ApartmentMap(),
                ApartmentDetailContact(),
              ],
            ),
          );
        },
      ),
    );
  }
}
