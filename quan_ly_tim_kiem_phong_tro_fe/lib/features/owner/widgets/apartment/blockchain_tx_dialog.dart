import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/fabric_service.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/service/wallet_service.dart';

/// Enum trạng thái luồng giao dịch blockchain
enum _TxStep {
  preparingTx,       // Đang gọi prepare-tx
  awaitingConfirm,   // Hiển thị chi tiết TX, chờ user bấm "Xác nhận"
  signingAndSubmit,  // Đang ký local + gọi submit-tx
  success,           // Thành công
  error,             // Thất bại
}

/// Dialog ký giao dịch Hyperledger Fabric theo kiểu MetaMask.
///
/// Luồng:
///  1. Auto gọi prepare-tx → lấy proposalBytes + digestHex
///  2. Hiển thị chi tiết giao dịch → user bấm "Xác nhận"
///  3. Tự ký ECDSA P-256 local bằng private key trong ví
///  4. Auto gọi submit-tx với chữ ký DER
///  5. Hiển thị transactionId + blockStatus
class BlockchainTxDialog extends StatefulWidget {
  final String apartmentId;
  final String ownerId;
  final String dailyRate;

  const BlockchainTxDialog({
    super.key,
    required this.apartmentId,
    required this.ownerId,
    required this.dailyRate,
  });

  /// Helper mở dialog và trả về transactionId nếu thành công, null nếu không.
  static Future<String?> show(
    BuildContext context, {
    required String apartmentId,
    required String ownerId,
    required String dailyRate,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlockchainTxDialog(
        apartmentId: apartmentId,
        ownerId: ownerId,
        dailyRate: dailyRate,
      ),
    );
  }

  @override
  State<BlockchainTxDialog> createState() => _BlockchainTxDialogState();
}

