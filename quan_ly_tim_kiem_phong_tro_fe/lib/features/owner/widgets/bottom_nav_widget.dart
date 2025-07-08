import 'package:flutter/material.dart';

class TopNavWidget extends StatelessWidget {
  const TopNavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 382,
    height: 46,
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
        ),
    ),
    child: Stack(
        children: [
            Positioned(
                left: 0,
                top: 0,
                child: Container(
                    width: 382,
                    height: 46,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFEBE7E7),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                        shadows: [
                            BoxShadow(
                                color: Color(0x3F000000),
                                blurRadius: 4,
                                offset: Offset(0, 4),
                                spreadRadius: 0,
                            )
                        ],
                    ),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 24,
                        children: [
                            Container(
                                width: 74,
                                height: 35,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Tổng Quan',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                height: 2.54,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 74,
                                height: 35,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Khu Trọ',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                height: 2.54,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 74,
                                height: 35,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 1),
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            strokeAlign: BorderSide.strokeAlignOutside,
                                            color: const Color(0xFF4285F4),
                                        ),
                                        borderRadius: BorderRadius.circular(10),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Room',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 13,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w500,
                                                height: 2.54,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            SizedBox(
                                width: 74,
                                child: Text(
                                    'Bài Đăng',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 13,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w500,
                                        height: 2.54,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
        ],
    ),
); 
    
    }
} //add container