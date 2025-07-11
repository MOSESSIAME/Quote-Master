import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quotation.dart';
import 'quotation_form_screen.dart';
import 'quotation_detail_screen.dart';

/// The HomeScreen widget displays a list of quotations and allows
/// the user to add, edit, or delete quotations.
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List to hold all quotation objects
  List<Quotation> quotations = [];

  @override
  void initState() {
    super.initState();
    _loadQuotations(); // Load saved quotations when the screen initializes
  }

  /// Loads quotations from local storage using SharedPreferences.
  Future<void> _loadQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('quotations');
    if (data != null) {
      // Decode the JSON string into a list of quotations
      final decoded = jsonDecode(data) as List;
      setState(() {
        quotations = decoded.map((e) => Quotation.fromJson(e)).toList();
      });
    }
  }

  /// Saves the current quotations list to local storage.
  Future<void> _saveQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert the quotations list to a JSON string and save it
    final data = jsonEncode(quotations.map((e) => e.toJson()).toList());
    await prefs.setString('quotations', data);
  }

  /// Adds a new quotation to the list and saves it.
  void _addQuotation(Quotation quotation) {
    setState(() {
      quotations.add(quotation);
    });
    _saveQuotations();
  }

  /// Edits an existing quotation at the given index and saves.
  void _editQuotation(int index, Quotation quotation) {
    setState(() {
      quotations[index] = quotation;
    });
    _saveQuotations();
  }

  /// Deletes the quotation at the given index and saves.
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
          // Show a message when there are no quotations
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
          // Show the list of quotations
          : ListView.builder(
              itemCount: quotations.length,
              itemBuilder: (context, index) {
                final q = quotations[index];
                return ListTile(
                  title: Text(q.clientName),
                  subtitle: Text('Quote#: ${q.quoteNumber}'),
                  // Open the quotation detail screen on tap
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
      // Floating button to add a new quotation
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          // Open the form to create a new quotation and add if result is not null
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