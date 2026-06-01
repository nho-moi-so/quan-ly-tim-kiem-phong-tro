import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_amenities.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_card.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_detail_contact.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_map.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/images.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/search_criteria.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/booking_request/total.dart';

class ViewApartmentScreens extends StatelessWidget {
  final Apartment apartment;
  final Post post;
  final SearchCriteria? criteria;
  final DateTime? checkInDate;
  final DateTime? checkOutDate;
  const ViewApartmentScreens({
    super.key,
    required this.apartment,
    required this.post,
    this.criteria,
    this.checkInDate,
    this.checkOutDate,
  });

  @override
  Widget build(BuildContext context) {
    int soNgayO = 1;
    if (criteria?.checkIn != null && criteria?.checkOut != null) {
      soNgayO = criteria!.checkOut!.difference(criteria!.checkIn!).inDays;
      if (soNgayO <= 0) soNgayO = 1;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          post.header.isNotEmpty
              ? post.header
              : (apartment.CodeApartment ?? "Chi tiết căn hộ"),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Images(apartment: apartment),
            ApartmentDetail(apartment: apartment),
            ApartmentDetailCard(apartment: apartment),
            ApartmentAmenities(apartment: apartment),
            ApartmentMap(apartment: apartment),
            ApartmentDetailContact(
              apartment: apartment,
              criteria: criteria,
              post: post,
            ),
          ],
        ),
      ),
    );
  }
}
