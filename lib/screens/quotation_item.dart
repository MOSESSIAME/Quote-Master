class QuotationItem {
  final String code;
  final String description;
  final double width;
  final double height;
  final int quantity;
  final double area;
  final double unitPrice;
  final double netPrice;

  QuotationItem({
    required this.code,
    required this.description,
    required this.width,
    required this.height,
    required this.quantity,
    required this.area,
    required this.unitPrice,
    required this.netPrice,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) => QuotationItem(
        code: json['code'],
        description: json['description'],
        width: (json['width'] as num).toDouble(),
        height: (json['height'] as num).toDouble(),
        quantity: json['quantity'],
        area: (json['area'] as num).toDouble(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
        netPrice: (json['netPrice'] as num).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'width': width,
        'height': height,
        'quantity': quantity,
        'area': area,
        'unitPrice': unitPrice,
        'netPrice': netPrice,
      };
}