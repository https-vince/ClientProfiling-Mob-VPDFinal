import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_summary.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  return ref.watch(dashboardServiceProvider).fetchSummary();
});

final dashboardMonthlyProvider = FutureProvider<List<int>>((ref) async {
  return ref.watch(dashboardServiceProvider).fetchSoldProductMonthly(
        year: 2026,
        months: 4,
      );
});
