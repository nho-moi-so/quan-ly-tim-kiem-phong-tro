import 'package:flutter/material.dart';

class ApartmentSearch extends StatelessWidget {
  const ApartmentSearch({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search
        Expanded(
          child: Container(
            height: 42,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFF4285F4)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: const [
                Icon(Icons.search, size: 20, color: Color(0xFF4285F4)),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Search Inquires...',
                    style: TextStyle(
                      color: Color(0xFFCCCCCC),
                      fontSize: 14,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Filter
        Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF4285F4)),
            borderRadius: BorderRadius.circular(7),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Filter',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Icon(Icons.arrow_drop_down, color: Colors.black),
            ],
          ),
        ),
      ],
    );
  }
}
