import 'package:flutter/material.dart';

class FliterStatusWidget extends StatefulWidget {
  final ValueChanged<String>? onStatusChanged;
  final List<String> tabs;
  
  const FliterStatusWidget({super.key, this.onStatusChanged, required this.tabs});

  @override
  State<FliterStatusWidget> createState() => _FliterStatusWidgetState();
}

class _FliterStatusWidgetState extends State<FliterStatusWidget> {
  int activeIndex = 0;

  Color _getColorForStatus(String status) {
    // Map màu dựa trên text status được truyền vào
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('pending') || lowerStatus.contains('chờ')) {
      return const Color(0xFFF59E0B); // Orange
    } else if (lowerStatus.contains('approved') || lowerStatus.contains('duyệt') || lowerStatus.contains('xác nhận')) {
      return const Color(0xFF10B981); // Green
    } else if (lowerStatus.contains('canceled') || lowerStatus.contains('hủy') || lowerStatus.contains('từ chối')) {
      return const Color(0xFFEF4444); // Red
    } else if (lowerStatus.contains('completed') || lowerStatus.contains('hoàn thành')) {
      return const Color(0xFF8B5CF6); // Purple
    } else if (lowerStatus.contains('all') || lowerStatus.contains('tất cả')) {
      return const Color(0xFF4C6FFF); // Blue
    } else {
      return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getIconForStatus(String status) {
    // Map icon dựa trên text status được truyền vào
    final lowerStatus = status.toLowerCase();
    if (lowerStatus.contains('pending') || lowerStatus.contains('chờ')) {
      return Icons.schedule_rounded;
    } else if (lowerStatus.contains('approved') || lowerStatus.contains('duyệt') || lowerStatus.contains('xác nhận')) {
      return Icons.check_circle_rounded;
    } else if (lowerStatus.contains('canceled') || lowerStatus.contains('hủy') || lowerStatus.contains('từ chối')) {
      return Icons.cancel_rounded;
    } else if (lowerStatus.contains('completed') || lowerStatus.contains('hoàn thành')) {
      return Icons.verified_rounded;
    } else if (lowerStatus.contains('all') || lowerStatus.contains('tất cả')) {
      return Icons.grid_view_rounded;
    } else {
      return Icons.label_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth - 32,
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8F9FF),
            Color(0xFFFFFFFF),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFCDE6), width: 2),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            spreadRadius: 0,
            offset: const Offset(0, 4),
            color: Colors.black.withOpacity(0.06),
          ),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(widget.tabs.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                right: index < widget.tabs.length - 1 ? 8 : 0,
              ),
              child: _StatusChip(
                label: widget.tabs[index],
                icon: _getIconForStatus(widget.tabs[index]),
                color: _getColorForStatus(widget.tabs[index]),
                isActive: activeIndex == index,
                onTap: () {
                  setState(() {
                    activeIndex = index;
                    widget.onStatusChanged?.call(widget.tabs[index]);
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isActive;
  final VoidCallback? onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isActive ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : color.withOpacity(0.2),
            width: isActive ? 2 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : color,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
