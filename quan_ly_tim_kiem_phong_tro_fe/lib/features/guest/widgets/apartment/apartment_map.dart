import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/model/apartment.dart';

class ApartmentMap extends StatelessWidget {
  final Apartment apartment;

  const ApartmentMap({
    super.key,
    required this.apartment,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    /// fallback nếu chưa có tọa độ
    final double lat = apartment.latitude ?? 10.0452;
    final double lng = apartment.longitude ?? 105.7469;

    final LatLng location = LatLng(lat, lng);

    return Container(
      margin: EdgeInsets.all(screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF4285F4)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vị trí',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: screenWidth * 0.03),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// ================= MAP =================
              Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: location,
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.quan_ly_tim_kiem_phong_tro_fe',
                      ),

                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location,
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: screenWidth * 0.04),

              /// ================= INFO =================
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '9.2 Trên cả tuyệt vời',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        color: Colors.redAccent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    Text(
                      'Điểm đánh giá vị trí',
                      style: TextStyle(
                        fontSize: screenWidth * 0.036,
                        color: Colors.grey[600],
                      ),
                    ),

                    SizedBox(height: screenWidth * 0.02),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: const Color(0xFF4285F4),
                          size: screenWidth * 0.045,
                        ),

                        SizedBox(width: screenWidth * 0.01),

                        Expanded(
                          child: Text(
                            apartment.address ??
                                '45 Nguyễn Văn Cừ, Cần Thơ',
                            style: TextStyle(
                              fontSize: screenWidth * 0.036,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}