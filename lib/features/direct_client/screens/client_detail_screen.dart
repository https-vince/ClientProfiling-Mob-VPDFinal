import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/loaders/css_style_preloader.dart';
import '../providers/client_detail_provider.dart';

class ClientDetailScreen extends ConsumerStatefulWidget {
  final Map<String, String> client;

  const ClientDetailScreen({Key? key, required this.client}) : super(key: key);

  @override
  ConsumerState<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends ConsumerState<ClientDetailScreen> {
  int currentProductPage = 1;
  int currentServicePage = 1;

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(clientDetailProvider(widget.client));

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF87CEEB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
        actions: [
          IconButton(
            icon:
                const Icon(Icons.account_circle_outlined, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: detailAsync.when(
        loading: () => const ColoredBox(
          color: Color(0xFFF7F5F5),
          child: Center(child: CssStylePreloader()),
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
        data: (detail) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Shop Details ──────────────────────────────────────────
              _buildSectionHeader('Shop Details'),
              const SizedBox(height: 8),
              _buildShopDetailsCard(detail.shopDetails),

              const SizedBox(height: 20),

              // ── Product Details ───────────────────────────────────────
              _buildSectionHeader('Product Details'),
              const SizedBox(height: 8),
              _buildProductsCard(detail.products),

              const SizedBox(height: 20),

              // ── Services ─────────────────────────────────────────────
              _buildSectionHeader('Services'),
              const SizedBox(height: 8),
              _buildServicesCard(detail.services),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header text ─────────────────────────────────────────────────
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

  // ── Shop details card ───────────────────────────────────────────────────
  Widget _buildShopDetailsCard(Map<String, String> detail) {
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
          _infoRow('Address', detail['address'] ?? '-'),
          _divider(),
          _infoRow('Pin Location', detail['pinLocation'] ?? '-'),
          _divider(),
          _infoRow('Google Maps', detail['googleMaps'] ?? '-'),
          _divider(),
          _infoRow('Branch Type', detail['branchType'] ?? '-'),
          _divider(),
          _infoRow('Contact Person', detail['contactPerson'] ?? '-'),
          _divider(),
          _infoRow('Contact Person\nEmail', detail['contactEmail'] ?? '-'),
          _divider(),
          _infoRow('Contact No.', detail['contactNo'] ?? '-'),
          _divider(),
          _infoRow('Viber No.', detail['viberNo'] ?? '-'),
          const SizedBox(height: 16),

          // Edit and Delete action buttons
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  // TODO: implement edit
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  elevation: 0,
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // TODO: implement delete
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  elevation: 0,
                ),
                child: const Icon(Icons.delete, color: Colors.white, size: 18),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Product details card ────────────────────────────────────────────────
  Widget _buildProductsCard(List<Map<String, String>> products) {
    final productsPerPage = 5;
    final totalPages = (products.length / productsPerPage).ceil();
    final startIndex = (currentProductPage - 1) * productsPerPage;
    final endIndex = (startIndex + productsPerPage).clamp(0, products.length);
    final paginatedProducts = startIndex >= products.length 
        ? [] 
        : products.sublist(startIndex, endIndex);

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
          // Search + Add Product row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchField('Search'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: implement add product
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Add Product',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Table header
          _buildTableHeader(const ['Model Name', 'Purchase Order']),

          // Data rows (paginated)
          ...paginatedProducts.map(
            (p) => _buildTableRow([p['modelName']!, p['purchaseOrder']!]),
          ),

          // Pagination controls
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $currentProductPage of $totalPages',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentProductPage > 1
                            ? () => setState(() => currentProductPage--)
                            : null,
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: currentProductPage < totalPages
                            ? () => setState(() => currentProductPage++)
                            : null,
                        label: const Text('Next'),
                        icon: const Icon(Icons.chevron_right, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Services card ───────────────────────────────────────────────────────
  Widget _buildServicesCard(List<Map<String, String>> services) {
    final servicesPerPage = 5;
    final totalPages = (services.length / servicesPerPage).ceil();
    final startIndex = (currentServicePage - 1) * servicesPerPage;
    final endIndex = (startIndex + servicesPerPage).clamp(0, services.length);
    final paginatedServices = startIndex >= services.length
        ? []
        : services.sublist(startIndex, endIndex);

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
          // Search + Add Service row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: _buildSearchField('Search'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: implement add service
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text(
                    'Add Service',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFA500),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    elevation: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Table header
          _buildTableHeader(
              const ['Service Order\nReport No.', 'Service Type']),

          // Data rows (paginated)
          ...paginatedServices.map(
            (s) => _buildTableRow([s['reportNo']!, s['serviceType']!]),
          ),

          // Pagination controls
          if (totalPages > 1)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Page $currentServicePage of $totalPages',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: currentServicePage > 1
                            ? () => setState(() => currentServicePage--)
                            : null,
                        icon: const Icon(Icons.chevron_left, size: 18),
                        label: const Text('Previous'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: currentServicePage < totalPages
                            ? () => setState(() => currentServicePage++)
                            : null,
                        label: const Text('Next'),
                        icon: const Icon(Icons.chevron_right, size: 18),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: Colors.grey[300],
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.grey[600],
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Reusable helpers ────────────────────────────────────────────────────

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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _buildTableHeader(List<String> columns) {
    return Container(
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: columns.map((col) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              child: Text(
                col,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTableRow(List<String> cells) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[100]!),
        ),
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

  Widget _buildPaginationFooter(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing 1 to $count of $count entries',
            style: TextStyle(fontSize: 11, color: Colors.grey[600]),
          ),
          Row(
            children: [
              const _PaginationBtn(icon: Icons.keyboard_double_arrow_left),
              const _PaginationBtn(icon: Icons.chevron_left),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '1',
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const _PaginationBtn(icon: Icons.chevron_right),
              const _PaginationBtn(icon: Icons.keyboard_double_arrow_right),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Small pagination icon button ─────────────────────────────────────────────
class _PaginationBtn extends StatelessWidget {
  final IconData icon;

  const _PaginationBtn({Key? key, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 16, color: Colors.grey[600]),
      ),
    );
  }
}
