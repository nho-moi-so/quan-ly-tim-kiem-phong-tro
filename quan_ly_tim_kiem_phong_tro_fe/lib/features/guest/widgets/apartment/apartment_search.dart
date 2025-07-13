import 'package:flutter/material.dart';

class ApartmentSearch extends StatelessWidget {
  const ApartmentSearch({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Search
          Expanded(
            flex: 6,
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

          SizedBox(width: screenWidth * 0.03),

          // Filter
          Expanded(
            flex: 4,
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFF4285F4)),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          ),
        ],
      ),
    );
  }
}
