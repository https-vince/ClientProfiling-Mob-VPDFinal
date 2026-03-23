import 'package:flutter/material.dart';
import '../../../../shared/widgets/custom_app_bar.dart';
import 'edit_key_technical_features_screen.dart';

class KeyTechnicalFeaturesScreen extends StatefulWidget {
  const KeyTechnicalFeaturesScreen({Key? key}) : super(key: key);

  @override
  State<KeyTechnicalFeaturesScreen> createState() =>
      _KeyTechnicalFeaturesScreenState();
}

class _KeyTechnicalFeaturesScreenState
    extends State<KeyTechnicalFeaturesScreen> {
  List<Map<String, String>> _entries = [];

  Future<void> _openEditScreen() async {
    final result =
        await Navigator.of(context).push<List<Map<String, String>>>(
      MaterialPageRoute(
        builder: (_) =>
            EditKeyTechnicalFeaturesScreen(entries: _entries),
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
              // ── Title row ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 16, 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Expanded(
                      child: Text(
                        'Key Technical Features and Specifications',
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
              if (_entries.isEmpty)
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                  child: Center(
                    child: Text(
                      'No content yet. Tap Edit Content to add entries.',
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((entry['title'] ?? '').isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(
                                  entry['title']!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            if ((entry['body'] ?? '').isNotEmpty)
                              Text(
                                entry['body']!,
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
