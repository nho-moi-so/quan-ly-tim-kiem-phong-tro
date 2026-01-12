import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Model chứa thông tin vị trí được chọn
class LocationResult {
  final double latitude;
  final double longitude;
  final String address;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.address,
  });
}

/// Dialog cho phép người dùng chọn vị trí trên bản đồ OpenStreetMap
class MapPickerDialog extends StatefulWidget {
  final String? initialAddress;
  final double? initialLatitude;
  final double? initialLongitude;

  const MapPickerDialog({
    super.key,
    this.initialAddress,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapPickerDialog> createState() => _MapPickerDialogState();
}

class _MapPickerDialogState extends State<MapPickerDialog> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();
  
  // Vị trí mặc định: Thành phố Hồ Chí Minh
  LatLng _selectedLocation = const LatLng(10.8231, 106.6297);
  String _selectedAddress = '';
  
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingAddress = false;
  bool _isGettingCurrentLocation = false;
  Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    // Nếu có tọa độ ban đầu, sử dụng nó
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(widget.initialLatitude!, widget.initialLongitude!);
    }
    if (widget.initialAddress != null && widget.initialAddress!.isNotEmpty) {
      _selectedAddress = widget.initialAddress!;
      _searchController.text = widget.initialAddress!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  /// Tìm kiếm địa chỉ sử dụng Nominatim API
  Future<void> _searchAddress(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=${Uri.encodeComponent(query)}&limit=5&countrycodes=vn&accept-language=vi',
        ),
        headers: {
          'User-Agent': 'QuanLyPhongTro/1.0',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchResults = data.map((item) => {
            'display_name': item['display_name'] ?? '',
            'lat': double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
            'lon': double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
          }).toList();
        });
      }
    } catch (e) {
      debugPrint('Error searching address: $e');
    } finally {
      setState(() {
        _isSearching = false;
      });
    }
  }

  /// Reverse geocoding: lấy địa chỉ từ tọa độ
  Future<void> _getAddressFromCoordinates(LatLng location) async {
    setState(() {
      _isLoadingAddress = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${location.latitude}&lon=${location.longitude}&accept-language=vi',
        ),
        headers: {
          'User-Agent': 'QuanLyPhongTro/1.0',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _selectedAddress = data['display_name'] ?? 
            '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
        });
      }
    } catch (e) {
      debugPrint('Error getting address: $e');
      setState(() {
        _selectedAddress = '${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}';
      });
    } finally {
      setState(() {
        _isLoadingAddress = false;
      });
    }
  }

  /// Chọn một kết quả tìm kiếm
  void _selectSearchResult(Map<String, dynamic> result) {
    final lat = result['lat'] as double;
    final lon = result['lon'] as double;
    
    setState(() {
      _selectedLocation = LatLng(lat, lon);
      _selectedAddress = result['display_name'] as String;
      _searchResults = [];
      _searchController.text = _selectedAddress;
    });

    _mapController.move(_selectedLocation, 16);
  }

  /// Xử lý khi người dùng tap vào bản đồ
  void _onMapTap(TapPosition tapPosition, LatLng location) {
    setState(() {
      _selectedLocation = location;
      _searchResults = [];
    });
    _getAddressFromCoordinates(location);
  }

  /// Lấy vị trí hiện tại của người dùng
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isGettingCurrentLocation = true;
    });

    try {
      // Kiểm tra quyền truy cập vị trí
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Vui lòng bật dịch vụ định vị trên thiết bị'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Quyền truy cập vị trí bị từ chối'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Quyền vị trí bị từ chối vĩnh viễn. Vui lòng mở cài đặt để cấp quyền.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      // Lấy vị trí hiện tại
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _selectedLocation = newLocation;
        _searchResults = [];
      });

      // Di chuyển bản đồ đến vị trí mới
      _mapController.move(newLocation, 17);
      
      // Lấy địa chỉ từ tọa độ
      await _getAddressFromCoordinates(newLocation);

    } catch (e) {
      debugPrint('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí hiện tại: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingCurrentLocation = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF4C6FFF),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.white),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Chọn vị trí trên bản đồ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            
            // Search bar
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey[100],
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm địa chỉ...',
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF4C6FFF)),
                        suffixIcon: _isSearching
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF4C6FFF),
                                  ),
                                ),
                              )
                            : _searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchResults = [];
                                      });
                                    },
                                    icon: const Icon(Icons.clear, color: Colors.grey),
                                  )
                                : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        _debounceTimer?.cancel();
                        _debounceTimer = Timer(const Duration(milliseconds: 500), () {
                          _searchAddress(value);
                        });
                      },
                    ),
                  ),
                  
                  // Kết quả tìm kiếm
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final result = _searchResults[index];
                          return ListTile(
                            leading: const Icon(
                              Icons.location_on_outlined,
                              color: Color(0xFF4C6FFF),
                            ),
                            title: Text(
                              result['display_name'] as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                            onTap: () => _selectSearchResult(result),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            
            // Map
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation,
                        initialZoom: 15,
                        onTap: _onMapTap,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.quan_ly_tim_kiem_phong_tro_fe',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation,
                              width: 50,
                              height: 50,
                              child: const Icon(
                                Icons.location_pin,
                                color: Color(0xFFEF4444),
                                size: 50,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Nút vị trí hiện tại
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: FloatingActionButton(
                      heroTag: 'currentLocationBtn',
                      onPressed: _isGettingCurrentLocation ? null : _getCurrentLocation,
                      backgroundColor: Colors.white,
                      elevation: 4,
                      child: _isGettingCurrentLocation
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4C6FFF),
                              ),
                            )
                          : const Icon(
                              Icons.my_location,
                              color: Color(0xFF4C6FFF),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Địa chỉ đã chọn và nút xác nhận
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFF4C6FFF),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Địa chỉ đã chọn:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      if (_isLoadingAddress)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF4C6FFF),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _selectedAddress.isEmpty
                          ? 'Chạm vào bản đồ hoặc tìm kiếm để chọn vị trí'
                          : _selectedAddress,
                      style: TextStyle(
                        fontSize: 13,
                        color: _selectedAddress.isEmpty ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tọa độ: ${_selectedLocation.latitude.toStringAsFixed(6)}, ${_selectedLocation.longitude.toStringAsFixed(6)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFF4C6FFF)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Hủy',
                            style: TextStyle(
                              color: Color(0xFF4C6FFF),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed: _selectedAddress.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                    LocationResult(
                                      latitude: _selectedLocation.latitude,
                                      longitude: _selectedLocation.longitude,
                                      address: _selectedAddress,
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4C6FFF),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Xác nhận vị trí',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
