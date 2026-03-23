import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../services/direct_client_service.dart';

class EditProductDetailsScreen extends StatefulWidget {
  const EditProductDetailsScreen({super.key, required this.product});

  final Map<String, String> product;

  @override
  State<EditProductDetailsScreen> createState() => _EditProductDetailsScreenState();
}

class _EditProductDetailsScreenState extends State<EditProductDetailsScreen> {
  final DirectClientService _service = DirectClientService();

  final _modelNameController = TextEditingController();
  final _uomController = TextEditingController();
  final _modelCodeController = TextEditingController();
  final _applianceTypeController = TextEditingController();
  final _notesController = TextEditingController();

  DateTime? _contractDate;
  DateTime? _deliveryDate;
  DateTime? _installmentDate;

  String? _employeeId;
  List<Map<String, String>> _employees = const <Map<String, String>>[];

  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, String> _fieldErrors = const <String, String>{};

  String get _productIdText => (widget.product['productId'] ?? '').trim();
  String get _clientIdText => (widget.product['clientId'] ?? '').trim();

  @override
  void initState() {
    super.initState();
    _prefill(widget.product);
    _load();
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _uomController.dispose();
    _modelCodeController.dispose();
    _applianceTypeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final employeesFuture = _service.fetchEmployees();
      final id = int.tryParse(_productIdText);
      final productFuture = id == null
          ? Future<Map<String, String>>.value(widget.product)
          : _service.getProductById(id.toString());

      final employees = await employeesFuture;
      final product = await productFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
      });
      _prefill(product);
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load product details.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _prefill(Map<String, String> product) {
    _modelNameController.text = (product['modelName'] ?? '').trim();
    _uomController.text = (product['uom'] ?? '').trim();
    _modelCodeController.text = (product['modelCode'] ?? '').trim();
    _applianceTypeController.text = (product['supplierType'] ?? '').trim();
    _notesController.text = (product['notes'] ?? '').trim();

    _contractDate = _parseDate(product['contractDate']);
    _deliveryDate = _parseDate(product['deliveryDate']);
    _installmentDate = _parseDate(product['installationDate']);
    _employeeId = (product['employeeId'] ?? '').trim().isEmpty
        ? _employeeId
        : (product['employeeId'] ?? '').trim();

    if (mounted) {
      setState(() {});
    }
  }

  DateTime? _parseDate(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) {
      return null;
    }

    final ymd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final mdy = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');

    if (ymd.hasMatch(raw)) {
      final m = ymd.firstMatch(raw)!;
      return DateTime(
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
        int.parse(m.group(3)!),
      );
    }

    if (mdy.hasMatch(raw)) {
      final m = mdy.firstMatch(raw)!;
      return DateTime(
        int.parse(m.group(3)!),
        int.parse(m.group(1)!),
        int.parse(m.group(2)!),
      );
    }

    return null;
  }

  String _toApiDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '${value.year}-$month-$day';
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    setState(() => _fieldErrors = const <String, String>{});

    final productId = int.tryParse(_productIdText);
    final clientId = int.tryParse(_clientIdText);
    final employeeId = int.tryParse((_employeeId ?? '').trim());

    if (productId == null) {
      _showError('Missing product id.');
      return;
    }
    if (clientId == null) {
      _showError('Missing client id.');
      return;
    }
    if (_modelNameController.text.trim().isEmpty ||
        _uomController.text.trim().isEmpty ||
        _modelCodeController.text.trim().isEmpty ||
        _applianceTypeController.text.trim().isEmpty ||
        employeeId == null ||
        _contractDate == null) {
      _showError('Please complete required fields before saving.');
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.updateProduct(
        productId: productId,
        modelName: _modelNameController.text.trim(),
        unitsOfMeasurement: _uomController.text.trim(),
        contractDate: _toApiDate(_contractDate),
        deliveryDate: _toApiDate(_deliveryDate),
        installmentDate: _toApiDate(_installmentDate),
        notes: _notesController.text.trim(),
        clientId: clientId,
        modelCode: _modelCodeController.text.trim(),
        applianceType: _applianceTypeController.text.trim(),
        employeeId: employeeId,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _fieldErrors = e.fieldErrors);
      _showError(e.message);
    } catch (_) {
      _showError('Failed to update product. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate(ValueChanged<DateTime> onPicked, DateTime? current) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }

  String _displayDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    return '$month/$day/${value.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(title: 'Direct Client', showMenuButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Product Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 10),
            _buildField(
              controller: _modelNameController,
              label: 'model_name',
              errorText: _fieldErrors['model_name'],
            ),
            _buildField(
              controller: _uomController,
              label: 'unitsofmeasurement',
              errorText: _fieldErrors['unitsofmeasurement'],
            ),
            _buildField(
              controller: _modelCodeController,
              label: 'model_code',
              errorText: _fieldErrors['model_code'],
            ),
            _buildField(
              controller: _applianceTypeController,
              label: 'appliance_type',
              errorText: _fieldErrors['appliance_type'],
            ),
            _buildDateField(
              label: 'contract_date',
              value: _contractDate,
              onTap: () => _pickDate((v) => setState(() => _contractDate = v), _contractDate),
              errorText: _fieldErrors['contract_date'],
            ),
            _buildDateField(
              label: 'delivery_date',
              value: _deliveryDate,
              onTap: () => _pickDate((v) => setState(() => _deliveryDate = v), _deliveryDate),
              errorText: _fieldErrors['delivery_date'],
            ),
            _buildDateField(
              label: 'installment_date',
              value: _installmentDate,
              onTap: () => _pickDate((v) => setState(() => _installmentDate = v), _installmentDate),
              errorText: _fieldErrors['installment_date'],
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DropdownButtonFormField<String>(
                value: _employeeId,
                decoration: InputDecoration(
                  labelText: 'employee_id',
                  errorText: _fieldErrors['employee_id'],
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.white,
                ),
                items: _employees
                    .map((e) => DropdownMenuItem<String>(
                          value: e['id'],
                          child: Text(e['name'] ?? '-'),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _employeeId = value),
              ),
            ),
            _buildField(
              controller: _notesController,
              label: 'notes',
              maxLines: 4,
              errorText: _fieldErrors['notes'],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          errorText: errorText,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            errorText: errorText,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(value == null ? 'Select date' : _displayDate(value)),
        ),
      ),
    );
  }
}
