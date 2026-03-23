import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_statement_of_purpose_screen.dart';

class StatementOfPurposeScreen extends StatefulWidget {
  const StatementOfPurposeScreen({Key? key}) : super(key: key);

  @override
  State<StatementOfPurposeScreen> createState() =>
      _StatementOfPurposeScreenState();
}

class _StatementOfPurposeScreenState extends State<StatementOfPurposeScreen> {
  String _paragraph1 =
      'This policy defines the standards and principles that govern all '
      'interactions between the Bulla Crave and its valued customers. It '
      'establishes a clear framework that guides all employees in delivering '
      'exceptional customer service. This set of company policies ensures '
      'consistency, professionalism, fairness, trust, and accountability in '
      'every engagement with our valued customers.';

  String _paragraph2 =
      'As a customer-centric organization, Bulla Crave Laundry Machine Trading '
      'is committed to building and maintaining strong, transparent, and lasting '
      'relationships with our clients by providing reliable laundry equipment, '
      'efficient after-sales support, and responsive technical services. We '
      'strive to deliver solutions that empower our customers\' businesses, '
      'ensuring satisfaction and long-term partnership through quality products '
      'and dedicated service.';

  String _paragraph3 =
      'Driven by our Corporate Values \u2014 F.O.R.C.E. (Focus, Obedience, '
      'Reality, Commitment, and Excellence), we uphold our commitment to '
      'transparency, reliability, and customer satisfaction. These principles '
      'serve as the foundation for building trust, resolving concerns '
      'effectively, and sustaining long-term relationships with our valued '
      'customers.';

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<Map<String, String>>(
      MaterialPageRoute(
        builder: (_) => EditStatementOfPurposeScreen(
          paragraph1: _paragraph1,
          paragraph2: _paragraph2,
          paragraph3: _paragraph3,
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _paragraph1 = result['paragraph1']!;
        _paragraph2 = result['paragraph2']!;
        _paragraph3 = result['paragraph3']!;
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
              // ── Title row with Edit button ────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Statement of Purpose',
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

              // ── Content paragraphs ────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _paragraph1,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _paragraph2,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      _paragraph3,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.7,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
