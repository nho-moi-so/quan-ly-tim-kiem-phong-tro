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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // keep app bar minimal; header content moved into body to match ApartmentScreen layout
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // add bottom padding for buttons
          color: Colors.grey[50],
          child: contractDetail == null
              ? SizedBox(
                  height: screenHeight - kToolbarHeight,
                  child: errorMessage != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                            
                              Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    errorMessage = null;
                                  });
                                  _loadContractDetail();
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Thử lại'),
                              ),
                            ],
                          ),
                        )
                      : const Center(child: CircularProgressIndicator()),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo centered (matching ApartmentScreen layout)
                    Center(child: LogoWidget()),
                    // Title row similar to ApartmentScreen: Tag + badge/action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TagWithIconWidget(title: 'Chi tiết hợp đồng'),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            '#${widget.contractId}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    SizedBox(height: screenHeight * 0.01),
                    // Section Header - HỢP ĐỒNG
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.shade600,
                            Colors.green.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.description_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'THÔNG TIN HỢP ĐỒNG',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Main card with summary and details
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SummaryWidget(
                              imageUrl: contractDetail!.imageUrl,
                              price: contractDetail!.price,
                              deposit: contractDetail!.price,
                              title: contractDetail!.title,
                              address: contractDetail!.address,
                              features: contractDetail!.features,
                            ),
                            const SizedBox(height: 12),
                            LocationReviewWidget(
                              imageUrl: contractDetail!.imageUrlMap!,
                              ratingText: contractDetail!.ratingText!,
                              address: contractDetail!.address!,
                              rating: contractDetail!.rating!,
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Extended info card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ExtendInfoWidget(
                          checkInTime: contractDetail!.checkInTime.toString(),
                          checkOutTime: contractDetail!.checkOutTime.toString(),
                          extraInfo: contractDetail!.extraInfo!,
                          description: contractDetail!.description!,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    // Section Header - HÓA ĐƠN
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade600,
                            Colors.blue.shade400,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.receipt_long_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'CHI TIẾT HÓA ĐƠN',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                    // Invoice card
                    InvoiceWidget(
                      dailyRate: contractDetail!.dailyRate ?? 0,
                      numberOfDays: contractDetail!.numberOfDays ?? 1,
                      otherFees: contractDetail!.otherFees ?? 0,
                      taxRate: contractDetail!.taxRate ?? 0,
                      discount: contractDetail!.discount ?? 0,
                      onDownload: _downloadInvoice,
                      isDownloading: _isDownloadingInvoice,
                    ),
                    // // Password card
                    // Card(
                    //   shape: RoundedRectangleBorder(
                    //     borderRadius: BorderRadius.circular(12),
                    //   ),
                    //   elevation: 1,
                    //   child: Padding(
                    //     padding: const EdgeInsets.all(12.0),
                    //     child:
                    //         PasswordDisplayWidget(password: contractDetail!.password!),
                    //   ),
                    // ),
                  ],
                ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: Colors.black, // text & icon màu đen
          ),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Quay lại'),
          onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.black, // text & icon màu đen
          ),
          icon: _isDownloading
              ? const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.black,
            ),
                )
              : const Icon(Icons.description_rounded),
          label: Text(_isDownloading ? 'Đang tải...' : 'Tải hợp đồng'),
          onPressed: contractDetail == null || _isDownloading
              ? null
              : _downloadContract,
              ),
            ),
          ],
        ),
      ),
    );
  }
}