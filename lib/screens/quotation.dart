import 'quotation_item.dart';

class Quotation {
  final String clientName;
  final String clientAddress;
  final String clientCell;
  final String clientEmail;
  final String attn;
  final String quoteNumber;
  final DateTime date;
  final String refNo;
  final List<QuotationItem> items;
  final String terms;
  final double totalArea;
  final double totalPrice;
  final String? description;

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