class _BlockchainTxDialogState extends State<BlockchainTxDialog>
    with SingleTickerProviderStateMixin {
  // ── State ──────────────────────────────────────────────────────────────
  _TxStep _step = _TxStep.preparingTx;
  String _errorMsg = '';
  String _proposalBytes = '';
  String _digestHex = '';
  String _transactionId = '';
  String _blockStatus = '';

  // Keystore data
  String _certificate = '';
  String _mspId = 'Org1MSP';
  String _privateKey = '';

  // Animation
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  // ── Lifecycle ──────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _runPrepareTx());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ── Logic ──────────────────────────────────────────────────────────────

  Future<void> _runPrepareTx() async {
    // Load keystore
    final keystore = await WalletService().loadKeystore();
    if (keystore == null) {
      if (!mounted) return;
      setState(() {
        _step = _TxStep.error;
        _errorMsg =
            'Không tìm thấy ví blockchain.\nVui lòng đăng ký hoặc import ví trước.';
      });
      return;
    }

    _certificate = keystore['certificate'] as String? ?? '';
    _mspId = keystore['mspId'] as String? ?? 'Org1MSP';
    _privateKey = keystore['privateKey'] as String? ?? '';

    if (_certificate.isEmpty || _privateKey.isEmpty) {
      if (!mounted) return;
      setState(() {
        _step = _TxStep.error;
        _errorMsg = 'Ví không đầy đủ thông tin (thiếu certificate hoặc privateKey).';
      });
      return;
    }

    // Gọi prepare-tx
    final result = await FabricService().prepareTx(
      functionName: 'CreateApartment',
      args: [widget.apartmentId, widget.ownerId, widget.dailyRate],
      certificate: _certificate,
      mspId: _mspId,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _proposalBytes = result['proposalBytes'] as String;
        _digestHex = result['digestHex'] as String;
        _step = _TxStep.awaitingConfirm;
      });
    } else {
      setState(() {
        _step = _TxStep.error;
        _errorMsg = result['message'] as String? ?? 'Lỗi không xác định';
      });
    }
    
    /*
    // =========================
    // code test ui
    // ==========================
    await Future.delayed(const Duration(seconds: 1)); // giả lập thời gian gọi prepare-tx
    if (!mounted) return;
    setState(() {
      _certificate = '-----BEGIN CERTIFICATE-----\nMIICVjCC...MockCert... \n-----END CERTIFICATE-----';
      _mspId = 'Org1MSP';
      _privateKey = 'mock_private_key';
      _proposalBytes = 'mock_proposal_bytes';
      _digestHex = 'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855';
      _step = _TxStep.awaitingConfirm;
    });
    // =========================
    */
  }

  /// Ký local + endorse + ký local + submit — gọi khi user bấm "Xác nhận"
  Future<void> _confirmAndSign() async {
    setState(() => _step = _TxStep.signingAndSubmit);
    // ==========================================
    // LẦN 1: KÝ PROPOSAL VÀ GỌI ENDORSE
    // ==========================================
    final sig1 =
        await FabricService().signDigest(_digestHex, _privateKey);

    if (sig1 == null) {
      if (!mounted) return;
      setState(() {
        _step = _TxStep.error;
        _errorMsg =
            'Ký Proposal thất bại. Kiểm tra lại private key trong ví.\n'
            '(ECDSA P-256 / prime256v1)';
      });
      return;
    }

    final endorseResult = await FabricService().endorseTx(
      proposalBytes: _proposalBytes,
      derSignatureHex: sig1,
      certificate: _certificate,
      mspId: _mspId,
    );

    if (!mounted) return;

    if (endorseResult['success'] != true) {
      setState(() {
        _step = _TxStep.error;
        _errorMsg = endorseResult['message'] as String? ?? 'Lỗi endorse-tx';
      });
      return;
    }

    final transactionBytes = endorseResult['transactionBytes'] as String;
    final transactionDigestHex = endorseResult['digestHex'] as String;

    // ==========================================
    // LẦN 2: KÝ TRANSACTION VÀ GỌI SUBMIT
    // ==========================================
    final sig2 =
        await FabricService().signDigest(transactionDigestHex, _privateKey);

    if (sig2 == null) {
      setState(() {
        _step = _TxStep.error;
        _errorMsg = 'Ký Transaction thất bại.';
      });
      return;
    }

    final submitResult = await FabricService().submitTx(
      transactionBytes: transactionBytes,
      derSignatureHex: sig2,
      certificate: _certificate,
      mspId: _mspId,
    );

    if (!mounted) return;

    if (submitResult['success'] == true) {
      setState(() {
        _transactionId = submitResult['transactionId'] as String? ?? '';
        _blockStatus = submitResult['blockStatus'] as String? ?? 'VALID';
        _step = _TxStep.success;
      });
    } else {
      setState(() {
        _step = _TxStep.error;
        _errorMsg = submitResult['message'] as String? ?? 'Lỗi submit-tx';
      });
    }
    
    /*
    // =========================
    // code test ui
    // ==========================
    await Future.delayed(const Duration(seconds: 2)); // giả lập thời gian sign và submit
    if (!mounted) return;
    
    setState(() {
      _transactionId = 'tx_mock_1234567890abcdef1234567890abcdef';
      _blockStatus = 'VALID';
      _step = _TxStep.success;
    });
    // =========================
    */
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label đã được sao chép'),
        backgroundColor: const Color(0xFF4C6FFF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ── Build ───────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF1E3A5F), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4C6FFF).withValues(alpha: 0.25),
              blurRadius: 40,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            _buildStepBar(),
            Flexible(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.05),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: _buildBody(),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: _buildFooter(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4C6FFF).withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.link_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Ký giao dịch Fabric',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hyperledger Fabric - ${_mspId }',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Nút đóng (chỉ cho phép khi không loading)
          if (_step != _TxStep.preparingTx && _step != _TxStep.signingAndSubmit)
            GestureDetector(
              onTap: () => Navigator.of(context).pop(
                _step == _TxStep.success ? _transactionId : null,
              ),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.close, color: Colors.white54, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  // ── Step Bar ───────────────────────────────────────────────────────────
  Widget _buildStepBar() {
    final step1Done = _step != _TxStep.preparingTx;
    final step2Done = _step == _TxStep.success;
    final step1Active = _step == _TxStep.preparingTx;
    final step2Active = _step == _TxStep.awaitingConfirm ||
        _step == _TxStep.signingAndSubmit;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          _stepDot(1, 'Prepare', step1Active, step1Done),
          Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: step1Done
                      ? [const Color(0xFF10B981), const Color(0xFF4C6FFF)]
                      : [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.white.withValues(alpha: 0.1),
                        ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
          _stepDot(2, 'Sign & Submit', step2Active, step2Done),
        ],
      ),
    );
  }

  Widget _stepDot(int num, String label, bool active, bool done) {
    final Color bg = done
        ? const Color(0xFF10B981)
        : active
            ? const Color(0xFF4C6FFF).withValues(alpha: 0.2)
            : Colors.transparent;
    final Color border = done
        ? const Color(0xFF10B981)
        : active
            ? const Color(0xFF4C6FFF)
            : Colors.white.withValues(alpha: 0.2);

    final Widget inner = done
        ? const Icon(Icons.check, size: 14, color: Colors.white)
        : Text(
            '$num',
            style: TextStyle(
              color: active
                  ? const Color(0xFF4C6FFF)
                  : Colors.white.withValues(alpha: 0.3),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          );

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border, width: 2),
            shape: BoxShape.circle,
          ),
          child: Center(child: inner),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: (active || done)
                ? Colors.white.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.3),
            fontSize: 9,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ── Body ───────────────────────────────────────────────────────────────
  Widget _buildBody() {
    switch (_step) {
      case _TxStep.preparingTx:
        return _buildLoadingState(
          key: const ValueKey('prep'),
          title: 'Đang chuẩn bị giao dịch...',
          subtitle: 'Kết nối Hyperledger Fabric',
        );
      case _TxStep.awaitingConfirm:
        return _buildConfirmState(key: const ValueKey('confirm'));
      case _TxStep.signingAndSubmit:
        return _buildLoadingState(
          key: const ValueKey('sign'),
          title: 'Đang ký & ghi lên blockchain...',
          subtitle: 'ECDSA P-256 · Hyperledger Fabric',
        );
      case _TxStep.success:
        return _buildSuccessState(key: const ValueKey('success'));
      case _TxStep.error:
        return _buildErrorState(key: const ValueKey('error'));
    }
  }

  // Loading spinner
  Widget _buildLoadingState({
    required Key key,
    required String title,
    required String subtitle,
  }) {
    return SizedBox(
      key: key,
      height: 160,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnim,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4C6FFF).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ── MetaMask-style Confirm Screen ──────────────────────────────────────
  Widget _buildConfirmState({required Key key}) {
    final certPreview = _certificate.length > 50
        ? '${_certificate.substring(0, 27)}...${_certificate.substring(_certificate.length - 20)}'
        : _certificate;

    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Tiêu đề xác nhận ===
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF4C6FFF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(0xFF4C6FFF).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF4C6FFF).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description_rounded,
                  color: Color(0xFF93C5FD),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CreateApartment',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Chaincode: renting · Channel: rentingchannel',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // === Chi tiết giao dịch ===
        _sectionTitle('CHI TIẾT GIAO DỊCH'),
        const SizedBox(height: 8),
        _txRow(Icons.home_rounded, 'Apartment ID', widget.apartmentId),
        _divider(),
        _txRow(Icons.person_rounded, 'Owner ID', widget.ownerId),
        _divider(),
        _txRow(
          Icons.payments_rounded,
          'Giá mỗi ngày',
          '${_formatPrice(widget.dailyRate)} VND/ngày',
          valueColor: const Color(0xFF34D399),
        ),

        const SizedBox(height: 14),

        // === Thông tin ký ===
        _sectionTitle('THÔNG TIN KÝ'),
        const SizedBox(height: 8),
        _txRow(Icons.security_rounded, 'MSP ID', _mspId),
        _divider(),
        GestureDetector(
          onTap: () => _copyToClipboard(_digestHex, 'Digest Hex'),
          child: _txRow(
            Icons.fingerprint_rounded,
            'Digest (SHA-256)',
            '${_digestHex.substring(0, 8)}...${_digestHex.substring(_digestHex.length - 8)}',
            trailing: const Icon(Icons.copy_rounded, size: 14, color: Colors.white24),
          ),
        ),
        _divider(),
        _txRow(
          Icons.badge_rounded,
          'Certificate',
          certPreview,
          maxLines: 1,
        ),

        const SizedBox(height: 14),

        // // === Cảnh báo bảo mật ===
        // Container(
        //   padding: const EdgeInsets.all(12),
        //   decoration: BoxDecoration(
        //     color: const Color(0xFFF59E0B).withValues(alpha: 0.08),
        //     borderRadius: BorderRadius.circular(12),
        //     border: Border.all(
        //       color: const Color(0xFFF59E0B).withValues(alpha: 0.25),
        //     ),
        //   ),
        //   // child: Row(
        //   //   children: [
        //   //     const Icon(
        //   //       Icons.lock_rounded,
        //   //       color: Color(0xFFFBBF24),
        //   //       size: 16,
        //   //     ),
        //   //     const SizedBox(width: 10),
        //   //     // Expanded(
        //   //     //   child: Text(
        //   //     //     'Private key sẽ ký cục bộ trên thiết bị. Không được truyền ra ngoài.',
        //   //     //     style: TextStyle(
        //   //     //       color: Colors.white.withValues(alpha: 0.6),
        //   //     //       fontSize: 11,
        //   //     //       height: 1.5,
        //   //     //     ),
        //   //     //   ),
        //   //     // ),
        //   //   ],
        //   // ),
        // ),

        const SizedBox(height: 16),
      ],
    );
  }

  // Success state
  Widget _buildSuccessState({required Key key}) {
    return Column(
      key: key,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 38),
        ),
        const SizedBox(height: 16),
        const Text(
          'Giao dịch thành công!',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Căn hộ đã được ghi lên Hyperledger Fabric',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 18),
        // Transaction ID
        GestureDetector(
          onTap: () => _copyToClipboard(_transactionId, 'Transaction ID'),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRANSACTION ID',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _transactionId.length > 30
                            ? '${_transactionId.substring(0, 16)}...${_transactionId.substring(_transactionId.length - 10)}'
                            : _transactionId,
                        style: const TextStyle(
                          color: Color(0xFF93C5FD),
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.copy_rounded, size: 14, color: Colors.white30),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        // Block Status badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.verified_rounded, size: 15, color: Color(0xFF10B981)),
                const SizedBox(width: 6),
                Text(
                  'Block: $_blockStatus',
                  style: const TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Error state
  Widget _buildErrorState({required Key key}) {
    return Column(
      key: key,
      children: [
        const SizedBox(height: 8),
        Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFEF4444).withValues(alpha: 0.12),
            border: Border.all(
              color: const Color(0xFFEF4444).withValues(alpha: 0.4),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Giao dịch thất bại',
          style: TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFEF4444).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFEF4444).withValues(alpha: 0.2)),
          ),
          child: Text(
            _errorMsg,
            style: const TextStyle(
              color: Color(0xFFEF4444),
              fontSize: 12,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Footer buttons ─────────────────────────────────────────────────────
  Widget _buildFooter() {
    switch (_step) {
      case _TxStep.preparingTx:
      case _TxStep.signingAndSubmit:
        return const SizedBox.shrink();

      case _TxStep.awaitingConfirm:
        return Row(
          children: [
            // Từ chối
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(null),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Center(
                    child: Text(
                      'Từ chối',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Xác nhận — nút chính
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: _confirmAndSign,
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4C6FFF).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Xác nhận',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );

      case _TxStep.success:
        return GestureDetector(
          onTap: () => Navigator.of(context).pop(_transactionId),
          child: Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.done_all_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text(
                  'Hoàn tất',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        );

      case _TxStep.error:
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(null),
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                  ),
                  child: Center(
                    child: Text(
                      'Bỏ qua',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _step = _TxStep.preparingTx;
                    _errorMsg = '';
                  });
                  _runPrepareTx();
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Thử lại',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }

  // ── Mini widgets ──────────────────────────────────────────────────────
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.3),
        fontSize: 9,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _txRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
    int maxLines = 2,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.4)),
          const SizedBox(width: 10),
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: valueColor ?? Colors.white.withValues(alpha: 0.85),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _divider() {
    return Divider(
      color: Colors.white.withValues(alpha: 0.06),
      height: 1,
    );
  }

  String _formatPrice(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return raw;
    final n = int.tryParse(digits);
    if (n == null) return raw;
    // Format 1,000,000
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
