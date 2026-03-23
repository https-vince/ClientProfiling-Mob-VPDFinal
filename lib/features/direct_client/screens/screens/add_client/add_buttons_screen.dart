import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../../../core/network/api_exception.dart';
import '../../../../../shared/widgets/custom_app_bar.dart';
import '../../../services/direct_client_service.dart';

enum AddMode { client, product, service, shop }

class AddButtonsScreen extends StatefulWidget {
  const AddButtonsScreen({
    super.key,
    required this.mode,
    this.contextData,
  });

  final AddMode mode;
  final Map<String, String>? contextData;

  @override
  State<AddButtonsScreen> createState() => _AddButtonsScreenState();
}

class _AddButtonsScreenState extends State<AddButtonsScreen> {
  final DirectClientService _service = DirectClientService();
  bool _isSubmitting = false;
  bool _isLoadingOptions = false;

  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _clientNotesController = TextEditingController();

  final _shopNameController = TextEditingController();
  final _shopAddressController = TextEditingController();
  final _pinLocationController = TextEditingController();
  final _locationLinkController = TextEditingController();
  final _contactPersonController = TextEditingController();
  final _contactNoController = TextEditingController();
  final _viberNoController = TextEditingController();
  final _shopEmailController = TextEditingController();
  final _shopNotesController = TextEditingController();
  final _shopTypeIdController = TextEditingController();
  String? _shopTypeId;

  final _modelNameController = TextEditingController();
  final _uomController = TextEditingController();
  final _modelCodeController = TextEditingController();
  final _applianceTypeController = TextEditingController();
  final _productNotesController = TextEditingController();
  DateTime? _contractDate;
  DateTime? _deliveryDate;
  DateTime? _installmentDate;
  String? _employeeId;

  String? _serviceTypeId;
  String? _serialNumberId;
  String? _serviceEmployeeId;
  DateTime? _serviceDate;
  final _eventIdController = TextEditingController();
  final _controlNumberController = TextEditingController();
  final _serviceNotesController = TextEditingController();
  String? _pickedFileName;

  List<Map<String, String>> _employees = const <Map<String, String>>[];
  List<Map<String, String>> _serviceTypes = const <Map<String, String>>[];
  List<Map<String, String>> _serialNumbers = const <Map<String, String>>[];

