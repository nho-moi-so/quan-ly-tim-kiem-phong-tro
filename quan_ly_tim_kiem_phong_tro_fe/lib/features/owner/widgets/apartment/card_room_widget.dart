import 'package:flutter/material.dart';

class CardRoomWidget extends StatelessWidget {
  const CardRoomWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 368,
    height: 228,
    decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
        ),
    ),
    child: Stack(
        children: [
            Positioned(
                left: 0,
                top: 0,
                child: Container(
                    width: 368,
                    height: 228,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xD8756A6A),
                            ),
                            borderRadius: BorderRadius.circular(15),
                        ),
                    ),
                    child: Stack(
                        children: [
                            Positioned(
                                left: 251,
                                top: 179,
                                child: Container(
                                    width: 330,
                                    height: 22,
                                    child: Stack(
                                        children: [
                                            Positioned(
                                                left: 212,
                                                top: -0.21,
                                                child: Text(
                                                    'Xem Chi Tiết',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 16,
                                                        fontFamily: 'Noto Sans',
                                                        fontWeight: FontWeight.w400,
                                                        height: 1.12,
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 128,
                                top: 350,
                                child: Container(width: 76, height: 17),
                            ),
                            Positioned(
                                left: 251,
                                top: 390,
                                child: Text(
                                    'Chi Tiết',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w500,
                                        height: 1.29,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 193,
                                top: 182,
                                child: Container(
                                    width: 168,
                                    height: 29,
                                    decoration: ShapeDecoration(
                                        color: const Color(0xFF4285F4),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                        ),
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 241,
                                top: 188,
                                child: Text(
                                    'Chỉnh Sửa',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.29,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 8,
                                top: 183,
                                child: Container(
                                    width: 168,
                                    height: 29,
                                    decoration: ShapeDecoration(
                                        color: const Color(0x354285F4),
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                        ),
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 72,
                                top: 189,
                                child: Text(
                                    'Xóa ',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.29,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 50,
                                top: 21,
                                child: Text(
                                    'Phòng 101 - Khu 1',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.12,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 50,
                                top: 60,
                                child: Text(
                                    'Phạm Thị Loi',
                                    style: TextStyle(
                                        color: const Color(0xFF15B20A),
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.12,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 21,
                                top: 99,
                                child: Container(
                                    width: 16,
                                    height: 16,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child: Stack(),
                                ),
                            ),
                            Positioned(
                                left: 50,
                                top: 99,
                                child: Text(
                                    '4.000.000đ',
                                    style: TextStyle(
                                        color: const Color(0xFFC70909),
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.12,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 231,
                                top: 16,
                                child: Container(
                                    width: 130,
                                    height: 30,
                                    decoration: BoxDecoration(color: const Color(0xFF9E4F4F)),
                                ),
                            ),
                            Positioned(
                                left: 252,
                                top: 22,
                                child: Text(
                                    'Xem Chi Tiết',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.12,
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 21,
                                top: 134,
                                child: Container(
                                    width: 17,
                                    height: 17,
                                    decoration: ShapeDecoration(
                                        color: const Color(0xFF34A853),
                                        shape: OvalBorder(),
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 50,
                                top: 134,
                                child: Text(
                                    'Đang ở',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontFamily: 'Noto Sans',
                                        fontWeight: FontWeight.w400,
                                        height: 1.12,
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