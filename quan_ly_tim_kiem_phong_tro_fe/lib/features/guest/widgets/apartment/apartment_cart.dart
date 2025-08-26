import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApartmentCart extends StatelessWidget {
  final Apartment apartment;

  const ApartmentCart({super.key, required this.apartment});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double cardWidth = screenWidth * 0.9;
    final double imageHeight = cardWidth * 0.6;

    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8),
        width: cardWidth,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              blurRadius: 6,
              color: Colors.black.withOpacity(0.1),
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  child: Image.network(
                    apartment.pathImage.first,
                    width: cardWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade400),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Giá Hôm Nay",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Đặt cọc: ${apartment.deposit}",
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color.fromARGB(255, 48, 54, 58),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Giá phòng: ${apartment.dailyRate}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    apartment.type,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text("Sức chứa: ${apartment.maxOccupancy} người"),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.grey),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          apartment.address,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('amenityInApartment')
                        .where('ApartmentID', isEqualTo: apartment.apartmentID)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator(strokeWidth: 2);
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Text(
                          "Chưa có tiện ích",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        );
                      }
                      var amenityDocs = snapshot.data!.docs;
                      return Wrap(
                        spacing: 10,
                        runSpacing: 6,
                        children: amenityDocs.map<Widget>((doc) {
                          var data = doc.data() as Map<String, dynamic>;
                          return FutureBuilder<DocumentSnapshot>(
                            future: FirebaseFirestore.instance
                                .collection('amenity')
                                .doc(data['AmenityID'])
                                .get(),
                            builder: (context, amenitySnapshot) {
                              if (!amenitySnapshot.hasData)
                                return SizedBox.shrink();

                              print("AmenityID: ${data['AmenityID']}");
                              print(
                                "Doc data: ${amenitySnapshot.data!.data()}",
                              );

                              var amenityData =
                                  amenitySnapshot.data!.data()
                                      as Map<String, dynamic>;
                              int quantity = data['quantity'] ?? 1;
                              return Row(
                                children: [
                                  Icon(Icons.check, size: 16),
                                  Text(
                                    "${amenityData['Name']} ${quantity > 1 ? '($quantity)' : ''}",
                                  ),
                                ],
                              );
                            },
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(
                          Icons.person,
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 6),
                      Text(
                        "Được đăng bởi Em bóng",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