  @override
  void initState() {
    super.initState();
    if (widget.mode == AddMode.product || widget.mode == AddMode.service) {
      _loadDependencies();
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _clientNotesController.dispose();
    _shopNameController.dispose();
    _shopAddressController.dispose();
    _pinLocationController.dispose();
    _locationLinkController.dispose();
    _contactPersonController.dispose();
    _contactNoController.dispose();
    _viberNoController.dispose();
    _shopEmailController.dispose();
    _shopNotesController.dispose();
    _shopTypeIdController.dispose();
    _modelNameController.dispose();
    _uomController.dispose();
    _modelCodeController.dispose();
    _applianceTypeController.dispose();
    _productNotesController.dispose();
    _eventIdController.dispose();
    _controlNumberController.dispose();
    _serviceNotesController.dispose();
    super.dispose();
  }

  Future<void> _loadDependencies() async {
    setState(() => _isLoadingOptions = true);
    try {
      final employeesFuture = _service.fetchEmployees();
      final serviceTypesFuture = _service.fetchServiceTypes();
      final serialNumbersFuture = _service.fetchSerialNumbers();

      final employees = await employeesFuture;
      final serviceTypes = await serviceTypesFuture;
      final serialNumbers = await serialNumbersFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _employees = employees;
        _serviceTypes = serviceTypes;
        _serialNumbers = serialNumbers;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to load form dependencies.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoadingOptions = false);
      }
    }
  }

  Future<void> _submit() async {
    if (_isSubmitting) {
      return;
    }

    final validation = _validate();
    if (validation != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(validation)));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      switch (widget.mode) {
        case AddMode.client:
          await _service.createClient(
            firstName: _firstNameController.text.trim(),
            middleName: _middleNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            companyName: _companyNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            notes: _clientNotesController.text.trim(),
          );
          break;
        case AddMode.shop:
          await _service.createShop(
            clientId: _asInt(widget.contextData?['clientId']),
            shopName: _shopNameController.text.trim(),
            shopAddress: _shopAddressController.text.trim(),
            shopType: _shopTypeId,
            pinLocation: _pinLocationController.text.trim(),
            googleMaps: _locationLinkController.text.trim(),
            contactPerson: _contactPersonController.text.trim(),
            contactNo: _contactNoController.text.trim(),
            viberNo: _viberNoController.text.trim(),
            contactEmail: _shopEmailController.text.trim(),
            notes: _shopNotesController.text.trim(),
          );
          break;
        case AddMode.product:
          await _service.createProduct(
            clientId: _asInt(widget.contextData?['clientId']),
            shopId: _asInt(widget.contextData?['shopId']),
            modelName: _modelNameController.text.trim(),
            unitsOfMeasurement: _uomController.text.trim(),
            modelCode: _modelCodeController.text.trim(),
            applianceType: _applianceTypeController.text.trim(),
            employeeId: _asInt(_employeeId),
            quantity: '',
            purchaseOrder: '',
            serialNumber: '',
            contractDate: _contractDate,
            deliveryDate: _deliveryDate,
            installationDate: _installmentDate,
            laborPlan: '',
            notes: _productNotesController.text.trim(),
          );
          break;
        case AddMode.service:
          await _service.createService(
            clientId: _asInt(widget.contextData?['clientId']),
            shopId: _asInt(widget.contextData?['shopId']),
            serviceTypeId: (_serviceTypeId ?? '').trim(),
            serviceDate: _serviceDate,
            employeeId: _asInt(_serviceEmployeeId),
            eventId: _eventIdController.text.trim(),
            controlNumber: _controlNumberController.text.trim(),
            serialNumberId: (_serialNumberId ?? '').trim(),
            image: _pickedFileName ?? '',
            notes: _serviceNotesController.text.trim(),
          );
          break;
      }

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }

      final fieldMessages = e.fieldErrors.values.where((m) => m.trim().isNotEmpty).join('\n');
      final message = fieldMessages.isNotEmpty ? fieldMessages : e.message;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit. Please try again.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  String? _validate() {
    switch (widget.mode) {
      case AddMode.client:
        if (_firstNameController.text.trim().isEmpty) {
          return 'First name is required.';
        }
        if (_lastNameController.text.trim().isEmpty) {
          return 'Last name is required.';
        }
        return null;
      case AddMode.shop:
        if (_asInt(widget.contextData?['clientId']) == null) {
          return 'Missing client id for Add Shop.';
        }
        if (_shopNameController.text.trim().isEmpty) {
          return 'Shop name is required.';
        }
        if (_shopAddressController.text.trim().isEmpty) {
          return 'Shop address is required.';
        }
        if ((_shopTypeId ?? '').trim().isEmpty) {
          _shopTypeId = _shopTypeIdController.text.trim();
        }
        if ((_shopTypeId ?? '').trim().isEmpty) {
          return 'shop_type_id is required.';
        }
        return null;
      case AddMode.product:
        if (_asInt(widget.contextData?['clientId']) == null) {
          return 'Missing client id for Add Product.';
        }
        if (_modelNameController.text.trim().isEmpty) {
          return 'model_name is required.';
        }
        if (_uomController.text.trim().isEmpty) {
          return 'unitsofmeasurement is required.';
        }
        if (_contractDate == null) {
          return 'contract_date is required.';
        }
        if (_modelCodeController.text.trim().isEmpty) {
          return 'model_code is required.';
        }
        if (_applianceTypeController.text.trim().isEmpty) {
          return 'appliance_type is required.';
        }
        if (_asInt(_employeeId) == null) {
          return 'employee_id is required.';
        }
        return null;
      case AddMode.service:
        if (_asInt(widget.contextData?['clientId']) == null) {
          return 'Missing client id for Add Service.';
        }
        if ((_serviceTypeId ?? '').trim().isEmpty) {
          return 'service_type_id is required.';
        }
        if (_serviceDate == null) {
          return 'service_date is required.';
        }
        return null;
    }
  }

  int? _asInt(String? value) => int.tryParse((value ?? '').trim());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Direct Client', showMenuButton: false),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_title(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 14),
            if (_isLoadingOptions) const LinearProgressIndicator(),
            const SizedBox(height: 10),
            _buildFormByMode(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _title() {
    switch (widget.mode) {
      case AddMode.client:
        return 'Add Client';
      case AddMode.product:
        return 'Add Product';
      case AddMode.service:
        return 'Add Service';
      case AddMode.shop:
        return 'Add Shop';
    }
  }

  Widget _buildFormByMode() {
    switch (widget.mode) {
      case AddMode.client:
        return Column(
          children: [
            _buildField(_firstNameController, 'First Name'),
            _buildField(_middleNameController, 'Middle Name'),
            _buildField(_lastNameController, 'Last Name'),
            _buildField(_companyNameController, 'Company Name'),
            _buildField(_emailController, 'Email'),
            _buildField(_phoneController, 'Phone'),
            _buildField(_clientNotesController, 'Notes', maxLines: 4),
          ],
        );
      case AddMode.shop:
        return Column(
          children: [
            _buildField(_shopNameController, 'shopname'),
            _buildField(_shopAddressController, 'saddress'),
            _buildField(_contactPersonController, 'scontactperson'),
            _buildField(_contactNoController, 'scontactnum'),
            _buildField(_viberNoController, 'svibernum'),
            _buildField(_shopEmailController, 'semailaddress'),
            _buildField(_pinLocationController, 'pin_location'),
            _buildField(_locationLinkController, 'location_link'),
            _buildField(_shopNotesController, 'notes', maxLines: 4),
            _buildField(
              _shopTypeIdController,
              'shop_type_id',
              onChanged: (v) => _shopTypeId = v,
            ),
          ],
        );
      case AddMode.product:
        return Column(
          children: [
            _buildField(_modelNameController, 'model_name'),
            _buildField(_uomController, 'unitsofmeasurement'),
            _buildField(_modelCodeController, 'model_code'),
            _buildField(_applianceTypeController, 'appliance_type'),
            _buildDate('contract_date', _contractDate, (v) => setState(() => _contractDate = v)),
            _buildDate('delivery_date', _deliveryDate, (v) => setState(() => _deliveryDate = v)),
            _buildDate('installment_date', _installmentDate, (v) => setState(() => _installmentDate = v)),
            _buildEmployeeDropdown(
              label: 'employee_id',
              value: _employeeId,
              onChanged: (v) => setState(() => _employeeId = v),
            ),
            _buildField(_productNotesController, 'notes', maxLines: 4),
          ],
        );
      case AddMode.service:
        return Column(
          children: [
            _buildServiceTypeDropdown(),
            _buildDate('service_date', _serviceDate, (v) => setState(() => _serviceDate = v)),
            _buildEmployeeDropdown(
              label: 'employee_id (optional)',
              value: _serviceEmployeeId,
              onChanged: (v) => setState(() => _serviceEmployeeId = v),
              optional: true,
            ),
            _buildSerialDropdown(),
            _buildField(_eventIdController, 'event_id (optional)'),
            _buildField(_controlNumberController, 'control_number (optional)'),
            _buildUploadField(),
            _buildField(_serviceNotesController, 'notes', maxLines: 4),
          ],
        );
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    ValueChanged<String>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDate(String label, DateTime? value, ValueChanged<DateTime> onPicked) {
    final display = value == null
        ? ''
        : '${value.month.toString().padLeft(2, '0')}/${value.day.toString().padLeft(2, '0')}/${value.year}';
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
          );
          if (picked != null) {
            onPicked(picked);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(display.isEmpty ? 'Select date' : display),
        ),
      ),
    );
  }

  Widget _buildEmployeeDropdown({
    required String label,
    required String? value,
    required ValueChanged<String?> onChanged,
    bool optional = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: [
          if (optional)
            const DropdownMenuItem<String>(value: '', child: Text('None')),
          ..._employees.map((employee) => DropdownMenuItem<String>(
                value: employee['id'],
                child: Text(employee['name'] ?? '-'),
              )),
        ],
        onChanged: (v) => onChanged((v ?? '').isEmpty ? null : v),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _serviceTypeId,
        decoration: const InputDecoration(
          labelText: 'service_type_id',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: _serviceTypes
            .map((item) => DropdownMenuItem<String>(
                  value: item['id'],
                  child: Text(item['name'] ?? '-'),
                ))
            .toList(),
        onChanged: (v) => setState(() => _serviceTypeId = v),
      ),
    );
  }

  Widget _buildSerialDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _serialNumberId,
        decoration: const InputDecoration(
          labelText: 'serial_number_id (optional)',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        items: [
          const DropdownMenuItem<String>(value: '', child: Text('None')),
          ..._serialNumbers.map((item) => DropdownMenuItem<String>(
                value: item['id'],
                child: Text(item['name'] ?? '-'),
              )),
        ],
        onChanged: (v) => setState(() => _serialNumberId = (v ?? '').isEmpty ? null : v),
      ),
    );
  }

  Widget _buildUploadField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () async {
          final result = await FilePicker.platform.pickFiles();
          if (result != null && result.files.isNotEmpty) {
            setState(() => _pickedFileName = result.files.single.name);
          }
        },
        child: InputDecorator(
          decoration: const InputDecoration(
            labelText: 'image (optional)',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
          child: Text(_pickedFileName ?? 'Choose file'),
        ),
      ),
    );
  }
}
