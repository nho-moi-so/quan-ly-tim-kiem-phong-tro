import 'package:flutter/material.dart';

class BookingFilterTabs extends StatefulWidget {
  const BookingFilterTabs({super.key});

  @override
  State<BookingFilterTabs> createState() => _BookingFilterTabsState();
}

class _BookingFilterTabsState extends State<BookingFilterTabs> {
  int selectedIndex = 0;

  final List<String> tabs = ['Tất Cả', 'Mới Nhất', 'Cũ Nhất', 'Đã Hủy'];

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    // final double tabHeight = screenWidth * 0.1;
    final double fontSize = screenWidth * 0.035;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final bool isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                selectedIndex = index;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  width: 1.2,
                ),
              ),
              child: Text(
                tabs[index],
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? Colors.black : Colors.grey[700],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
