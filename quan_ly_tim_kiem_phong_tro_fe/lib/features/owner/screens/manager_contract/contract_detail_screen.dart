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

  @override
  void initState() {
    super.initState();
    _loadContractDetail();
  }

  Future<void> _loadContractDetail() async {
    final detail = await _contractcontroller.viewDetail(widget.contractId);
    setState(() {
      contractDetail = detail;
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
          child: contractDetail == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Center(child: LogoWidget()),
                    Row(
                      children: [
                        const Spacer(),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    // FliterStatusWidget(),
                    SizedBox(height: screenHeight * 0.02),
                    LabelTitleWidget(title: "Chi tiết hợp đồng"),
                    SummaryWidget(
                      imageUrl: contractDetail!.imageUrl,
                      price: contractDetail!.price,
                      deposit: contractDetail!.deposit,
                      title: contractDetail!.title,
                      address: contractDetail!.address,
                      features: contractDetail!.features,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    LocationReviewWidget(
                      imageUrl: contractDetail!.imageUrlMap!,
                      ratingText: contractDetail!.ratingText!,
                      address: contractDetail!.address!,
                      rating: contractDetail!.rating!,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    ExtendInfoWidget(
                      checkInTime: DateTime(2023, 10, 1, 14, 0).toString(),
                      checkOutTime: DateTime(2023, 10, 2, 12, 0).toString(),
                      extraInfo: contractDetail!.extraInfo!,
                      description: contractDetail!.description!,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    PasswordDisplayWidget(password: contractDetail!.password!),
                  ],
                ),
        ),
      ),
    );
  }
}