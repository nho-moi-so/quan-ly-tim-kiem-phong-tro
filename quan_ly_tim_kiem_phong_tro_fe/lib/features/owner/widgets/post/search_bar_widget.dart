import 'package:flutter/material.dart';

class SearchBarWidget extends StatelessWidget {
  const SearchBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 390,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Tìm kiếm bài đăng…',
          hintStyle: const TextStyle(
            color: Color(0xFFA09CAB),
            fontSize: 16,
            fontFamily: 'Inter',
            // fontWeight: FontWeight.w400,
            // height: 1.25,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFA09CAB),
            size: 24,
          ),
          filled: true,
          fillColor: const Color(0xFFEFF1F5),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
