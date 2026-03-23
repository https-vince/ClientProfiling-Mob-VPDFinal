import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_data_privacy_policy_screen.dart';

class DataPrivacyPolicyScreen extends StatefulWidget {
  const DataPrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  State<DataPrivacyPolicyScreen> createState() =>
      _DataPrivacyPolicyScreenState();
}

class _DataPrivacyPolicyScreenState extends State<DataPrivacyPolicyScreen> {
  List<Map<String, String>> _entries = [
    {
      'title': 'Policy Statement',
      'body':
          'Bulla Crave Laundry Machine Trading recognizes the importance of '
              'protecting the privacy and confidentiality of all customer data '
              'collected in the course of business operations. The Company is '
              'committed to safeguarding personal and transactional information '
              'in compliance with the Data Privacy Act of 2012 (Republic Act '
              'No. 10173) and other applicable laws, ensuring that all data is '
              'handled responsibly, securely, and transparently.',
    },
    {
      'title': 'Customer Data Protection',
      'body': '• All personal, financial, and transactional information '
          'obtained from customers shall be treated as strictly confidential.\n'
          '• Data shall be stored in secured systems or authorized repositories '
          'with appropriate access controls and encryption measures in place.\n'
          '• Representatives and authorized personnel must ensure that customer '
          'information is protected against loss, unauthorized access, '
          'alteration, disclosure, or misuse.\n'
          '• Physical and electronic records containing customer data shall be '
          'properly secured when not in use and disposed of safely when '
          'retention is no longer required.',
    },
    {
      'title': 'Use of Customer Information',
      'body': 'Customer data shall be collected and processed only for '
          'legitimate business purposes, including but not limited to service '
          'fulfillment, warranty processing, customer support, billing, '
          'communication, and recordkeeping.\n\n'
          'The use of customer information must always align with the '
          'company\'s service objectives and privacy commitments.\n\n'
          'Data sharing with third parties shall be limited to authorized '
          'partners or service providers bound by confidentiality agreements '
          'and data protection protocols.\n\n'
          'Any secondary use of data, such as for marketing or analytics, '
          'requires prior customer consent and adherence to privacy standards.',
    },
    {
      'title': 'Employee Responsibility',
      'body': '• All employees, contractors, and representatives with access '
          'to customer information are personally accountable for maintaining '
          'data confidentiality and integrity.\n'
          '• Unauthorized disclosure, copying, or use of customer data is '
          'strictly prohibited and may result in disciplinary action, up to '
          'and including termination of employment.\n'
          '• Employees shall immediately report any suspected data breach, '
          'loss, or unauthorized access to their department head or the '
          'designated Data Protection Officer (DPO).\n'
          '• Regular training and awareness programs shall be conducted to '
          'reinforce employees\' understanding of data privacy principles and '
          'company procedures.',
    },
    {
      'title': 'Compliance and Enforcement',
      'body': '• The Company shall comply with all provisions of the Data '
          'Privacy Act of 2012, its Implementing Rules and Regulations (IRR), '
          'and other applicable standards related to data protection.\n'
          '• The designated Data Protection Officer shall oversee the '
          'implementation, monitoring, and periodic review of data privacy '
          'measures to ensure continuous compliance.\n\n'
          'All customer inquiries, requests for data access, or complaints '
          'regarding privacy shall be handled promptly and transparently in '
          'accordance with company protocols.\n\n'
          'Any violations of this policy shall be subject to disciplinary '
          'action and may involve legal consequences as prescribed by '
          'applicable law.',
    },
    {
      'title': 'Commitment to Trust',
      'body': 'Bulla Crave is committed to maintaining the trust and '
          'confidence of its customers by ensuring that all personal and '
          'transactional data are managed ethically, securely, and in full '
          'respect of individual privacy rights. The protection of customer '
          'data is integral to our promise of reliability, accountability, '
          'and service excellence.',
    },
  ];

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) => EditDataPrivacyPolicyScreen(entries: _entries),
      ),
    );
    if (result != null && mounted) {
      setState(() => _entries = result);
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
                        'Data Privacy and Confidentiality Policy',
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
                  children: _entries.map((e) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e['title']!,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            e['body']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.7,
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
