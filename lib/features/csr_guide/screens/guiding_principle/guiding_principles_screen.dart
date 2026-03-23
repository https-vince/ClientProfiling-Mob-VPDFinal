import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_guiding_principles_screen.dart';

class GuidingPrinciplesScreen extends StatefulWidget {
  const GuidingPrinciplesScreen({Key? key}) : super(key: key);

  @override
  State<GuidingPrinciplesScreen> createState() =>
      _GuidingPrinciplesScreenState();
}

class _GuidingPrinciplesScreenState extends State<GuidingPrinciplesScreen> {
  List<Map<String, String>> _principles = [
    {
      'title': 'Customer-Centric Approach',
      'body':
          'Customers are the foundation of our business. Every action, decision, '
              'and communication must aim to provide a positive, respectful, and '
              'solution-oriented experience.',
    },
    {
      'title': 'Transparency',
      'body':
          'All service terms, fees, and procedures shall be communicated clearly '
              'and honestly to prevent misunderstandings and promote trust.',
    },
    {
      'title': 'Accountability',
      'body':
          'Each representative is responsible for the accuracy, reliability, and '
              'integrity of all information and services provided to customers.',
    },
    {
      'title': 'Consistency',
      'body':
          'Every customer shall receive the same standard of courtesy, quality, '
              'and attention, regardless of transaction size, status, or profile.',
    },
  ];

  Future<void> _openEditScreen() async {
    final result =
        await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) =>
            EditGuidingPrinciplesScreen(principles: _principles),
      ),
    );
    if (result != null && mounted) {
      setState(() => _principles = result);
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
              // ── Title row with Edit button ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Guiding Principles',
                        style: TextStyle(
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

              // ── Principles list ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _principles.map((p) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p['body']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
