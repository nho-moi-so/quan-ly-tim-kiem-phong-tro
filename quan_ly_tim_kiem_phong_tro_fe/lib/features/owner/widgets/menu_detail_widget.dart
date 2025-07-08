import 'package:flutter/material.dart';

class MenuDetailWidget extends StatelessWidget {
  const MenuDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
    width: 208,
    height: 385,
    child: Stack(
        children: [
            Positioned(
                left: 9,
                top: 34,
                child: Container(
                    width: 182,
                    height: 344,
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                        Container(
                                            width: 18,
                                            height: 18,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(),
                                        ),
                                        Text(
                                            'Dashboard',
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
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            'Quản Lý Bài Đăng',
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
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 10,
                                    children: [
                                      TextButton(
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size(0, 0),
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      onPressed: () {
                                        // TODO: Add your onPressed logic here
                                      },
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
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
                                        SizedBox(width: 10),
                                        Text(
                                          'Lịch Sử Đặt Phòng',
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
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            'Rooms',
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
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFF4285F4),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            'Liên Hệ Khách Hàng',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 14,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w400,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            'Logout',
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
                                width: double.infinity,
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                        Container(
                                            width: double.infinity,
                                            decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                    side: BorderSide(
                                                        width: 1,
                                                        strokeAlign: BorderSide.strokeAlignCenter,
                                                        color: const Color(0xFFBFBFBF),
                                                    ),
                                                ),
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                            'Settings',
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
        ],
    ),
);
   }
 } //add container