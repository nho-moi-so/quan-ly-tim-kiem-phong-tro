# 📱 UI Design Guideline - Quản Lý Tìm Kiếm Phòng Trọ

> Tài liệu tổng hợp chi tiết các quy tắc thiết kế giao diện để refactor và đồng bộ hóa các màn hình trong ứng dụng.

---

## 📋 MỤC LỤC

1. [Cấu Trúc Màn Hình Chung](#1-cấu-trúc-màn-hình-chung)
2. [Hệ Màu Sắc (Color Palette)](#2-hệ-màu-sắc-color-palette)
3. [Typography](#3-typography)
4. [Container & Card Styles](#4-container--card-styles)
5. [Component Widgets](#5-component-widgets)
6. [Action Buttons](#6-action-buttons)
7. [Status Indicators](#7-status-indicators)
8. [Filter & Search Components](#8-filter--search-components)
9. [Spacing & Layout](#9-spacing--layout)
10. [Shadow & Effects](#10-shadow--effects)
11. [Code Examples](#11-code-examples)

---

## 1. CẤU TRÚC MÀN HÌNH CHUNG

### 1.1 Layout Pattern

Tất cả màn hình đều sử dụng cấu trúc thống nhất:

```dart
Scaffold(
  body: SingleChildScrollView(
    child: Container(
      width: screenWidth,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Spacing (5% màn hình)
          SizedBox(height: screenHeight * 0.05),
          
          // 2. Logo Widget (căn giữa)
          Center(child: LogoWidget()),
          
          // 3. Header Row (Title + Action Button)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TagWithIconWidget(title: "Tiêu đề màn hình"),
              ButtonAddWidget(...), // Optional
            ],
          ),
          
          // 4. Spacing
          SizedBox(height: screenHeight * 0.02),
          
          // 5. Filter/Search Components (Optional)
          FilterWidget(...),
          
          // 6. Spacing
          SizedBox(height: screenHeight * 0.02),
          
          // 7. Main Content (List/Cards/Charts)
          ContentWidgets(...),
          
          // 8. Bottom Spacing
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    ),
  ),
)
```

### 1.2 Responsive Sizing

```dart
// Lấy kích thước màn hình
final screenWidth = MediaQuery.of(context).size.width;
final screenHeight = MediaQuery.of(context).size.height;

// Vertical Spacing (theo tỉ lệ phần trăm)
SizedBox(height: screenHeight * 0.05)  // 5% - Top padding
SizedBox(height: screenHeight * 0.02)  // 2% - Section spacing
SizedBox(height: screenHeight * 0.01)  // 1% - Small spacing

// Horizontal Padding
padding: const EdgeInsets.symmetric(horizontal: 16)

// Card/Container width
width: screenWidth - 32  // Full width trừ padding
```

---

## 2. HỆ MÀU SẮC (COLOR PALETTE)

### 2.1 Primary Colors

| Tên | Hex Code | Sử dụng |
|-----|----------|---------|
| **Primary Blue** | `#4C6FFF` | Button chính, Icon primary, Links |
| **Primary Blue Light** | `#6B8AFF` | Gradient secondary |
| **Primary Purple** | `#7C3AED` | Accent, Gradient |
| **Primary Purple Light** | `#8B5CF6` | Edit buttons, Secondary actions |

### 2.2 Semantic Colors (Status)

| Status | Hex Code | Icon | Sử dụng |
|--------|----------|------|---------|
| **Success/Available** | `#10B981` | ✓ | Còn trống, Đã duyệt, Success |
| **Error/Rented** | `#EF4444` | ✗ | Đã thuê, Hủy, Xóa, Đăng xuất |
| **Warning/Pending** | `#F59E0B` | ⏳ | Đang chờ, Cảnh báo |
| **Completed** | `#8B5CF6` | ✓ | Hoàn thành |

### 2.3 Neutral Colors

| Tên | Hex Code | Sử dụng |
|-----|----------|---------|
| **Text Primary** | `#1F2937` / `#1A1F36` | Tiêu đề chính |
| **Text Secondary** | `#6B7280` | Label, subtitle |
| **Text Muted** | `#64748B` | Mô tả phụ |
| **Border Primary** | `#E0E7FF` | Card borders |
| **Border Secondary** | `#BFCDE6` | Chart/Widget borders |
| **Border Light** | `#E5E7EB` | Dividers |
| **Background Light** | `#FAFBFF` | Card gradient start |
| **Background White** | `#FFFFFF` | Card gradient end |
| **Background Tint** | `#F8F9FF` | Chart backgrounds |

### 2.4 Color Usage Code

```dart
// Primary Blue
const Color(0xFF4C6FFF)

// Status Colors
const Color(0xFF10B981) // Green - Available/Success
const Color(0xFFEF4444) // Red - Rented/Error
const Color(0xFFF59E0B) // Orange - Pending/Warning
const Color(0xFF8B5CF6) // Purple - Completed/Edit

// Text Colors
const Color(0xFF1F2937) // Primary text
const Color(0xFF6B7280) // Secondary text
const Color(0xFF64748B) // Muted text

// Borders
const Color(0xFFE0E7FF) // Card border
const Color(0xFFBFCDE6) // Widget border
const Color(0xFFE5E7EB) // Divider
```

---

## 3. TYPOGRAPHY

### 3.1 Font Families

```dart
// Primary Font
fontFamily: 'Noto Sans'

// Secondary Font (cho một số widget)
fontFamily: 'Inter'
```

### 3.2 Text Styles

| Loại | Size | Weight | Color | Sử dụng |
|------|------|--------|-------|---------|
| **Heading XL** | 28 | w800 | `#1A1F36` | Số lớn trong charts |
| **Heading L** | 20 | w700 | `#1A1F36` | Section titles |
| **Heading M** | 18 | w700 | `#1A1F36` | Widget titles |
| **Heading S** | 16 | w700 | `#1F2937` | Card titles |
| **Body L** | 15 | w700 | varies | Values có highlight |
| **Body M** | 14 | w600 | `#6B7280` | Labels |
| **Body S** | 13 | w500/w600 | `#6B7280` | Descriptions |
| **Caption** | 12 | w500/w600 | varies | Status, small labels |
| **Caption XS** | 11 | w500 | gray | Axis labels |

### 3.3 Text Style Examples

```dart
// Heading Large
TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  fontFamily: 'Noto Sans',
  color: Color(0xFF1A1F36),
  letterSpacing: -0.5,
)

// Card Title
TextStyle(
  fontSize: 16,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1F2937),
)

// Label
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: Color(0xFF6B7280),
)

// Body/Value
TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w700,
  color: Color(0xFF1F2937),
)

// Caption/Status
TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  fontFamily: 'Inter',
  color: Colors.white, // hoặc status color
)

// Subtitle
TextStyle(
  fontSize: 12,
  fontFamily: 'Noto Sans',
  color: Color(0xFF64748B),
  fontWeight: FontWeight.w400,
)
```

---

## 4. CONTAINER & CARD STYLES

### 4.1 Standard Card Container

```dart
Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFAFBFF),
        Color(0xFFFFFFFF),
      ],
    ),
    borderRadius: BorderRadius.circular(16), // hoặc 20 cho cards lớn
    border: Border.all(
      color: const Color(0xFFE0E7FF), // hoặc #BFCDE6 cho widgets
      width: 2,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 16, // hoặc 22 cho widgets lớn
        spreadRadius: 0,
        offset: const Offset(0, 4), // hoặc (0, 6)
      ),
    ],
  ),
  child: ...
)
```

### 4.2 Card với Header có Status Color

```dart
Container(
  decoration: BoxDecoration(
    gradient: const LinearGradient(...),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
    boxShadow: [...],
  ),
  child: Column(
    children: [
      // Header với gradient theo status
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              statusColor.withOpacity(0.1),
              statusColor.withOpacity(0.05),
            ],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
          ),
        ),
        child: Row(...),
      ),
      // Body content
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(...),
      ),
    ],
  ),
)
```

### 4.3 BorderRadius Standards

```dart
// Cards lớn (Room Card, Booking Card)
borderRadius: BorderRadius.circular(20)

// Widgets trung bình (Charts, Status)
borderRadius: BorderRadius.circular(16)

// Buttons, Chips
borderRadius: BorderRadius.circular(12)

// Small elements (status badges, icons)
borderRadius: BorderRadius.circular(8) hoặc BorderRadius.circular(10)

// Rounded (số trong charts)
borderRadius: BorderRadius.circular(6)
```

---

## 5. COMPONENT WIDGETS

### 5.1 LogoWidget

```dart
// Sử dụng mặc định
Center(child: LogoWidget())

// Với scale tùy chỉnh
LogoWidget(scale: 0.8)
```

### 5.2 TagWithIconWidget (Screen Title)

```dart
TagWithIconWidget(title: "Tên màn hình")
```

### 5.3 Info Row Pattern

Pattern chung cho hiển thị thông tin trong cards:

```dart
Widget _buildInfoRow({
  required IconData icon,
  required Color iconColor,
  required String label,
  required String value,
  TextStyle? valueStyle,
}) {
  return Row(
    children: [
      // Icon Container
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              iconColor.withOpacity(0.15),
              iconColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      const SizedBox(width: 12),
      // Label
      Expanded(
        flex: 2,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
      // Value
      Expanded(
        flex: 3,
        child: Text(
          value,
          style: valueStyle ?? const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
          textAlign: TextAlign.right,
        ),
      ),
    ],
  );
}
```

### 5.4 Header với Icon Pattern

```dart
Row(
  children: [
    // Icon container với gradient
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
        Icons.icon_name,
        color: Colors.white,
        size: 24,
      ),
    ),
    const SizedBox(width: 12),
    // Title + Subtitle
    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tiêu đề',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              fontFamily: 'Noto Sans',
              color: Color(0xFF1A1F36),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Mô tả phụ',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Noto Sans',
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    ),
  ],
)
```

### 5.5 LoadingWidget

```dart
// Sử dụng cơ bản
LoadingWidget()

// Với message tùy chỉnh
LoadingWidget(
  message: 'Đang tải danh sách phòng...',
)
```

### 5.6 EmptyStateWidget

```dart
EmptyStateWidget(
  title: 'Không có dữ liệu',
  message: 'Mô tả chi tiết về trạng thái rỗng',
  icon: Icons.inbox_outlined,
)
```

---

## 6. ACTION BUTTONS

### 6.1 Standard Action Button Pattern

```dart
Widget _actionButton({
  required String label,
  required IconData icon,
  required Color bgColor,
  required Color textColor,
  required VoidCallback onTap,
}) {
  return Container(
    height: 44,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [bgColor, bgColor.withOpacity(0.85)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: bgColor.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: textColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

### 6.2 Button Color Schemes

| Loại Button | bgColor | textColor | Icon Examples |
|-------------|---------|-----------|---------------|
| **View/Detail** | `#4C6FFF` | White | `visibility_rounded` |
| **Post/Create** | `#10B981` | White | `post_add_rounded` |
| **Contract** | `#10B981` | White | `description_rounded` |
| **Edit** | `#8B5CF6` | White | `edit_rounded` |
| **Delete** | `#EF4444` | White | `delete_rounded` |
| **Add Customer** | `#8B5CF6` | White | `person_add_rounded` |
| **Refund** | `#F59E0B` | White | `monetization_on_rounded` |

### 6.3 Button Add Widget

```dart
ButtonAddWidget(
  title: "Thêm căn hộ mới",
  screen: DetailScreen(),
  onNavigateBack: _refreshList,
)
```

---

## 7. STATUS INDICATORS

### 7.1 Status Badge Pattern

```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [statusColor, statusColor.withOpacity(0.85)],
    ),
    borderRadius: BorderRadius.circular(8),
    boxShadow: [
      BoxShadow(
        color: statusColor.withOpacity(0.3),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Text(
    statusText,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: Colors.white,
    ),
  ),
)
```

### 7.2 Status Color Mapping

```dart
Color _getStatusColor(String status) {
  final s = status.toLowerCase();
  
  // Available/Approved
  if (s.contains('available') || s.contains('approved') || 
      s.contains('duyệt') || s.contains('trống')) {
    return const Color(0xFF10B981);
  }
  // Rented/Canceled/Rejected
  else if (s.contains('rented') || s.contains('canceled') || 
           s.contains('rejected') || s.contains('hủy') || s.contains('thuê')) {
    return const Color(0xFFEF4444);
  }
  // Pending
  else if (s.contains('pending') || s.contains('chờ')) {
    return const Color(0xFFF59E0B);
  }
  // Completed
  else if (s.contains('completed') || s.contains('hoàn thành')) {
    return const Color(0xFF8B5CF6);
  }
  // Default
  return const Color(0xFF6B7280);
}
```

### 7.3 Status Vietnamese Mapping

```dart
String _getStatusInVietnamese(String status) {
  final s = status.toLowerCase();
  if (s.contains('available')) return 'Còn trống';
  if (s.contains('rented')) return 'Đã thuê';
  if (s.contains('approved')) return 'Đã duyệt';
  if (s.contains('canceled')) return 'Đã hủy';
  if (s.contains('pending')) return 'Đang chờ';
  if (s.contains('rejected')) return 'Đã từ chối';
  if (s.contains('completed')) return 'Hoàn thành';
  return status;
}
```

### 7.4 Status Icon Mapping

```dart
IconData _getIconForStatus(String status) {
  final s = status.toLowerCase();
  if (s.contains('pending')) return Icons.schedule_rounded;
  if (s.contains('approved')) return Icons.check_circle_rounded;
  if (s.contains('canceled')) return Icons.cancel_rounded;
  if (s.contains('completed')) return Icons.verified_rounded;
  if (s.contains('all')) return Icons.grid_view_rounded;
  return Icons.label_rounded;
}
```

---

## 8. FILTER & SEARCH COMPONENTS

### 8.1 Filter Status Widget (Tabs)

```dart
FliterStatusWidget(
  tabs: ['Approved', 'Canceled'],
  onStatusChanged: (status) {
    setState(() {
      selectedStatus = status;
    });
  },
)
```

### 8.2 Label Status Widget (Room Filter)

```dart
LabelStatusWidget(
  initialFilter: currentFilter,
  onFilterChanged: (filter) {
    setState(() {
      currentFilter = filter;
    });
  },
)
```

### 8.3 Filter Chip Pattern

```dart
class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

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
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : color,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 8.4 Search By Date Widget

```dart
SearchByDateWidget(
  onDateRangeChanged: (from, to) async {
    // Handle date range change
  },
)
```

---

## 9. SPACING & LAYOUT

### 9.1 Standard Spacing Values

| Size | Value | Sử dụng |
|------|-------|---------|
| **XS** | 4px | Giữa icon và text nhỏ |
| **S** | 6px | Giữa elements gần nhau |
| **M** | 8px | Spacing trong buttons |
| **L** | 12px | Spacing trong cards |
| **XL** | 16px | Padding cards, sections |
| **XXL** | 20px | Padding widgets lớn |
| **XXXL** | 24px | Spacing giữa sections |

### 9.2 Padding Standards

```dart
// Screen padding
padding: const EdgeInsets.symmetric(horizontal: 16)

// Card padding
padding: const EdgeInsets.all(16)

// Widget padding (charts, status widgets)
padding: const EdgeInsets.all(20)

// Button padding
padding: const EdgeInsets.symmetric(horizontal: 12)
padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10)

// Status badge padding
padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6)

// Icon container padding
padding: const EdgeInsets.all(8)
padding: const EdgeInsets.all(10)
```

### 9.3 Margin Standards

```dart
// Card margin
margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8)
margin: const EdgeInsets.only(bottom: 16)
margin: const EdgeInsets.only(bottom: 12)

// Filter widget margin
margin: const EdgeInsets.symmetric(vertical: 12)
```

---

## 10. SHADOW & EFFECTS

### 10.1 Standard Shadows

```dart
// Light Shadow (buttons, chips inactive)
BoxShadow(
  color: Colors.black.withOpacity(0.03),
  blurRadius: 4,
  offset: const Offset(0, 2),
)

// Medium Shadow (cards, containers)
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 16,
  offset: const Offset(0, 4),
)

// Large Shadow (widgets, charts)
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 22,
  spreadRadius: 0,
  offset: const Offset(0, 6),
)

// Color Shadow (buttons, status badges)
BoxShadow(
  color: bgColor.withOpacity(0.3),
  blurRadius: 8,
  offset: const Offset(0, 4),
)

// Active Filter Shadow
BoxShadow(
  color: color.withOpacity(0.25),
  blurRadius: 12,
  offset: const Offset(0, 4),
)
```

### 10.2 Gradient Patterns

```dart
// Primary Gradient (buttons, icons)
LinearGradient(
  colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)

// Card Background Gradient
LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [
    Color(0xFFFAFBFF),
    Color(0xFFFFFFFF),
  ],
)

// Status Color Gradient
LinearGradient(
  colors: [statusColor, statusColor.withOpacity(0.85)],
)

// Icon Background Gradient
LinearGradient(
  colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
)
```

---

## 11. CODE EXAMPLES

### 11.1 Complete Screen Template

```dart
import 'package:flutter/material.dart';
import '../widgets/widgets.dart';

class ExampleScreen extends StatefulWidget {
  const ExampleScreen({super.key});

  @override
  State<ExampleScreen> createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  bool _isLoading = true;
  List<DataModel> _data = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    // Load data...
    setState(() {
      _data = [...];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.05),
              Center(child: LogoWidget()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TagWithIconWidget(title: "Tiêu đề màn hình"),
                  ButtonAddWidget(
                    title: "Thêm mới",
                    screen: DetailScreen(),
                    onNavigateBack: _loadData,
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              
              // Content
              _isLoading
                ? const LoadingWidget(message: 'Đang tải...')
                : _data.isEmpty
                  ? EmptyStateWidget(
                      title: 'Không có dữ liệu',
                      message: 'Chưa có dữ liệu nào',
                      icon: Icons.inbox_outlined,
                    )
                  : Column(
                      children: _data.map((item) => ItemCard(data: item)).toList(),
                    ),
              
              SizedBox(height: screenHeight * 0.02),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 11.2 Complete Card Widget Template

```dart
class ItemCardWidget extends StatelessWidget {
  final DataModel data;

  const ItemCardWidget({super.key, required this.data});

  Color _getStatusColor(String status) {
    // Status color mapping...
  }

  String _getStatusText(String status) {
    // Status text mapping...
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(data.status);
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFAFBFF), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7FF), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  statusColor.withOpacity(0.1),
                  statusColor.withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Title với icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4C6FFF),
                            const Color(0xFF4C6FFF).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4C6FFF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.icon, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Label',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        Text(
                          data.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor, statusColor.withOpacity(0.85)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: statusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusText(data.status),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildInfoRow(
                  icon: Icons.person_rounded,
                  iconColor: const Color(0xFF10B981),
                  label: 'Label',
                  value: data.value,
                ),
                const SizedBox(height: 12),
                // More info rows...
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 12),
          
          // Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Chi Tiết',
                    icon: Icons.visibility_rounded,
                    bgColor: const Color(0xFF4C6FFF),
                    textColor: Colors.white,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _actionButton(
                    label: 'Chỉnh Sửa',
                    icon: Icons.edit_rounded,
                    bgColor: const Color(0xFF8B5CF6),
                    textColor: Colors.white,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({...}) { ... }
  Widget _actionButton({...}) { ... }
}
```

---

## 📌 CHECKLIST KHI TẠO MÀN HÌNH MỚI

- [ ] Sử dụng layout pattern chung (SingleChildScrollView + Container + Column)
- [ ] Thêm LogoWidget ở đầu màn hình
- [ ] Sử dụng TagWithIconWidget cho title
- [ ] Thêm ButtonAddWidget nếu cần action tạo mới
- [ ] Sử dụng LoadingWidget khi đang tải
- [ ] Sử dụng EmptyStateWidget khi không có dữ liệu
- [ ] Áp dụng đúng color palette cho status
- [ ] Sử dụng gradient cho cards và buttons
- [ ] Áp dụng đúng border radius theo loại component
- [ ] Thêm shadow theo chuẩn
- [ ] Sử dụng đúng typography styles
- [ ] Đảm bảo responsive với screenWidth/screenHeight

---

## 📝 NOTES

1. **Consistency**: Luôn sử dụng cùng pattern cho các component tương tự
2. **Animation**: Sử dụng `AnimatedContainer` với `duration: 250ms` cho transitions
3. **Accessibility**: Đảm bảo contrast ratio đủ cho text
4. **Performance**: Sử dụng `const` constructor khi có thể
5. **Localization**: Sử dụng helper functions để map status text sang tiếng Việt

---

> **Cập nhật lần cuối**: Tháng 1, 2026
