import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
    width: 390,
    height: 844,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(color: Colors.white),
    child: Stack(
        children: [
            Positioned(
                left: 0,
                top: 548,
                child: Container(
                    width: 390,
                    height: 12,
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                ),
            ),
            Positioned(
                left: 0,
                top: 276,
                child: Container(
                    width: 390,
                    height: 12,
                    padding: const EdgeInsets.only(top: 8, left: 16, right: 16, bottom: 4),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                ),
            ),
            Positioned(
                left: 0,
                top: 152,
                child: Container(
                    width: 390,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            Container(
                                width: double.infinity,
                                padding: const EdgeInsets.only(
                                    top: 10,
                                    left: 16,
                                    right: 48,
                                    bottom: 10,
                                ),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFFEFF1F5),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(32),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
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
                                                        left: 5,
                                                        top: 5,
                                                        child: Container(
                                                            width: 14,
                                                            height: 14,
                                                            decoration: ShapeDecoration(
                                                                shape: RoundedRectangleBorder(
                                                                    side: BorderSide(
                                                                        width: 2,
                                                                        strokeAlign: BorderSide.strokeAlignCenter,
                                                                        color: const Color(0xFFA09CAB),
                                                                    ),
                                                                    borderRadius: BorderRadius.circular(13.71),
                                                                ),
                                                            ),
                                                        ),
                                                    ),
                                                ],
                                            ),
                                        ),
                                        SizedBox(
                                            width: 262,
                                            child: Text(
                                                'Tìm kiếm bài đăng…',
                                                style: TextStyle(
                                                    color: const Color(0xFFA09CAB),
                                                    fontSize: 16,
                                                    fontFamily: 'Inter',
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.25,
                                                ),
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
                left: 49,
                top: 101,
                child: Container(
                    width: 300,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            SizedBox(
                                width: 268,
                                child: Text(
                                    'Duyệt bài đăng',
                                    style: TextStyle(
                                        color: const Color(0xFF1C1B1F),
                                        fontSize: 32,
                                        fontFamily: 'Inter',
                                        fontWeight: FontWeight.w600,
                                        height: 1.25,
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 0,
                top: 48,
                child: Container(
                    width: 390,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(color: Colors.white),
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 6,
                        children: [
                            Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 10,
                                                children: [
                                                    Container(
                                                        width: 18,
                                                        height: 18,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Stack(),
                                                    ),
                                                ],
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Container(
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50),
                                    ),
                                ),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 10,
                                    children: [
                                        Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(color: const Color(0xFFF2F2F2)),
                                            child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                spacing: 10,
                                                children: [
                                                    Container(
                                                        width: 18,
                                                        height: 18,
                                                        clipBehavior: Clip.antiAlias,
                                                        decoration: BoxDecoration(),
                                                        child: Stack(),
                                                    ),
                                                ],
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
                left: 26,
                top: 117,
                child: Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 2,
                                color: const Color(0x00FF8181),
                            ),
                        ),
                    ),
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
            ),
            Positioned(
                left: 0,
                top: 820,
                child: Container(
                    width: 390,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 4,
                        children: [
                            Container(
                                width: 108,
                                height: 4,
                                decoration: ShapeDecoration(
                                    color: const Color(0xFF1C1B1F),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 0,
                top: 764,
                child: Container(
                    width: 390,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.white),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            Container(
                                width: double.infinity,
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
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 19,
                top: 267,
                child: Container(
                    width: 355,
                    height: 490,
                    decoration: ShapeDecoration(
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
                                child: Stack(
                                    children: [
                                        Container(
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
                                        Container(
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
                                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    spacing: 16,
                                    children: [
                                        Container(
                                            width: double.infinity,
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
                                        Container(
                                            width: double.infinity,
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
                                        Container(
                                            width: double.infinity,
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
                                        Container(
                                            width: double.infinity,
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
                                        Container(
                                            width: double.infinity,
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
                                        Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            spacing: 4,
                                            children: [
                                            
                                            ],
                                        ),
                                    ],
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 248,
                top: 702,
                child: Container(
                    width: 106,
                    height: 41,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                        color: const Color(0xFF0D6EFD),
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
                            Text(
                                'Xem chi tiết',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: 'Noto Sans',
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 32,
                top: 702,
                child: Container(
                    width: 161,
                    height: 41,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: ShapeDecoration(
                        color: const Color(0xFFFFC107),
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
                            Text(
                                'Chuyển lại trạng thái chờ',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                    fontFamily: 'Noto Sans',
                                    fontWeight: FontWeight.w600,
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 17,
                top: 221,
                child: Container(
                    width: 351,
                    height: 28,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 8,
                        children: [
                            Container(
                                width: 109,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: ShapeDecoration(
                                    color: const Color(0xFF14FF2F),
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
                                        Text(
                                            'Đã duyệt (469)',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 12,
                                                fontFamily: 'Noto Sans',
                                                fontWeight: FontWeight.w600,
                                            ),
                                        ),
                                    ],
                                ),
                            ),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: ShapeDecoration(
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
                                            Text(
                                                'Đang chờ (293)',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                            Expanded(
                                child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: ShapeDecoration(
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
                                            Text(
                                                'Từ chối (62)',
                                                style: TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 12,
                                                    fontFamily: 'Noto Sans',
                                                    fontWeight: FontWeight.w600,
                                                ),
                                            ),
                                        ],
                                    ),
                                ),
                            ),
                        ],
                    ),
                ),
            ),
            Positioned(
                left: 441,
                top: 61,
                child: Container(
                    width: 24,
                    height: 24,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 2,
                                color: const Color(0x00FF8181),
                            ),
                        ),
                    ),
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
            ),
        ],
    ),
);
  }
}


