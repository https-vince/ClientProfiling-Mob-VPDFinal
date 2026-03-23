import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/network/api_exception.dart';
import '../../../shared/widgets/analytics_card.dart';
import '../../../shared/widgets/animated_fade_slide.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../services/direct_client_service.dart';
import 'screens/add_client/add_buttons_screen.dart';
import 'clientshop_details_screen.dart';

class DirectClientScreen extends StatefulWidget {
  const DirectClientScreen({Key? key}) : super(key: key);

  @override
  State<DirectClientScreen> createState() => _DirectClientScreenState();
}

class _DirectClientScreenState extends State<DirectClientScreen> {
  final DirectClientService _service = DirectClientService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, String>> _clients = const <Map<String, String>>[];
  bool _isLoading = false;
  String? _errorMessage;
  int _currentPage = 1;
  int _lastPage = 1;
  int _perPage = 10;
  int _total = 0;
  int _overallOwner = 0;
  int _overallCoOwner = 0;
  int _overallShops = 0;
  int _soldProducts = 0;
  int _successfulService = 0;
  int _requestEpoch = 0;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadClients() async {
    final requestId = ++_requestEpoch;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final resultFuture = _service.fetchClientsPage(
        page: _currentPage,
        perPage: _perPage,
        q: _searchController.text,
      );
      final summaryFuture = _service.fetchData();

      final result = await resultFuture;
      final summary = await summaryFuture;

      if (!mounted || requestId != _requestEpoch) {
        return;
      }

      final rows = (result['data'] as List?)
              ?.whereType<Map<String, String>>()
              .toList() ??
          const <Map<String, String>>[];

      setState(() {
        _clients = rows;
        _currentPage = result['current_page'] as int? ?? _currentPage;
        _perPage = result['per_page'] as int? ?? _perPage;
        _total = result['total'] as int? ?? 0;
        _lastPage = result['last_page'] as int? ?? 1;
        _overallOwner = summary.overallOwner;
        _overallCoOwner = summary.overallCoOwner;
        _overallShops = summary.overallShops;
        _soldProducts = summary.soldProducts;
        _successfulService = summary.successfulService;
      });
    } on ApiException catch (e) {
      if (!mounted || requestId != _requestEpoch) {
        return;
      }
      setState(() => _errorMessage = e.message);
    } catch (_) {
      if (!mounted || requestId != _requestEpoch) {
        return;
      }
      setState(() => _errorMessage = 'Failed to load clients.');
    } finally {
      if (mounted && requestId == _requestEpoch) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (!mounted) {
        return;
      }
      setState(() => _currentPage = 1);
      _loadClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Direct Client',
        showMenuButton: true,
      ),
      drawer: const AppDrawer(currentPage: 'Direct Client'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Analytics Cards — fade + slide in
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
            // Analytics Cards Grid
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.5,
              children: [
                AnalyticsCard(
                  title: 'Owner',
                  value: _overallOwner.toString(),
                  backgroundColor: const Color(0xFFB3E5FC),
                ),
                AnalyticsCard(
                  title: 'Co-Owner',
                  value: _overallCoOwner.toString(),
                  backgroundColor: const Color(0xFFB3E5FC),
                ),
                AnalyticsCard(
                  title: 'Shops',
                  value: _overallShops.toString(),
                  backgroundColor: const Color(0xFFB3E5FC),
                ),
                AnalyticsCard(
                  title: 'Sold Products',
                  value: _soldProducts.toString(),
                  backgroundColor: const Color(0xFFB3E5FC),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Successful Service Card (single, full-width)
            SizedBox(
              width: double.infinity,
              height: 90,
              child: AnalyticsCard(
                title: 'Successful Service',
                value: _successfulService.toString(),
                backgroundColor: const Color(0xFFB3E5FC),
              ),
            ),
            const SizedBox(height: 24),
                ],
              ),
            ),

            // Client List Section — fades in with delay
            AnimatedFadeSlide(
              delay: const Duration(milliseconds: 200),
              child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with title and Add Client button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Client List',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () async {
                          final created = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddButtonsScreen(
                                mode: AddMode.client,
                              ),
                            ),
                          );

                          if (created == true && mounted) {
                            _loadClients();
                          }
                        },
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('Add Client'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC300),
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (_isLoading) const LinearProgressIndicator(),
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),

                  // Filter + Search row
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Filter is not available yet.'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.filter_list, size: 18),
                        label: const Text('Filter'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.black87,
                          side: BorderSide(color: Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Search clients...',
                            hintStyle: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[400],
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              size: 18,
                              color: Colors.grey[400],
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
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
                              borderSide: const BorderSide(
                                  color: Color(0xFF2563EB), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Table header
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                      ),
                    ),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(
                              'Shop',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(
                              'Name',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            child: Text(
                              'Actions',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Data rows
                  if (_clients.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.people_outline,
                                size: 44, color: Colors.grey[300]),
                            const SizedBox(height: 8),
                            Text(
                              'No clients yet',
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[400]),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap "Add Client" to get started',
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._clients.map((client) => Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              child: Text(
                                client['shop']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 8),
                              child: Text(
                                client['name']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Center(
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ClientDetailsScreen(client: client),
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 6),
                                  side: const BorderSide(
                                      color: Color(0xFF2563EB)),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.visibility_outlined,
                                        size: 13, color: Color(0xFF2563EB)),
                                    SizedBox(width: 3),
                                    Text('View',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Color(0xFF2563EB),
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _total == 0
                            ? 'Showing 0 of 0 entries'
                            : 'Showing ${((_currentPage - 1) * _perPage) + 1} to ${((_currentPage - 1) * _perPage) + _clients.length} of $_total entries',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      Row(
                        children: [
                          _PaginationButton(
                            icon: Icons.keyboard_double_arrow_left,
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() => _currentPage = 1);
                                    _loadClients();
                                  }
                                : () {},
                          ),
                          _PaginationButton(
                            icon: Icons.chevron_left,
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() => _currentPage -= 1);
                                    _loadClients();
                                  }
                                : () {},
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$_currentPage',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          _PaginationButton(
                            icon: Icons.chevron_right,
                            onPressed: _currentPage < _lastPage
                                ? () {
                                    setState(() => _currentPage += 1);
                                    _loadClients();
                                  }
                                : () {},
                          ),
                          _PaginationButton(
                            icon: Icons.keyboard_double_arrow_right,
                            onPressed: _currentPage < _lastPage
                                ? () {
                                    setState(() => _currentPage = _lastPage);
                                    _loadClients();
                                  }
                                : () {},
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _PaginationButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
