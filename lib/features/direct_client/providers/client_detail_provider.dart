import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/client_detail_data.dart';
import '../services/client_detail_service.dart';

final clientDetailServiceProvider = Provider<ClientDetailService>((ref) {
  return ClientDetailService();
});

final clientDetailProvider = FutureProvider.autoDispose
    .family<ClientDetailData, Map<String, String>>((ref, client) async {
  return ref.watch(clientDetailServiceProvider).fetchData(client);
});

  

