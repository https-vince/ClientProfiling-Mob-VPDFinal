import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/custom_app_bar.dart';
import '../../preloader/widgets/washing_loader.dart';
import '../providers/client_detail_provider.dart';
import 'edit_shop_screen.dart';
import 'productdetailsentities_screen.dart';
import 'services_entities_screen.dart';
import 'screens/add_client/add_buttons_screen.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final Map<String, String> client;

  const ClientDetailScreen({Key? key, required this.client}) : super(key: key);

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  int _currentProductPage = 1;
  int _currentServicePage = 1;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(clientDetailProvider(widget.client));

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
                  'Failed to load client details.',
                  style: TextStyle(fontSize: 15),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => ref.invalidate(clientDetailProvider(widget.client)),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (detail) {
          final productsPerPage = 5;
          final servicesPerPage = 5;

          final productsTotalPages =
              (detail.products.length / productsPerPage).ceil().clamp(1, 9999);
          final servicesTotalPages =
              (detail.services.length / servicesPerPage).ceil().clamp(1, 9999);

          final productStart = (_currentProductPage - 1) * productsPerPage;
          final productEnd = (productStart + productsPerPage).clamp(0, detail.products.length);
          final paginatedProducts = productStart >= detail.products.length
              ? <Map<String, String>>[]
              : detail.products.sublist(productStart, productEnd);

          final serviceStart = (_currentServicePage - 1) * servicesPerPage;
          final serviceEnd = (serviceStart + servicesPerPage).clamp(0, detail.services.length);
          final paginatedServices = serviceStart >= detail.services.length
              ? <Map<String, String>>[]
              : detail.services.sublist(serviceStart, serviceEnd);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('Shop Details'),
                const SizedBox(height: 8),
                _buildShopDetailsCard(context, detail.shopDetails),

                const SizedBox(height: 20),

                _buildSectionHeader('Product Details'),
                const SizedBox(height: 8),
                _buildProductsCard(
                  context,
                  paginatedProducts,
                  detail.products.length,
                  _currentProductPage,
                  productsTotalPages,
                  onPrev: _currentProductPage > 1
                      ? () => setState(() => _currentProductPage--)
                      : null,
                  onNext: _currentProductPage < productsTotalPages
                      ? () => setState(() => _currentProductPage++)
                      : null,
                ),

                const SizedBox(height: 20),

                _buildSectionHeader('Services'),
                const SizedBox(height: 8),
                _buildServicesCard(
                  context,
                  paginatedServices,
                  detail.services.length,
                  _currentServicePage,
                  servicesTotalPages,
                  onPrev: _currentServicePage > 1
                      ? () => setState(() => _currentServicePage--)
                      : null,
                  onNext: _currentServicePage < servicesTotalPages
                      ? () => setState(() => _currentServicePage++)
                      : null,
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildShopDetailsCard(BuildContext context, Map<String, String> client) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow('Address', client['address'] ?? '-'),
          _divider(),
          _infoRow('Pin Location', client['pinLocation'] ?? '-'),
          _divider(),
          _infoRow('Google Maps', client['googleMaps'] ?? '-'),
          _divider(),
          _infoRow('Branch Type', client['branchType'] ?? '-'),
          _divider(),
          _infoRow('Contact Person', client['contactPerson'] ?? '-'),
          _divider(),
          _infoRow('Contact Person\nEmail', client['contactEmail'] ?? '-'),
          _divider(),
          _infoRow('Contact No.', client['contactNo'] ?? '-'),
          _divider(),
          _infoRow('Viber No.', client['viberNo'] ?? '-'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditShopScreen(client: client),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                  label: const Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.delete, color: Colors.white, size: 18),
                  label: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF4444),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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

  Widget _buildProductsCard(
    BuildContext context,
    List<Map<String, String>> products,
    int totalCount,
    int currentPage,
    int totalPages, {
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    return _buildDataCard(
      context,
      addMode: AddMode.product,
      addLabel: 'Add Product',
      headers: const ['Model Name', 'Purchase Order'],
      rows: products
          .map((p) => [p['modelName'] ?? '-', p['purchaseOrder'] ?? '-'])
          .toList(),
      totalCount: totalCount,
      currentPage: currentPage,
      totalPages: totalPages,
      onPrev: onPrev,
      onNext: onNext,
    );
  }

  Widget _buildServicesCard(
    BuildContext context,
    List<Map<String, String>> services,
    int totalCount,
    int currentPage,
    int totalPages, {
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    return _buildDataCard(
      context,
      addMode: AddMode.service,
      addLabel: 'Add Service',
      headers: const ['Service Order\nReport No.', 'Service Type'],
      rows: services
          .map((s) => [s['reportNo'] ?? '-', s['serviceType'] ?? '-'])
          .toList(),
      totalCount: totalCount,
      currentPage: currentPage,
      totalPages: totalPages,
      onPrev: onPrev,
      onNext: onNext,
    );
  }

  Widget _buildDataCard(
    BuildContext context, {
    required AddMode addMode,
    required String addLabel,
    required List<String> headers,
    required List<List<String>> rows,
    required int totalCount,
    required int currentPage,
    required int totalPages,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(child: _buildSearchField('Search')),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddButtonsScreen(mode: addMode),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: Text(
                    addLabel,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
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
          _buildTableHeader(headers),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No data found',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ),
            )
          else
            ...rows.map(_buildTableRow),
          _buildPaginationFooter(
            count: totalCount,
            currentPage: currentPage,
            totalPages: totalPages,
            onPrev: onPrev,
            onNext: onNext,
          ),
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
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: Colors.grey[200]);

  Widget _buildSearchField(String hint) {
    return SizedBox(
      height: 36,
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
            borderSide: const BorderSide(color: Color(0xFF87CEEB), width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildProductRow(BuildContext context, Map<String, String> p) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(p['modelName']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(p['purchaseOrder']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
                      builder: (_) => ProductDetailsEntitiesScreen(product: p),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.visibility_outlined,
                        size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 3),
                    Text('View',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceRow(BuildContext context, Map<String, String> s) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(s['reportNo']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(s['serviceType']!,
                  style: const TextStyle(fontSize: 12, color: Colors.black87)),
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
                      builder: (_) => ServicesEntitiesScreen(
                        service: s,
                        shopName: client['shop'] ?? '3J\'s Laundry',
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.visibility_outlined,
                        size: 14, color: Color(0xFF2563EB)),
                    SizedBox(width: 3),
                    Text('View',
                        style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(horizontal: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          // All columns except the last are Expanded
          ...columns.sublist(0, columns.length - 1).map((col) => Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  child: Text(
                    col,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),
              )),
          // Last column ("Actions") is fixed width to align with View button
          SizedBox(
            width: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                columns.last,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableRow(List<String> cells) {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: cells.map((cell) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              child: Text(
                cell,
                style: const TextStyle(fontSize: 12, color: Colors.black87),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginationFooter({
    required int count,
    required int currentPage,
    required int totalPages,
    VoidCallback? onPrev,
    VoidCallback? onNext,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing ${count == 0 ? 0 : (currentPage - 1) * 5 + 1} to ${(currentPage - 1) * 5 + (count >= 5 ? 5 : count)} of $count entries',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Row(
            children: [
              _PaginationBtn(icon: Icons.chevron_left, onTap: onPrev),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '$currentPage',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _PaginationBtn(icon: Icons.chevron_right, onTap: onNext),
              const SizedBox(width: 6),
              Text(
                '/ $totalPages',
                style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PaginationBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _PaginationBtn({Key? key, required this.icon, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }
}
