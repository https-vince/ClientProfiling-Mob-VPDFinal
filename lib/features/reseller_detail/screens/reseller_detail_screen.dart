import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/custom_app_bar.dart';
import '../../preloader/widgets/washing_loader.dart';
import '../../resellers/providers/resellers_provider.dart';
import '../models/reseller_detail_data.dart';
import '../providers/reseller_detail_provider.dart';

class ResellerDetailScreen extends ConsumerStatefulWidget {
  final Map<String, String> reseller;

  const ResellerDetailScreen({Key? key, required this.reseller}) : super(key: key);

  @override
  ConsumerState<ResellerDetailScreen> createState() => _ResellerDetailScreenState();
}

class _ResellerDetailScreenState extends ConsumerState<ResellerDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 5;
  int _currentPage = 1;
  String _searchQuery = '';
  String _sortBy = 'default';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, String>> _filteredProducts(List<Map<String, String>> products) {
    final query = _searchQuery.trim().toLowerCase();
    var filtered = products.where((product) {
      if (query.isEmpty) {
        return true;
      }
      return (product['modelName'] ?? '').toLowerCase().contains(query) ||
          (product['purchaseOrder'] ?? '').toLowerCase().contains(query);
    }).toList();

    if (_sortBy == 'model_asc') {
      filtered.sort((a, b) => (a['modelName'] ?? '').compareTo(b['modelName'] ?? ''));
    } else if (_sortBy == 'model_desc') {
      filtered.sort((a, b) => (b['modelName'] ?? '').compareTo(a['modelName'] ?? ''));
    } else if (_sortBy == 'po_asc') {
      filtered.sort((a, b) => (a['purchaseOrder'] ?? '').compareTo(b['purchaseOrder'] ?? ''));
    } else if (_sortBy == 'po_desc') {
      filtered.sort((a, b) => (b['purchaseOrder'] ?? '').compareTo(a['purchaseOrder'] ?? ''));
    }

    return filtered;
  }

  Future<void> _refreshDetail() async {
    ref.invalidate(resellerDetailProvider(widget.reseller));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(resellerDetailProvider(widget.reseller));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const CustomAppBar(
        title: 'Reseller Detail',
      ),
      body: detailAsync.when(
        loading: () => const ColoredBox(
          color: Color(0xFFF7F5F5),
          child: Center(child: WashingLoader(scale: 1.2)),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Failed to load reseller details.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshDetail,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) {
          final reseller = detail.reseller;
          final filteredProducts = _filteredProducts(detail.products);

          final totalPages =
              (filteredProducts.length / _entriesPerPage).ceil().clamp(1, 9999);

          if (_currentPage > totalPages) {
            _currentPage = totalPages;
          }

          final startIndex = (_currentPage - 1) * _entriesPerPage;
          final endIndex = (startIndex + _entriesPerPage).clamp(0, filteredProducts.length);
          final paginatedProducts = startIndex >= filteredProducts.length
              ? <Map<String, String>>[]
              : filteredProducts.sublist(startIndex, endIndex);

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Company Information Card
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF87CEEB), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  (reseller['companyName'] ?? 'R').substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reseller['companyName'] ?? '-',
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Reseller Account',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            _buildInfoRow(
                              Icons.location_on_outlined,
                              'Address',
                              reseller['address'] ?? '-',
                            ),
                            const SizedBox(height: 14),
                            _buildInfoRow(
                              Icons.email_outlined,
                              'Email',
                              reseller['email'] ?? '-',
                            ),
                            const SizedBox(height: 14),
                            _buildInfoRow(
                              Icons.phone_outlined,
                              'Phone No.',
                              reseller['phoneNumber'] ?? '-',
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showEditDialog(detail),
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    label: const Text('Edit'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF2563EB),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () => _showDeleteConfirmation(detail),
                                    icon: const Icon(Icons.delete_outline, size: 18),
                                    label: const Text('Delete'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFEF4444),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 13),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 0,
                                      textStyle: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Product Details Section
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 18, 16, 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFF8C42),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Text(
                                  'Product Details',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _showAddProductDialog(detail),
                              icon: const Icon(Icons.add_rounded, size: 16),
                              label: const Text('Add Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF8C42),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _searchQuery = value;
                                    _currentPage = 1;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search products...',
                                  hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: Colors.grey[400]),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide(color: Colors.grey[200]!),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            OutlinedButton.icon(
                              onPressed: _showFilterSheet,
                              icon: const Icon(Icons.filter_list_rounded, size: 17),
                              label: const Text('Filter'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                                side: BorderSide(color: Colors.grey[300]!),
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FC),
                          border: Border.symmetric(
                            horizontal: BorderSide(color: Colors.grey[200]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Model Name',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Purchase Order',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[600],
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (paginatedProducts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 40),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey[300]),
                                const SizedBox(height: 10),
                                Text(
                                  'No products found',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...paginatedProducts.asMap().entries.map((entry) {
                          final index = entry.key;
                          final product = entry.value;
                          final isLast = index == paginatedProducts.length - 1;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: index.isEven ? Colors.white : const Color(0xFFFAFAFC),
                              border: !isLast
                                  ? Border(bottom: BorderSide(color: Colors.grey[100]!, width: 1))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    product['modelName'] ?? '-',
                                    style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    product['purchaseOrder'] ?? '-',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      Container(
                        padding: const EdgeInsets.fromLTRB(16, 12, 12, 16),
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: Colors.grey[100]!, width: 1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Showing '
                              '${filteredProducts.isEmpty ? 0 : startIndex + 1} '
                              'to '
                              '${startIndex + paginatedProducts.length} '
                              'of ${filteredProducts.length} entries',
                              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                            ),
                            Row(
                              children: [
                                _PageBtn(
                                  icon: Icons.first_page_rounded,
                                  enabled: _currentPage > 1,
                                  onTap: () => setState(() => _currentPage = 1),
                                ),
                                _PageBtn(
                                  icon: Icons.chevron_left_rounded,
                                  enabled: _currentPage > 1,
                                  onTap: () => setState(() => _currentPage--),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _currentPage.toString(),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                _PageBtn(
                                  icon: Icons.chevron_right_rounded,
                                  enabled: _currentPage < totalPages,
                                  onTap: () => setState(() => _currentPage++),
                                ),
                                _PageBtn(
                                  icon: Icons.last_page_rounded,
                                  enabled: _currentPage < totalPages,
                                  onTap: () => setState(() => _currentPage = totalPages),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF2563EB).withOpacity(0.07),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 17, color: const Color(0xFF2563EB)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[500],
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showEditDialog(ResellerDetailData detail) async {
    final reseller = detail.reseller;
    final resellerId = reseller['id'] ?? '';
    if (resellerId.trim().isEmpty) {
      _showSnack('Unable to edit reseller: missing reseller ID.', isError: true);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final companyController = TextEditingController(text: reseller['companyName'] ?? '');
    final addressController = TextEditingController(text: reseller['address'] ?? '');
    final emailController = TextEditingController(text: reseller['email'] ?? '');
    final phoneController = TextEditingController(text: reseller['phoneNumber'] ?? '');

    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Edit Reseller'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: companyController,
                        decoration: const InputDecoration(labelText: 'Company Name'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Company Name is required'
                            : null,
                      ),
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: 'Address'),
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Address is required'
                            : null,
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          final text = (value ?? '').trim();
                          if (text.isEmpty) {
                            return 'Email is required';
                          }
                          if (!text.contains('@')) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone Number'),
                        keyboardType: TextInputType.phone,
                        validator: (value) => (value == null || value.trim().isEmpty)
                            ? 'Phone Number is required'
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          setLocalState(() => isSaving = true);
                          try {
                            await ref.read(resellerDetailServiceProvider).updateReseller(
                                  resellerId: resellerId,
                                  companyName: companyController.text.trim(),
                                  address: addressController.text.trim(),
                                  email: emailController.text.trim(),
                                  phoneNumber: phoneController.text.trim(),
                                );
                            if (!mounted) {
                              return;
                            }
                            Navigator.of(dialogContext).pop();
                            await _refreshDetail();
                            ref.invalidate(resellersDataProvider);
                            ref.invalidate(resellersSummaryProvider);
                            _showSnack('Reseller updated successfully.');
                          } catch (_) {
                            setLocalState(() => isSaving = false);
                            _showSnack('Failed to update reseller.', isError: true);
                          }
                        },
                  child: Text(isSaving ? 'Saving...' : 'Save'),
                ),
              ],
            );
          },
        );
      },
    );

    companyController.dispose();
    addressController.dispose();
    emailController.dispose();
    phoneController.dispose();
  }

  Future<void> _showAddProductDialog(ResellerDetailData detail) async {
    final resellerId = detail.reseller['id'] ?? '';
    if (resellerId.trim().isEmpty) {
      _showSnack('Unable to add product: missing reseller ID.', isError: true);
      return;
    }

    final formKey = GlobalKey<FormState>();
    final modelController = TextEditingController();
    final poController = TextEditingController();
    var isSaving = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Add Product'),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: modelController,
                      decoration: const InputDecoration(labelText: 'Model Name'),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Model Name is required'
                          : null,
                    ),
                    TextFormField(
                      controller: poController,
                      decoration: const InputDecoration(labelText: 'Purchase Order'),
                      validator: (value) => (value == null || value.trim().isEmpty)
                          ? 'Purchase Order is required'
                          : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }
                          setLocalState(() => isSaving = true);
                          try {
                            await ref.read(resellerDetailServiceProvider).addProduct(
                                  resellerId: resellerId,
                                  modelName: modelController.text.trim(),
                                  purchaseOrder: poController.text.trim(),
                                );
                            if (!mounted) {
                              return;
                            }
                            Navigator.of(dialogContext).pop();
                            await _refreshDetail();
                            ref.invalidate(resellersSummaryProvider);
                            _showSnack('Product added successfully.');
                          } catch (_) {
                            setLocalState(() => isSaving = false);
                            _showSnack('Failed to add product.', isError: true);
                          }
                        },
                  child: Text(isSaving ? 'Saving...' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );

    modelController.dispose();
    poController.dispose();
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Model Name (A-Z)'),
                onTap: () {
                  setState(() {
                    _sortBy = 'model_asc';
                    _currentPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Model Name (Z-A)'),
                onTap: () {
                  setState(() {
                    _sortBy = 'model_desc';
                    _currentPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Purchase Order (A-Z)'),
                onTap: () {
                  setState(() {
                    _sortBy = 'po_asc';
                    _currentPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Purchase Order (Z-A)'),
                onTap: () {
                  setState(() {
                    _sortBy = 'po_desc';
                    _currentPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Clear Filter'),
                onTap: () {
                  setState(() {
                    _sortBy = 'default';
                    _currentPage = 1;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(ResellerDetailData detail) {
    final resellerId = detail.reseller['id'] ?? '';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        var isDeleting = false;

        return StatefulBuilder(
          builder: (context, setLocalState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text(
                'Delete Reseller',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Text(
                'Are you sure you want to delete ${detail.reseller['companyName']}? This action cannot be undone.',
              ),
              actions: [
                TextButton(
                  onPressed: isDeleting ? null : () => Navigator.of(dialogContext).pop(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isDeleting
                      ? null
                      : () async {
                          if (resellerId.trim().isEmpty) {
                            _showSnack(
                              'Unable to delete reseller: missing reseller ID.',
                              isError: true,
                            );
                            return;
                          }

                          setLocalState(() => isDeleting = true);
                          try {
                            await ref.read(resellerDetailServiceProvider).deleteReseller(resellerId);
                            if (!mounted) {
                              return;
                            }
                            Navigator.of(dialogContext).pop();
                            ref.invalidate(resellersDataProvider);
                            ref.invalidate(resellersSummaryProvider);
                            _showSnack('Reseller deleted successfully');
                            Navigator.of(context).pop(true);
                          } catch (_) {
                            setLocalState(() => isDeleting = false);
                            _showSnack('Failed to delete reseller.', isError: true);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE74C3C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    isDeleting ? 'Deleting...' : 'Delete',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? const Color(0xFFE74C3C) : const Color(0xFF2563EB),
      ),
    );
  }
}

class _PageBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PageBtn({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Icon(
          icon,
          size: 22,
          color: enabled ? Colors.grey[700] : Colors.grey[300],
        ),
      ),
    );
  }
}
