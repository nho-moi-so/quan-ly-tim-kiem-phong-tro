import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/contract_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/helpers/format_currency.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/contact/invoice_widget.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/widgets.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({super.key, required this.contractId});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final ContractController _contractcontroller = ContractController();
  ContractDetail? contractDetail;
  String? errorMessage;

  bool _isDownloading = false;
  bool _isDownloadingInvoice = false;
  bool _isVerifying = false;

  // Store raw values for verification
  double _rawPrice = 0.0;

  // Controllers for verify modal (editable fields)
  final TextEditingController _contractIdCtrl = TextEditingController();
  final TextEditingController _apartmentCodeCtrl = TextEditingController();
  final TextEditingController _priceCtrl = TextEditingController();
  final TextEditingController _ownerEmailCtrl = TextEditingController();
  final TextEditingController _guestEmailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _checkinCtrl = TextEditingController();
  final TextEditingController _checkoutCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContractDetail();
  }

  Future<void> _loadContractDetail() async {
    try {
      final detail = await _contractcontroller.viewDetail(widget.contractId);

      // Lấy dữ liệu đầy đủ cho blockchain verify modal
      final verifyData = await _contractcontroller
          .getDetailContractForBlockchainVerify(widget.contractId);

      setState(() {
        contractDetail = detail;
        errorMessage = null;

        // Prefill verify modal controllers với dữ liệu đầy đủ từ contract
        _contractIdCtrl.text = verifyData['contractId'] ?? '';
        _apartmentCodeCtrl.text = verifyData['apartmentCode'] ?? '';

        // Store raw price and display formatted version
        final priceValue = verifyData['price'];
        _rawPrice = (priceValue is num) ? priceValue.toDouble() : 0.0;
        _priceCtrl.text = formatCurrency(_rawPrice);

        _ownerEmailCtrl.text = verifyData['ownerEmail'] ?? '';
        _guestEmailCtrl.text = verifyData['guestEmail'] ?? '';
        _passwordCtrl.text = verifyData['password'] ?? '';

        // Format datetime cho checkin/checkout (bao gồm giờ)
        final checkinDate = verifyData['checkinDate'] as DateTime?;
        final checkoutDate = verifyData['checkoutDate'] as DateTime?;
        _checkinCtrl.text = checkinDate != null
            ? '${checkinDate.day.toString().padLeft(2, '0')}/${checkinDate.month.toString().padLeft(2, '0')}/${checkinDate.year} ${checkinDate.hour.toString().padLeft(2, '0')}:${checkinDate.minute.toString().padLeft(2, '0')}'
            : '';
        _checkoutCtrl.text = checkoutDate != null
            ? '${checkoutDate.day.toString().padLeft(2, '0')}/${checkoutDate.month.toString().padLeft(2, '0')}/${checkoutDate.year} ${checkoutDate.hour.toString().padLeft(2, '0')}:${checkoutDate.minute.toString().padLeft(2, '0')}'
            : '';
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Không thể tải thông tin hợp đồng: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _downloadContract() async {
    if (contractDetail == null) return;
    setState(() => _isDownloading = true);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bắt đầu tải về hợp đồng...')));

    // Placeholder for real download logic. Simulate a short delay.
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã tải về hợp đồng ${widget.contractId}')),
    );
  }

  Future<void> _downloadInvoice() async {
    if (contractDetail == null) return;
    setState(() => _isDownloadingInvoice = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bắt đầu tải về hóa đơn...'),
        backgroundColor: Colors.blue,
      ),
    );

    // Placeholder for real download logic. Simulate a short delay.
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isDownloadingInvoice = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã tải về hóa đơn ${widget.contractId}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _pickDateTime(
    BuildContext context,
    TextEditingController controller,
  ) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF4C6FFF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && context.mounted) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: Color(0xFF4C6FFF),
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Color(0xFF1F2937),
              ),
            ),
            child: child!,
          );
        },
      );

      if (pickedTime != null) {
        final DateTime fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        controller.text =
            '${fullDateTime.day.toString().padLeft(2, '0')}/${fullDateTime.month.toString().padLeft(2, '0')}/${fullDateTime.year} ${fullDateTime.hour.toString().padLeft(2, '0')}:${fullDateTime.minute.toString().padLeft(2, '0')}';
      }
    }
  }

  /// Parse date string from format "dd/MM/yyyy HH:mm" to DateTime
  DateTime? _parseDateTime(String dateString) {
    try {
      if (dateString.isEmpty) return null;

      // Format: "01/11/2025 00:00"
      final parts = dateString.split(' ');
      if (parts.length != 2) return null;

      final dateParts = parts[0].split('/');
      final timeParts = parts[1].split(':');

      if (dateParts.length != 3 || timeParts.length != 2) return null;

      return DateTime(
        int.parse(dateParts[2]), // year
        int.parse(dateParts[1]), // month
        int.parse(dateParts[0]), // day
        int.parse(timeParts[0]), // hour
        int.parse(timeParts[1]), // minute
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _openVerifyModal() async {
    if (contractDetail == null) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
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
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4C6FFF).withOpacity(0.1),
                            const Color(0xFF4C6FFF).withOpacity(0.05),
                          ],
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(18),
                          topRight: Radius.circular(18),
                        ),
                      ),
                      child: Row(
                        children: [
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
                                  color: const Color(
                                    0xFF4C6FFF,
                                  ).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kiểm tra Blockchain',
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
                                  'Xác minh dữ liệu hợp đồng',
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
                      ),
                    ),

                    // Content
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildTextField(
                              label: 'ID Hợp đồng',
                              controller: _contractIdCtrl,
                              icon: Icons.fingerprint_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Mã căn hộ',
                              controller: _apartmentCodeCtrl,
                              icon: Icons.apartment_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Số tiền',
                              controller: _priceCtrl,
                              icon: Icons.payments_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Email chủ căn hộ',
                              controller: _ownerEmailCtrl,
                              icon: Icons.email_rounded,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Email khách hàng',
                              controller: _guestEmailCtrl,
                              icon: Icons.email_rounded,
                            ),
                            // const SizedBox(height: 16),
                            // _buildTextField(
                            //   label: 'Mật khẩu (nếu là khách)',
                            //   controller: _passwordCtrl,
                            //   obscure: true,
                            //   icon: Icons.lock_rounded,
                            // ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Ngày giờ checkin',
                              controller: _checkinCtrl,
                              readOnly: true,
                              icon: Icons.event_rounded,
                              onTap: () => _pickDateTime(ctx, _checkinCtrl),
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              label: 'Ngày giờ checkout',
                              controller: _checkoutCtrl,
                              readOnly: true,
                              icon: Icons.event_available_rounded,
                              onTap: () => _pickDateTime(ctx, _checkoutCtrl),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Actions
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: const Color(0xFFE5E7EB).withOpacity(0.5),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _buildModalButton(
                              label: 'Đóng',
                              icon: Icons.close_rounded,
                              bgColor: const Color(0xFF6B7280),
                              textColor: Colors.white,
                              onTap: () => Navigator.of(ctx).pop(),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: _buildModalButton(
                              label: _isVerifying
                                  ? 'Đang kiểm tra...'
                                  : 'Xác minh',
                              icon: Icons.verified_rounded,
                              bgColor: const Color(0xFF4C6FFF),
                              textColor: Colors.white,
                              isLoading: _isVerifying,
                              onTap: _isVerifying
                                  ? () {}
                                  : () async {
                                      setLocalState(() => _isVerifying = true);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                      strokeWidth: 2,
                                                      color: Colors.white,
                                                    ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Text(
                                                'Đang kiểm tra với blockchain...',
                                              ),
                                            ],
                                          ),
                                          backgroundColor: const Color(
                                            0xFF4C6FFF,
                                          ),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                        ),
                                      );
                                      final matched = await _contractcontroller
                                          .verifyDataOnBlockchainByOwner(
                                            contractId: _contractIdCtrl.text
                                                .trim(),
                                            apartmentCode: _apartmentCodeCtrl
                                                .text
                                                .trim(),
                                            price: _priceCtrl.text
                                                .trim()
                                                .replaceAll('.', ''), // Loại bỏ dấu chấm phân cách
                                            ownerEmail: _ownerEmailCtrl.text
                                                .trim(),
                                            guestEmail: _guestEmailCtrl.text
                                                .trim(),
                                            checkinDate:
                                                _parseDateTime(
                                                  _checkinCtrl.text.trim(),
                                                ) ??
                                                DateTime.now(),
                                            checkoutDate:
                                                _parseDateTime(
                                                  _checkoutCtrl.text.trim(),
                                                ) ??
                                                DateTime.now(),
                                          );
                                      setLocalState(() => _isVerifying = false);
                                      Navigator.of(ctx).pop();
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(
                                                matched
                                                    ? Icons.check_circle_rounded
                                                    : Icons.error_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  matched
                                                      ? 'Dữ liệu trùng khớp với blockchain'
                                                      : 'Dữ liệu KHÔNG trùng khớp với blockchain',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: matched
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFEF4444),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          duration: const Duration(seconds: 3),
                                        ),
                                      );
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          child: contractDetail == null
              ? Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(child: LogoWidget()),
                    SizedBox(height: screenHeight * 0.1),
                    errorMessage != null
                        ? EmptyStateWidget(
                            title: 'Không thể tải hợp đồng',
                            message: errorMessage!,
                            icon: Icons.error_outline,
                          )
                        : const LoadingWidget(
                            message: 'Đang tải thông tin hợp đồng...',
                          ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Spacing
                    SizedBox(height: screenHeight * 0.05),

                    // 2. Logo Widget
                    Center(child: LogoWidget()),

                    // 3. Header Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TagWithIconWidget(title: 'Chi tiết hợp đồng'),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4C6FFF), Color(0xFF6B8AFF)],
                            ),
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4C6FFF).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '#${widget.contractId}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: screenHeight * 0.02),

                    // THÔNG TIN HỢP ĐỒNG Card
                    _buildContractInfoCard(),

                    SizedBox(height: screenHeight * 0.02),

                    // CHI TIẾT HÓA ĐƠN Card
                    _buildInvoiceCard(),

                    SizedBox(height: screenHeight * 0.02),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: contractDetail != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'Quay lại',
                        icon: Icons.arrow_back_rounded,
                        bgColor: const Color(0xFF6B7280),
                        textColor: Colors.white,
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionButton(
                        label: 'Kiểm tra',
                        icon: Icons.verified_rounded,
                        bgColor: const Color(0xFF4C6FFF),
                        textColor: Colors.white,
                        onTap: _openVerifyModal,
                        isLoading: _isVerifying,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildContractInfoCard() {
    return Container(
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
                  const Color(0xFF10B981).withOpacity(0.1),
                  const Color(0xFF10B981).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF10B981).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Thông Tin Hợp Đồng',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
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
                SummaryWidget(
                  imageUrl: contractDetail!.imageUrl,
                  price: contractDetail!.price,
                  deposit: contractDetail!.price,
                  title: contractDetail!.title,
                  address: contractDetail!.address,
                  features: contractDetail!.features,
                ),
                const SizedBox(height: 16),
                _buildInteractiveMap(),
                const SizedBox(height: 16),
                ExtendInfoWidget(
                  checkInTime: contractDetail!.checkInTime.toString(),
                  checkOutTime: contractDetail!.checkOutTime.toString(),
                  extraInfo: contractDetail!.extraInfo!,
                  description: contractDetail!.description!,
                ),
                const SizedBox(height: 16),
                // Nút tải hợp đồng
                SizedBox(
                  width: double.infinity,
                  child: _actionButton(
                    label: _isDownloading ? 'Đang tải...' : 'Tải hợp đồng',
                    icon: Icons.download_rounded,
                    bgColor: const Color(0xFF10B981),
                    textColor: Colors.white,
                    onTap: _isDownloading ? () {} : _downloadContract,
                    isLoading: _isDownloading,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard() {
    return Container(
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
                  const Color(0xFF4C6FFF).withOpacity(0.1),
                  const Color(0xFF4C6FFF).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
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
                  child: const Icon(
                    Icons.receipt_long_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chi Tiết Hóa Đơn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: InvoiceWidget(
              dailyRate: contractDetail!.dailyRate ?? 0,
              numberOfDays: contractDetail!.numberOfDays ?? 1,
              otherFees: contractDetail!.otherFees ?? 0,
              taxRate: contractDetail!.taxRate ?? 0,
              discount: contractDetail!.discount ?? 0,
              onDownload: _downloadInvoice,
              isDownloading: _isDownloadingInvoice,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      height: 48,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, size: 20, color: textColor),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    bool obscure = false,
    IconData? icon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: readOnly ? const Color(0xFFF8F9FF) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: readOnly
                  ? const Color(0xFFE0E7FF)
                  : const Color(0xFFBFCDE6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            obscureText: obscure,
            onTap: onTap,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: readOnly
                  ? const Color(0xFF6B7280)
                  : const Color(0xFF1F2937),
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: InputBorder.none,
              prefixIcon: icon != null
                  ? Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: Icon(
                        icon,
                        size: 20,
                        color: readOnly
                            ? const Color(0xFF6B7280)
                            : const Color(0xFF4C6FFF),
                      ),
                    )
                  : null,
              prefixIconConstraints: const BoxConstraints(
                minWidth: 40,
                minHeight: 20,
              ),
              suffixIcon: obscure
                  ? Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Icon(
                        Icons.visibility_off_rounded,
                        size: 20,
                        color: const Color(0xFF6B7280),
                      ),
                    )
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
    bool isLoading = false,
  }) {
    return Container(
      height: 48,
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isLoading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  Icon(icon, size: 20, color: textColor),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                      letterSpacing: 0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveMap() {
    // Vị trí mặc định nếu không có tọa độ
    final lat = contractDetail?.latitude ?? 10.8231;
    final lon = contractDetail?.longitude ?? 106.6297;
    final address = contractDetail?.address ?? 'Địa chỉ không có sẵn';
    
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF4C6FFF), width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4C6FFF).withOpacity(0.1),
                  const Color(0xFF4C6FFF).withOpacity(0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4C6FFF), Color(0xFF7C3AED)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Vị trí trên bản đồ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (contractDetail?.ratingText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      contractDetail!.ratingText!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Map
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            child: SizedBox(
              height: 250,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(lat, lon),
                  initialZoom: 15,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.quan_ly_tim_kiem_phong_tro_fe',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: LatLng(lat, lon),
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
          ),
          
          // Address footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(10),
                bottomRight: Radius.circular(10),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 18,
                  color: Color(0xFF4C6FFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    address,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                if (contractDetail?.rating != null) ...[
                  Row(
                    children: List.generate(
                      5,
                      (index) => Icon(
                        index < (contractDetail!.rating ?? 0).round()
                            ? Icons.star
                            : Icons.star_border,
                        size: 16,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
