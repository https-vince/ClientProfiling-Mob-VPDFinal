import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_policy_awareness_screen.dart';

class PolicyAwarenessScreen extends StatefulWidget {
  const PolicyAwarenessScreen({Key? key}) : super(key: key);

  @override
  State<PolicyAwarenessScreen> createState() => _PolicyAwarenessScreenState();
}

class _PolicyAwarenessScreenState extends State<PolicyAwarenessScreen> {
  List<Map<String, dynamic>> _entries = [
    {
      'title': 'Policy Awareness',
      'paragraphs': [
        'All employees, particularly those in customer-facing roles, shall be '
            'made fully aware of the contents and intent of this policy. '
            'Department Heads and Supervisors are responsible for ensuring '
            'that Customer Service Representatives (CSRs) receive proper '
            'orientation and training on the standards, procedures, and '
            'ethical guidelines outlined herein.',
        'All CSRs must acknowledge that they have read, understood, and '
            'agreed to comply with this policy as part of their professional '
            'responsibility. Regular refresher sessions shall be conducted to '
            'reinforce awareness and alignment with current practices.',
      ],
    },
    {
      'title': 'Policy Review',
      'paragraphs': [
        'This policy shall be reviewed annually or as deemed necessary to '
            'ensure its continued relevance, effectiveness, and alignment '
            'with company goals, legal requirements, and customer service '
            'standards. The Customer Relations Department, in coordination '
            'with the Human Resources and the designated Data Protection '
            'Officer (DPO), shall oversee the review and recommend revisions '
            'for management approval.',
        'Any amendments or updates shall be formally communicated to all '
            'employees to ensure company-wide compliance and understanding.',
      ],
    },
  ];

  Future<void> _openEditScreen() async {
    final result =
        await Navigator.of(context).push<List<Map<String, dynamic>>>(
      MaterialPageRoute(
        builder: (_) => EditPolicyAwarenessScreen(entries: _entries),
      ),
    );
    if (result != null && mounted) setState(() => _entries = result);
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
                        'Policy Awareness and Reviews',
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

              // ── Content ───────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _entries.map((entry) {
                    final paragraphs =
                        entry['paragraphs'] as List<dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry['title'] as String,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          ...paragraphs.map((p) => Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  p as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black87,
                                    height: 1.7,
                                  ),
                                ),
                              )),
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
