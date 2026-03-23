import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../services/direct_client_service.dart';

class EditProductDetailsScreen extends StatefulWidget {
  final Map<String, String> product;

  const EditProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

  @override
  State<EditProductDetailsScreen> createState() =>
      _EditProductDetailsScreenState();
}

class _EditProductDetailsScreenState extends State<EditProductDetailsScreen> {
  final DirectClientService _service = DirectClientService();

  final _modelNameController = TextEditingController();
  final _uomController = TextEditingController();
  final _contractDateController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _installationDateController = TextEditingController();
  final _modelCodeController = TextEditingController();
  final _notesController = TextEditingController();

  String? _applianceType;
  String? _employeeName;
  String? _employeeId;
  String? _productId;
  String? _clientId;

  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, String> _fieldErrors = const {};

  final List<String> _applianceTypes = ['Washer', 'Dryer', 'Combo'];
  List<Map<String, String>> _employees = const [];
  List<String> _employeeNames = const [];

  @override
  void initState() {
    super.initState();

    _productId = (widget.product['productId'] ?? '').trim();
    _clientId = (widget.product['clientId'] ?? '').trim();

    _prefillFromMap(widget.product);
    _loadInitialData();
  }

  @override
  void dispose() {
    _modelNameController.dispose();
    _uomController.dispose();
    _contractDateController.dispose();
    _deliveryDateController.dispose();
    _installationDateController.dispose();
    _modelCodeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    await Future.wait([_loadEmployees(), _loadProductById()]);
  }

