import 'quotation_item.dart';

/// Model class representing a full quotation, including client info,
/// items, totals, and additional description or terms.
class Quotation {
  /// The client's name (company or individual).
  final String clientName;

  /// The client's address.
  final String clientAddress;

  /// The client's cell phone number.
  final String clientCell;

  /// The client's email address.
  final String clientEmail;

  /// The 'ATTN' (attention) field, e.g., person the quotation is addressed to.
  final String attn;

  /// The unique quotation number.
  final String quoteNumber;

  /// The date the quotation was issued.
  final DateTime date;

  /// An optional reference number.
  final String refNo;

  /// List of all items included in the quotation.
  final List<QuotationItem> items;

  /// Quotation terms and conditions.
  final String terms;

  /// Total area for all items (sum of item areas).
  final double totalArea;

  /// Total price for all items (sum of item net prices).
  final double totalPrice;

  /// Optional description or extra notes for the quotation.
  final String? description;

  /// Creates a new [Quotation] instance.
  Quotation({
    required this.clientName,
    required this.clientAddress,
    required this.clientCell,
    required this.clientEmail,
    required this.attn,
    required this.quoteNumber,
    required this.date,
    required this.refNo,
    required this.items,
    required this.terms,
    required this.totalArea,
    required this.totalPrice,
    this.description,
  });

  /// Factory to create a [Quotation] from a JSON map.
  factory Quotation.fromJson(Map<String, dynamic> json) => Quotation(
        clientName: json['clientName'],
        clientAddress: json['clientAddress'],
        clientCell: json['clientCell'],
        clientEmail: json['clientEmail'],
        attn: json['attn'],
        quoteNumber: json['quoteNumber'],
        date: DateTime.parse(json['date']),
        refNo: json['refNo'],
        items: (json['items'] as List)
            .map((e) => QuotationItem.fromJson(e))
            .toList(),
        terms: json['terms'],
        totalArea: (json['totalArea'] as num).toDouble(),
        totalPrice: (json['totalPrice'] as num).toDouble(),
        description: json['description'],
      );

  /// Converts the [Quotation] instance to a JSON map.
  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'clientAddress': clientAddress,
        'clientCell': clientCell,
        'clientEmail': clientEmail,
        'attn': attn,
        'quoteNumber': quoteNumber,
        'date': date.toIso8601String(),
        'refNo': refNo,
        'items': items.map((e) => e.toJson()).toList(),
        'terms': terms,
        'totalArea': totalArea,
        'totalPrice': totalPrice,
        'description': description,
      };
}