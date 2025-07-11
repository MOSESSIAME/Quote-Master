/// Model class representing a single item in a quotation.
class QuotationItem {
  /// Unique code for the item (e.g., SKU or product code)
  final String code;

  /// Description of the item
  final String description;

  /// Width of the item (e.g., in meters)
  final double width;

  /// Height of the item (e.g., in meters)
  final double height;

  /// Quantity of the item
  final int quantity;

  /// Total area for this item (width * height * quantity)
  final double area;

  /// Price per unit area
  final double unitPrice;

  /// Total net price for this item (area * unitPrice)
  final double netPrice;

  /// Constructor for creating a QuotationItem instance.
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

  /// Create a QuotationItem from a JSON map.
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

  /// Convert a QuotationItem instance to a JSON map.
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