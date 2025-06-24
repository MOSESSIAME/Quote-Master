import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation.dart';
import 'quotation_form_screen.dart';
import 'quotation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quotation> quotations = [];

  @override
  void initState() {
    super.initState();
    _loadQuotations();
  }

  Future<void> _loadQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('quotations');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        quotations = decoded.map((e) => Quotation.fromJson(e)).toList();
      });
    }
  }

  Future<void> _saveQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(quotations.map((e) => e.toJson()).toList());
    await prefs.setString('quotations', data);
  }

  void _addQuotation(Quotation quotation) {
    setState(() {
      quotations.add(quotation);
    });
    _saveQuotations();
  }

  void _editQuotation(int index, Quotation quotation) {
    setState(() {
      quotations[index] = quotation;
    });
    _saveQuotations();
  }

  void _deleteQuotation(int index) {
    setState(() {
      quotations.removeAt(index);
    });
    _saveQuotations();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quotations')),
      body: quotations.isEmpty
          ? Center(
              child: Text(
                "There are no quotations yet.\nClick + to create one.",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: quotations.length,
              itemBuilder: (context, index) {
                final q = quotations[index];
                return ListTile(
                  title: Text(q.clientName),
                  subtitle: Text('Quote#: ${q.quoteNumber}'),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => QuotationDetailScreen(
                          quotation: q,
                          onDelete: () {
                            _deleteQuotation(index);
                          },
                          onEdit: (newQ) {
                            _editQuotation(index, newQ);
                          },
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final newQ = await Navigator.push<Quotation>(
            context,
            MaterialPageRoute(builder: (_) => QuotationFormScreen()),
          );
          if (newQ != null) {
            _addQuotation(newQ);
          }
        },
      ),
    );
  }
}