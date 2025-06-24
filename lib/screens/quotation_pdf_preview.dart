import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../pdf/pdf_company_header.dart';
import '../screens/quotation.dart';

class QuotationPdfPreview extends StatelessWidget {
  final Quotation quotation;
  final bool showUnitPrice;

  const QuotationPdfPreview({
    Key? key,
    required this.quotation,
    this.showUnitPrice = true,
  }) : super(key: key);

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();
    final logo = await rootBundle.load('assets/images/header.png');
    final logoBytes = logo.buffer.asUint8List();

    const companyName = 'WILHOETE LTD';
    const tpin = '1018233036';
    const bankName = 'UBA';
    const bankAccountName = 'WILHOETE LIMITED';
    const bankAccountNo = '9030160 010969';
    const bankBranch = 'CAIRO ROAD';
    const bankCode = '370000';
    const sortCode = '370003';
    const swiftCode = 'UNAFMLU';

    doc.addPage(
      pw.Page(
        pageFormat: format,
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          final tableHeaders = [
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('CODE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('DESCRIPTION', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('WIDTH', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('HEIGHT', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('QTY', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
            pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('AREA (SQM)', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
          ];
          if (showUnitPrice) {
            tableHeaders.add(pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('UNIT PRICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))));
          }
          tableHeaders.add(pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('NET PRICE', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))));

          final columnWidths = <int, pw.TableColumnWidth>{
            0: pw.FixedColumnWidth(40),
            1: pw.FlexColumnWidth(3),
            2: pw.FixedColumnWidth(48),
            3: pw.FixedColumnWidth(48),
            4: pw.FixedColumnWidth(32),
            5: pw.FixedColumnWidth(56),
          };
          int col = 6;
          if (showUnitPrice) {
            columnWidths[col++] = pw.FixedColumnWidth(56);
          }
          columnWidths[col] = pw.FixedColumnWidth(72);

          final tableRows = <pw.TableRow>[
            pw.TableRow(
              decoration: pw.BoxDecoration(color: PdfColors.grey300),
              children: tableHeaders,
            ),
            ...quotation.items.map((item) {
              final row = [
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.code}', style: pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.description}', style: pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.width}', style: pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.height}', style: pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.quantity}', style: pw.TextStyle(fontSize: 9))),
                pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.area.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9))),
              ];
              if (showUnitPrice) {
                row.add(pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.unitPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9))));
              }
              row.add(pw.Padding(padding: pw.EdgeInsets.all(2), child: pw.Text('${item.netPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 9))));
              return pw.TableRow(children: row);
            }),
          ];

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              buildCompanyHeader(logoBytes),
              pw.SizedBox(height: 2),
              pw.Center(
                child: pw.Text(
                  'QUOTATION',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 2,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('CLIENT NAME: ${quotation.clientName}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                          pw.Text('Address: ${quotation.clientAddress}'),
                          pw.Text('Cell No: ${quotation.clientCell}'),
                          pw.Text('Email: ${quotation.clientEmail}'),
                          pw.Text('ATTN: ${quotation.attn}'),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('$companyName', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11)),
                          pw.Text('TPIN: $tpin', style: pw.TextStyle(fontSize: 10)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Container(
                      padding: pw.EdgeInsets.all(6),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(width: 1),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Expanded(child: pw.Text('Quote No:', style: pw.TextStyle(fontSize: 10))),
                              pw.Text('${quotation.quoteNumber}', style: pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Expanded(child: pw.Text('Date:', style: pw.TextStyle(fontSize: 10))),
                              pw.Text('${quotation.date.toLocal().toString().split(' ')[0]}', style: pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                          pw.Row(
                            children: [
                              pw.Expanded(child: pw.Text('Ref No:', style: pw.TextStyle(fontSize: 10))),
                              pw.Text('${quotation.refNo}', style: pw.TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                border: pw.TableBorder.all(),
                columnWidths: columnWidths,
                children: tableRows,
              ),
              pw.SizedBox(height: 6),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Terms and Conditions: ${quotation.terms}', style: pw.TextStyle(fontSize: 10)),
                        pw.Text('Quotation Validity: 7 Days', style: pw.TextStyle(fontSize: 10)),
                        if (quotation.description != null && quotation.description!.isNotEmpty)
                          pw.Text(quotation.description!, style: pw.TextStyle(fontSize: 10)),
                        // pw.Text('Supply and installation of Aluminium windows South Africa Standard profile', style: pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Container(
                    padding: pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(width: 1),
                      color: PdfColors.purple100,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Text('TOTAL AREA (sqm): ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                            pw.Text('${quotation.totalArea.toStringAsFixed(2)}', style: pw.TextStyle(fontSize: 10)),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Text('TOTAL PRICE (K): ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.purple800)),
                            pw.Text('${quotation.totalPrice.toStringAsFixed(2)}', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 13, color: PdfColors.purple800)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                padding: pw.EdgeInsets.all(6),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  color: PdfColors.grey200,
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('BANKING DETAILS:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
                    pw.Text('BANK NAME: $bankName', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('ACCOUNT NAME: $bankAccountName', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('ACCOUNT NO: $bankAccountNo', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('BRANCH: $bankBranch', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('BANK CODE: $bankCode', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('SORT CODE: $sortCode', style: pw.TextStyle(fontSize: 10)),
                    pw.Text('SWIFT CODE: $swiftCode', style: pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quotation PDF Preview'),
        actions: [
          IconButton(
            icon: Icon(showUnitPrice ? Icons.visibility : Icons.visibility_off),
            tooltip: showUnitPrice ? 'Hide Unit Price' : 'Show Unit Price',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuotationPdfPreview(
                    quotation: quotation,
                    showUnitPrice: !showUnitPrice,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: PdfPreview(
        build: _buildPdf,
        canChangePageFormat: false,
      ),
    );
  }
}