  Future<void> _loadProductById() async {
    final productId = _productId;
    if (productId == null || productId.isEmpty) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fetched = await _service.getProductById(productId);
      if (!mounted || fetched.isEmpty) {
        return;
      }

      _prefillFromMap(fetched);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      _showMessage(_apiErrorMessage(e));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Failed to load product details.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadEmployees() async {
    try {
      final employees = await _service.fetchEmployees();
      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _employeeNames = employees
            .map((e) => e['name'] ?? '')
            .where((n) => n.trim().isNotEmpty)
            .toList();
      });

      if ((_employeeId ?? '').isNotEmpty) {
        final matched = employees.where((e) => e['id'] == _employeeId).toList();
        if (matched.isNotEmpty) {
          setState(() => _employeeName = matched.first['name']);
        }
      } else if ((_employeeName ?? '').trim().isNotEmpty) {
        final nameMatch =
            employees.where((e) => e['name'] == _employeeName).toList();
        if (nameMatch.isNotEmpty) {
          setState(() => _employeeId = nameMatch.first['id']);
        }
      }
    } catch (_) {
      // Keep form usable even when employees endpoint fails.
    }
  }

  void _prefillFromMap(Map<String, String> data) {
    _productId = (data['productId'] ?? _productId ?? '').trim();
    _clientId = (data['clientId'] ?? _clientId ?? '').trim();

    _modelNameController.text = (data['modelName'] ?? '').trim();
    _uomController.text = (data['uom'] ?? '').trim();
    _contractDateController.text = _displayDate((data['contractDate'] ?? '').trim());
    _deliveryDateController.text = _displayDate((data['deliveryDate'] ?? '').trim());
    _installationDateController.text =
        _displayDate((data['installationDate'] ?? '').trim());
    _modelCodeController.text = (data['modelCode'] ?? '').trim();
    _notesController.text = (data['notes'] ?? '').trim();

    final type = (data['supplierType'] ?? '').trim();
    if (type.isNotEmpty && !_applianceTypes.contains(type)) {
      _applianceTypes.add(type);
    }
    _applianceType = type.isEmpty ? _applianceType : type;

    final employeeId = (data['employeeId'] ?? '').trim();
    if (employeeId.isNotEmpty) {
      _employeeId = employeeId;
    }

    final employeeName = (data['employeeName'] ?? '').trim();
    if (employeeName.isNotEmpty) {
      if (_employeeId == null || _employeeId!.isEmpty) {
        final maybeId = int.tryParse(employeeName);
        if (maybeId != null) {
          _employeeId = maybeId.toString();
        } else {
          _employeeName = employeeName;
        }
      } else {
        _employeeName = employeeName;
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  String _displayDate(String value) {
    if (value.isEmpty) {
      return '';
    }

    if (_toApiDate(value) != null && value.contains('-')) {
      final parts = value.split('-');
      if (parts.length == 3) {
        return '${parts[1]}/${parts[2]}/${parts[0]}';
      }
    }

    return value;
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.text =
          '${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}';
    }
  }

  Future<void> _saveProductChanges() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _fieldErrors = const {};
    });

    final productId = int.tryParse((_productId ?? '').trim());
    final clientId = int.tryParse((_clientId ?? '').trim());
    final employeeId = int.tryParse((_employeeId ?? '').trim());

    final contractDate = _toApiDate(_contractDateController.text.trim());
    final deliveryDate = _toApiDate(_deliveryDateController.text.trim());
    final installmentDate = _toApiDate(_installationDateController.text.trim());

    if (productId == null) {
      _showMessage('Missing product id. Please reopen this page.');
      return;
    }
    if (_modelNameController.text.trim().isEmpty) {
      _showMessage('Model Name is required.');
      return;
    }
    if (_uomController.text.trim().isEmpty) {
      _showMessage('Units of Measurement is required.');
      return;
    }
    if (contractDate == null) {
      _showMessage('Contract Date is required (YYYY-MM-DD).');
      return;
    }
    if (_modelCodeController.text.trim().isEmpty) {
      _showMessage('Model Code is required.');
      return;
    }
    if ((_applianceType ?? '').trim().isEmpty) {
      _showMessage('Appliance Type is required.');
      return;
    }
    if ((employeeId ?? 0) <= 0) {
      _showMessage('Employee is required.');
      return;
    }
    if ((clientId ?? 0) <= 0) {
      _showMessage('Missing client id. Cannot update product.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _service.updateProduct(
        productId: productId,
        modelName: _modelNameController.text.trim(),
        unitsOfMeasurement: _uomController.text.trim(),
        contractDate: contractDate,
        deliveryDate: deliveryDate ?? contractDate,
        installmentDate: installmentDate ?? contractDate,
        notes: _notesController.text.trim(),
        clientId: clientId,
        modelCode: _modelCodeController.text.trim(),
        applianceType: (_applianceType ?? '').trim(),
        employeeId: employeeId,
      );

      if (!mounted) {
        return;
      }

      _showMessage('Product updated successfully.');
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      if (e.statusCode == 422 && e.fieldErrors.isNotEmpty) {
        setState(() {
          _fieldErrors = Map<String, String>.from(e.fieldErrors);
        });
      }

      _showMessage(_apiErrorMessage(e));
    } catch (_) {
      if (!mounted) {
        return;
      }
      _showMessage('Failed to update product. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _toApiDate(String raw) {
    if (raw.trim().isEmpty) {
      return null;
    }

    final ymd = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');
    final mdy = RegExp(r'^(\d{2})\/(\d{2})\/(\d{4})$');

    if (ymd.hasMatch(raw)) {
      return raw;
    }

    final match = mdy.firstMatch(raw);
    if (match != null) {
      return '${match.group(3)}-${match.group(1)}-${match.group(2)}';
    }

    return null;
  }

  String _apiErrorMessage(ApiException e) {
    if (e.statusCode == 401) {
      return 'Session expired. Please log in again.';
    }
    if (e.statusCode == 404) {
      return 'Product not found.';
    }
    if (e.statusCode == 422 || e.fieldErrors.isNotEmpty) {
      final details =
          e.fieldErrors.values.where((m) => m.trim().isNotEmpty).join('\n');
      if (details.isNotEmpty) {
        return details;
      }
    }
    return e.message;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
                    'Edit Product Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: LinearProgressIndicator(minHeight: 2),
                    ),

                  _buildField(
                    'Model Name',
                    _modelNameController,
                    hint: 'Enter model name',
                    errorText: _fieldErrors['model_name'],
                  ),
                  const SizedBox(height: 14),

                  _buildField(
                    'Units of Measurement',
                    _uomController,
                    hint: 'Enter units',
                    errorText: _fieldErrors['unitsofmeasurement'],
                  ),
                  const SizedBox(height: 14),

                  _buildDateField(
                    'Contract Date',
                    _contractDateController,
                    errorText: _fieldErrors['contract_date'],
                  ),
                  const SizedBox(height: 14),

                  _buildDateField(
                    'Delivery Date',
                    _deliveryDateController,
                    errorText: _fieldErrors['delivery_date'],
                  ),
                  const SizedBox(height: 14),

                  _buildDateField(
                    'Installation Date',
                    _installationDateController,
                    errorText: _fieldErrors['installment_date'],
                  ),
                  const SizedBox(height: 14),

                  _buildField(
                    'Model Code',
                    _modelCodeController,
                    hint: 'Enter model code',
                    errorText: _fieldErrors['model_code'],
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Appliance Type'),
                  const SizedBox(height: 6),
                  _buildDropdown(
                    value: _applianceType,
                    items: _applianceTypes,
                    hint: 'Select appliance type',
                    onChanged: (v) => setState(() => _applianceType = v),
                    errorText: _fieldErrors['appliance_type'],
                  ),
                  const SizedBox(height: 14),

                  _buildLabel('Employee'),
                  const SizedBox(height: 6),
                  _buildEmployeeDropdown(
                    errorText: _fieldErrors['employee_id'],
                  ),
                  const SizedBox(height: 14),

                  _buildField(
                    'Notes',
                    _notesController,
                    hint: '',
                    maxLines: 6,
                    errorText: _fieldErrors['notes'],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          Container(
            width: double.infinity,
            color: const Color(0xFFF5F7FA),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: ElevatedButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Save Changes'),
                    content:
                        const Text('Are you sure you want to save these changes?'),
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
                  await _saveProductChanges();
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
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(
                      'Save Changes',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

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
    int maxLines = 1,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
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

  Widget _buildDateField(
    String label,
    TextEditingController controller, {
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          readOnly: true,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
          decoration: InputDecoration(
            hintText: 'MM/DD/YYYY',
            errorText: errorText,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            suffixIcon: Icon(Icons.calendar_month, color: Colors.grey[600]),
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
          onTap: () => _pickDate(controller),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required ValueChanged<String?> onChanged,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                hint,
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.black87),
                        ),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
        if (errorText != null && errorText.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
            ),
          ),
      ],
    );
  }

  Widget _buildEmployeeDropdown({
    String? errorText,
  }) {
    final hasSelected = (_employeeId ?? '').trim().isNotEmpty;
    final selectedInItems = hasSelected
        ? _employees.any((e) => e['id'] == _employeeId)
        : false;
    final dropdownValue = selectedInItems ? _employeeId : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: dropdownValue,
              isExpanded: true,
              hint: Text(
                'Select employee',
                style: TextStyle(color: Colors.grey[400], fontSize: 14),
              ),
              items: _employees
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e['id'],
                      child: Text(
                        e['name'] ?? '',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.black87),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (id) {
                final selected = _employees.firstWhere(
                  (e) => e['id'] == id,
                  orElse: () => <String, String>{},
                );
                setState(() {
                  _employeeId = id;
                  _employeeName = selected['name'];
                });
              },
            ),
          ),
        ),
        if (errorText != null && errorText.trim().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 12),
            child: Text(
              errorText,
              style: const TextStyle(fontSize: 12, color: Color(0xFFD32F2F)),
            ),
          ),
      ],
    );
  }
}
