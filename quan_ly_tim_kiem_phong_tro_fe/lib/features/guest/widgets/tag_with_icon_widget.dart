import 'package:flutter/material.dart';

/// TagWithIconWidget - Header title component for screens
/// 
/// Follows UI Design Guideline Section 5.2 & 5.4
/// 
/// Usage:
/// ```dart
/// TagWithIconWidget(title: "Tên màn hình")
/// 
/// // With custom icon
/// TagWithIconWidget(
///   title: "Tên màn hình",
///   icon: Icons.dashboard_rounded,
/// )
/// 
/// // With subtitle
/// TagWithIconWidget(
///   title: "Tên màn hình",
///   subtitle: "Mô tả phụ",
/// )
/// ```
class TagWithIconWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool showIcon;

  const TagWithIconWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.home_rounded,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (showIcon) ...[
          // Icon container với gradient theo guideline
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4C6FFF).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
        ],
        // Title + Subtitle
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Noto Sans',
                  color: Color(0xFF1A1F36),
                  letterSpacing: -0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Noto Sans',
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}