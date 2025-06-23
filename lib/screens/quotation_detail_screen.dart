import 'package:flutter/material.dart';
import '../screens/quotation.dart';
import 'quotation_form_screen.dart';
import 'item_form_dialog.dart';
import 'quotation_pdf_preview.dart';

class QuotationDetailScreen extends StatefulWidget {
  final Quotation quotation;
  final VoidCallback onDelete;
  final ValueChanged<Quotation> onEdit;

  const QuotationDetailScreen({
    Key? key,
    required this.quotation,
    required this.onDelete,
    required this.onEdit,
  }) : super(key: key);

  @override
  State<QuotationDetailScreen> createState() => _QuotationDetailScreenState();
}

class _QuotationDetailScreenState extends State<QuotationDetailScreen> {
  late Quotation quotation;

  @override
  void initState() {
    super.initState();
    quotation = widget.quotation;
  }

  Future<void> _editQuotation(BuildContext context) async {
    final updated = await Navigator.push<Quotation>(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationFormScreen(existing: quotation),
      ),
    );
    if (updated != null) {
      setState(() {
        quotation = updated;
      });
      widget.onEdit(updated);
      Navigator.pop(context);
    }
  }

  Future<void> _editItem(BuildContext context, int index) async {
    final updatedItem = await showDialog(
      context: context,
      builder: (context) => ItemFormDialog(
        quotationItem: quotation.items[index],
      ),
    );
    if (updatedItem != null) {
      final updatedItems = List.of(quotation.items);
      updatedItems[index] = updatedItem;
      final updatedQuotation = Quotation(
        clientName: quotation.clientName,
        clientAddress: quotation.clientAddress,
        clientCell: quotation.clientCell,
        clientEmail: quotation.clientEmail,
        attn: quotation.attn,
        quoteNumber: quotation.quoteNumber,
        date: quotation.date,
        refNo: quotation.refNo,
        items: updatedItems,
        terms: quotation.terms,
        totalArea: updatedItems.fold(0.0, (sum, item) => sum + item.area),
        totalPrice: updatedItems.fold(0.0, (sum, item) => sum + item.netPrice),
        description: quotation.description,
      );
      setState(() {
        quotation = updatedQuotation;
      });
      widget.onEdit(updatedQuotation);
    }
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quotation?'),
        content: const Text('Are you sure you want to delete this quotation? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      widget.onDelete();
      Navigator.pop(context);
    }
  }

  void _previewPdf(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuotationPdfPreview(quotation: quotation), // Default: showUnitPrice is true
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quotation ${quotation.quoteNumber}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Preview PDF",
            onPressed: () => _previewPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: "Edit",
            onPressed: () => _editQuotation(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: "Delete",
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Client: ${quotation.clientName}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Address: ${quotation.clientAddress}"),
            Text("Cell: ${quotation.clientCell}"),
            Text("Email: ${quotation.clientEmail}"),
            Text("ATTN: ${quotation.attn}"),
            const SizedBox(height: 16),
            Text("Quote No: ${quotation.quoteNumber}"),
            Text("Date: ${quotation.date.toLocal().toString().split(' ')[0]}"),
            Text("Ref No: ${quotation.refNo}"),
            const SizedBox(height: 16),
            const Text("Items:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...List.generate(quotation.items.length, (index) {
              final item = quotation.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(item.description),
                  subtitle: Text(
                    "Code: ${item.code}\nWidth: ${item.width}\nHeight: ${item.height}\nQty: ${item.quantity}\nArea: ${item.area.toStringAsFixed(2)} sqm\nUnit Price: K${item.unitPrice.toStringAsFixed(2)}\nNet: K${item.netPrice.toStringAsFixed(2)}"
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    tooltip: "Edit item",
                    onPressed: () => _editItem(context, index),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            Text("Total Area: ${quotation.totalArea.toStringAsFixed(2)} sqm", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("TOTAL PRICE (K): ${quotation.totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple)),
            const SizedBox(height: 16),
            const Text("Terms", style: TextStyle(fontWeight: FontWeight.bold)),
            Text(quotation.terms),
          ],
        ),
      ),
    );
  }
}