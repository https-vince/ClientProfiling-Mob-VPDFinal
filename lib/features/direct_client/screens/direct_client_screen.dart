import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/analytics_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../preloader/widgets/washing_loader.dart';
import '../providers/direct_client_provider.dart';
import 'clientshop_details_screen.dart';
import 'screens/add_client/add_buttons_screen.dart';

class DirectClientScreen extends ConsumerStatefulWidget {
  const DirectClientScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DirectClientScreen> createState() => _DirectClientScreenState();
}

class _DirectClientScreenState extends ConsumerState<DirectClientScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _entriesPerPage = 5;
  int _currentPage = 1;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directClientAsync = ref.watch(directClientDataProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Direct Client',
        showMenuButton: true,
      ),
      drawer: const AppDrawer(currentPage: 'Direct Client'),
      body: directClientAsync.when(
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
                  'Failed to load direct clients.',
                  style: TextStyle(fontSize: 15),
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
        data: (data) {
          final filteredClients = data.clients.where((client) {
            if (_searchQuery.isEmpty) {
              return true;
            }
            final query = _searchQuery.toLowerCase();
            return (client['shop'] ?? '').toLowerCase().contains(query) ||
                (client['name'] ?? '').toLowerCase().contains(query);
          }).toList();

          final startIndex = (_currentPage - 1) * _entriesPerPage;
          final endIndex = (startIndex + _entriesPerPage).clamp(0, filteredClients.length);
          final paginatedClients = startIndex >= filteredClients.length
              ? <Map<String, String>>[]
              : filteredClients.sublist(startIndex, endIndex);
          final totalPages = (filteredClients.length / _entriesPerPage).ceil().clamp(1, 9999);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                      value: data.overallOwner.toString(),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Co-Owner',
                      value: data.overallCoOwner.toString(),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Shops',
                      value: data.overallShops.toString(),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                    AnalyticsCard(
                      title: 'Sold Products',
                      value: data.soldProducts.toString(),
                      backgroundColor: const Color(0xFFB3E5FC),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 90,
                  child: AnalyticsCard(
                    title: 'Successful Service',
                    value: data.successfulService.toString(),
                    backgroundColor: const Color(0xFFB3E5FC),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  builder: (context) => const AddButtonsScreen(
                                    mode: AddMode.client,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Client'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFC300),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: DropdownButton<int>(
                              value: _entriesPerPage,
                              underline: const SizedBox(),
                              items: [5, 10, 25, 50].map((int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text(value.toString()),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() {
                                  _entriesPerPage = value;
                                  _currentPage = 1;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
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
                                hintText: 'Search clients...',
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey[300]!, width: 1),
                          ),
                        ),
                        child: const Row(
                          children: [
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
                          ],
                        ),
                      ),

                      if (paginatedClients.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.people_outline, size: 44, color: Colors.grey[300]),
                                const SizedBox(height: 8),
                                Text(
                                  'No clients found',
                                  style: TextStyle(fontSize: 13, color: Colors.grey[400]),
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
                                    builder: (_) => ClientDetailsScreen(client: client),
                                  ),
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                        child: Text(client['shop'] ?? '-', style: const TextStyle(fontSize: 14)),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                                        child: Text(client['name'] ?? '-', style: const TextStyle(fontSize: 14)),
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
                            'Showing ${filteredClients.isEmpty ? 0 : startIndex + 1} to ${startIndex + paginatedClients.length} of ${filteredClients.length} entries',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          Row(
                            children: [
                              _PaginationButton(
                                icon: Icons.keyboard_double_arrow_left,
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage = 1)
                                    : null,
                              ),
                              _PaginationButton(
                                icon: Icons.chevron_left,
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _currentPage.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              _PaginationButton(
                                icon: Icons.chevron_right,
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                              _PaginationButton(
                                icon: Icons.keyboard_double_arrow_right,
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage = totalPages)
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
    final enabled = onPressed != null;
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? Colors.grey[700] : Colors.grey[400],
        ),
      ),
    );
  }
}
