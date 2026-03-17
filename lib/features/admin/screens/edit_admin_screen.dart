import 'package:flutter/material.dart';
import '../../../shared/widgets/custom_app_bar.dart';

import '../../../core/network/api_exception.dart';
import '../services/admin_service.dart';

class EditAdminScreen extends StatefulWidget {
  final Map<String, String> admin;

  const EditAdminScreen({Key? key, required this.admin}) : super(key: key);

  @override
  State<EditAdminScreen> createState() => _EditAdminScreenState();
}

class _EditAdminScreenState extends State<EditAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final AdminService _adminService = AdminService();

  late final TextEditingController _firstNameController;
  late final TextEditingController _middleNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;

  String? _selectedRole;
  bool _isSubmitting = false;

  final List<String> _roles = ['Super Admin', 'Admin', 'Salesperson', 'Technician'];

  @override
  void initState() {
    super.initState();
    _firstNameController =
        TextEditingController(text: widget.admin['firstName'] ?? '');
    _middleNameController =
      TextEditingController(text: widget.admin['middleName'] ?? '');
    _lastNameController =
        TextEditingController(text: widget.admin['lastName'] ?? '');
    _usernameController =
        TextEditingController(text: widget.admin['username'] ?? '');
    _phoneController =
        TextEditingController(text: widget.admin['phone'] ?? '');
    _emailController =
        TextEditingController(text: widget.admin['email'] ?? '');
    _addressController =
        TextEditingController(text: widget.admin['address'] ?? '');
    _selectedRole = widget.admin['role'];
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.admin['role'] ?? 'Admin';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Admin',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Heading
            Text(
              'Edit $role',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),

            _buildLabel('First Name'),
            _buildTextField(controller: _firstNameController),
            const SizedBox(height: 14),

            _buildLabel('Middle Name'),
            _buildTextField(controller: _middleNameController, required: false),
            const SizedBox(height: 14),

            _buildLabel('Last Name'),
            _buildTextField(controller: _lastNameController),
            const SizedBox(height: 14),

            _buildLabel('Username'),
            _buildTextField(controller: _usernameController),
            const SizedBox(height: 14),

            _buildLabel('Phone No.'),
            _buildTextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 14),

            _buildLabel('Email Address'),
            _buildTextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),

            _buildLabel('Role'),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              items: _roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedRole = v),
              validator: (v) => v == null ? 'Please select a role' : null,
              decoration: _inputDecoration(),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            ),
            const SizedBox(height: 14),

            _buildLabel('Address'),
            _buildTextField(controller: _addressController, maxLines: 2),
            const SizedBox(height: 32),

            // Update Admin button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFC107),
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Admin'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final adminId = (widget.admin['id'] ?? '').trim();
    if (adminId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Missing admin ID.')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await _adminService.updateUser(
        id: adminId,
        username: _usernameController.text.trim(),
        firstname: _firstNameController.text.trim(),
        middlename: _middleNameController.text.trim(),
        surname: _lastNameController.text.trim(),
        phonenum: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        email: _emailController.text.trim(),
        role: (_selectedRole ?? '').trim(),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin updated successfully')),
      );
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update admin.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = true,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? 'This field is required' : null
          : null,
      decoration: _inputDecoration(),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Color(0xFF2563EB)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }
}
