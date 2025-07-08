import 'package:flutter/material.dart';

class CardRoomDetailWidget extends StatelessWidget {
  const CardRoomDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 393,
    height: 1194.99,
    child: Stack(
        children: [
            Positioned(
                left: 53,
                top: 739,
                child: Container(
                    width: 305,
                    height: 401.82,
                    child: Stack(
                        children: [
                            Positioned(
                                left: 0,
                                top: 43.22,
                                child: Container(
                                    width: 305,
                                    height: 353.79,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                width: 1,
                                                color: const Color(0xFF4285F4),
                                            ),
                                            borderRadius: BorderRadius.circular(10),
                                        ),
                                    ),
                                    child: Stack(
                                        children: [
                                            Container(
                                                width: 209.88,
                                                height: 143,
                                                child: Stack(
                                                    children: [
                                                        Positioned(
                                                            left: 80.88,
                                                            top: 0,
                                                            child: Container(
                                                                width: 48,
                                                                height: 48,
                                                                clipBehavior: Clip.antiAlias,
                                                                decoration: BoxDecoration(),
                                                                child: Stack(),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                width: 205.68,
                                                height: 22.52,
                                                child: Stack(
                                                    children: [
                                                        Positioned(
                                                            left: 4,
                                                            top: -6,
                                                            child: SizedBox(
                                                                width: 193,
                                                                height: 32,
                                                                child: Text(
                                                                    'Drag and drop your images here, or click to browse',
                                                                    textAlign: TextAlign.center,
                                                                    style: TextStyle(
                                                                        color: const Color(0xFF4B5563),
                                                                        fontSize: 11.90,
                                                                        fontFamily: 'Inter',
                                                                        fontWeight: FontWeight.w400,
                                                                        height: 1.68,
                                                                    ),
                                                                ),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Container(
                                                width: 79.06,
                                                height: 18.77,
                                                decoration: ShapeDecoration(
                                                    color: Colors.white,
                                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                                ),
                                                child: Stack(
                                                    children: [
                                                        Positioned(
                                                            left: 1.23,
                                                            top: 0,
                                                            child: Container(
                                                                width: 75.34,
                                                                height: 19,
                                                                child: Stack(
                                                                    children: [
                                                                        Positioned(
                                                                            left: 0,
                                                                            top: 0,
                                                                            child: SizedBox(
                                                                                width: 75.34,
                                                                                height: 19,
                                                                                child: Text(
                                                                                    'Upload files',
                                                                                    textAlign: TextAlign.center,
                                                                                    style: TextStyle(
                                                                                        color: const Color(0xFF2563EB),
                                                                                        fontSize: 11.90,
                                                                                        fontFamily: 'Inter',
                                                                                        fontWeight: FontWeight.w500,
                                                                                        height: 1.68,
                                                                                    ),
                                                                                ),
                                                                            ),
                                                                        ),
                                                                    ],
                                                                ),
                                                            ),
                                                        ),
                                                        Positioned(
                                                            left: 38.23,
                                                            top: -1,
                                                            child: Container(
                                                                width: 1,
                                                                height: 1,
                                                                decoration: BoxDecoration(color: Colors.white),
                                                            ),
                                                        ),
                                                    ],
                                                ),
                                            ),
                                            Positioned(
                                                left: 18,
                                                top: 23,
                                                child: SizedBox(
                                                    width: 175,
                                                    child: Text(
                                                        'Describe the property',
                                                        style: TextStyle(
                                                            color: const Color(0xFF808080),
                                                            fontSize: 16,
                                                            fontFamily: 'Inter',
                                                            fontWeight: FontWeight.w400,
                                                            height: 1.25,
                                                        ),
                                                    ),
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Positioned(
                                left: 0,
                                top: 10,
                                child: Text(
                                    'Upload Images',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 14,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 1.25,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 134,
                top: 1144.12,
                child: Container(
                    width: 74,
                    height: 50.87,
                    padding: const EdgeInsets.only(
                        top: 11,
                        left: 37,
                        right: 15,
                        bottom: 11,
                    ),
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 1,
                                color: const Color(0xFF4285F4),
                            ),
                            borderRadius: BorderRadius.circular(7),
                        ),
                    ),
                    child: Stack(
                        children: [
                            Positioned(
                                left: 19,
                                top: 16,
                                child: Text(
                                    'Hủy',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 19,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w400,
                                        height: 0.95,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 221,
                top: 1144.12,
                child: Container(
                    width: 153,
                    height: 50.87,
                    padding: const EdgeInsets.only(
                        top: 11,
                        left: 80,
                        right: 15,
                        bottom: 11,
                    ),
                    decoration: ShapeDecoration(
                        color: const Color(0xFF4285F4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                    ),
                    child: Stack(
                        children: [
                            Positioned(
                                left: 34,
                                top: 16,
                                child: Text(
                                    'Cập Nhật',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 19,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 0.95,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 44,
                top: 384,
                child: Text(
                    'Cho Nuôi Chó Mèo',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                ),
            ),
            Positioned(
                left: 19,
                top: 385,
                child: Container(
                    width: 17,
                    height: 17,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                    ),
                ),
            ),
            Positioned(
                left: 19,
                top: 416,
                child: Container(
                    width: 17,
                    height: 17,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                    ),
                ),
            ),
            Positioned(
                left: 205,
                top: 386,
                child: Text(
                    'Có Khóa Vân Tay, Mật Khảu',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                ),
            ),
            Positioned(
                left: 180,
                top: 387,
                child: Container(
                    width: 17,
                    height: 17,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                    ),
                ),
            ),
            Positioned(
                left: 205,
                top: 419,
                child: Text(
                    'Wifi miễn phí',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                ),
            ),
            Positioned(
                left: 180,
                top: 420,
                child: Container(
                    width: 17,
                    height: 17,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(side: BorderSide(width: 1)),
                    ),
                ),
            ),
            Positioned(
                left: 16,
                top: 339,
                child: Container(
                    width: 167,
                    height: 30,
                    decoration: ShapeDecoration(
                        color: const Color(0xC19E4F4F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 36,
                top: 345,
                child: SizedBox(
                    width: 105,
                    child: Text(
                        '+ Thêm Tiện Ích',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 16,
                top: 537,
                child: Container(
                    width: 120,
                    height: 30,
                    decoration: ShapeDecoration(
                        color: const Color(0xC19E4F4F),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 30.66,
                top: 543,
                child: SizedBox(
                    width: 86.11,
                    child: Text(
                        '+ Loại Phòng',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontFamily: 'Noto Sans',
                            fontWeight: FontWeight.w400,
                            height: 1.29,
                        ),
                    ),
                ),
            ),
            Positioned(
                left: 148,
                top: 526,
                child: Container(
                    width: 12,
                    height: 12,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                    ),
                ),
            ),
            Positioned(
                left: 170,
                top: 523,
                child: Text(
                    '1 Phòng Ngủ',
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
                left: 284,
                top: 560,
                child: Container(
                    width: 12,
                    height: 12,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                    ),
                ),
            ),
            Positioned(
                left: 306,
                top: 557,
                child: Text(
                    '3 Phòng Ngủ',
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
                left: 148,
                top: 560,
                child: Container(
                    width: 12,
                    height: 12,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                    ),
                ),
            ),
            Positioned(
                left: 170,
                top: 557,
                child: Text(
                    'Studio',
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
                left: 284,
                top: 526,
                child: Container(
                    width: 12,
                    height: 12,
                    decoration: ShapeDecoration(
                        color: const Color(0xFFD9D9D9),
                        shape: OvalBorder(),
                    ),
                ),
            ),
            Positioned(
                left: 306,
                top: 523,
                child: Text(
                    '2 Phòng Ngủ',
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
                left: 16,
                top: 590,
                child: Container(
                    width: 370,
                    height: 41,
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
                left: 34,
                top: 599,
                child: Text(
                    'Trạng Thái Phòng',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.57,
                    ),
                ),
            ),
            Positioned(
                left: 45,
                top: 415,
                child: Text(
                    'Bãi Đậu Xe',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontFamily: 'Noto Sans',
                        fontWeight: FontWeight.w400,
                        height: 1.50,
                    ),
                ),
            ),
            Positioned(
                left: 0,
                top: 0,
                child: SizedBox(
                    width: 135,
                    height: 27,
                    child: Text(
                        'Mã Phòng Mới',
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
            ),
            Positioned(
                left: 16,
                top: 32,
                child: Container(
                    width: 363,
                    height: 41,
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
                left: 20,
                top: 81,
                child: SizedBox(
                    width: 73,
                    height: 27,
                    child: Text(
                        'Diện Tích ',
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
            ),
            Positioned(
                left: 16,
                top: 161,
                child: SizedBox(
                    width: 73,
                    height: 27,
                    child: Text(
                        'Checkin ',
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
            ),
            Positioned(
                left: 19,
                top: 245,
                child: SizedBox(
                    width: 118,
                    height: 27,
                    child: Text(
                        'Sức Chứa Tối Đa ',
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
            ),
            Positioned(
                left: 233,
                top: 161,
                child: SizedBox(
                    width: 73,
                    height: 27,
                    child: Text(
                        'Checkout ',
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
            ),
            Positioned(
                left: 16,
                top: 115,
                child: Container(
                    width: 361,
                    height: 41,
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
                left: 16,
                top: 279,
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
                left: 16,
                top: 193,
                child: Container(
                    width: 172,
                    height: 41,
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
                left: 207,
                top: 193,
                child: Container(
                    width: 172,
                    height: 41,
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
                top: 444,
                child: SizedBox(
                    width: 98.04,
                    height: 27,
                    child: Text(
                        'Giá Phòng ',
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
            ),
            Positioned(
                left: 16,
                top: 471,
                child: Container(
                    width: 374,
                    height: 37,
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
                left: 16,
                top: 675,
                child: Container(
                    width: 374,
                    height: 64,
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
                left: 13,
                top: 638,
                child: SizedBox(
                    width: 98.04,
                    height: 27,
                    child: Text(
                        'Mô Tả Thêm',
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
            ),
        ],
    ),
); //add container

  }
}