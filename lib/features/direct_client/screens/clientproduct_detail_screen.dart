import 'dart:async';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../login/screens/login_screen.dart';
import '../services/client_detail_service.dart';
import '../services/direct_client_service.dart';
import 'edit_shop_screen.dart';
import 'productdetailsentities_screen.dart';
import 'services_entities_screen.dart';
import 'screens/add_client/add_buttons_screen.dart';

class ClientDetailScreen extends StatefulWidget {
  const ClientDetailScreen({super.key, required this.client});

  final Map<String, String> client;

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final ClientDetailService _clientDetailService = ClientDetailService();
  final DirectClientService _directClientService = DirectClientService();

  final TextEditingController _productSearchController = TextEditingController();
  final TextEditingController _serviceSearchController = TextEditingController();

  Map<String, String> _client = const <String, String>{};
  List<Map<String, String>> _products = const <Map<String, String>>[];
  List<Map<String, String>> _services = const <Map<String, String>>[];
  List<Map<String, String>> _filteredProducts = const <Map<String, String>>[];
  List<Map<String, String>> _filteredServices = const <Map<String, String>>[];

  bool _isLoading = false;
  String? _errorMessage;
  Timer? _productDebounce;
  Timer? _serviceDebounce;
  int _requestEpoch = 0;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _load();
  }

  @override
  void dispose() {
    _productDebounce?.cancel();
    _serviceDebounce?.cancel();
    _productSearchController.dispose();
    _serviceSearchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final requestId = ++_requestEpoch;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _clientDetailService.fetchData(_client);

      if (!mounted || requestId != _requestEpoch) {
        return;
      }

      setState(() {
        _products = data.products;
        _services = data.services;
      });
      _applyProductSearch();
      _applyServiceSearch();
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestEpoch) {
        return;
      }
      if (e.statusCode == 401) {
        _handleUnauthorized();
        return;
      }
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted || requestId != _requestEpoch) {
        return;
      }
      setState(() => _errorMessage = 'Failed to load shop details.');
    } finally {
      if (mounted && requestId == _requestEpoch) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleUnauthorized() {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Session expired. Please log in again.')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onProductSearchChanged(String _) {
    _productDebounce?.cancel();
    _productDebounce = Timer(const Duration(milliseconds: 400), _applyProductSearch);
  }

  void _onServiceSearchChanged(String _) {
    _serviceDebounce?.cancel();
    _serviceDebounce = Timer(const Duration(milliseconds: 400), _applyServiceSearch);
  }

  void _applyProductSearch() {
    final q = _productSearchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredProducts = _products);
      return;
    }

    final filtered = _products.where((item) {
      final model = (item['modelName'] ?? '').toLowerCase();
      final po = (item['purchaseOrder'] ?? '').toLowerCase();
      return model.contains(q) || po.contains(q);
    }).toList();

    setState(() => _filteredProducts = filtered);
  }

  void _applyServiceSearch() {
    final q = _serviceSearchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredServices = _services);
      return;
    }

    final filtered = _services.where((item) {
      final report = (item['reportNo'] ?? '').toLowerCase();
      final type = (item['serviceType'] ?? '').toLowerCase();
      return report.contains(q) || type.contains(q);
    }).toList();

    setState(() => _filteredServices = filtered);
  }

  Future<void> _deleteShop() async {
    final shopId = int.tryParse((_client['shopId'] ?? '').trim());
    if (shopId == null) {
      return;
    }

    try {
      await _directClientService.deleteShop(shopId);
      if (!mounted) {
        return;
      }
      Navigator.pop(context, true);
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _handleUnauthorized();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete shop.')),
      );
    }
  }

  Future<void> _deleteProduct(Map<String, String> product) async {
    final productId = int.tryParse((product['productId'] ?? '').trim());
    if (productId == null) {
      return;
    }

    try {
      await _directClientService.deleteProduct(productId);
      await _load();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _handleUnauthorized();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product.')),
      );
    }
  }

  Future<void> _deleteService(Map<String, String> service) async {
    final serviceId = int.tryParse((service['serviceId'] ?? '').trim());
    if (serviceId == null) {
      return;
    }

    try {
      await _directClientService.deleteService(serviceId);
      await _load();
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        _handleUnauthorized();
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete service.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: CustomAppBar(
        title: 'Direct Client',
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            _buildSectionHeader('Shop Details'),
            const SizedBox(height: 8),
            _buildShopDetailsCard(context),
            const SizedBox(height: 20),
            _buildSectionHeader('Product Details'),
            const SizedBox(height: 8),
            _buildProductsCard(context),
            const SizedBox(height: 20),
            _buildSectionHeader('Services'),
            const SizedBox(height: 8),
            _buildServicesCard(context),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
    );
  }

  Widget _buildShopDetailsCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Address', _client['address'] ?? '-'),
          _divider(),
          _infoRow('Pin Location', _client['pinLocation'] ?? '-'),
          _divider(),
          _linkInfoRow(context, 'Google Maps', _client['googleMaps'] ?? ''),
          _divider(),
          _infoRow('Branch Type', _client['branchType'] ?? '-'),
          _divider(),
          _infoRow('Contact Person', _client['contactPerson'] ?? '-'),
          _divider(),
          _infoRow('Contact Person\nEmail', _client['contactEmail'] ?? '-'),
          _divider(),
          _infoRow('Contact No.', _client['contactNo'] ?? '-'),
          _divider(),
          _infoRow('Viber No.', _client['viberNo'] ?? '-'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => EditShopScreen(client: _client)),
                    );
                    if (updated == true && mounted) {
                      _load();
                    }
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text('Edit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Shop'),
                        content: const Text('Are you sure you want to delete this shop? This action cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white, elevation: 0),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await _deleteShop();
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                  label: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _buildSearchField('Search products', _productSearchController, _onProductSearchChanged)),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final added = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => AddButtonsScreen(mode: AddMode.product, contextData: _client)),
                    );
                    if (added == true && mounted) {
                      _load();
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Product', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildTableHeader(const ['Model Name', 'Purchase Order', 'Actions']),
          if (_filteredProducts.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No products found'),
            )
          else
            ..._filteredProducts.map((p) => _buildProductRow(context, p)),
          _buildPaginationFooter(_filteredProducts.length),
        ],
      ),
    );
  }

  Widget _buildServicesCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _buildSearchField('Search services', _serviceSearchController, _onServiceSearchChanged)),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final added = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => AddButtonsScreen(mode: AddMode.service, contextData: _client)),
                    );
                    if (added == true && mounted) {
                      _load();
                    }
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Service', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildTableHeader(const ['Service Order\nReport No.', 'Service Type', 'Actions']),
          if (_filteredServices.isEmpty)
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text('No services found'),
            )
          else
            ..._filteredServices.map((s) => _buildServiceRow(context, s)),
          _buildPaginationFooter(_filteredServices.length),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, color: Colors.black87)),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[200]);

  static Future<void> _openUrl(String rawUrl) async {
    if (rawUrl.isEmpty) {
      return;
    }
    final uri = Uri.tryParse(rawUrl);
    if (uri == null || !uri.scheme.startsWith('http')) {
      return;
    }
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _linkInfoRow(BuildContext context, String label, String value) {
    final hasLink = value.isNotEmpty && value.startsWith('http');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(
            child: GestureDetector(
              onTap: hasLink ? () => _openUrl(value) : null,
              child: Text(
                value.isEmpty ? '-' : value,
                style: TextStyle(
                  fontSize: 13,
                  color: hasLink ? const Color(0xFF2563EB) : Colors.black87,
                  decoration: hasLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(String hint, TextEditingController controller, ValueChanged<String> onChanged) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
        prefixIcon: Icon(Icons.search, size: 18, color: Colors.grey[400]),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildTableHeader(List<String> headers) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
      child: Row(
        children: [
          for (var i = 0; i < headers.length; i++)
            SizedBox(
              width: i == headers.length - 1 ? 84 : null,
              child: i == headers.length - 1
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                      child: Text(headers[i], textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    )
                  : Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                        child: Text(headers[i], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                      ),
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, Map<String, String> product) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(product['modelName'] ?? '-', style: const TextStyle(fontSize: 14)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(product['purchaseOrder'] ?? '-', style: const TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(
            width: 84,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF2563EB)),
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(builder: (_) => ProductDetailsEntitiesScreen(product: product)),
                    );
                    if (updated == true && mounted) {
                      _load();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Product'),
                        content: const Text('Are you sure you want to delete this product?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await _deleteProduct(product);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, Map<String, String> service) {
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(service['reportNo'] ?? '-', style: const TextStyle(fontSize: 14)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              child: Text(service['serviceType'] ?? '-', style: const TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(
            width: 84,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.visibility_outlined, size: 18, color: Color(0xFF2563EB)),
                  onPressed: () async {
                    final updated = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServicesEntitiesScreen(
                          service: service,
                          shopName: _client['shop'] ?? '-',
                        ),
                      ),
                    );
                    if (updated == true && mounted) {
                      _load();
                    }
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Service'),
                        content: const Text('Are you sure you want to delete this service?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444), foregroundColor: Colors.white),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      await _deleteService(service);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationFooter(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        count == 0 ? 'Showing 0 of 0 entries' : 'Showing 1 to $count of $count entries',
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }
}
