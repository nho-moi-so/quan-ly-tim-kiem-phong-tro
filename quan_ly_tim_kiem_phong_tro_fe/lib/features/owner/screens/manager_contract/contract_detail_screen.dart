import 'package:flutter/material.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/controller/contract_controller.dart';
import 'package:quan_ly_tim_kiem_phong_tro_fe/features/owner/viewmodel/contract_detail.dart';
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
      const SnackBar(content: Text('Bắt đầu tải về...')),
    );

    // Placeholder for real download logic. Simulate a short delay.
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isDownloading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã tải về hợp đồng ${widget.contractId}')),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Chi tiết hợp đồng',
          style: TextStyle(color: Colors.black87),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: screenWidth,
          padding: EdgeInsets.fromLTRB(16, 12, 16, 100), // add bottom padding for buttons
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
                              const SizedBox(height: 16),
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
                    SizedBox(height: screenHeight * 0.01),
                    Center(child: LogoWidget()),
                    SizedBox(height: screenHeight * 0.02),

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
                              deposit: contractDetail!.deposit,
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

                    SizedBox(height: screenHeight * 0.02),

                    // Extended info card
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: ExtendInfoWidget(
                          checkInTime: DateTime(2023, 10, 1, 14, 0).toString(),
                          checkOutTime: DateTime(2023, 10, 2, 12, 0).toString(),
                          extraInfo: contractDetail!.extraInfo!,
                          description: contractDetail!.description!,
                        ),
                      ),
                    ),

                    SizedBox(height: screenHeight * 0.02),

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
                ),
                icon: _isDownloading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.download),
                label: Text(_isDownloading ? 'Đang tải...' : 'Tải về'),
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