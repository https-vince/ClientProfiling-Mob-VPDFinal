import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/reseller_detail_data.dart';
import '../services/reseller_detail_service.dart';

final resellerDetailServiceProvider = Provider<ResellerDetailService>((ref) {
  return ResellerDetailService();
});

final resellerDetailProvider = FutureProvider.autoDispose
    .family<ResellerDetailData, Map<String, String>>((ref, reseller) async {
  return ref.watch(resellerDetailServiceProvider).fetchDetail(reseller);
});
