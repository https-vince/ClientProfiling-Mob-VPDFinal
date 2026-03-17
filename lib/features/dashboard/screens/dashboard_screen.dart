import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/analytics_card.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../../shared/widgets/loaders/css_style_preloader.dart';
import '../providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String selectedService = 'Select Services to Purchase';

  // ── Profile panel state ──────────────────────────────────────────────────
  bool _profileVisible = false;
  late final AnimationController _profileAnim;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _profileAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    // Panel slides up from the bottom edge
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _profileAnim, curve: Curves.easeOutCubic));
    // Backdrop fades in
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _profileAnim, curve: Curves.easeOut),
    );
  }

  double _soldProductChartMaxY(List<int> soldProductMonthly) {
    var maxValue = 0;
    for (final value in soldProductMonthly) {
      if (value > maxValue) {
        maxValue = value;
      }
    }

    if (maxValue <= 0) {
      return 100;
    }

    final withHeadroom = (maxValue * 1.2).ceil();
    final rounded = ((withHeadroom + 99) ~/ 100) * 100;
    return rounded.toDouble();
  }

  double _soldProductChartInterval(List<int> soldProductMonthly) {
    final maxY = _soldProductChartMaxY(soldProductMonthly);
    final raw = (maxY / 7).ceil();
    final rounded = ((raw + 9) ~/ 10) * 10;
    return rounded.toDouble();
  }

  List<BarChartGroupData> _soldProductBarGroups(List<int> soldProductMonthly) {
    return List<BarChartGroupData>.generate(4, (index) {
      final value = index < soldProductMonthly.length
          ? soldProductMonthly[index].toDouble()
          : 0.0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value,
            color: const Color(0xFF6366F1),
            width: 32,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
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
  void dispose() {
    _profileAnim.dispose();
    super.dispose();
  }

  /// Toggle the profile panel open / closed.
  void _toggleProfile() {
    if (_profileVisible) {
      _profileAnim.reverse().then((_) {
        if (mounted) setState(() => _profileVisible = false);
      });
    } else {
      setState(() => _profileVisible = true);
      _profileAnim.forward();
    }
  }

  /// Close the profile panel (used by backdrop tap & close button).
  void _closeProfile() {
    if (!_profileVisible) return;
    _profileAnim.reverse().then((_) {
      if (mounted) setState(() => _profileVisible = false);
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final monthlyAsync = ref.watch(dashboardMonthlyProvider);

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
          'Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Notification icon
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {},
          ),
          // Profile avatar — tapping opens the slide-up panel
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: _toggleProfile,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white.withOpacity(0.22),
                child: Icon(
                  Icons.person_outline,
                  size: 22,
                  color:
                      _profileVisible ? const Color(0xFF2563EB) : Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      drawer: const AppDrawer(currentPage: 'Dashboard'),
      body: summaryAsync.when(
        loading: () => const ColoredBox(
          color: Color(0xFFF7F5F5),
          child: Center(
            child: CssStylePreloader(),
          ),
        ),
        error: (error, stackTrace) => _buildErrorState(
          message: 'Failed to load dashboard summary.',
          onRetry: () => ref.invalidate(dashboardSummaryProvider),
        ),
        data: (summary) => monthlyAsync.when(
          loading: () => const ColoredBox(
            color: Color(0xFFF7F5F5),
            child: Center(
              child: CssStylePreloader(),
            ),
          ),
          error: (error, stackTrace) => _buildErrorState(
            message: 'Failed to load monthly chart data.',
            onRetry: () => ref.invalidate(dashboardMonthlyProvider),
          ),
          data: (soldProductMonthly) => Stack(
            children: [
              // ── Main scrollable content ────────────────────────────────────
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Back Section
                    const Text(
                      'Welcome Back',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),

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
                          title: 'Overall Client',
                          value: _formatNumber(summary.totalClients),
                          backgroundColor: const Color(0xFFB3E5FC),
                        ),
                        AnalyticsCard(
                          title: 'All Sold Product',
                          value: _formatNumber(summary.totalSoldProducts),
                          backgroundColor: const Color(0xFFB3E5FC),
                        ),
                        AnalyticsCard(
                          title: 'Total Services',
                          value: _formatNumber(summary.totalServices),
                          backgroundColor: const Color(0xFFB3E5FC),
                        ),
                        AnalyticsCard(
                          title: 'All Shops',
                          value: _formatNumber(summary.totalShops),
                          backgroundColor: const Color(0xFFB3E5FC),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Sold Product in 2026 Chart
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sold Product in 2026',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 250,
                            child: BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _soldProductChartMaxY(soldProductMonthly),
                                minY: 0,
                                barTouchData: BarTouchData(enabled: false),
                                titlesData: FlTitlesData(
                                  show: true,
                                  topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: _soldProductChartInterval(
                                        soldProductMonthly,
                                      ),
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          value.toInt().toString(),
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        const months = [
                                          'Jan',
                                          'Feb',
                                          'Mar',
                                          'Apr'
                                        ];
                                        if (value.toInt() >= 0 &&
                                            value.toInt() < months.length) {
                                          return Padding(
                                            padding:
                                                const EdgeInsets.only(top: 8.0),
                                            child: Text(
                                              months[value.toInt()],
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          );
                                        }
                                        return const Text('');
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  horizontalInterval: 100,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey[300],
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    left: BorderSide(color: Colors.grey[300]!),
                                    bottom:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                ),
                                barGroups: _soldProductBarGroups(
                                  soldProductMonthly,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Available Services Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Available Services',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButton<String>(
                              value: selectedService,
                              isExpanded: true,
                              underline: const SizedBox(),
                              items: const [
                                DropdownMenuItem(
                                  value: 'Select Services to Purchase',
                                  child: Text('Select Services to Purchase'),
                                ),
                                DropdownMenuItem(
                                  value: 'Service 1',
                                  child: Text('Service 1'),
                                ),
                                DropdownMenuItem(
                                  value: 'Service 2',
                                  child: Text('Service 2'),
                                ),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedService = value!;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Apply',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date Labels
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Jan 11, 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'August 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          'September 2026',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Second Chart (Comparison Chart)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SizedBox(
                        height: 250,
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: 100,
                            minY: 0,
                            barTouchData: BarTouchData(enabled: false),
                            titlesData: FlTitlesData(
                              show: true,
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 30,
                                  interval: 20,
                                  getTitlesWidget: (value, meta) {
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 20,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[300],
                                  strokeWidth: 1,
                                );
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border(
                                left: BorderSide(color: Colors.grey[300]!),
                                bottom: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            barGroups: List.generate(8, (index) {
                              final heights = [
                                [
                                  65.0,
                                  0.0
                                ], // First pair - tall light blue only
                                [25.0, 50.0], // Second pair
                                [
                                  0.0,
                                  30.0
                                ], // Third pair - short dark blue only
                                [
                                  40.0,
                                  0.0
                                ], // Fourth pair - medium light blue only
                                [
                                  0.0,
                                  35.0
                                ], // Fifth pair - short dark blue only
                                [
                                  55.0,
                                  0.0
                                ], // Sixth pair - tall light blue only
                                [
                                  0.0,
                                  25.0
                                ], // Seventh pair - short dark blue only
                                [
                                  80.0,
                                  0.0
                                ], // Eighth pair - very tall light blue only
                              ];

                              return BarChartGroupData(
                                x: index,
                                barsSpace: 4,
                                barRods: [
                                  if (heights[index][0] > 0)
                                    BarChartRodData(
                                      toY: heights[index][0],
                                      color: const Color(0xFF93C5FD),
                                      width: 12,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(2),
                                        topRight: Radius.circular(2),
                                      ),
                                    ),
                                  if (heights[index][1] > 0)
                                    BarChartRodData(
                                      toY: heights[index][1],
                                      color: const Color(0xFF3B82F6),
                                      width: 12,
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(2),
                                        topRight: Radius.circular(2),
                                      ),
                                    ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── Semi-transparent backdrop ─────────────────────────────────────
              // Tapping anywhere on the backdrop dismisses the profile panel
              if (_profileVisible)
                FadeTransition(
                  opacity: _fadeAnim,
                  child: GestureDetector(
                    onTap: _closeProfile,
                    child: Container(color: Colors.black.withOpacity(0.35)),
                  ),
                ),

              // ── Sliding profile card ──────────────────────────────────────────
              // Anchored to the bottom; SlideTransition carries it up smoothly
              if (_profileVisible)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: _buildProfilePanel(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile panel widget ─────────────────────────────────────────────────
  // Returns the floating card shown when the profile avatar is tapped
  Widget _buildProfilePanel() {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 2,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag-handle pill at the top (visual affordance)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // ── Close button ──────────────────────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20, color: Colors.grey),
                onPressed: _closeProfile,
              ),
            ),
            // ── Profile avatar ────────────────────────────────────────
            const CircleAvatar(
              radius: 44,
              backgroundColor: Color(0xFFE8F5E9),
              child: Icon(Icons.person, size: 52, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            // ── Full name ─────────────────────────────────────────────
            const Text(
              'Alvince Maryosep',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            // ── Email subtitle ────────────────────────────────────────
            const Text(
              'maryosepkaalvince@gmail.com',
              style: TextStyle(fontSize: 13, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            // ── Info rows ─────────────────────────────────────────────
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _ProfileInfoRow(label: 'Username', value: 'dev'),
                  _ProfileInfoRow(label: 'Address', value: 'DEv'),
                  _ProfileInfoRow(label: 'Phone', value: '0962-464-3757'),
                  _ProfileInfoRow(
                      label: 'Email', value: 'maryosepkaalvince@gmail.com'),
                  _ProfileInfoRow(label: 'Role', value: 'Admin'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // ── Action buttons ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Row(
                children: [
                  // Edit profile button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
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
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Logout button
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
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
}

// ── Reusable profile info row ─────────────────────────────────────────────────
// Displays a label/value pair inside the profile panel
class _ProfileInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black54,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
