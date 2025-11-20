import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'quotation.dart';
import 'quotation_form_screen.dart';
import 'quotation_detail_screen.dart';

/// HomeScreen with dotted background and search
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Quotation> quotations = [];
  List<Quotation> filteredQuotations = [];
  final TextEditingController _searchController = TextEditingController();
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
    // Re-apply current search after saving so UI stays in sync
    _filterQuotations(_searchController.text);
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

  /// Helper to find the original index of a quotation when we’re working
  /// with the filtered list.
  int _findOriginalIndex(Quotation q) {
    final byIdentity = quotations.indexOf(q);
    if (byIdentity != -1) return byIdentity;

    final idx = quotations.indexWhere((element) {
      final sameName =
          (element.clientName).toString() == (q.clientName).toString();
      final sameNumber =
          (element.quoteNumber).toString() == (q.quoteNumber).toString();
      final sameDate = (element.date).toString() == (q.date).toString();
      return (sameNumber && sameName) ||
          (sameName && sameDate) ||
          (sameNumber && sameDate);
    });
    return idx;
  }

  /// Main search logic.
  /// - Name: partial match
  /// - Quote number: partial match (string)
  /// - Date: accepts `yyyy-MM-dd` or `dd/MM/yyyy`
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

      // Already a DateTime
      if (dateValue is DateTime) {
        return [
          DateFormat('yyyy-MM-dd').format(dateValue),
          DateFormat('dd/MM/yyyy').format(dateValue),
        ].join('|');
      }

      // Stored as String
      if (dateValue is String) {
        // Try parse ISO first
        try {
          final parsed = DateTime.parse(dateValue);
          return [
            DateFormat('yyyy-MM-dd').format(parsed),
            DateFormat('dd/MM/yyyy').format(parsed),
            dateValue,
          ].join('|');
        } catch (_) {
          // Not ISO. Return as-is so user can still search the raw string.
          return dateValue;
        }
      }

      return dateValue.toString();
    }

    setState(() {
      filteredQuotations = quotations.where((quotation) {
        final name = (quotation.clientName ?? '').toString().toLowerCase();
        final number = (quotation.quoteNumber ?? '').toString().toLowerCase();
        final dateString = formatDateCandidate(
          quotation.date,
        ).toLowerCase(); // includes both formats

        final matchesName = name.contains(q);
        final matchesNumber = number.contains(q);
        final matchesDate = dateString.contains(q);

        return matchesName || matchesNumber || matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final listToShow = filteredQuotations;
    final theme = Theme.of(context);

    return Scaffold(
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
      body: Stack(
        children: [
          // Dotted background
          const Positioned.fill(
            child: CustomPaint(painter: _DottedBackgroundPainter()),
          ),

          // Gradient wash over background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: const Alignment(-0.9, -1),
                  end: const Alignment(1, 1),
                  colors: [
                    Color.fromRGBO(246, 241, 255, 0.72),
                    Color.fromRGBO(255, 255, 255, 0.95),
                  ],
                  stops: const [0, 1],
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  // Search bar
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
                          // SEARCH BUTTON (tap this to search what you typed)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: IconButton(
                              icon: const Icon(
                                Icons.search,
                                size: 22,
                                color: Color(0xFF6D4CFF),
                              ),
                              onPressed: () =>
                                  _filterQuotations(_searchController.text),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              tooltip: 'Search',
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
                              onSubmitted: _filterQuotations,
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

                  // List / empty states
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

                              // Format date safely
                              String dateDisplay = '';
                              try {
                                if (q.date != null) {
                                  if (q.date is DateTime) {
                                    dateDisplay = DateFormat(
                                      'yyyy-MM-dd',
                                    ).format(q.date as DateTime);
                                  } else {
                                    final parsed = DateTime.tryParse(
                                      q.date.toString(),
                                    );
                                    dateDisplay = parsed != null
                                        ? DateFormat(
                                            'yyyy-MM-dd',
                                          ).format(parsed)
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
                                            if (originalIndex != -1) {
                                              _deleteQuotation(originalIndex);
                                            }
                                          },
                                          onEdit: (newQ) {
                                            if (originalIndex != -1) {
                                              _editQuotation(
                                                originalIndex,
                                                newQ,
                                              );
                                            }
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
                                        // avatar / initial
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
                                        // text
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                q.clientName ?? '',
                                                style: theme
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
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
                                                  if (dateDisplay
                                                      .isNotEmpty) ...[
                                                    const SizedBox(width: 10),
                                                    Text(
                                                      '•',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .grey
                                                            .shade400,
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
        ],
      ),
    );
  }
}

/// Dotted background painter used for soft pattern.
class _DottedBackgroundPainter extends CustomPainter {
  const _DottedBackgroundPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF9E8CFF).withOpacity(0.10);

    final shortest = size.shortestSide;
    final spacing = (shortest / 18).clamp(14.0, 32.0);
    final dotSize = (shortest / 380).clamp(1.4, 4.0);

    for (double y = 0; y < size.height + spacing; y += spacing) {
      final rowOffset = ((y / spacing) % 2 == 0) ? 0.0 : spacing / 2;
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        final dx = x + rowOffset;
        canvas.drawCircle(Offset(dx, y), dotSize, paint);
      }
    }

    final cornerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF7C4DFF).withOpacity(0.035);

    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.08),
      shortest * 0.09,
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.92, size.height * 0.92),
      shortest * 0.07,
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
