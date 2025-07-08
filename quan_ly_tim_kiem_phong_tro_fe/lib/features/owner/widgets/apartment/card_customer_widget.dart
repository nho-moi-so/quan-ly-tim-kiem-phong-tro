import 'package:flutter/material.dart';

class CardCustomerWidget extends StatelessWidget {
  const CardCustomerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 369,
    height: 572,
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
        ),
    ),
    child: Stack(
        children: [
            Positioned(
                left: 80,
                top: 0,
                child: SizedBox(
                    width: 259,
                    height: 15,
                    child: Text(
                        'Thêm Khách Thuê Mới',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: const Color(0xFF4B5563),
                            fontSize: 23,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                            height: 0.96,
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 0,
                top: 79,
                child: Container(
                    width: 363,
                    height: 45,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 2,
                top: 173,
                child: Container(
                    width: 361,
                    height: 45,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 3,
                top: 275,
                child: Container(
                    width: 360,
                    height: 80,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 3,
                top: 411,
                child: Container(
                    width: 362,
                    height: 45,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 7,
                top: 509,
                child: Container(
                    width: 362,
                    height: 63,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 6,
                top: 40,
                child: Text(
                    'Tên Khách Trọ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.47,
                    ),
                ),
            ),
            Positioned(
                left: 6,
                top: 138,
                child: Text(
                    'Số Điện Thoại ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.47,
                    ),
                ),
            ),
            Positioned(
                left: 10,
                top: 235,
                child: Text(
                    'CCCD & Hộ Chiếu ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.47,
                    ),
                ),
            ),
            Positioned(
                left: 12,
                top: 372,
                child: Text(
                    'Giới TÍnh ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.47,
                    ),
                ),
            ),
            Positioned(
                left: 14,
                top: 469,
                child: Text(
                    'Địa Chỉ Thường Chú ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black.withValues(alpha: 0.80),
                        fontSize: 15,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w400,
                        height: 1.47,
                    ),
                ),
            ),
        ],
    ),
);
   }
 } //add container