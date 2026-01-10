import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/contract_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/contact/invoice_widget.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/widgets/widgets.dart';

class ContractDetailScreen extends StatefulWidget {
  final String contractId;

  const ContractDetailScreen({
    super.key,
    required this.contractId,
  });

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final ContractController _contractcontroller = ContractController();
  ContractDetail? contractDetail;
  String? errorMessage;

  bool _isDownloading = false;
  bool _isDownloadingInvoice = false;

  @override
  void initState() {
    super.initState();
    _loadContractDetail();
  }

  Future<void> _loadContractDetail() async {
    try {
      final detail = await _contractcontroller.viewDetail(widget.contractId);
      setState(() {
        contractDetail = detail;
        errorMessage = null;
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bắt đầu tải về hợp đồng...')),
    );

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
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                LocationReviewWidget(
                  imageUrl: contractDetail!.imageUrlMap!,
                  ratingText: contractDetail!.ratingText!,
                  address: contractDetail!.address!,
                  rating: contractDetail!.rating!,
                ),
                const SizedBox(height: 16),
                ExtendInfoWidget(
                  checkInTime: contractDetail!.checkInTime.toString(),
                  checkOutTime: contractDetail!.checkOutTime.toString(),
                  extraInfo: contractDetail!.extraInfo!,
                  description: contractDetail!.description!,
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
}