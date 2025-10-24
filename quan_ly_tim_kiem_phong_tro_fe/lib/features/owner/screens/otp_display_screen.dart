import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/owner/socket_service.dart';

class OtpDisplayScreen extends StatefulWidget {
  const OtpDisplayScreen({super.key});

  @override
  State<OtpDisplayScreen> createState() => _OtpDisplayScreenState();
}

class _OtpDisplayScreenState extends State<OtpDisplayScreen> {
  bool _dialogShown = false;

  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);

    // Show dialog when OTP is received
    if (socketService.otp != null && !_dialogShown) {
      _dialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOtpDialog(context, socketService);
      });
    }

    // Reset dialog flag when OTP is cleared
    if (socketService.otp == null && _dialogShown) {
      _dialogShown = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('IOT Connection Monitor'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              // Connection Status Card
              Card(
                elevation: 4,
                color: _getStatusColor(socketService.connectionStatus),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(socketService.connectionStatus),
                        size: 48,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Trạng thái Socket',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        socketService.connectionStatus ?? 'Initializing...',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Instructions
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, size: 40, color: Colors.blue),
                      SizedBox(height: 12),
                      Text(
                        'Hướng dẫn test:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        '1. Đảm bảo server đang chạy\n'
                        '2. Gửi POST request từ Postman:\n'
                        '   http://localhost:3000/api/iot/connect-room\n'
                        '   Body: {"roomCode": "P101"}\n'
                        '3. Dialog OTP sẽ hiển thị tự động',
                        textAlign: TextAlign.left,
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Current OTP Info (if available)
              if (socketService.otp != null)
                Card(
                  color: Colors.green.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          '✅ OTP đã nhận',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Room: ${socketService.roomName ?? socketService.roomCode}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        if (socketService.apartmentName != null)
                          Text(
                            'Apartment: ${socketService.apartmentName}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'OTP: ${socketService.otp}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'Connected':
      case 'OTP Ready':
      case 'Verification Successful':
        return Colors.green;
      case 'Disconnected':
        return Colors.red;
      case 'Error':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(String? status) {
    switch (status) {
      case 'Connected':
        return Icons.check_circle;
      case 'OTP Ready':
        return Icons.key;
      case 'Verification Successful':
        return Icons.verified;
      case 'Disconnected':
        return Icons.cancel;
      default:
        return Icons.sync;
    }
  }

  void _showOtpDialog(BuildContext context, SocketService socketService) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.wifi_tethering,
                  color: Colors.blue.shade700,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '🔑 Thiết bị IOT yêu cầu kết nối',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Room Info
              if (socketService.roomName != null) ...[
                _buildInfoRow('Phòng:', socketService.roomName!),
                const SizedBox(height: 8),
              ],
              if (socketService.apartmentName != null) ...[
                _buildInfoRow('Tòa nhà:', socketService.apartmentName!),
                const SizedBox(height: 16),
              ],
              // OTP Display
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade700,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Mã OTP',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          socketService.otp ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Clipboard.setData(
                              ClipboardData(text: socketService.otp ?? ''),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✓ Đã copy mã OTP'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.copy,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Instructions
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Nhập mã này vào thiết bị ESP32 để xác thực',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                socketService.resetOtp();
              },
              child: const Text('Đóng'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
