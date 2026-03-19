import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/analytics_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../preloader/widgets/washing_loader.dart';
import '../../reseller_detail/screens/reseller_detail_screen.dart';
import '../providers/resellers_provider.dart';
import '../services/resellers_service.dart';
import 'add_reseller/screens/add_reseller_screen.dart';

class ResellersScreen extends ConsumerStatefulWidget {
  const ResellersScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ResellersScreen> createState() => _ResellersScreenState();
}

class _ResellersScreenState extends ConsumerState<ResellersScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resellersListControllerProvider);
    final summaryAsync = ref.watch(resellersSummaryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: CustomAppBar(
        title: 'Resellers',
        showMenuButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'Resellers'),
      body: state.isInitialLoading
          ? const ColoredBox(
              color: Color(0xFFF7F5F5),
              child: Center(child: WashingLoader(scale: 1.2)),
            )
          : _buildContent(context, state, summaryAsync),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ResellersListState state,
    AsyncValue<ResellersSummary> summaryAsync,
  ) {
    final notifier = ref.read(resellersListControllerProvider.notifier);
    final rows = state.items;
    final overallResellers = summaryAsync.asData?.value.overallResellers ?? state.total;
    final soldProducts = summaryAsync.asData?.value.soldProducts ?? 0;

    return Stack(
      children: [
        SingleChildScrollView(
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
                    title: 'Overall Resellers',
                    value: overallResellers.toString(),
                    backgroundColor: const Color(0xFFB3E5FC),
                  ),
                  AnalyticsCard(
                    title: 'Sold Products',
                    value: soldProducts.toString(),
                    backgroundColor: const Color(0xFFB3E5FC),
                  ),
                ],
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
                        Row(
                          children: [
                            const Text(
                              'Resellers List',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(Icons.info_outline, size: 18, color: Colors.blue[600]),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddResellerScreen(),
                              ),
                            );
                            if (result == true) {
                              await notifier.refreshCurrentPage();
                              ref.invalidate(resellersSummaryProvider);
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Reseller'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[300]!),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: DropdownButton<int>(
                                value: state.perPage,
                                underline: const SizedBox(),
                                items: const [5, 10, 20, 50].map((value) {
                                  return DropdownMenuItem<int>(
                                    value: value,
                                    child: Text('$value'),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  if (value == null) {
                                    return;
                                  }
                                  notifier.changePerPage(value);
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'entries per page',
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 16),
                            child: TextField(
                              controller: _searchController,
                              onChanged: notifier.onSearchChanged,
                              decoration: InputDecoration(
                                hintText: 'Search:',
                                hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (state.errorMessage != null && rows.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Color(0xFFB91C1C), size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.errorMessage!,
                                style: const TextStyle(fontSize: 13, color: Color(0xFF7F1D1D)),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                notifier.retry();
                                ref.invalidate(resellersSummaryProvider);
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border(
                          top: BorderSide(color: Colors.grey[300]!),
                          bottom: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Company Name',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Phone Number',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 80,
                            child: Text(
                              'Actions',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (rows.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        child: Center(
                          child: Text(
                            'No resellers found',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ),
                      )
                    else
                      ...rows.map((reseller) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Text(
                                  reseller['companyName'] ?? '-',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  reseller['email'] ?? '-',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Expanded(
                                flex: 2,
                                child: Text(
                                  reseller['phoneNumber'] ?? '-',
                                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                                ),
                              ),
                              SizedBox(
                                width: 80,
                                child: OutlinedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ResellerDetailScreen(
                                          reseller: reseller,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      await notifier.refreshCurrentPage();
                                      ref.invalidate(resellersSummaryProvider);
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    side: const BorderSide(color: Color(0xFF2563EB)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 14,
                                        color: Color(0xFF2563EB),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'View',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF2563EB),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Showing ${rows.isEmpty ? 0 : ((state.currentPage - 1) * state.perPage) + 1} '
                          'to ${((state.currentPage - 1) * state.perPage) + rows.length} '
                          'of ${state.total} ${state.total == 1 ? 'entry' : 'entries'}',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: state.currentPage > 1
                                  ? () => notifier.goToPage(1)
                                  : null,
                              icon: const Icon(Icons.first_page),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: state.currentPage > 1
                                  ? () => notifier.goToPage(state.currentPage - 1)
                                  : null,
                              icon: const Icon(Icons.chevron_left),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2563EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                state.currentPage.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: state.currentPage < state.lastPage
                                  ? () => notifier.goToPage(state.currentPage + 1)
                                  : null,
                              icon: const Icon(Icons.chevron_right),
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.isRefreshing || state.isLoadingMore)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black12,
                child: const Center(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
