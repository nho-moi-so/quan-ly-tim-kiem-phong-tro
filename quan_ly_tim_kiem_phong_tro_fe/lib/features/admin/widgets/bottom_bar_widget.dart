import 'package:flutter/material.dart';

class BottomBarWidget extends StatelessWidget {
  const BottomBarWidget({super.key});

  @override
  Widget build(BuildContext context){
    return Container(
    width: 390,
    padding: const EdgeInsets.symmetric(vertical: 8),
    decoration: BoxDecoration(color: Colors.white),
    child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 8,
        children: [
            Expanded(
                child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 83,
                        children: [
                            Container(
                                width: 48,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(color: Colors.white),
                                            child: Stack(
                                                children: [
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Text(
                                            'Trang chủ',
                                            style: TextStyle(
                                                color: const Color(0xFF1C1B1F),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 48,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(
                                                children: [
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Text(
                                            'Duyệt bài',
                                            style: TextStyle(
                                                color: const Color(0xFFA09CAB),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 48,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(
                                                children: [
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Text(
                                            'Người dùng',
                                            style: TextStyle(
                                                color: const Color(0xFFA09CAB),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 48,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(
                                                children: [
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Text(
                                            'Thống kê',
                                            style: TextStyle(
                                                color: const Color(0xFFA09CAB),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                width: 48,
                                height: 40,
                                padding: const EdgeInsets.symmetric(horizontal: 13),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    spacing: 8,
                                    children: [
                                        Container(
                                            width: 24,
                                            height: 24,
                                            clipBehavior: Clip.antiAlias,
                                            decoration: BoxDecoration(),
                                            child: Stack(
                                                children: [
                                                    Positioned(
                                                        left: 0,
                                                        top: 0,
                                                        child: Container(
                                                            width: 24,
                                                            height: 24,
                                                            clipBehavior: Clip.antiAlias,
                                                            decoration: BoxDecoration(),
                                                            child: Stack(),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        Text(
                                            'Tài khoản',
                                            style: TextStyle(
                                                color: const Color(0xFFA09CAB),
                                                fontSize: 11,
                                                fontFamily: 'Inter',
                                                fontWeight: FontWeight.w600,
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
}