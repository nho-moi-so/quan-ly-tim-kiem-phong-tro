class InvoiceDetail {
  final String invoiceDetailID;
  final String description;
  final int quantity;
  final double unitPrice;
  final double subTotal;

  InvoiceDetail({
    required this.invoiceDetailID,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.subTotal,
  });

  factory InvoiceDetail.fromMap(String id, Map<String, dynamic> map) => InvoiceDetail(
        invoiceDetailID: id,
        description: map['Description'] ?? '',
        quantity: map['Quantity'] ?? 0,
        unitPrice: (map['UnitPrice'] as num).toDouble(),
        subTotal: (map['SubTotal'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'Description': description,
        'Quantity': quantity,
        'UnitPrice': unitPrice,
        'SubTotal': subTotal,
      };
}