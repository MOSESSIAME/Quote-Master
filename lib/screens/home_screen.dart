import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'quotation.dart';
import 'quotation_form_screen.dart';
import 'quotation_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quotation> quotations = [];
  List<Quotation> filteredQuotations = [];
  final TextEditingController _searchController = TextEditingController();

  // keep the same listener so we can remove it later
  late final VoidCallback _onSearchChanged;

  @override
  void initState() {
    super.initState();
    _onSearchChanged = () => _filterQuotations(_searchController.text);
    _searchController.addListener(_onSearchChanged);
    _loadQuotations();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('quotations');
    if (data != null) {
      final decoded = jsonDecode(data) as List;
      setState(() {
        quotations = decoded.map((e) => Quotation.fromJson(e)).toList();
        filteredQuotations = List.from(quotations);
      });
    } else {
      setState(() {
        quotations = [];
        filteredQuotations = [];
      });
    }
  }

  Future<void> _saveQuotations() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(quotations.map((e) => e.toJson()).toList());
    await prefs.setString('quotations', data);
    _filterQuotations(_searchController.text); // keep filtered list in sync
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

  int _findOriginalIndex(Quotation q) {
    // Try identity (same object)
    final byIdentity = quotations.indexOf(q);
    if (byIdentity != -1) return byIdentity;

    // Fallback: try matching by combination of common fields (non-destructive)
    final idx = quotations.indexWhere((element) {
      final sameName =
          (element.clientName ?? '').toString() ==
          (q.clientName ?? '').toString();
      final sameNumber =
          (element.quoteNumber ?? '').toString() ==
          (q.quoteNumber ?? '').toString();
      final sameDate =
          (element.date ?? '').toString() == (q.date ?? '').toString();
      // match if at least quote number and name match, or all three match
      return (sameNumber && sameName) ||
          (sameName && sameDate) ||
          (sameNumber && sameDate);
    });
    return idx;
  }

  void _filterQuotations(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() {
        filteredQuotations = List.from(quotations);
      });
      return;
    }

    String formatDateCandidate(dynamic dateValue) {
      if (dateValue == null) return '';
      if (dateValue is DateTime) {
        return DateFormat('yyyy-MM-dd').format(dateValue) +
            '|' +
            DateFormat('dd/MM/yyyy').format(dateValue);
      }
      if (dateValue is String) {
        try {
          final parsed = DateTime.parse(dateValue);
          return DateFormat('yyyy-MM-dd').format(parsed) +
              '|' +
              DateFormat('dd/MM/yyyy').format(parsed) +
              '|' +
              dateValue;
        } catch (_) {
          return dateValue;
        }
      }
      return dateValue.toString();
    }

    setState(() {
      filteredQuotations = quotations.where((quotation) {
        final name = (quotation.clientName ?? '').toString().toLowerCase();
        final number = (quotation.quoteNumber ?? '').toString().toLowerCase();
        final dateString = formatDateCandidate(quotation.date).toLowerCase();

        final matchesName = name.contains(q);
        final matchesNumber = number.contains(q);
        final matchesDate = dateString.contains(q);

        return matchesName || matchesNumber || matchesDate;
      }).toList();
    });
  }

  // Modernized visual components below
  @override
  Widget build(BuildContext context) {
    final listToShow = filteredQuotations;
    final theme = Theme.of(context);

    return Scaffold(
      // Transparent background for appBar so gradient flows behind it
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Quotations'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        automaticallyImplyLeading: false,
        foregroundColor: Colors.black87,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF7C4DFF),
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
      body: Container(
        // Soft diagonal gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFf3e8ff), // very light purple
              Color(0xFFFFFFFF), // white
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              children: [
                // Search card
                Material(
                  elevation: 4,
                  shadowColor: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.search,
                            size: 22,
                            color: Color(0xFF6D4CFF),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  'Search by name, quote number or date (e.g. 2025-11-16 or 16/11/2025)',
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                            textInputAction: TextInputAction.search,
                            onSubmitted: (value) => _filterQuotations(value),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              _filterQuotations('');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 18,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // List or empty states in a soft card container
                Expanded(
                  child: quotations.isEmpty
                      ? Center(
                          child: Text(
                            "There are no quotations yet.\nClick + to create one.",
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : listToShow.isEmpty
                      ? Center(
                          child: Text(
                            'No results for "${_searchController.text}".',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: listToShow.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final q = listToShow[index];

                            // compute date display safely
                            String dateDisplay = '';
                            try {
                              if (q.date != null) {
                                if (q.date is DateTime) {
                                  dateDisplay = DateFormat(
                                    'yyyy-MM-dd',
                                  ).format(q.date);
                                } else {
                                  final parsed = DateTime.tryParse(
                                    q.date.toString(),
                                  );
                                  dateDisplay = parsed != null
                                      ? DateFormat('yyyy-MM-dd').format(parsed)
                                      : q.date.toString();
                                }
                              }
                            } catch (_) {
                              dateDisplay = q.date?.toString() ?? '';
                            }

                            return Material(
                              elevation: 2,
                              shadowColor: Colors.black12,
                              borderRadius: BorderRadius.circular(12),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final originalIndex = _findOriginalIndex(q);
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => QuotationDetailScreen(
                                        quotation: q,
                                        onDelete: () {
                                          if (originalIndex != -1)
                                            _deleteQuotation(originalIndex);
                                        },
                                        onEdit: (newQ) {
                                          if (originalIndex != -1)
                                            _editQuotation(originalIndex, newQ);
                                        },
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // avatar / icon
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF9A7BFF),
                                              Color(0xFF7C4DFF),
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.08,
                                              ),
                                              offset: const Offset(0, 3),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            (q.clientName ?? '').isNotEmpty
                                                ? (q.clientName![0]
                                                      .toUpperCase())
                                                : '?',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      // main text
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              q.clientName ?? '',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                Text(
                                                  'Quote#: ${q.quoteNumber ?? ''}',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors
                                                            .grey
                                                            .shade700,
                                                      ),
                                                ),
                                                if (dateDisplay.isNotEmpty) ...[
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    '•',
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade400,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    dateDisplay,
                                                    style: theme
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: Colors
                                                              .grey
                                                              .shade600,
                                                        ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // chevron
                                      const Icon(
                                        Icons.chevron_right,
                                        color: Colors.black38,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
