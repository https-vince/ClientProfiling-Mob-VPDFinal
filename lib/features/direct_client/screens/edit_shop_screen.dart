import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../services/direct_client_service.dart';

class EditShopScreen extends StatefulWidget {
  final Map<String, String> client;

  const EditShopScreen({Key? key, required this.client}) : super(key: key);

  @override
  State<EditShopScreen> createState() => _EditShopScreenState();
}

class _EditShopScreenState extends State<EditShopScreen> {
  final DirectClientService _service = DirectClientService();

  late final TextEditingController _shopNameController;
  late final TextEditingController _shopAddressController;
  late final TextEditingController _pinCoordinatesController;
  late final TextEditingController _googleMapsController;
  late final TextEditingController _contactPersonController;
  late final TextEditingController _contactNoController;
  late final TextEditingController _viberNoController;
  late final TextEditingController _emailController;
  late final TextEditingController _notesController;

  String? _shopType;
  final List<String> _shopTypes = ['Main Branch', 'Sub Branch', 'Kiosk'];
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _shopNameController =
        TextEditingController(text: widget.client['shop'] ?? '');
    _shopAddressController =
        TextEditingController(text: widget.client['address'] ?? '');
    _pinCoordinatesController =
        TextEditingController(text: widget.client['pinLocation'] ?? '');
    _googleMapsController =
        TextEditingController(text: widget.client['googleMaps'] ?? '');
    _contactPersonController =
        TextEditingController(text: widget.client['contactPerson'] ?? '');
    _contactNoController =
        TextEditingController(text: widget.client['contactNo'] ?? '');
    _viberNoController =
        TextEditingController(text: widget.client['viberNo'] ?? '');
    _emailController =
        TextEditingController(text: widget.client['contactEmail'] ?? '');
    _notesController = TextEditingController();

    // Pre-select shop type if it matches one of the options
    final branchType = widget.client['branchType'] ?? '';
    if (_shopTypes.contains(branchType)) {
      _shopType = branchType;
    }
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _pinCoordinatesController.dispose();
    _googleMapsController.dispose();
    _contactPersonController.dispose();
    _contactNoController.dispose();
    _viberNoController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(title: 'Direct Client', showMenuButton: false),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edit Shop',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildField('Shop name', _shopNameController,
                      hint: "3J's Laundry"),
                  const SizedBox(height: 14),

                  _buildField('Shop Address', _shopAddressController,
                      hint: '42 Fuchsia St., De Nacia VIII 4, Brgy. Sauyo, QC'),
                  const SizedBox(height: 14),

                  _buildLabel('Shop Type'),
                  const SizedBox(height: 6),
                  _buildDropdown(),
                  const SizedBox(height: 14),

                  _buildField('Pin Coordinates', _pinCoordinatesController,
                      hint: '14.6888888888888888123123.',
                      keyboardType: TextInputType.text),
                  const SizedBox(height: 14),

                  _buildField('Google Maps Link', _googleMapsController,
                      hint: 'https://maps.app.goo.gl/Lfoqiwqel23'),
                  const SizedBox(height: 14),

                  _buildField('Contact Person Name', _contactPersonController,
                      hint: 'Glenda Valeroso'),
                  const SizedBox(height: 14),

                  _buildField('Contact No.', _contactNoController,
                      hint: '0966-135-9282',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),

                  _buildField('Viber No.', _viberNoController,
                      hint: '0966-135-9282',
                      keyboardType: TextInputType.phone),
                  const SizedBox(height: 14),

                  _buildField('Email Address', _emailController,
                      hint: 'glendavaleroso25@gmail.com',
                      keyboardType: TextInputType.emailAddress),
                  const SizedBox(height: 14),

                  _buildField('Notes', _notesController,
                      hint: '', maxLines: 6),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Save Changes button pinned at bottom
          Container(
            width: double.infinity,
            color: const Color(0xFFF5F7FA),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ElevatedButton(
              onPressed: () async {
                if (_isSaving) {
                  return;
                }

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Save Changes'),
                    content: const Text(
                        'Are you sure you want to save these changes?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC300),
                          foregroundColor: Colors.black,
                          elevation: 0,
                        ),
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true) {
                  await _saveShopChanges();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFC300),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    String hint = '',
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _shopType,
          isExpanded: true,
          hint: Text(
            'Select Shop Type',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          items: _shopTypes
              .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87)),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _shopType = value),
        ),
      ),
    );
  }

  Future<void> _saveShopChanges() async {
    final shopId = int.tryParse((widget.client['shopId'] ?? '').trim());
    final clientId = int.tryParse((widget.client['clientId'] ?? '').trim());

    if (shopId == null) {
      _showMessage('Missing shop id. Please reopen this page from shop details.');
      return;
    }

    if (clientId == null) {
      _showMessage('Missing client id. Please reopen this page from shop details.');
      return;
    }

    if (_shopNameController.text.trim().isEmpty ||
        _shopAddressController.text.trim().isEmpty ||
        _viberNoController.text.trim().isEmpty ||
        _contactPersonController.text.trim().isEmpty ||
        _contactNoController.text.trim().isEmpty ||
        (_shopType ?? '').trim().isEmpty) {
      _showMessage('Please complete all required shop fields before saving.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _service.updateShop(
        shopId: shopId,
        clientId: clientId,
        shopName: _shopNameController.text.trim(),
        shopAddress: _shopAddressController.text.trim(),
        viberNo: _viberNoController.text.trim(),
        contactPerson: _contactPersonController.text.trim(),
        contactNo: _contactNoController.text.trim(),
        shopTypeId: (_shopType ?? '').trim(),
        contactEmail: _emailController.text.trim(),
        notes: _notesController.text.trim(),
        googleMaps: _googleMapsController.text.trim(),
        pinLocation: _pinCoordinatesController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(_apiErrorMessage(e));
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showMessage('Failed to update shop. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String _apiErrorMessage(ApiException e) {
    if (e.statusCode == 401) {
      return 'Unauthorized (401). Please log in again.';
    }

    if (e.statusCode == 404) {
      return 'Shop not found (404). It may have been deleted.';
    }

    if (e.statusCode == 422 || e.fieldErrors.isNotEmpty) {
      final detailedErrors = e.fieldErrors.values
          .where((message) => message.trim().isNotEmpty)
          .join('\n');
      if (detailedErrors.isNotEmpty) {
        return detailedErrors;
      }
      return e.message;
    }

    return e.message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
