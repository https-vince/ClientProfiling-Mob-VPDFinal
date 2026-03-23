import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_customer_satisfaction_screen.dart';

class CustomerSatisfactionScreen extends StatefulWidget {
  const CustomerSatisfactionScreen({Key? key}) : super(key: key);

  @override
  State<CustomerSatisfactionScreen> createState() => _CustomerSatisfactionScreenState();
}

class _CustomerSatisfactionScreenState extends State<CustomerSatisfactionScreen> {
  List<Map<String, String>> _entries = [];

  Future<void> _openEditScreen() async {
    final result = await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) => EditCustomerSatisfactionScreen(entries: _entries),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Customer Satisfaction and Loyalty',
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
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: _entries.isEmpty
                    ? const Text(
                        'No content yet. Tap "Edit Content" to add.',
                        style: TextStyle(fontSize: 14, color: Colors.black38, height: 1.6),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _entries.map((e) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(e['title']!,
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                                const SizedBox(height: 4),
                                Text(e['body']!,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6)),
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
