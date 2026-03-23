import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../services/direct_client_service.dart';

class UpdateServiceScreen extends StatefulWidget {
  const UpdateServiceScreen({
    super.key,
    required this.service,
    required this.shopName,
  });

  final Map<String, String> service;
  final String shopName;

  @override
  State<UpdateServiceScreen> createState() => _UpdateServiceScreenState();
}

class _UpdateServiceScreenState extends State<UpdateServiceScreen> {
  final DirectClientService _service = DirectClientService();

  final TextEditingController _controlNumberController = TextEditingController();
  final TextEditingController _eventIdController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime? _serviceDate;
  String? _serviceTypeId;
  String? _employeeId;
  String? _serialNumberId;

  List<Map<String, String>> _serviceTypes = const <Map<String, String>>[];
  List<Map<String, String>> _employees = const <Map<String, String>>[];
  List<Map<String, String>> _serials = const <Map<String, String>>[];

  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controlNumberController.text = widget.service['controlNumber'] ?? '';
    _eventIdController.text = widget.service['eventId'] ?? '';
    _notesController.text = widget.service['notes'] ?? '';
    _serviceTypeId = (widget.service['serviceTypeId'] ?? '').trim().isEmpty
        ? null
        : widget.service['serviceTypeId'];
    _employeeId = (widget.service['employeeId'] ?? '').trim().isEmpty
        ? null
        : widget.service['employeeId'];
    _serialNumberId = (widget.service['serialSpareParts'] ?? '').trim().isEmpty
        ? null
        : widget.service['serialSpareParts'];
    _serviceDate = _parseDate(widget.service['serviceDate']);
    _loadDropdowns();
  }

  @override
  void dispose() {
    _controlNumberController.dispose();
    _eventIdController.dispose();
    _notesController.dispose();
    super.dispose();
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
      return DateTime(int.parse(m.group(1)!), int.parse(m.group(2)!), int.parse(m.group(3)!));
    }
    if (mdy.hasMatch(raw)) {
      final m = mdy.firstMatch(raw)!;
      return DateTime(int.parse(m.group(3)!), int.parse(m.group(1)!), int.parse(m.group(2)!));
    }

    return null;
  }

  String _toApiDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    final mm = value.month.toString().padLeft(2, '0');
    final dd = value.day.toString().padLeft(2, '0');
    return '${value.year}-$mm-$dd';
  }

  Future<void> _loadDropdowns() async {
    setState(() => _isLoading = true);
    try {
      final serviceTypesFuture = _service.fetchServiceTypes();
      final employeesFuture = _service.fetchEmployees();
      final serialsFuture = _service.fetchSerialNumbers();

      final serviceTypes = await serviceTypesFuture;
      final employees = await employeesFuture;
      final serials = await serialsFuture;

      if (!mounted) {
        return;
      }

      setState(() {
        _serviceTypes = serviceTypes;
        _employees = employees;
        _serials = serials;
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _save() async {
    if (_isSaving) {
      return;
    }

    final serviceId = int.tryParse((widget.service['serviceId'] ?? '').trim());
    final clientId = int.tryParse((widget.service['clientId'] ?? '').trim());
    final shopId = int.tryParse((widget.service['shopId'] ?? '').trim());

    if (serviceId == null || clientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing service or client id.')),
      );
      return;
    }

    if ((_serviceTypeId ?? '').trim().isEmpty || _serviceDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('service_type_id and service_date are required.')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await _service.updateService(
        serviceId: serviceId,
        serviceTypeId: (_serviceTypeId ?? '').trim(),
        serviceDate: _toApiDate(_serviceDate),
        clientId: clientId,
        employeeId: int.tryParse((_employeeId ?? '').trim()),
        shopId: shopId,
        notes: _notesController.text.trim(),
        eventId: _eventIdController.text.trim(),
        serialNumberId: (_serialNumberId ?? '').trim(),
        controlNumber: _controlNumberController.text.trim(),
      );

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
        const SnackBar(content: Text('Failed to update service.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: const CustomAppBar(title: 'Direct Client', showMenuButton: false),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.shopName, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
            const SizedBox(height: 16),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 10),
            _buildDateField(),
            const SizedBox(height: 12),
            _buildServiceTypeDropdown(),
            const SizedBox(height: 12),
            _buildEmployeeDropdown(),
            const SizedBox(height: 12),
            _buildSerialDropdown(),
            const SizedBox(height: 12),
            _buildField(_controlNumberController, 'control_number'),
            const SizedBox(height: 12),
            _buildField(_eventIdController, 'event_id (optional)'),
            const SizedBox(height: 12),
            _buildField(_notesController, 'notes', maxLines: 4),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC300),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String label, {int maxLines = 1}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateField() {
    final display = _serviceDate == null
        ? ''
        : '${_serviceDate!.month.toString().padLeft(2, '0')}/${_serviceDate!.day.toString().padLeft(2, '0')}/${_serviceDate!.year}';

    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _serviceDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          setState(() => _serviceDate = picked);
        }
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'service_date',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(display.isEmpty ? 'Select date' : display),
      ),
    );
  }

  Widget _buildServiceTypeDropdown() {
    return DropdownButtonFormField<String>(
      value: _serviceTypeId,
      decoration: const InputDecoration(
        labelText: 'service_type_id',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: _serviceTypes
          .map((e) => DropdownMenuItem<String>(value: e['id'], child: Text(e['name'] ?? '-')))
          .toList(),
      onChanged: (value) => setState(() => _serviceTypeId = value),
    );
  }

  Widget _buildEmployeeDropdown() {
    return DropdownButtonFormField<String>(
      value: _employeeId,
      decoration: const InputDecoration(
        labelText: 'employee_id (optional)',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('None')),
        ..._employees.map((e) => DropdownMenuItem<String>(value: e['id'], child: Text(e['name'] ?? '-'))),
      ],
      onChanged: (value) => setState(() => _employeeId = (value ?? '').isEmpty ? null : value),
    );
  }

  Widget _buildSerialDropdown() {
    return DropdownButtonFormField<String>(
      value: _serialNumberId,
      decoration: const InputDecoration(
        labelText: 'serial_number_id (optional)',
        border: OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      items: [
        const DropdownMenuItem<String>(value: '', child: Text('None')),
        ..._serials.map((e) => DropdownMenuItem<String>(value: e['id'], child: Text(e['name'] ?? '-'))),
      ],
      onChanged: (value) => setState(() => _serialNumberId = (value ?? '').isEmpty ? null : value),
    );
  }
}
