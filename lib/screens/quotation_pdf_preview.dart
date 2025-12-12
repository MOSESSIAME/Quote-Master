import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import '../pdf/pdf_company_header.dart';
import '../screens/quotation.dart';

class QuotationPdfPreview extends StatefulWidget {
  final Quotation quotation;
  final bool showUnitPrice;

  const QuotationPdfPreview({
    super.key,
    required this.quotation,
    this.showUnitPrice = true,
  });

  @override
  State<QuotationPdfPreview> createState() => _QuotationPdfPreviewState();
}

class _QuotationPdfPreviewState extends State<QuotationPdfPreview> {
  late TextEditingController _filenameController;

  @override
  void initState() {
    super.initState();
    String defaultName = widget.quotation.clientName.trim().isNotEmpty
        ? '${widget.quotation.clientName.replaceAll(RegExp(r"[^\w]+"), "_")}_quotation.pdf'
        : 'Quote_${widget.quotation.quoteNumber}.pdf';
    _filenameController = TextEditingController(text: defaultName);
  }

  @override
  void dispose() {
    _filenameController.dispose();
    super.dispose();
  }

  Future<Uint8List> _buildPdf(PdfPageFormat format) async {
    final doc = pw.Document();

    final logo = await rootBundle.load('assets/images/header.png');
    final logoBytes = logo.buffer.asUint8List();

    const companyName = 'WILHOETE LTD';
    const tpin = '1018233036';

    // Build table header widgets
    final tableHeaders = [
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'CODE',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'DESCRIPTION',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'WIDTH',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'HEIGHT',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'QTY',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'AREA (SQM)',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
    ];

    if (widget.showUnitPrice) {
      tableHeaders.add(
        pw.Padding(
          padding: pw.EdgeInsets.all(2),
          child: pw.Text(
            'UNIT PRICE',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
        ),
      );
    }

    tableHeaders.add(
      pw.Padding(
        padding: pw.EdgeInsets.all(2),
        child: pw.Text(
          'NET PRICE',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9),
        ),
      ),
    );

    final columnWidths = <int, pw.TableColumnWidth>{
      0: pw.FixedColumnWidth(40),
      1: pw.FlexColumnWidth(3),
      2: pw.FixedColumnWidth(48),
      3: pw.FixedColumnWidth(48),
      4: pw.FixedColumnWidth(32),
      5: pw.FixedColumnWidth(56),
    };
    int col = 6;
    if (widget.showUnitPrice) {
      columnWidths[col++] = pw.FixedColumnWidth(56);
    }
    columnWidths[col] = pw.FixedColumnWidth(72);

    // Build rows from items
    final tableRows = <pw.TableRow>[
      pw.TableRow(
        decoration: pw.BoxDecoration(color: PdfColors.grey300),
        children: tableHeaders,
      ),
      ...widget.quotation.items.map((item) {
        final row = <pw.Widget>[
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(item.code, style: pw.TextStyle(fontSize: 9)),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(item.description, style: pw.TextStyle(fontSize: 9)),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text('${item.width}', style: pw.TextStyle(fontSize: 9)),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text('${item.height}', style: pw.TextStyle(fontSize: 9)),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
              '${item.quantity}',
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
              item.area.toStringAsFixed(2),
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        ];
        if (widget.showUnitPrice) {
          row.add(
            pw.Padding(
              padding: pw.EdgeInsets.all(2),
              child: pw.Text(
                item.unitPrice.toStringAsFixed(2),
                style: pw.TextStyle(fontSize: 9),
              ),
            ),
          );
        }
        row.add(
          pw.Padding(
            padding: pw.EdgeInsets.all(2),
            child: pw.Text(
              item.netPrice.toStringAsFixed(2),
              style: pw.TextStyle(fontSize: 9),
            ),
          ),
        );
        return pw.TableRow(children: row);
      }),
    ];

    final solidTableBorder = pw.TableBorder.all(
      width: 0.6,
      color: PdfColors.grey600,
    );
    final boxBorder = pw.Border.all(width: 0.6, color: PdfColors.grey600);

    // totals widget (will appear after the table, and be paginated naturally)
    final totalsWidget = pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Expanded(flex: 3, child: pw.Container()),
        pw.SizedBox(width: 12),
        pw.Container(
          padding: pw.EdgeInsets.all(6),
          decoration: pw.BoxDecoration(
            border: boxBorder,
            color: PdfColors.purple100,
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text(
                    'TOTAL AREA (sqm): ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.Text(
                    widget.quotation.totalArea.toStringAsFixed(2),
                    style: pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.Text(
                    'TOTAL PRICE (K): ',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                      color: PdfColors.purple800,
                    ),
                  ),
                  pw.Text(
                    widget.quotation.totalPrice.toStringAsFixed(2),
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 13,
                      color: PdfColors.purple800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );

    // Now create one MultiPage that contains header -> table -> totals -> terms.
    doc.addPage(
      pw.MultiPage(
        pageFormat: format,
        margin: pw.EdgeInsets.all(16),
        build: (pw.Context context) {
          // helper for terms paragraphs
          pw.Widget para(String text, pw.TextStyle style) => pw.Padding(
            padding: pw.EdgeInsets.only(bottom: 6),
            child: pw.Text(text, style: style, textAlign: pw.TextAlign.left),
          );

          final bodyStyle = pw.TextStyle(fontSize: 9.8, height: 1.14);
          final headingStyle = pw.TextStyle(
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
          );

          return <pw.Widget>[
            // header + meta
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
                    decoration: pw.BoxDecoration(border: boxBorder),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'CLIENT NAME: ${widget.quotation.clientName}',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('Address: ${widget.quotation.clientAddress}'),
                        pw.Text('Cell No: ${widget.quotation.clientCell}'),
                        pw.Text('Email: ${widget.quotation.clientEmail}'),
                        pw.Text('ATTN: ${widget.quotation.attn}'),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(border: boxBorder),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          companyName,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        pw.Text(
                          'TPIN: $tpin',
                          style: pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 6),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: pw.EdgeInsets.all(6),
                    decoration: pw.BoxDecoration(border: boxBorder),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Quote No:',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              widget.quotation.quoteNumber,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Date:',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              widget.quotation.date.toLocal().toString().split(
                                ' ',
                              )[0],
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        pw.Row(
                          children: [
                            pw.Expanded(
                              child: pw.Text(
                                'Ref No:',
                                style: pw.TextStyle(fontSize: 10),
                              ),
                            ),
                            pw.Text(
                              widget.quotation.refNo,
                              style: pw.TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 10),

            // table (this will be paginated by MultiPage if it overflows)
            pw.Table(
              border: solidTableBorder,
              columnWidths: columnWidths,
              children: tableRows,
            ),
            pw.SizedBox(height: 6),

            // totals (placed after the table; will appear on next page automatically if table runs out of room)
            pw.SizedBox(height: 8),
            totalsWidget,
            pw.SizedBox(height: 10),

            // thin separator
            pw.Container(
              padding: pw.EdgeInsets.all(6),
              decoration: pw.BoxDecoration(
                border: boxBorder,
                color: PdfColors.grey200,
              ),
            ),

            // Terms & Conditions header + body. These will follow and be paginated normally.
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'Terms & Conditions',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              'Payment Terms:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'A 70% deposit, based on the full value of the Project, is required on placement of order. '
              'The 30% balance of the project value is payable upon installation. Where installation of the product '
              'is unable to take place because of delays on-site caused by any party other than Wilhoete Glass and Aluminium '
              'by more than 30 days from the date of advice to the Client of completion of manufacture of the product, any balance '
              'outstanding will become immediately payable, irrespective of such delays.',
              bodyStyle,
            ),

            pw.SizedBox(height: 8),
            pw.Text(
              'Delivery Terms:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'The manufacturing and commencement of Installation of ordered products will take_____Working Days (the "lead time" ) '
              'where Standard Stock Colours and standard glass are used (Bronze, black, White or Natural). '
              'Where Wilhoete glass and Aluminium measures existing spaces and manufactures to the size, Wilhoete glass Aluminium '
              'will not be responsible for the cost associated with re sizing and re-installation of the product. '
              'The quotation is based on the standard designs of windows and or doors.',
              bodyStyle,
            ),

            pw.Text(
              'Installation:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'Installation period will be dependent on the size of the Job, number of Components requiring installation, '
              'and the state of readiness of the actual Apertures. Phasing of any project will be subject to additional costs and payment terms. '
              'Practical completion is when a project is \'practically complete\', in the sense of the works being capable of being used '
              'or having been installed, as distinct from when they are finished (with all defects rectified).',
              bodyStyle,
            ),

            pw.Text(
              'Defects & Punch / Snag List post Practical Completion of Installation:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'The Client shall within 7 Days after Final Servicing of all Products, furnish Willhoete glass and Aluminium with a final written '
              'snag / punch list of defects occasioned by defective workmanship and/or faulty materials. Wilhoete Aluminium shall remedy the defects '
              'identified in the snag / punch list, (unless such defects are not occasioned by defective workmanship and/or faulty materials) within '
              '14 Working Days after the delivery of the snag / punch list to Wilhoete Aluminium, and thereafter consider the project and installation to be finalised complete.',
              bodyStyle,
            ),

            pw.Text(
              'Exclusions:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'This quotation excludes all or any Building, Plastering and/or Masonry work. The removal of protective tapes and plastic wrapping is done by the Contractor / Builder on completion of Plastering and Painting. Sealing of Windows and Doors, including cladding and cover strips, will be quoted for and itemized separately where required, and if not itemized, is excluded from this quotation. Wilhoete Aluminium will supply access ladders and equipment up to a maximum height of 2.5 meters. All and any scaffolding and lifting equipment (Hoists, Cherry Picker) is the responsibility of the client and, unless specifically detailed in this quotation, is excluded. Client to provide power onsite.',
              bodyStyle,
            ),

            pw.Text(
              'Transfer of installed product ownership:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'The Client hereby acknowledges that all products manufactured & installed by Wilhoete glass and Aluminium remains the property of Wilhoete glass and Aluminium until such time as the account is paid in full. The Client hereby authorizes Wilhoete glass and Aluminium to enter the property and remove any or all of its products installed should full payment not be received within the payment terms detailed above or agreed by the parties (client and Wilhoete glass and Aluminium). Should the Client be a contractor or builder who is not also the owner of the property at which the product is being installed, then, at the sole discretion of Wilhoete glass and Aluminium, the Client undertakes to obtain the owners written consent and signature to the attached Annexure A confirming the owners acceptance of the terms and conditions referred to in these terms.',
              bodyStyle,
            ),

            pw.Text(
              'Acceptance of the Quotation:',
              style: headingStyle,
              textAlign: pw.TextAlign.left,
            ),
            pw.SizedBox(height: 6),
            para(
              'The Client confirms that they have read all above conditions and have accepted such. This quote is Valid for a period of 14 Days from date of Quotation. The Signee confirms that they have checked the sizes, configuration and directions, glass and colour used on all components.',
              bodyStyle,
            ),

            pw.SizedBox(height: 20),
            pw.Text(
              'Signed at________________on the________day of_________202_____',
              style: bodyStyle,
              textAlign: pw.TextAlign.left,
            ),
          ];
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
            icon: Icon(
              widget.showUnitPrice ? Icons.visibility : Icons.visibility_off,
            ),
            tooltip: widget.showUnitPrice
                ? 'Hide Unit Price'
                : 'Show Unit Price',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => QuotationPdfPreview(
                    quotation: widget.quotation,
                    showUnitPrice: !widget.showUnitPrice,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _filenameController,
              decoration: InputDecoration(
                labelText: 'PDF Filename',
                suffixIcon: Icon(Icons.edit),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: PdfPreview(
              build: _buildPdf,
              canChangePageFormat: false,
              pdfFileName: _filenameController.text,
            ),
          ),
        ],
      ),
    );
  }
}
