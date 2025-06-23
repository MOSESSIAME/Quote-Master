import 'package:flutter/material.dart';
import '../screens/quotation_item.dart';

class ItemFormDialog extends StatefulWidget {
  final QuotationItem? quotationItem;
  const ItemFormDialog({Key? key, this.quotationItem}) : super(key: key);

  @override
  State<ItemFormDialog> createState() => _ItemFormDialogState();
}

class _ItemFormDialogState extends State<ItemFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _widthController;
  late final TextEditingController _heightController;
  late final TextEditingController _qtyController;
  late final TextEditingController _unitPriceController;

  double _area = 0.0;
  double _netPrice = 0.0;

  void _updateAreaAndNet() {
    final width = double.tryParse(_widthController.text) ?? 0.0;
    final height = double.tryParse(_heightController.text) ?? 0.0;
    final qty = int.tryParse(_qtyController.text) ?? 0;
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
    setState(() {
      _area = width * height * qty;
      _netPrice = _area * unitPrice;
    });
  }

  @override
  void initState() {
    super.initState();
    _codeController = TextEditingController(text: widget.quotationItem?.code ?? '');
    _descriptionController = TextEditingController(text: widget.quotationItem?.description ?? '');
    _widthController = TextEditingController(
        text: widget.quotationItem != null ? widget.quotationItem!.width.toString() : '');
    _heightController = TextEditingController(
        text: widget.quotationItem != null ? widget.quotationItem!.height.toString() : '');
    _qtyController = TextEditingController(
        text: widget.quotationItem != null ? widget.quotationItem!.quantity.toString() : '');
    _unitPriceController = TextEditingController(
        text: widget.quotationItem != null ? widget.quotationItem!.unitPrice.toString() : '');

    if (widget.quotationItem != null) {
      final width = widget.quotationItem!.width;
      final height = widget.quotationItem!.height;
      final qty = widget.quotationItem!.quantity;
      final unitPrice = widget.quotationItem!.unitPrice;
      _area = width * height * qty;
      _netPrice = _area * unitPrice;
    }

    _widthController.addListener(_updateAreaAndNet);
    _heightController.addListener(_updateAreaAndNet);
    _qtyController.addListener(_updateAreaAndNet);
    _unitPriceController.addListener(_updateAreaAndNet);
  }

  @override
  void dispose() {
    _codeController.dispose();
    _descriptionController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _qtyController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState!.validate()) {
      final width = double.tryParse(_widthController.text) ?? 0.0;
      final height = double.tryParse(_heightController.text) ?? 0.0;
      final qty = int.tryParse(_qtyController.text) ?? 0;
      final area = width * height * qty;
      final unitPrice = double.tryParse(_unitPriceController.text) ?? 0.0;
      final netPrice = area * unitPrice;
      final item = QuotationItem(
        code: _codeController.text,
        description: _descriptionController.text,
        width: width,
        height: height,
        quantity: qty,
        area: area,
        unitPrice: unitPrice,
        netPrice: netPrice,
      );
      Navigator.pop(context, item);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.quotationItem != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Item' : 'Add Item'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeController,
                decoration: const InputDecoration(labelText: 'Code'),
                validator: (val) => val == null || val.isEmpty ? 'Enter code' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (val) => val == null || val.isEmpty ? 'Enter description' : null,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _widthController,
                      decoration: const InputDecoration(labelText: 'Width'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => (double.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter width',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _heightController,
                      decoration: const InputDecoration(labelText: 'Height'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (val) => (double.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter height',
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _qtyController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
                validator: (val) => (int.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter quantity',
              ),
              TextFormField(
                controller: _unitPriceController,
                decoration: const InputDecoration(labelText: 'Unit Price (K)'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (val) => (double.tryParse(val ?? '') ?? 0) > 0 ? null : 'Enter unit price',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Area (sqm): ${_area.toStringAsFixed(2)}'),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Net Price (K): ${_netPrice.toStringAsFixed(2)}'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSave,
          child: Text(isEditing ? 'Update' : 'Add'),
        ),
      ],
    );
  }
}