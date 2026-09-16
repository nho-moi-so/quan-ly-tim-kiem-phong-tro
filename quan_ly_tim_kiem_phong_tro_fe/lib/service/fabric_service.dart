import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pointycastle/asn1.dart';
import 'package:pointycastle/export.dart';

/// Service gọi các API Hyperledger Fabric (prepare-tx, submit-tx)
/// và thực hiện ký số ECDSA P-256 cục bộ (local signing).
class FabricService {
  static final FabricService _instance = FabricService._internal();
  factory FabricService() => _instance;
  FabricService._internal();

  // ─── Cấu hình endpoint ───────────────────────────────────────────────────

  static const Map<String, String> _defaultHeaders = {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true',
  };

  // ─── STEP 1: Prepare TX ──────────────────────────────────────────────────

  /// Gửi yêu cầu tạo unsigned Fabric Proposal
  ///
  /// Trả về Map:
  /// - success: bool
  /// - proposalBytes: String (base64)
  /// - digestHex: String (hex SHA-256 của proposal, cần ký)
  /// - message: String (nếu lỗi)
  Future<Map<String, dynamic>> prepareTx({
    required String functionName,
    required List<String> args,
    required String certificate,
    String mspId = 'Org1MSP',
  }) async {
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];
      if (serverDomain == null) {
        throw Exception('HOST_SERVER not defined in .env file');
      }

      final body = {
        'functionName': functionName,
        'args': args,
        'certificate': certificate,
        'mspId': mspId,
      };

      final response = await http
          .post(
            Uri.parse('$serverDomain/api/fabric/prepare-tx'),
            headers: _defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = decoded['status']?.toString().toLowerCase();
        if (status == 'success') {
          final data = decoded['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'proposalBytes': data['proposalBytes'] as String,
            'digestHex': data['digestHex'] as String,
          };
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Lỗi prepare-tx không xác định',
        };
      }

