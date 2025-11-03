import 'package:flutter/material.dart';

enum RoomFilter {
  all,      // Tất cả
  rented,   // Đang Ở
  available // Đang Trống
}

class LabelStatusWidget extends StatefulWidget {
  final RoomFilter initialFilter;
  final Function(RoomFilter)? onFilterChanged;

  const LabelStatusWidget({
    super.key,
    this.initialFilter = RoomFilter.all,
    this.onFilterChanged,
  });

  @override
  State<LabelStatusWidget> createState() => _LabelStatusWidgetState();
}

class _LabelStatusWidgetState extends State<LabelStatusWidget> {
  late RoomFilter selectedFilter;

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter;
  }

  void _onFilterTap(RoomFilter filter) {
    setState(() {
      selectedFilter = filter;
    });
    widget.onFilterChanged?.call(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
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
      child: Row(
        children: [
          Expanded(
            child: _FilterChip(
              label: 'Tất cả',
              icon: Icons.grid_view_rounded,
              color: const Color(0xFF4C6FFF),
              isSelected: selectedFilter == RoomFilter.all,
              onTap: () => _onFilterTap(RoomFilter.all),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'Đang Ở',
              icon: Icons.home_rounded,
              color: const Color(0xFFEF4444),
              isSelected: selectedFilter == RoomFilter.rented,
              onTap: () => _onFilterTap(RoomFilter.rented),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _FilterChip(
              label: 'Đang Trống',
              icon: Icons.door_front_door_rounded,
              color: const Color(0xFF10B981),
              isSelected: selectedFilter == RoomFilter.available,
              onTap: () => _onFilterTap(RoomFilter.available),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [color, color.withOpacity(0.85)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.2),
            width: isSelected ? 2 : 1.5,
          ),
          boxShadow: isSelected
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? Colors.white : color,
                  fontSize: 13,
                  fontFamily: 'Noto Sans',
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
