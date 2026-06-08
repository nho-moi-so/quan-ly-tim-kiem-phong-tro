import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/post.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/guest/widgets/apartment/apartment_cart.dart';

class HomePostList extends StatelessWidget {
  const HomePostList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('posts')
          .snapshots(),

      builder: (context, snapshot) {

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final posts = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),

          itemCount: posts.length,

          itemBuilder: (context, index) {

            final post =
                Post.fromFirestore(posts[index]);

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('apartments')
                  .doc(post.apartmentID)
                  .get(),

              builder: (context, apartmentSnap) {

                if (apartmentSnap.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!apartmentSnap.hasData ||
                    !apartmentSnap.data!.exists) {
                  return const SizedBox();
                }

                final apartment =
                    Apartment.fromFirestore(
                      apartmentSnap.data!,
                    );

                return ApartmentCart(
                  apartment: apartment,
                  post: post,
                );
              },
            );
          },
        );
      },
    );
  }
}