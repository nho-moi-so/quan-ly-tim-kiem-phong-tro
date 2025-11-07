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

  String _displayLabel(String status) {
    final s = status.toLowerCase();
    if (s.contains('approved') || s.contains('duyệt') || s.contains('xác nhận')) return 'Đã duyệt';
    if (s.contains('canceled') || s.contains('hủy') || s.contains('từ chối')) return 'Đã hủy';
    if (s.contains('pending') || s.contains('chờ')) return 'Chờ xử lý';
    if (s.contains('completed') || s.contains('hoàn thành')) return 'Hoàn thành';
    if (s.contains('all') || s.contains('tất cả')) return 'Tất cả';
    return status;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Container(
      width: screenWidth - 32,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: List.generate(widget.tabs.length, (index) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 4,
                right: index == widget.tabs.length - 1 ? 0 : 4,
              ),
              child: _StatusChip(
                label: _displayLabel(widget.tabs[index]),
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
            ),
          );
        }),
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
        height: 48,
        decoration: BoxDecoration(
          gradient: isActive
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : LinearGradient(
                  colors: [Colors.white, Colors.grey.shade50],
                ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? color : const Color(0xFFE5E7EB),
            width: isActive ? 2 : 1.5,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isActive ? Colors.white : color,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : color,
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
