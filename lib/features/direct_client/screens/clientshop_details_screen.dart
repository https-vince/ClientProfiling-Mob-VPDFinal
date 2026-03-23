import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../login/screens/login_screen.dart';
import '../services/direct_client_service.dart';
import 'clientproduct_detail_screen.dart';
import 'edit_owner_screen.dart';
import 'screens/add_client/add_buttons_screen.dart';

class ClientDetailsScreen extends StatefulWidget {
  const ClientDetailsScreen({super.key, required this.client});

  final Map<String, String> client;

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen> {
  final DirectClientService _service = DirectClientService();
  final TextEditingController _searchController = TextEditingController();

  Map<String, String> _client = const <String, String>{};
  List<Map<String, String>> _shops = const <Map<String, String>>[];
  List<Map<String, String>> _filteredShops = const <Map<String, String>>[];

  bool _isLoading = false;
  String? _errorMessage;
  int _requestEpoch = 0;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _client = widget.client;
    _load();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final requestId = ++_requestEpoch;
    final clientId = (_client['clientId'] ?? '').trim();
    if (clientId.isEmpty) {
      setState(() => _errorMessage = 'Missing client id.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final clientFuture = _service.fetchClientById(clientId);
      final shopsFuture = _service.fetchShopsByClientId(clientId);

      final client = await clientFuture;
      final shops = await shopsFuture;

      if (!mounted || requestId != _requestEpoch) {
        return;
      }

      setState(() {
        _client = {
          ..._client,
          ...client,
        };
        _shops = shops;
      });
      _applySearch();
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
      setState(() => _errorMessage = 'Failed to load client details.');
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

  void _applySearch() {
    final q = _searchController.text.trim().toLowerCase();
    if (q.isEmpty) {
      setState(() => _filteredShops = _shops);
      return;
    }

    final filtered = _shops.where((shop) {
      final name = (shop['shop'] ?? '').toLowerCase();
      final contact = (shop['contactPerson'] ?? '').toLowerCase();
      return name.contains(q) || contact.contains(q);
    }).toList();

    setState(() => _filteredShops = filtered);
  }

  void _onSearchChanged(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _applySearch);
  }

  Future<void> _deleteClient() async {
    final clientId = (_client['clientId'] ?? '').trim();
    if (clientId.isEmpty) {
      return;
    }

    try {
      await _service.deleteClient(clientId);
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
        const SnackBar(content: Text('Failed to delete client.')),
      );
    }
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
              'Client Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            if (_isLoading) const LinearProgressIndicator(),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _infoRow('Name:', [
                    _client['firstName'] ?? '',
                    _client['middleName'] ?? '',
                    _client['lastName'] ?? '',
                  ].where((v) => v.trim().isNotEmpty).join(' ').trim().isEmpty
                      ? (_client['name'] ?? '-')
                      : [
                          _client['firstName'] ?? '',
                          _client['middleName'] ?? '',
                          _client['lastName'] ?? '',
                        ].where((v) => v.trim().isNotEmpty).join(' ')),
                  _divider(),
                  _infoRow('Company Name:', _client['companyName'] ?? '-'),
                  _divider(),
                  _infoRow('Email:', _client['contactEmail'] ?? '-'),
                  _divider(),
                  _infoRow('Phone No.:', _client['contactNo'] ?? '-'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final updated = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(builder: (_) => EditOwnerScreen(client: _client)),
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
                                title: const Text('Delete Client'),
                                content: const Text('Are you sure you want to delete this client? This action cannot be undone.'),
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
                              await _deleteClient();
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
            ),
            const SizedBox(height: 24),
            const Text(
              'Shop Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            decoration: InputDecoration(
                              hintText: 'Search shops...',
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
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final added = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddButtonsScreen(mode: AddMode.shop, contextData: _client),
                              ),
                            );
                            if (added == true && mounted) {
                              _load();
                            }
                          },
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Shop'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFC300),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            elevation: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[300]!, width: 1))),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            child: Text('Shop', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            child: Text('Contact Person', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text('Actions', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_filteredShops.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.store_outlined, size: 44, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text('No shops found', style: TextStyle(fontSize: 13, color: Colors.grey[400])),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._filteredShops.map((shop) => Container(
                          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: Colors.grey[200]!, width: 1))),
                          child: Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  child: Text(shop['shop'] ?? '-', style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  child: Text(shop['contactPerson'] ?? '-', style: const TextStyle(fontSize: 14)),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: Center(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final merged = <String, String>{
                                        ..._client,
                                        ...shop,
                                      };
                                      final updated = await Navigator.push<bool>(
                                        context,
                                        MaterialPageRoute(builder: (_) => ClientDetailScreen(client: merged)),
                                      );
                                      if (updated == true && mounted) {
                                        _load();
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                      side: const BorderSide(color: Color(0xFF2563EB)),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: const [
                                        Icon(Icons.visibility_outlined, size: 13, color: Color(0xFF2563EB)),
                                        SizedBox(width: 3),
                                        Text('View', style: TextStyle(fontSize: 11, color: Color(0xFF2563EB), fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text(
                      _filteredShops.isEmpty
                          ? 'Showing 0 of 0 entries'
                          : 'Showing 1 to ${_filteredShops.length} of ${_filteredShops.length} entries',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87)),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[200]);
}