      return {
        'success': false,
        'message':
            decoded['message'] ?? 'HTTP ${response.statusCode}: prepare-tx thất bại',
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối prepare-tx: ${e.toString()}',
      };
    }
  }

  // ─── LOCAL SIGNING: ECDSA P-256 ──────────────────────────────────────────

  /// Ký cục bộ digestHex bằng EC private key PEM
  ///
  /// [digestHex]: chuỗi hex SHA-256 từ prepare-tx (32 bytes)
  /// [privateKeyPem]: EC private key dạng PEM (PKCS#8 hoặc SEC1)
  ///
  /// Trả về DER-encoded signature dạng hex (để gửi submit-tx),
  /// hoặc null nếu ký thất bại.
  Future<String?> signDigest(String digestHex, String privateKeyPem) async {
    try {
      final digestBytes = _hexToBytes(digestHex);
      final privateKey = _parseECPrivateKeyFromPem(privateKeyPem);

      // RFC 6979 deterministic ECDSA — không cần SecureRandom
      // null digest = sign raw bytes (digestHex đã là SHA-256, không hash lại)
      final signer = ECDSASigner(null, HMac(SHA256Digest(), 64));
      signer.init(true, PrivateKeyParameter<ECPrivateKey>(privateKey));

      var sig = signer.generateSignature(digestBytes) as ECSignature;

      // Hyperledger Fabric yêu cầu Low-S để chống giả mạo chữ ký (malleability)
      final n = privateKey.parameters!.n;
      final halfN = n >> 1;
      if (sig.s > halfN) {
        sig = ECSignature(sig.r, n - sig.s);
      }

      final derBytes = _derEncodeSignature(sig.r, sig.s);
      return _bytesToHex(derBytes);
    } catch (e) {
      print('❌ signDigest error: $e');
      return null;
    }
  }

  // ─── STEP 2: Endorse TX ──────────────────────────────────────────────────

  /// Gửi proposal đã ký (chữ ký lần 1) lên Fabric để Endorsing Peers chứng thực.
  ///
  /// Trả về Map:
  /// - success: bool
  /// - transactionBytes: String (base64, của giao dịch đã có endorsement)
  /// - digestHex: String (hex SHA-256, để ký lần 2)
  /// - message: String (nếu lỗi)
  Future<Map<String, dynamic>> endorseTx({
    required String proposalBytes,
    required String derSignatureHex,
    required String certificate,
    String mspId = 'Org1MSP',
  }) async {
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];
      if (serverDomain == null) {
        throw Exception('HOST_SERVER not defined in .env file');
      }

      final body = {
        'proposalBytes': proposalBytes,
        'derSignatureHex': derSignatureHex,
        'certificate': certificate,
        'mspId': mspId,
      };

      final response = await http
          .post(
            Uri.parse('$serverDomain/api/fabric/endorse-tx'),
            headers: _defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 45));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = decoded['status']?.toString().toLowerCase();
        if (status == 'success') {
          final data = decoded['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'transactionBytes': data['transactionBytes'] as String,
            'digestHex': data['digestHex'] as String,
          };
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Lỗi endorse-tx không xác định',
        };
      }

      return {
        'success': false,
        'message':
            decoded['message'] ?? 'HTTP ${response.statusCode}: endorse-tx thất bại',
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối endorse-tx: ${e.toString()}',
      };
    }
  }

  // ─── STEP 3: Submit TX ───────────────────────────────────────────────────

  /// Gửi transaction đã ký (chữ ký lần 2) lên Fabric Orderer để commit vào sổ cái.
  ///
  /// Trả về Map:
  /// - success: bool
  /// - transactionId: String
  /// - blockStatus: String (vd: "VALID")
  /// - message: String (nếu lỗi)
  Future<Map<String, dynamic>> submitTx({
    required String transactionBytes,
    required String derSignatureHex,
    required String certificate,
    String mspId = 'Org1MSP',
  }) async {
    try {
      final String? serverDomain = dotenv.env['HOST_SERVER'];
      if (serverDomain == null) {
        throw Exception('HOST_SERVER not defined in .env file');
      }

      final body = {
        'transactionBytes': transactionBytes,
        'derSignatureHex': derSignatureHex,
        'certificate': certificate,
        'mspId': mspId,
      };

      final response = await http
          .post(
            Uri.parse('$serverDomain/api/fabric/submit-tx'),
            headers: _defaultHeaders,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 || response.statusCode == 201) {
        final status = decoded['status']?.toString().toLowerCase();
        if (status == 'success') {
          final data = decoded['data'] as Map<String, dynamic>;
          return {
            'success': true,
            'transactionId': data['transactionId'] as String? ?? '',
            'blockStatus': data['blockStatus'] as String? ?? 'VALID',
          };
        }
        return {
          'success': false,
          'message': decoded['message'] ?? 'Lỗi submit-tx không xác định',
        };
      }

      return {
        'success': false,
        'message':
            decoded['message'] ?? 'HTTP ${response.statusCode}: submit-tx thất bại',
      };
    } on Exception catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối submit-tx: ${e.toString()}',
      };
    }
  }

  // ─── Private Helpers ─────────────────────────────────────────────────────

  /// Chuyển hex string → Uint8List bytes
  Uint8List _hexToBytes(String hex) {
    final clean = hex.startsWith('0x') ? hex.substring(2) : hex;
    final result = Uint8List(clean.length ~/ 2);
    for (var i = 0; i < clean.length; i += 2) {
      result[i ~/ 2] = int.parse(clean.substring(i, i + 2), radix: 16);
    }
    return result;
  }

  /// Chuyển bytes → hex string
  String _bytesToHex(Uint8List bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Parse EC private key từ PEM (hỗ trợ PKCS#8 và SEC1)
  ECPrivateKey _parseECPrivateKeyFromPem(String pem) {
    // Chuẩn hóa PEM: thay \n literal thành newline thật
    final normalized = pem.replaceAll(r'\n', '\n');

    final base64Str = normalized
        .replaceAll('-----BEGIN PRIVATE KEY-----', '')
        .replaceAll('-----END PRIVATE KEY-----', '')
        .replaceAll('-----BEGIN EC PRIVATE KEY-----', '')
        .replaceAll('-----END EC PRIVATE KEY-----', '')
        .replaceAll('\n', '')
        .replaceAll('\r', '')
        .trim();

    final derBytes = Uint8List.fromList(base64.decode(base64Str));
    final parser = ASN1Parser(derBytes);
    final topSeq = parser.nextObject() as ASN1Sequence;
    final elements = topSeq.elements!;

    Uint8List privateKeyBytes;

    final firstElem = elements[0];
    if (firstElem is ASN1Integer) {
      final version = firstElem.integer!;
      if (version == BigInt.zero) {
        // ── PKCS#8 format: SEQUENCE { version=0, AlgId, OCTET_STRING { SEC1 } }
        final octetStr = elements[2] as ASN1OctetString;
        final innerParser = ASN1Parser(Uint8List.fromList(octetStr.octets!));
        final innerSeq = innerParser.nextObject() as ASN1Sequence;
        final keyOctet = innerSeq.elements![1] as ASN1OctetString;
        privateKeyBytes = Uint8List.fromList(keyOctet.octets!);
      } else {
        // ── SEC1 format: SEQUENCE { version=1, OCTET_STRING(key), ... }
        final keyOctet = elements[1] as ASN1OctetString;
        privateKeyBytes = Uint8List.fromList(keyOctet.octets!);
      }
    } else {
      throw Exception('Unknown EC private key format');
    }

    final domainParams = ECDomainParameters('prime256v1'); // P-256
    final d = BigInt.parse(_bytesToHex(privateKeyBytes), radix: 16);
    return ECPrivateKey(d, domainParams);
  }

  /// Encode chữ ký ECDSA (r, s) sang DER format (ASN.1)
  Uint8List _derEncodeSignature(BigInt r, BigInt s) {
    Uint8List encodeInt(BigInt n) {
      var hex = n.toRadixString(16);
      if (hex.length % 2 != 0) hex = '0$hex';
      final bytes = List<int>.generate(
        hex.length ~/ 2,
        (i) => int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16),
      );
      // Thêm 0x00 prefix nếu bit cao nhất là 1 (DER yêu cầu số dương)
      if (bytes.first & 0x80 != 0) bytes.insert(0, 0x00);
      return Uint8List.fromList(bytes);
    }

    final rBytes = encodeInt(r);
    final sBytes = encodeInt(s);

    // DER SEQUENCE: 0x30 [len] 0x02 [r_len] [r] 0x02 [s_len] [s]
    final content = <int>[
      0x02, rBytes.length, ...rBytes,
      0x02, sBytes.length, ...sBytes,
    ];
    return Uint8List.fromList([0x30, content.length, ...content]);
  }
}
