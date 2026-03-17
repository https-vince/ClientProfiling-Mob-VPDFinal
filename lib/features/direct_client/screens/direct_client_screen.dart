import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/analytics_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/loaders/css_style_preloader.dart';
import '../../add_client/screens/add_client_screen.dart';
import '../providers/direct_client_provider.dart';
import 'client_detail_screen.dart';

class DirectClientScreen extends ConsumerStatefulWidget {
  const DirectClientScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DirectClientScreen> createState() => _DirectClientScreenState();
}

class _DirectClientScreenState extends ConsumerState<DirectClientScreen> {
  static const int _rowsPerPage = 5;
  int _currentPage = 1;

  int _totalPagesFor(List<Map<String, String>> clients) {
    if (clients.isEmpty) {
      return 1;
    }
    return (clients.length + _rowsPerPage - 1) ~/ _rowsPerPage;
  }

  List<Map<String, String>> _paginatedClients(
      List<Map<String, String>> clients) {
    if (clients.isEmpty) {
      return const <Map<String, String>>[];
    }

    final start = (_currentPage - 1) * _rowsPerPage;
    final end = (start + _rowsPerPage).clamp(0, clients.length);
    if (start >= clients.length || start < 0) {
      return const <Map<String, String>>[];
    }

    return clients.sublist(start, end);
  }

  void _goFirstPage() {
    if (_currentPage == 1) return;
    setState(() {
      _currentPage = 1;
    });
  }

  void _goPreviousPage() {
    if (_currentPage <= 1) return;
    setState(() {
      _currentPage -= 1;
    });
  }

  void _goNextPage(int totalPages) {
    if (_currentPage >= totalPages) return;
    setState(() {
      _currentPage += 1;
    });
  }

  void _goLastPage(int totalPages) {
    if (_currentPage == totalPages) return;
    setState(() {
      _currentPage = totalPages;
    });
  }

  String _formatNumber(int value) {
    final raw = value.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < raw.length; i++) {
      final reverseIndex = raw.length - i;
      buffer.write(raw[i]);
      if (reverseIndex > 1 && reverseIndex % 3 == 1) {
        buffer.write(',');
      }
    }

    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    final directClientAsync = ref.watch(directClientDataProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          'Direct Client',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const AppDrawer(currentPage: 'Direct Client'),
      body: directClientAsync.when(
        loading: () => const ColoredBox(
          color: Color(0xFFF7F5F5),
          child: Center(
            child: CssStylePreloader(),
          ),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Failed to load direct client data.',
                  style: TextStyle(color: Colors.white, fontSize: 15),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(directClientDataProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (directClientData) {
          final clients = directClientData.clients;
          final totalPages = _totalPagesFor(clients);

          if (_currentPage > totalPages) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() {
                _currentPage = totalPages;
              });
            });
          }

          final paginatedClients = _paginatedClients(clients);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
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
                      title: 'Overall Owner',
                      value: _formatNumber(directClientData.overallOwner),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Overall Co-Owner',
                      value: _formatNumber(directClientData.overallCoOwner),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Overall Shops',
                      value: _formatNumber(directClientData.overallShops),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Sold Products',
                      value: _formatNumber(directClientData.soldProducts),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Successful Service Card (single)
                SizedBox(
                  height: 90,
                  child: AnalyticsCard(
                    title: 'Successful Service',
                    value: _formatNumber(directClientData.successfulService),
                    backgroundColor: const Color(0xFFB3E5FC),
                  ),
                ),
                const SizedBox(height: 24),

                // Client List Section
                Container(
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
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const AddClientScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Client'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              foregroundColor: Colors.white,
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

                      // Filter + Search row
                      Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement filter functionality
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
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide:
                                      BorderSide(color: Colors.grey[300]!),
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
                            bottom:
                                BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Text(
                                  'Shop',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 8),
                                child: Text(
                                  'Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Data rows
                      if (clients.isEmpty)
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
                        ...paginatedClients.map((client) => InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ClientDetailScreen(client: client),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.grey[200]!, width: 1),
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
                                  ],
                                ),
                              ),
                            )),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Showing ${clients.isEmpty ? 0 : ((_currentPage - 1) * _rowsPerPage + 1)} to ${clients.isEmpty ? 0 : ((_currentPage - 1) * _rowsPerPage + paginatedClients.length)} of ${clients.length} entries',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          Row(
                            children: [
                              _PaginationButton(
                                icon: Icons.keyboard_double_arrow_left,
                                onPressed:
                                    _currentPage > 1 ? _goFirstPage : null,
                              ),
                              _PaginationButton(
                                icon: Icons.chevron_left,
                                onPressed:
                                    _currentPage > 1 ? _goPreviousPage : null,
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
                                onPressed: _currentPage < totalPages
                                    ? () => _goNextPage(totalPages)
                                    : null,
                              ),
                              _PaginationButton(
                                icon: Icons.keyboard_double_arrow_right,
                                onPressed: _currentPage < totalPages
                                    ? () => _goLastPage(totalPages)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;

  const _PaginationButton({
    Key? key,
    required this.icon,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: isEnabled ? Colors.grey[700] : Colors.grey[400],
        ),
      ),
    );
  }
}
