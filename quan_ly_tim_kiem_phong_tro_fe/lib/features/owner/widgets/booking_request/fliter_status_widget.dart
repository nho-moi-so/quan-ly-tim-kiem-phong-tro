import 'package:flutter/material.dart';

class FliterStatusWidget extends StatefulWidget {
  const FliterStatusWidget({super.key});

  @override
  State<FliterStatusWidget> createState() => _FliterStatusWidgetState();
}

class _FliterStatusWidgetState extends State<FliterStatusWidget> {
  int activeIndex = 0;

  final List<String> tabs = [
    'Tất Cả',
    'Yêu Cầu Mới',
    'Đã Thanh Toán',
    'Đã Hủy',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 394,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFEBE7E7),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0x3F000000),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
      child: Row(
        children: List.generate(tabs.length, (index) {
          return TabButton(
            label: tabs[index],
            isActive: activeIndex == index,
            onTap: () {
              setState(() {
                activeIndex = index;
              });
            },
          );
        }),
      ),
    );
  }
}

class TabButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  const TabButton({
    super.key,
    required this.label,
    this.isActive = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        height: 35,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isActive
              ? Border.all(
                  color: const Color(0xFF4285F4),
                  width: 1,
                )
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 13,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              height: 2.54,
            ),
          ),
        ),
      ),
    );
  }
}
