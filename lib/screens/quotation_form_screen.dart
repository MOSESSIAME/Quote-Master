import 'package:flutter/material.dart';
import '../screens/quotation.dart';
import '../screens/quotation_item.dart';
import 'item_form_dialog.dart';

/// A form screen for creating or editing a Quotation.
/// Handles client info, quote details, items, and terms.
class QuotationFormScreen extends StatefulWidget {
  /// If editing, pass the existing Quotation to pre-fill the form.
  final Quotation? existing;
  const QuotationFormScreen({Key? key, this.existing}) : super(key: key);

  @override
  State<QuotationFormScreen> createState() => _QuotationFormScreenState();
}

class _QuotationFormScreenState extends State<QuotationFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for client details and quotation fields.
  final _clientNameController = TextEditingController();
  final _clientAddressController = TextEditingController();
  final _clientCellController = TextEditingController();
  final _clientEmailController = TextEditingController();
  final _attnController = TextEditingController();
  final _quoteNumberController = TextEditingController();
  final _refNoController = TextEditingController();
  DateTime _quoteDate = DateTime.now();

  // Quotation items and terms.
  List<QuotationItem> _items = [];
  String _terms =
      'Terms of payment: 70% Deposit 30% upon completion.\nQuotation Validity 7 Days';

  // Calculated totals (area and price).
  double get _totalArea => _items.fold(0, (sum, item) => sum + item.area);
  double get _totalPrice => _items.fold(0, (sum, item) => sum + item.netPrice);

  @override
  void initState() {
    super.initState();
    // If editing, pre-fill all controllers and fields with existing data.
    if (widget.existing != null) {
      final q = widget.existing!;
      _clientNameController.text = q.clientName;
      _clientAddressController.text = q.clientAddress;
      _clientCellController.text = q.clientCell;
      _clientEmailController.text = q.clientEmail;
      _attnController.text = q.attn;
      _quoteNumberController.text = q.quoteNumber;
      _refNoController.text = q.refNo;
      _quoteDate = q.date;
      _items = List.from(q.items);
      _terms = q.terms;
    }
  }

  /// Add a new item to the quotation.
  void _addItem(QuotationItem item) {
    setState(() {
      _items.add(item);
    });
  }

  /// Remove an item from the quotation.
  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  /// Pick a date for the quotation using a date picker dialog.
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _quoteDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _quoteDate) {
      setState(() {
        _quoteDate = picked;
      });
    }
  }

  /// Validate and save the quotation. Pop the result to the previous screen.
  void _onSave() {
    if (_formKey.currentState!.validate() && _items.isNotEmpty) {
      final quotation = Quotation(
        clientName: _clientNameController.text,
        clientAddress: _clientAddressController.text,
        clientCell: _clientCellController.text,
        clientEmail: _clientEmailController.text,
        attn: _attnController.text,
        quoteNumber: _quoteNumberController.text,
        date: _quoteDate,
        refNo: _refNoController.text,
        items: List.from(_items),
        terms: _terms,
        totalArea: _totalArea,
        totalPrice: _totalPrice,
      );
      Navigator.pop(context, quotation);
    }
  }

  @override
  void dispose() {
    // Dispose all controllers to free up resources.
    _clientNameController.dispose();
    _clientAddressController.dispose();
    _clientCellController.dispose();
    _clientEmailController.dispose();
    _attnController.dispose();
    _quoteNumberController.dispose();
    _refNoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing != null ? "Edit Quotation" : "New Quotation"),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // --- Client Details Section ---
            const Text("Client Details", style: TextStyle(fontWeight: FontWeight.bold)),
            TextFormField(
              controller: _clientNameController,
              decoration: const InputDecoration(labelText: "Client Name"),
              validator: (val) => val == null || val.isEmpty ? "Enter client name" : null,
            ),
            TextFormField(
              controller: _clientAddressController,
              decoration: const InputDecoration(labelText: "Address"),
            ),
            TextFormField(
              controller: _clientCellController,
              decoration: const InputDecoration(labelText: "Cell No."),
            ),
            TextFormField(
              controller: _clientEmailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextFormField(
              controller: _attnController,
              decoration: const InputDecoration(labelText: "ATTN"),
            ),
            const SizedBox(height: 16),

            // --- Quotation Details Section ---
            const Text("Quotation Details", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                // Quote number
                Expanded(
                  child: TextFormField(
                    controller: _quoteNumberController,
                    decoration: const InputDecoration(labelText: "Quote No."),
                    validator: (val) => val == null || val.isEmpty ? "Enter quote number" : null,
                  ),
                ),
                const SizedBox(width: 16),
                // Date picker widget
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "Date"),
                      child: Text(
                        "${_quoteDate.year}-${_quoteDate.month.toString().padLeft(2, '0')}-${_quoteDate.day.toString().padLeft(2, '0')}",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            TextFormField(
              controller: _refNoController,
              decoration: const InputDecoration(labelText: "Ref No."),
            ),
            const SizedBox(height: 16),

            // --- Items Section ---
            const Text("Items", style: TextStyle(fontWeight: FontWeight.bold)),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              itemBuilder: (context, index) {
                final item = _items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    title: Text(item.description),
                    subtitle: Text(
                        "Code: ${item.code}, Qty: ${item.quantity}, Area: ${item.area.toStringAsFixed(2)}, Net: K${item.netPrice.toStringAsFixed(2)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _removeItem(index),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            // Button to add a new item
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Add Item"),
              onPressed: () async {
                final item = await showDialog<QuotationItem>(
                  context: context,
                  builder: (_) => const ItemFormDialog(),
                );
                if (item != null) {
                  _addItem(item);
                }
              },
            ),
            const SizedBox(height: 16),

            // --- Terms Field ---
            TextFormField(
              initialValue: _terms,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Terms"),
              onChanged: (val) => _terms = val,
            ),
            const SizedBox(height: 16),

            // --- Totals Section ---
            Text("Total Area: ${_totalArea.toStringAsFixed(2)} sqm", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("TOTAL PRICE (K): ${_totalPrice.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.purple)),
            const SizedBox(height: 24),

            // --- Save Button ---
            ElevatedButton(
              onPressed: _onSave,
              child: Text(widget.existing != null ? "Update Quotation" : "Save Quotation"),
            ),
          ],
        ),
      ),
    );
  }
}