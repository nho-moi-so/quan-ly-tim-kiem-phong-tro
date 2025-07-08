import 'package:flutter/material.dart';
class PostCardDetailWidget extends StatelessWidget{
  const PostCardDetailWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
    width: 355,
    height: 640,
    decoration: ShapeDecoration(
        color: const Color(0xFFFFFCFC),
        shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1,
                color: const Color(0xFFBFBFBF),
            ),
            borderRadius: BorderRadius.circular(16),
        ),
    ),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 11,
        children: [
            Container(
                width: double.infinity,
                height: 200,
                child: Stack(
                    children: [
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                                width: 355,
                                height: 200,
                                decoration: ShapeDecoration(
                                    image: DecorationImage(
                                        image: NetworkImage("https://placehold.co/355x200"),
                                        fit: BoxFit.cover,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                        Positioned(
                            left: 0,
                            top: 0,
                            child: Container(
                                width: 355,
                                height: 200,
                                decoration: ShapeDecoration(
                                    gradient: LinearGradient(
                                        begin: Alignment(0.50, -0.00),
                                        end: Alignment(0.50, 1.00),
                                        colors: [const Color(0x00D9D9D9), Colors.black, Colors.black],
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                        ),
                                    ),
                                ),
                            ),
                        ),
                        Positioned(
                            left: 306,
                            top: 6,
                            child: Container(
                                width: 41,
                                height: 41,
                                padding: const EdgeInsets.all(4),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFE5E5E5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(29),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                    
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 178,
                            top: 185,
                            child: Container(
                                height: 5,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 2.50,
                                    children: [
                                        Container(
                                            width: 6,
                                            height: 6,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF2F2F2),
                                                shape: OvalBorder(),
                                            ),
                                        ),
                                        Container(
                                            width: 6,
                                            height: 6,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFBFBFBF),
                                                shape: OvalBorder(),
                                            ),
                                        ),
                                        Container(
                                            width: 5.50,
                                            height: 5.50,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFBFBFBF),
                                                shape: OvalBorder(),
                                            ),
                                        ),
                                        Container(
                                            width: 5,
                                            height: 5,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFBFBFBF),
                                                shape: OvalBorder(),
                                            ),
                                        ),
                                        Container(
                                            width: 4.50,
                                            height: 4.50,
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFBFBFBF),
                                                shape: OvalBorder(),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
            Container(
                width: double.infinity,
                height: 406,
                child: Stack(
                    children: [
                        Positioned(
                            left: 190,
                            top: 312,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFBFBFBF),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Điện: 5 ngàn/ ký',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 22,
                            top: 312,
                            child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFBFBFBF),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Text(
                                            'Nước: 10 ngàn/khối',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 0,
                            child: Container(
                                width: 323,
                                height: 19,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 16,
                                    children: [
                                        Container(
                                            height: 19,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 4,
                                                children: [
                                                    Text(
                                                        'Giá thuê:',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Noto Sans',
                                                            fontWeight: FontWeight.w600,
                                                        ),
                                                    ),
                                                    Text(
                                                        '2.500.000đ/tháng',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Noto Sans',
                                                            fontWeight: FontWeight.w400,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Container(
                                            height: 19,
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 4,
                                                children: [
                                                    Text(
                                                        'Diện tích:',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Noto Sans',
                                                            fontWeight: FontWeight.w600,
                                                        ),
                                                    ),
                                                    Text(
                                                        '25m²',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Noto Sans',
                                                            fontWeight: FontWeight.w400,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 35,
                            child: Container(
                                width: 323,
                                height: 57,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Mô tả:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        SizedBox(
                                            width: 275,
                                            child: Text(
                                                'Make beds: Change sheets and pillowcases, fluff pillows, straighten blankets.',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w400,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 108,
                            child: Container(
                                width: 323,
                                height: 31,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Người đăng:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: ShapeDecoration(
                                                color: const Color(0xFFF2F2F2),
                                                shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(16),
                                                ),
                                            ),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                spacing: 10,
                                                children: [
                                                    Container(
                                                        width: 18,
                                                        height: 18,
                                                        decoration: BoxDecoration(
                                                            image: DecorationImage(
                                                                image: NetworkImage("https://placehold.co/18x18"),
                                                                fit: BoxFit.contain,
                                                            ),
                                                        ),
                                                    ),
                                                    Text(
                                                        'John Doe',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14,
                                                            fontFamily: 'Noto Sans',
                                                            fontWeight: FontWeight.w400,
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 155,
                            child: Container(
                                width: 323,
                                height: 19,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Địa chỉ:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        Text(
                                            '123/45 Nguyễn Văn Cừ, Q.5, TP.HCM',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 190,
                            child: Container(
                                width: 323,
                                height: 19,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Ngày đăng:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        Text(
                                            '10/12/2023 16.00AM',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 225,
                            child: Container(width: 135, height: 24, child: Stack()),
                        ),
                        Positioned(
                            left: 17,
                            top: 270,
                            child: Container(
                                width: 75,
                                height: 31,
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFBFBFBF),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Stack(
                                    children: [
                                        Positioned(
                                            left: 12,
                                            top: 6,
                                            child: Text(
                                                '5 người',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w400,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 239,
                            top: 270,
                            child: Container(
                                width: 82,
                                height: 31,
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFBFBFBF),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Stack(
                                    children: [
                                        Positioned(
                                            left: 12,
                                            top: 6,
                                            child: Text(
                                                'gác lửng',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w400,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 109,
                            top: 270,
                            child: Container(
                                width: 114,
                                height: 31,
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 1,
                                            color: const Color(0xFFBFBFBF),
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Stack(
                                    children: [
                                        Positioned(
                                            left: 12,
                                            top: 6,
                                            child: Text(
                                                'nuôi chó mèo',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w400,
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 16,
                            top: 225,
                            child: Container(
                                width: 323,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Thông tin khác:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                        Positioned(
                            left: 18,
                            top: 365,
                            child: Container(
                                width: 323,
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                        Text(
                                            'Ngày duyệt:',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                        Text(
                                            '10/12/2023 16.00AM',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                        ),
                    ],
                ),
            ),
        ],
    ),
);
  }


}