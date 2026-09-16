import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Service quản lý ví Blockchain (Hyperledger Fabric keystore)
/// Lưu trữ cục bộ (local) an toàn bằng flutter_secure_storage
class WalletService {
  static final WalletService _instance = WalletService._internal();
  factory WalletService() => _instance;
  WalletService._internal();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const String _keystoreKey = 'wallet_keystore';
  static const String _userIdKey = 'wallet_user_id';
  static const String _emailKey = 'wallet_email';

  // ─────────────────────────────────────────────
  // SAVE
  // ─────────────────────────────────────────────

  /// Lưu thông tin keystore từ response đăng ký
  /// [credentials]: data.credentials từ API response
  /// [userId]: userId từ data
  /// [email]: email của user
  Future<bool> saveKeystore({
    required Map<String, dynamic> credentials,
    String? userId,
    String? email,
  }) async {
    try {
      final keystoreJson = jsonEncode(credentials);
      await _storage.write(key: _keystoreKey, value: keystoreJson);
      if (userId != null) {
        await _storage.write(key: _userIdKey, value: userId);
      }
      if (email != null) {
        await _storage.write(key: _emailKey, value: email);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // LOAD
  // ─────────────────────────────────────────────

  /// Đọc keystore từ SecureStorage
  /// Trả về null nếu chưa có ví
  Future<Map<String, dynamic>?> loadKeystore() async {
    try {
      final raw = await _storage.read(key: _keystoreKey);
      if (raw == null) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Kiểm tra xem đã có ví chưa
  Future<bool> hasKeystore() async {
    final raw = await _storage.read(key: _keystoreKey);
    return raw != null && raw.isNotEmpty;
  }

  /// Lấy thông tin hiển thị của ví (không bao gồm privateKey)
  Future<Map<String, dynamic>> getKeystoreDisplayInfo() async {
    try {
      final keystore = await loadKeystore();
      if (keystore == null) {
        return {'hasWallet': false};
      }
      final userId = await _storage.read(key: _userIdKey);
      final email = await _storage.read(key: _emailKey);
      return {
        'hasWallet': true,
        'mspId': keystore['mspId'] ?? 'Unknown',
        'type': keystore['type'] ?? 'Unknown',
        'hasPrivateKey': keystore['privateKey'] != null &&
            (keystore['privateKey'] as String).isNotEmpty,
        'hasCertificate': keystore['certificate'] != null &&
            (keystore['certificate'] as String).isNotEmpty,
        'userId': userId,
        'email': email,
      };
    } catch (e) {
      return {'hasWallet': false};
    }
  }

  // ─────────────────────────────────────────────
  // DELETE
  // ─────────────────────────────────────────────

  /// Xoá ví khỏi SecureStorage
  Future<bool> deleteKeystore() async {
    try {
      await _storage.delete(key: _keystoreKey);
      await _storage.delete(key: _userIdKey);
      await _storage.delete(key: _emailKey);
      return true;
    } catch (e) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // EXPORT
  // ─────────────────────────────────────────────

  /// Xuất keystore.json ra ngoài thiết bị qua share sheet
  /// Trả về Map với success, message
  Future<Map<String, dynamic>> exportKeystoreFile({String? userId}) async {
    try {
      final keystore = await loadKeystore();
      if (keystore == null) {
        return {
          'success': false,
          'message': 'Không tìm thấy ví. Vui lòng đăng ký trước.',
        };
      }

      final storedUserId = userId ?? await _storage.read(key: _userIdKey);
      final email = await _storage.read(key: _emailKey);

      // Tạo cấu trúc file export đầy đủ
      final exportData = {
        'version': '1.0',
        'exportedAt': DateTime.now().toIso8601String(),
        'userId': storedUserId,
        'email': email,
        'credentials': keystore,
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Ghi vào file tạm
      final tempDir = await getTemporaryDirectory();
      final safeEmail = (email ?? 'wallet')
          .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
      final fileName = 'keystore_$safeEmail.json';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsString(jsonString, encoding: utf8);

      // Share file
      final xFile = XFile(file.path, mimeType: 'application/json');
      final result = await Share.shareXFiles(
        [xFile],
        subject: 'Backup ví Blockchain - $fileName',
        text: 'File keystore ví Blockchain của bạn. Hãy giữ bảo mật!',
      );

      if (result.status == ShareResultStatus.success ||
          result.status == ShareResultStatus.dismissed) {
        return {
          'success': true,
          'message': 'Xuất file keystore thành công!',
          'fileName': fileName,
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể chia sẻ file.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi xuất ví: ${e.toString()}',
      };
    }
  }

  // ─────────────────────────────────────────────
  // IMPORT
  // ─────────────────────────────────────────────

  /// Nhập keystore từ file JSON được chọn bởi người dùng
  /// Trả về Map với success, message
  Future<Map<String, dynamic>> importKeystoreFile() async {
    try {
      // Mở file picker
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) {
        return {
          'success': false,
          'message': 'Không có file nào được chọn.',
        };
      }

      final pickedFile = result.files.first;
      String? content;

      // Đọc nội dung file
      if (pickedFile.bytes != null) {
        content = utf8.decode(pickedFile.bytes!);
      } else if (pickedFile.path != null) {
        content = await File(pickedFile.path!).readAsString(encoding: utf8);
      }

      if (content == null || content.isEmpty) {
        return {
          'success': false,
          'message': 'File rỗng hoặc không đọc được.',
        };
      }

      // Parse JSON
      final Map<String, dynamic> parsed = jsonDecode(content);

      // Validate: phải có trường credentials hoặc trực tiếp là credentials
      Map<String, dynamic>? credentials;
      String? userId;
      String? email;

      if (parsed.containsKey('credentials')) {
        // Format export mới: {version, userId, email, credentials: {...}}
        credentials = parsed['credentials'] as Map<String, dynamic>?;
        userId = parsed['userId'] as String?;
        email = parsed['email'] as String?;
      } else if (parsed.containsKey('privateKey') &&
          parsed.containsKey('certificate')) {
        // Format credentials trực tiếp
        credentials = parsed;
      }

      if (credentials == null) {
        return {
          'success': false,
          'message':
              'File không hợp lệ. Vui lòng chọn đúng file keystore.json.',
        };
      }

      // Validate required fields
      if (credentials['privateKey'] == null ||
          credentials['certificate'] == null) {
        return {
          'success': false,
          'message': 'File thiếu thông tin privateKey hoặc certificate.',
        };
      }

      // Lưu vào SecureStorage
      final saved = await saveKeystore(
        credentials: credentials,
        userId: userId,
        email: email,
      );

      if (saved) {
        return {
          'success': true,
          'message': 'Nhập ví thành công!',
          'mspId': credentials['mspId'],
        };
      } else {
        return {
          'success': false,
          'message': 'Không thể lưu ví. Vui lòng thử lại.',
        };
      }
    } on FormatException {
      return {
        'success': false,
        'message': 'File JSON không hợp lệ.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi khi nhập ví: ${e.toString()}',
      };
    }
  }
}
