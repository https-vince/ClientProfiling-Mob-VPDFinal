import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_spare_parts_screen.dart';

class SparePartsScreen extends StatefulWidget {
  const SparePartsScreen({Key? key}) : super(key: key);

  @override
  State<SparePartsScreen> createState() => _SparePartsScreenState();
}

class _SparePartsScreenState extends State<SparePartsScreen> {
  String _effectiveDate = 'June 7, 2025';
  final ScrollController _hScrollController = ScrollController();

  @override
  void dispose() {
    _hScrollController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _items = [
    {
      'partName': 'Bearing, Ball',
      'description1': '4280FR4048N (FH069FD) (Inner) Bearing, Ball',
      'description2': 'K121 (FH069FD) (Inner) Bearing, Ball',
      'srp': '₱1,209.66',
      'commonTerm': '',
      'compatibleModel': 'All Giant',
    },
    {
      'partName': 'Bearing, Ball',
      'description1': '4280FR4048Z (FH0C7FD) (Inner) Bearing, Ball',
      'description2': 'K121 (FH0C7FD) (Inner) Bearing, Ball',
      'srp': '₱1,486.11',
      'commonTerm': '',
      'compatibleModel': 'All Titan',
    },
    {
      'partName': 'Bearing, Ball',
      'description1': 'MAP61913707 (FH069FD) (Outer) Bearing, Ball',
      'description2': 'K122 (FH069FD) (Outer) Bearing, Ball',
      'srp': '₱839.58',
      'commonTerm': '',
      'compatibleModel': 'All Giant',
    },
    {
      'partName': 'Bearing, Ball',
      'description1': '4280FR4048N (FH069FD) (Outer) Bearing, Ball',
      'description2': 'K122 (FH069FD) (Outer) Bearing, Ball',
      'srp': '₱1,209.66',
      'commonTerm': '',
      'compatibleModel': 'All Titan',
    },
    {
      'partName': 'Bellows',
      'description1': 'MAR62181901 (FH0C7FD) Bellows/Drain',
      'description2': 'K520 (FH0C7FD) Bellows',
      'srp': '₱1,109.01',
      'commonTerm': '',
      'compatibleModel': '',
    },
    {
      'partName': 'Bellows',
      'description1': '4738ER1004B (FH0C7FD)',
      'description2': 'F310 (FH0C7FD) Bellows',
      'srp': '₱739.68',
      'commonTerm': '',
      'compatibleModel': '',
    },
  ];

  Future<void> _openEditScreen() async {
    final result =
        await Navigator.of(context).push<Map<String, dynamic>>(
      MaterialPageRoute(
        builder: (_) => EditSparePartsScreen(
          effectiveDate: _effectiveDate,
          items: _items,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _effectiveDate = result['effectiveDate'] as String;
        _items = List<Map<String, String>>.from(
          (result['items'] as List).map((e) => Map<String, String>.from(e)),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(title: 'CSR Guide', showMenuButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title row ────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        'Spare Parts (Effective $_effectiveDate)',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _openEditScreen,
                      icon: const Icon(Icons.edit, size: 15),
                      label: const Text('Edit Content'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1, color: Color(0xFFE5E7EB)),

              // ── Table ─────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 8, 16),
                child: _items.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text(
                            'No items yet. Tap Edit Content to add entries.',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 14),
                          ),
                        ),
                      )
                    : Scrollbar(
                        controller: _hScrollController,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: _hScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: _buildTable(),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTable() {
    const headerStyle = TextStyle(
        fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black87);
    const cellStyle =
        TextStyle(fontSize: 11, color: Colors.black87, height: 1.4);
    const boldCellStyle = TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
        height: 1.4);

    final headers = [
      'No.',
      'Part Name',
      'Part Description',
      '',
      'SRP',
      'Common Term',
      'Compatible Model'
    ];

    return Table(
      border: TableBorder.all(color: const Color(0xFFD1D5DB)),
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: const {
        0: FixedColumnWidth(36),
        1: FixedColumnWidth(110),
        2: FixedColumnWidth(160),
        3: FixedColumnWidth(160),
        4: FixedColumnWidth(80),
        5: FixedColumnWidth(90),
        6: FixedColumnWidth(110),
      },
      children: [
        // Header row
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF9FAFB)),
          children: headers.map((h) => _cell(h, headerStyle)).toList(),
        ),
        // Data rows
        for (int i = 0; i < _items.length; i++)
          TableRow(
            decoration: BoxDecoration(
              color: i.isEven ? Colors.white : const Color(0xFFFAFAFA),
            ),
            children: [
              _cell('${i + 1}', cellStyle, align: TextAlign.center),
              _cell(_items[i]['partName'] ?? '', boldCellStyle),
              _cell(_items[i]['description1'] ?? '', cellStyle),
              _cell(_items[i]['description2'] ?? '', cellStyle),
              _cell(_items[i]['srp'] ?? '', cellStyle),
              _cell(_items[i]['commonTerm'] ?? '', cellStyle),
              _cell(_items[i]['compatibleModel'] ?? '', cellStyle),
            ],
          ),
      ],
    );
  }

  Widget _cell(String text, TextStyle style,
      {TextAlign align = TextAlign.left}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(text, style: style, textAlign: align),
    );
  }
}
